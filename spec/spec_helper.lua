package.path = "./lib/?.lua;./lib/?/init.lua;" .. package.path

require "tagen"

pd2 = function(...) print(pretty.write(...)) end
