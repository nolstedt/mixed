#!/usr/bin/ruby

require 'bunny'
require 'json'
require 'yaml'

def loginfo(logger, msg)
        puts msg
        logger.info(msg)
end

def logfatal(logger, msg)
        puts msg
        logger.fatal(msg)
end

def logwarn(logger, msg)
        puts msg
        logger.warn(msg)
end

def readTemperature(file, logger)
	value = File.read(file).to_s.strip
	if value.eql?("85") then
		sleep 1
		value = File.read(file).to_s.strip
		loginfo(logger, "Read 85 value. New read gave: #{value}")
	end
	return value;
end

logger = Logger.new("#{File.basename(__FILE__)}.log", 20, 10240000)
config = YAML.load_file('config.yml')

host = config['host']
port = config['port']
vhost = config['vhost']
user = config['user']
password = config['password']
queue = config['queue']

path = config['path']

conn = Bunny.new(host: host, vhost: vhost, user: user, password: password)
conn.start
ch = conn.create_channel
x = ch.direct(queue, :durable => true)

Dir.chdir path
sensors = Dir.glob "28*"
sensors.each do |sensor|
	temperaturefile = File.join(path, sensor, "temperature")
	values = {}
	values["sensor"] = sensor
	values["value"] = readTemperature(temperaturefile, logger)
	values["time"] = Time.now.to_i
	message = JSON.unparse values
	x.publish(message, :routing_key => queue, :persistent => true)
	loginfo(logger, "published #{message}")
end

Dir.chdir path
sensors = Dir.glob "26*"
sensors.each do |sensor|
        file = File.join(path, sensor, "humidity")
        v = {}
        v["sensor"] = sensor
        v["value"] = File.read(file).to_s.strip
        v["time"] = Time.now.to_i
        message = JSON.unparse v
        x.publish(message, :routing_key => queue, :persistent => true)
        loginfo(logger, "published #{message}")
end

conn.close


