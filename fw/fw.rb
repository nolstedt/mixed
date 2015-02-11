require 'filewatcher'
require 'rest-client'
require 'yaml'

config = YAML.load_file('config.yml')
dir = config["dir"]
apikey = config["apikey"]
device = config["device"]

FileWatcher.new(dir).watch do |filename, event|
  if(event == :changed)
    puts "File updated: " + filename
  end
  if(event == :delete)
    puts "File deleted: " + filename
  end
  if(event == :new)
    puts "Added file: " + filename
    url = "https://#{apikey}:@api.pushbullet.com/v2/pushes"
    param = {}
    param["type"] = "note"
    param["title"] = "File appeared"
    param["body"] = filename
    param["device_iden"] = device
    
    puts RestClient.post url, param.to_json, :content_type => "application/json"
  end

end