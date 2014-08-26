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
session.visit "https://www.endomondo.com/login"

puts "Logging in."

session.fill_in 'Email', :with => username
session.fill_in 'Password', :with => password
session.find('.signInButton').click()

if !session.has_css?("a.profileMenuLink") then
	puts "Wrong credentials ?"
	exit
end
puts "Logged in."

session.find('.createWorkoutLink').click()
session.find('.fileImport').click()



files.each do |file| 
	puts file
	begin
		
		session.attach_file 'MainContent_fuTcx', file
		session.click_link_or_button 'MainContent_btnShowActivities'

		
	rescue => e
		puts e.message
		puts e
	end
	puts "#{file} done"
end
puts "complete"
sleep(2)
exit(-1)

