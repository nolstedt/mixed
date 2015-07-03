require 'bunny'
require 'json'
require 'logger'
require 'pg'
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

logger = Logger.new("#{File.basename(__FILE__)}.log", 20, 10240000)

config = YAML.load_file('config.yml')
htmldir = config['htmldir']

#rabbitmq-local
lhost = config['mqhost']
lport = config['mqport']
lvhost = "/"
luser = config['mquser']
lpassword = config['mqpass']
lqueue = config['mqqueue']

db = config['db']
dbhost = config['dbhost']
dbuser = config['dbuser']
dbpass = config['dbpass']

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

lq.subscribe(:manual_ack => true, block: true) do |delivery_info, metadata, payload|

	begin
		data = JSON.parse payload
		sensor = data["sensor"]
		value = data["value"]
		time_epoch = data["time"].to_i
		time_utc = Time.at(time_epoch).utc
		
		File.write( File.join(htmldir, sensor) + '.txt' , payload)
		loginfo(logger, "saved info to file")
		
		values = [sensor, value, time_utc, time_epoch]
		pg = PG::Connection.open(host:dbhost,dbname:db, password:dbpass )
		pg.exec_params("insert into values(id,sensor,value,time_utc,time_epoch) values (nextval('values_seq'),$1,$2,$3,$4)", values)
		pg.close
		loginfo(logger, "added to database: #{payload}")

	rescue => e
 		logfatal(logger, "Could not process payload, retry in 5min, #{e.message}")
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
