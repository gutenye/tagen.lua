--- Mixin class
--
-- Dependencies: `tagen.core`, `tagen.class`
-- @module tagen.mixin

local tagen = require("tagen.core")
local class = require("tagen.class")
local assert_arg = tagen.assert_arg

local function mixin(name)
  mixin = class(name, nil, true)

  return mixin
end

local function _include(klass, mixin)
  if mixin:method("included") then
    mixin.included(klass)
  end

  tagen.merge(klass.__methods, mixin.__methods)

  -- skip __index ...
  for k, v in pairs(mixin.__instance_methods) do
    if string.match(k, "^__") then
      -- pass
    else
      klass.__instance_methods[k] = v 
    end
  end

  klass.__mixins[mixin] = true
end

function Object.def:include(...)
  assert_arg(1, self, "class")

  local args = table.pack(...)

  for i=1, args.n do
    _include(self, args[i])
  end
end

return mixin
