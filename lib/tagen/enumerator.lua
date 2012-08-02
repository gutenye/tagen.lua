-- Dependencies: `tagen.core` `tagen.class`

local tagen = require("tagen.core")
local class = require("tagen.class")

-- to_enum(method="each")
function Object:to_enum(method)
  return Enumerator:new(self, method)
end

local Enumerator = class("Enumerator")

-- (source, method="each")
function Enumerator:initialize(source, method)
  method = method or "each" 

  self.source = source
  self.meth = source[method]
end

-- with_index(func)
-- with_index(offset, func)
function Enumerator:with_index(...)
  local args = table.pack(...)
  if args.n == 1 then
    offset = 0
    func = args[1]
  else
    offset, func = args
  end

  local idx = offset + 1

  self.meth(self.source, function(v)
    func(v, idx)
    idx = idx + 1
  end)

  return nil
end

function Enumerator:with_object(obj, func)
  self.meth(self.source, function(v)
    func(v, obj)
  end)

  return nil
end

return Enumerator
