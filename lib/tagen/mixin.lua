-- Dependencies: `tagen.class`

class = require("tagen.class")

-- @example
--   
--   Fooable = mixin("Fooable", {
--     ..
--   })
local function mixin(name, mixin)
  mixin = mixin or {}
  mixin["name"] = name

  local mt = {
    __tostring = function(m)
      return m.name
    end
  }

  return setmetatable(mixin, mt)
end

local function _include(klass, mixin)
  for k, v in pairs(mixin) do
    if k == "name" then 
      -- continue
    elseif k == "static" then
      for k2,v2 in pairs(v) do
        if k2 == "included" then
          v2(klass)
        else
          klass.__methods[k2] = v2
        end
      end
    else
      klass.__instance_methods[k] = v
    end
  end

  klass.__mixins[mixin] = true
end

function Object.static:include(...)
  local args = table.pack(...)

  for i=1, args.n do
    _include(self, args[i])
  end
end


return mixin
