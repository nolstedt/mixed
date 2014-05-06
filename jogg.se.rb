require 'capybara'
require 'selenium-webdriver'

def usage
	puts "<username> <password> <file/directory>"
	puts "all .gpx files in the directory will be processed"
	exit
end

if (ARGV.length != 3)
	usage()
end

files = []
if File.directory?(ARGV[2]) then
	Dir.chdir ARGV[2]
	files = Dir["*.gpx"]
	files = files.map {|x| File.join(ARGV[2], x) }
elsif File.file?(ARGV[2]) && File.extname(ARGV[2]).eql?(".gpx") then
	files = [File.absolute_path(ARGV[2])]
else
	usage()
end

username = ARGV[0]
password = ARGV[1]

puts "Files to process: #{files.count}"

session = Capybara::Session.new(:selenium)
Selenium::WebDriver::Firefox::Binary.path='/Applications/nolstedt/Firefox.app/Contents/MacOS/firefox-bin'
session.visit "http://www.jogg.se"

puts "Logging in."

session.fill_in 'loginControl_m_email', :with => username
session.fill_in 'loginControl_m_password', :with => password
session.click_link_or_button 'loginControl_m_submit'

if !session.has_css?("div#loginControl_m_loggedin") then
	puts "Wrong credentials ?"
	exit
end
puts "Logged in."


files.each do |file| 
	puts file
	begin
	session.visit 'http://www.jogg.se/Traning/NyttFilPass.aspx'
	session.attach_file 'MainContent_fuTcx', file
	session.click_link_or_button 'MainContent_btnShowActivities'

	session.within('#activityTable') do 
		session.choose('saveCheckBox')
		session.click_link_or_button 'saveButton'
	end
	session.within('#MainContent_saveData1') do
		session.click_link_or_button 'MainContent_btnSave'
	end
	rescue => e
		puts e.message
		puts e
	end
	puts "#{file} done"
end
puts "complete"
sleep(2)
exit(-1)

