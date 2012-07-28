local tagen = require "tagen.core"

-- ¤class
local function _create_class(name, super)
  local c = {name = name, super = super}
  c.__methods = {}
  c.__instance_methods = {}
  local mt = {
    __index = function(t, key)
      if key == "static" then  -- for define a class method
        return t.__methods
      else
        -- property
        local v = t.__methods["get_"..key]
        if v then return v(t.__methods) end

        -- variable or method
        v = t.__methods[key]
        if v ~= nil then return v end

        -- field
        return t.__methods["_"..key]
      end
    end,

    __newindex = c.__instance_methods,

    -- User
    __tostring = function(t)
      return t.name
    end,
  }

  local methods_newindex = function(t, key, value)
    -- property
    local v = t["set_"..key]
    if v then return v(t, value) end

    -- variable & method
    return rawset(t, key, value)
  end

  if super then
    setmetatable(c.__methods, {__index = super.__methods, __newindex = methods_newindex})
    setmetatable(c.__instance_methods, {__index = super.__instance_methods})
  else
    setmetatable(c.__methods, {
    __newindex = methods_newindex})
  end

  return setmetatable(c, mt)
end

Object = _create_class("Object", nil)

-- ¤instance
-- self is User, not User.static. because User:new() -> User.static:new()
function Object.static:allocate()
  local instance = {class = self}
  local mt = {
    __index = function(t, key)
      local class = t.class
      -- property
      local v = class.__instance_methods["get_"..key]
      if v then return v(t) end

      -- method
      v = class.__instance_methods[key]
      if v then return v end

      -- variable
      v = rawget(t, key)
      if v ~= nil then return v end

      -- field
      return rawget(t, '_'..key)
    end,

    __newindex = function(t, key, value)
      -- property
      local v = self.__instance_methods["set_"..key]
      if v then return v(t, value) end

      -- variable or method
      return rawset(t, key, value)
    end,

    -- #<User: a=1, _b=2>
    __tostring = function(t)
      local ret = "#<" .. t.class.name

      local ivars = {}
      local has_ivar = false
      for k, v in pairs(t) do
        if k == "class" then
          -- pass
        else
          has_ivar = true
          table.insert(ivars, k.."="..tostring(v))
        end
      end
      if has_ivar then
        ret = ret .. ": " .. table.concat(ivars, ", ")
      end

      return ret .. ">"
    end
  }

  return setmetatable(instance, mt)
end

function Object.static:new(...)
  local instance = self:allocate()
  instance:initialize(...)
  return instance
end

function Object.static:include(...)
  for _, m in ipairs(...) do
    for k, v in pairs(m) do
      if k == "static" then
        tagen.merge(self.__methods, v)
      else
        self.__instance_methods[k] = v
      end
    end
  end
end

function Object:initialize() end

function Object:super(...) 
  local name = debug.getinfo(2, "n").name
  self.class.super.__instance_methods[name](self, ...)
end

local class = setmetatable({}, {
  __call = function(func, name, super, ...)
    local super = super or Object
    local c = _create_class(name, super, ...)
    return c
  end
})

return class
