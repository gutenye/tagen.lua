--- Regexp class
--
-- Dependencies: `tagen.core`, `tagen.class`
-- @module tagen.regexp

local tagen = require("tagen.core")
local class = require("tagen.class")
local pd = tagen.pd
local assert_arg = tagen.assert_arg

local Regexp = class("Regexp")


function Regexp.def:__call(source)
  assert_arg(2, source, "string")

  return Regexp:new(source)
end

function Regexp:initialize(source)
  assert_arg(2, source, "string")

  self.source = source
end

function Regexp:__tostring()
  return ("/%s/"):format(self.source)
end
Regexp:ialias("to_s", "__tostring")
Regexp:ialias("inspect", "__tostring")

return Regexp
