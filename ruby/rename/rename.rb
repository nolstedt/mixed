#!/usr/bin/env ruby

def processDirectory(dir, ending) 
	dir_ = Dir.new dir
	dir_.entries.each do |x|
		filename = File.join(dir_.path , x)
		x = x.downcase
		x = x.gsub(" ", ".")
		newfilename = File.join(dir_.path, x)
		if File.file? filename and (filename.end_with? ending or ending.eql? "*") then
			puts "rename file: #{filename} -> #{newfilename}"
			File.rename(filename, newfilename)
		end	
	end

	newdirname = dir.downcase.gsub(" ", ".")
	puts "rename dir: #{dir} -> #{newdirname}"
	File.rename(dir, newdirname)
end

if ARGV.length != 2 then
	puts "wrong number of argumets"
	exit
end

if !Dir.exists? ARGV[0]
then
	puts "no such folder #{ARGV[0]}"
	exit
end

	
processDirectory(ARGV[0], ARGV[1])
puts ""



