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

files.each do |file| 
	puts file
	session.visit "https://www.endomondo.com/workouts/"

	session.has_css?("a[class=createWorkoutLink]")
	session.find('.createWorkoutLink').click()

	session.has_css?(".fileImport")
	session.find('.fileImport').click()

	session.within_frame ( session.find('.iframed') ) do
		session.attach_file 'uploadFile', file
	end
	puts "attached"
	sleep 1

	session.within_frame ( session.find('.iframed') ) do
		puts session.has_css?('a[value=Next]')
		session.find(:css, 'a[value=Next]').click
	end
	sleep 1
	
	session.within_frame ( session.find('.iframed') ) do
		puts session.has_css?('a[value=Save]')
		session.find(:css, 'a[value=Save]').click
	end
	sleep 1
	
	puts "#{file} done"
	#File.delete file
end

puts "complete"
sleep(2)
exit(-1)

