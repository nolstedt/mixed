require 'filewatcher'
require 'rest-client'

load "config.rb"

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