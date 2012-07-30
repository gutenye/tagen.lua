-- class, mixin = require("tagen.class")
--
-- Dependencies: `tagen.core` `tagen.tablex`
-- global: Object

local tagen = require "tagen.core"
local tablex = require "tagen.tablex"

-- ¤class
local function class(name, superclass)
  superclass = superclass or Object
  local c = {name = name, superclass = superclass} 
  c.__mixins = {} -- {<mixin>=true, ..}
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
    ---[[
    __tostring = function(t)
      return t.name
    end,
    --]]
  }

  local __methods_newindex = function(t, key, value)
    -- property
    local v = t["set_"..key]
    if v then return v(t, value) end

    -- variable & method
    return rawset(t, key, value)
  end

  if superclass then
    -- inherited
    local inherited = superclass.__methods["inherited"]
    if inherited then 
      inherited(superclass, c)
    end

    setmetatable(c.__methods, {__index = superclass.__methods, __newindex = __methods_newindex})
    setmetatable(c.__instance_methods, {__index = superclass.__instance_methods})
  else
    setmetatable(c.__methods, {__newindex = __methods_newindex})
  end

  return setmetatable(c, mt)
end

-- ¤Object
Object = class("Object", nil)

-- ¤instance

-- self is User, not User.static. because User:new() -> User.static:new()
function Object.static:new(...)
  local instance = self:allocate()
  instance:initialize(...)
  return instance
end

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

function Object.static:super(...)
  local name = debug.getinfo(2, "n").name
  self.superclass.__methods[name](self, ...)
end

--[[
-- include methods and variables
function Object.static:methods() 
  return tablex.keys(self.__methods)
end

function Object.static:instance_methods() 
  return tablex.keys(self.__instance_methods)
end
--]]

function Object:initialize() end

function Object:super(...) 
  local name = debug.getinfo(2, "n").name
  self.class.superclass.__instance_methods[name](self, ...)
end

function Object:instance_of(klass) 
  return self.class == klass
end

function Object:kind_of(klass)
  local c = self.class

  while c do
    if c == klass then 
      return true 
    elseif c.__mixins[klass] then
      return true
    end

    c = c.superclass
  end

  return false
end

return class
