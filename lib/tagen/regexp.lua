--- Regexp class
--
-- Dependencies: `tagen.class`
-- @module tagen.regexp

local class = require("tagen.class")
local Regexp = class("Regexp")

function Regexp.def:__call(source)
  return Regexp:new(source)
end

function Regexp:initialize(source)
  self.source = source
end

function Regexp:__tostring()
  return ("/%s/"):format(self.source)
end
Regexp:ialias("to_s", "__tostring")
Regexp:ialias("inspect", "__tostring")

return Regexp
