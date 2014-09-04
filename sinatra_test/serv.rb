require 'sinatra'
require 'sinatra/json'
require 'oci8'

 # database: '//sportia-scan.teamsportia-int.se:1521/xtest.teamsportia-int.se'
 # username: ralf_dev_owner
#  password: ralf_dev_owner

class Serv < Sinatra::Base
  get '/hi' do
    "Hello World!"
  end

  get '/param' do
    return "param"
  end

  get '/param/:param' do |p|
    return "param with arg #{p}"
  end
  
  get '/json' do
    a = {}
    a["emails"] = []
    a["emails"].push({"primary" => "a@b.com"})
    a["emails"].push({"secondary" => "a@c.com"})
    json a
  end

  def build_json(cursor, accountnum_only)
    ret = {}
    while row = cursor.fetch_hash()
      if (accountnum_only) then
        ret[row["ACCOUNTNUM"]] = row["ACCOUNTNUM"]
      else
        ret[row["ACCOUNTNUM"]] = row
      end
    end
    if (ret.empty?) then
      ret = {"error" => "no store matches query"}
    end
    return ret
  end

  def fetch_data(sql, param: nil, accountnum_only: false)
    conn = get_conn()
    if (param.nil?) then
      cursor = conn.exec(sql)
    else
      cursor = conn.exec(sql, param)
    end
    ret = build_json(cursor, accountnum_only)
    cursor.close
    conn.logoff
    puts ret.count
    return ret
  end

  get '/stores/:store' do |store|
    sql = "select ct.* from AX4LIVE.CUSTTABLE ct where ct.custgroup in ('20','21','25') and ct.dataareaid = 'tsc' and ACCOUNTNUM = :accountnum"
    json fetch_data(sql, param: store)
  end

  get '/stores' do
    sql = "select ct.* from AX4LIVE.CUSTTABLE ct where ct.custgroup in ('20','21','25') and ct.dataareaid = 'tsc'"
    json fetch_data(sql)
  end

  get '/stores_only_names' do
    sql = "select ct.accountnum from AX4LIVE.CUSTTABLE ct where ct.custgroup in ('20','21','25') and ct.dataareaid = 'tsc'"
    json fetch_data(sql, accountnum_only: true)
  end

  get '/suppliers/:supplier' do |supplier|
    sql = "select vt.* from AX4LIVE.VENDTABLE vt where vt.vendgroup = '30' and vt.dataareaid = 'tsc' and ACCOUNTNUM = :accountnum"
    json fetch_data(sql, param: supplier)
  end

  get '/suppliers' do
    sql = "select vt.* from AX4LIVE.VENDTABLE vt where vt.vendgroup = '30' and vt.dataareaid = 'tsc'"
    json fetch_data(sql)
  end

  get '/suppliers_only_names' do
    sql = "select vt.accountnum from AX4LIVE.VENDTABLE vt where vt.vendgroup = '30' and vt.dataareaid = 'tsc'"
    json fetch_data(sql, accountnum_only: true)
  end
end
