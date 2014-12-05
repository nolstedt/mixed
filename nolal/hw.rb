require 'sinatra'
require "sinatra/json"
require 'mysql2'
require 'json'

DEF = %Q{select id, 
gender_c, 
team_id,
team_name 

from nolstedt

where 1=1
}

def get_current
  return "( #{DEF} ) current"
end
def get_current_extra(ggg)
  return "( #{DEF} #{ggg} ) current"
end

def get_element(name) 
  out = {}
  if name.eql?("gender") then
    out["name"] = "gender"
    out["type"] = "pie"
    out["onselect"] = "and id in (select id from nolstedt where gender_c = 'VAL')"


  elsif name.eql?("teams") then
    out["name"] = "teams"
    out["type"] = "list"
    out["onselect"] = "and id in (select id from nolstedt where team_id = 'VAL')"
  end
  return out
end

get '/' do
  File.read('index.html')
end

get '/element' do
  name = params["name"]
  out = get_element(name)
  json out
end

get '/data' do 
  client = Mysql2::Client.new(:host => "localhost", :username => "root", database: "sugarcrm")
  name = params["name"]
  out = get_element(name)

  if out["type"].eql?("list") then
    sel = out["onselect"]
    val = params['VAL'] == nil ? "" : params["VAL"]
  end

  if val.length > 0 then
    sel = sel.gsub('VAL', client.escape(val))
    sql = "select team_id, team_name, count(team_id) team_id_c from #{get_current_extra(sel)} group by team_id"
  else
    sql = "select team_id, team_name, count(team_id) team_id_c from #{get_current} group by team_id"
  end
  
  puts sql 

  results = client.query(sql)
  out = {}
  out["data"] = []
  results.each do |r|
    curr = []
    curr << r["team_id"]
    curr << r["team_name"]
    curr << r["team_id_c"]
    out["data"] << curr
  end
  client.close
  json out

end

get '/teams' do
  
  #apply where part...

end

get '/gender' do
  client = Mysql2::Client.new(:host => "localhost", :username => "root", database: "sugarcrm")
  sel = params['sel'] == nil ? "" : params["sel"]
  val = params['VAL'] == nil ? "" : params["VAL"]

puts sel 
puts val
puts val.class

  #apply where part...
  if sel.length > 0 then
    sel = sel.gsub('VAL', client.escape(val))
    sql_c = "select count(*) as c from #{get_current_extra(sel)}"
    sql = "select gender_c, count(gender_c) gender_c_count from #{get_current_extra(sel)} group by gender_c"
  else
    sql_c = "select count(*) as c from #{get_current}"
    sql = "select gender_c, count(gender_c) gender_c_count from #{get_current} group by gender_c"
  end

  puts sql
  puts sql_c
  
  results_c = client.query(sql_c)

  results = client.query(sql)

  c = results_c.first["c"]
  out = {}
  out["data"] = []
  results.each do |r|
    curr = []
    curr << r["gender_c"]
    curr << r["gender_c_count"]
    curr << (r["gender_c_count"].to_f / c)
    out["data"] << curr
  end
  client.close
  json out
end



