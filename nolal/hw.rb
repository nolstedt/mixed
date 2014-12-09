#TODO
# formatering av selectat värde.
#   flera olika varianter
#    * mapping a->b
# i html spara aktuella värden och dess formatering, bra vid t.ex. line_chart select mellan vilka värden som gäller.
# då får man t.ex. allt mellan 1.56 och 3.45 => cell med index 2 och 3. dess värde skall nästa select bygga på.

# spara enbart en selektering per element, flera val kan göras men enbart en selektering kan vara aktiv.

# flytta ner beskrivning i databasen.

# stöd för fler databaser ? mysql syntax etc måste då abstraheras bort. dsl..jobbigt.


require 'sinatra'
require "sinatra/json"
require 'mysql2'
require 'json'

DEF = %Q{select id, 
  contact_created,
  gender_c, 
  team_id,
  team_name 
from nolstedt
  where 1=1
}

def get_current
  return "( #{DEF} ) current"
end
def get_current_extra(selections)
  ands = ""
  puts selections

  selections.each do |selection|
    #depending on the type !!
    element = get_element(selection["name"])
    onselect = element["onselect"]
    ands = ands + onselect.gsub('REPLACE', selection['value'])
    
  end
  current = "( #{DEF} #{ands} ) current"
  puts current
  return current
end

def get_element(name) 
  out = {}
  if name.eql?("gender") then
    out["name"] = "gender"
    out["type"] = "pie"
    out["select"] = ["gender_c"]
    out["onselect"] = "and id in (select id from nolstedt where gender_c = 'REPLACE')"
  elsif name.eql?("contact_created") then
    out["name"] = "contact_created"
    out["type"] = "line_chart"
    out["select"] = ["date_format(contact_created, '%Y-%m')"]
  elsif name.eql?("teams") then
    out["name"] = "teams"
    out["type"] = "list"
    out["select"] = ["team_id", "team_name", "team_id"]
    out["onselect"] = "and id in (select id from nolstedt where team_id = 'REPLACE')"
  elsif name.eql?("count") then
    out["name"] = "count"
    out["type"] = "current_count"
    out["select"] = "count(*)"
  
 
  end

  return out
end

post '/postit' do
  puts params
end

get '/' do
  File.read('index.html')
end

get '/element' do
  name = params["name"]
  out = get_element(name)
  json out
end

post '/data' do 
  
  request.body.rewind  # in case someone already read it
  body = request.body.read
  data = JSON.parse body

  client = Mysql2::Client.new(:host => "localhost", :username => "root", database: "sugarcrm")
  toupdate_name = data["toupdate"]
  toupdate = get_element(toupdate_name)
  

  if toupdate["type"].eql?("list") then
    if data["selection"].nil? then
      sql = "select #{toupdate["select"][0]}, #{toupdate["select"][1]}, count(#{toupdate["select"][2]}) from #{get_current} group by #{toupdate["select"][2]}" 
    else
      current = get_current_extra(data["selection"])
      sql = "select #{toupdate["select"][0]}, #{toupdate["select"][1]}, count(#{toupdate["select"][2]}) from #{current} group by #{toupdate["select"][2]}"  
    end

    results = client.query(sql)
    out = {}
    out["data"] = []
    results.each(:as => :array) do |row|
      curr = []
      curr << row[0]
      curr << row[1]
      curr << row[2]
      out["data"] << curr
    end

  elsif toupdate["type"].eql?("pie") then
    if data["selection"].nil? then
      sql_c = "select count(*) from #{get_current}"
      sql = "select #{toupdate["select"][0]}, count(#{toupdate["select"][0]}) from #{get_current} group by #{toupdate["select"][0]}" 
    else
      current = get_current_extra(data["selection"])
      sql_c = "select count(*) from #{current}"
      sql = "select #{toupdate["select"][0]}, count(#{toupdate["select"][0]}) from #{current} group by #{toupdate["select"][0]}" 
    end
    
    results_c = client.query(sql_c)
    results = client.query(sql)

    count = 0
    results_c.each(:as => :array) do |row|
      count = row[0]
    end

    out = {}
    out["data"] = []
    results.each(:as => :array) do |row|
      curr = []
      curr << row[0]
      curr << row[1]
      curr << (row[1].to_f / count)
      out["data"] << curr
    end
  
  elsif toupdate["type"].eql?('line_chart') then

    if data["selection"].nil? then
      current = get_current
    else
      current = get_current_extra(data["selection"])
    end
    sql = "select #{toupdate["select"][0]}, count(#{toupdate["select"][0]}) from #{current} group by #{toupdate["select"][0]}" 
  
    results = client.query(sql)

    out = {}
    out["data"] = {}
    out["data"]["x"] = []
    out["data"]["y"] = []    
    results.each(:as => :array) do |row|
      out["data"]["x"] << row[0]
      out["data"]["y"] << row[1]
    end

  elsif toupdate["type"].eql?("current_count") then

    if data["selection"].nil? then
      current = get_current
    else
      current = get_current_extra(data["selection"])
    end
    sql = "select #{toupdate["select"]} from #{current}"
    
    results = client.query(sql)
    count = 0
    results.each(:as => :array) do |row|
      count = row[0]
    end
    out = {}
    out["data"] = {}
    out["data"]["count"] = count
  end
    
  
  client.close
  json out

end



