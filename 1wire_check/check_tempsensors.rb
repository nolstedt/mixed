#!/usr/bin/ruby

sens = {}
sens["28.AB46E8030000"] = "chill"
sens["28.DD63E8030000"] = "bastu"

f = "/mnt/1wire"
Dir.chdir f
t = Dir.glob "28*"

t.each do |x| 
	a=File.join(f, x, "temperature")
	puts "#{a} #{sens[x]}  #{File.read(a)}"
end
