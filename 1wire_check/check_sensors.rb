#!/usr/bin/ruby

f = "/mnt/1wire"
Dir.chdir f
t = Dir.glob "28*"
t.each do |x| 
	a=File.join(f, x, "temperature")
	puts "#{a} #{File.read(a)}"
end

t = Dir.glob "26*"
t.each do |x| 
	a=File.join(f, x, "humidity")
	puts "#{a} #{File.read(a)}"
end
