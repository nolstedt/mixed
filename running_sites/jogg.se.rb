require 'capybara'
require 'selenium-webdriver'
require 'highline/import'

def usage
	puts "<file/directory>"
	puts "all .gpx files in the directory will be processed"
	exit
end

if (ARGV.length != 1)
	usage()
end
directory = ARGV[0]

files = []
if File.directory?(directory) then
	Dir.chdir directory
	files = Dir["*.gpx"]
	files = files.map {|x| File.join(directory, x) }
elsif File.file?(directory) && File.extname(directory).eql?(".gpx") then
	files = [File.absolute_path(directory)]
else
	usage()
end

puts "Files to process: #{files.count}"

username = ask("Enter your username:  ") { |q| q.echo = true }
password = ask("Enter your password:  ") { |q| q.echo = "*" }

Capybara.default_wait_time = 15
session = Capybara::Session.new(:selenium)
Selenium::WebDriver::Firefox::Binary.path='/Applications/Firefox.app/Contents/MacOS/firefox-bin'
session.visit "http://www.jogg.se/Traning/NyttFilPass.aspx"

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
	print file
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

