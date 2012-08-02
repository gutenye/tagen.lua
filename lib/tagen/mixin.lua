-- Dependencies: `tagen.class`

class = require("tagen.class")

local function mixin(name)
  mixin = class(name)
  return mixin
end

local function _include(klass, mixin)
  if mixin:method("included") then
    mixin.included(klass)
  end

  tagen.merge(klass.__methods, mixin.__methods)
  tagen.merge(klass.__instance_methods, mixin.__instance_methods)

  klass.__mixins[mixin] = true
end

function Object.def:include(...)
  local args = table.pack(...)

  for i=1, args.n do
    _include(self, args[i])
  end
end

return mixin
