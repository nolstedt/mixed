#!/usr/bin/ruby

require 'bunny'
require 'json'
require 'logger'
require 'yaml'

def loginfo(logger, msg)
	puts msg
	#logger.info(msg)
end

def logfatal(logger, msg)
	puts msg
	#logger.fatal(msg)
end

def logwarn(logger, msg)
	puts msg
	#logger.warn(msg)
end

logger = nil
#logger = Logger.new("#{File.basename(__FILE__)}.log", 20, 10240000)

config = YAML.load_file('config.yml')

#rabbitmq-local
lhost = config['lhost']
lport = config['lport']
lvhost =config['lvhost']
luser = config['luser']
lpassword = config['lpassword']
lqueue = config['lqueue']

#rabbitmq-beata
fhost = config['fhost']
fport = config['fport']
fvhost = config['fvhost']
fuser = config['fuser']
fpassword = config['fpassword']
fqueue = config['fqueue']

begin
	lconn = Bunny.new(:host => lhost, :port => lport, :vhost => lvhost, :user => luser, :password => lpassword)
	lconn.start
rescue Bunny::PossibleAuthenticationFailureError => e
	logfatal(logger, "Could not authenticate as #{luser}.")
	logfatal(logger, e.message)
	exit
rescue Bunny::ClientTimeout => e
	logfatal(logger, "Failed creating a connection to rabbitmq, #{lhost} #{lvhost}.")
	logfatal(logger, e.message)
	exit
rescue Exception => e
	logfatal(logger, "Failed creating a connection to rabbitmq, #{lhost} #{lvhost}.")
	logfatal(logger, e.message)
	exit
end

loginfo(logger, "Running, queue: #{lqueue}")

lch = lconn.create_channel
lx   = lch.direct(lqueue, :durable => true)
lq   = lch.queue(lqueue, :durable => true)
lq.bind(lx, :routing_key => lqueue)

lq.subscribe(:ack => true, block: true) do |delivery_info, metadata, payload|
	requeue = false
	loginfo(logger, "Process message.")

	begin
		fconn = Bunny.new(host: fhost, vhost: fvhost, user: fuser, password: fpassword)
		fconn.start

		fch = fconn.create_channel
		fx = fch.direct(fqueue, :durable => true)
		fmessage = payload
		fx.publish(fmessage, :routing_key => fqueue, :persistent => true)
		fconn.close
		loginfo(logger, "published: #{fmessage}")
	rescue => e
 		logfatal(logger, "Could not send to master, retry in 5min, #{e.message}")
		requeue = true
		sleep 60*5
	end
	if requeue then
		lch.basic_reject(delivery_info.delivery_tag, true)
	else
		loginfo(logger, "Ack message.")
		lch.ack(delivery_info.delivery_tag)
	end

end

lconn.close
