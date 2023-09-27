file = File.read("./data/chp1.txt")

file.split("\n").each { |sentence| puts sentence }