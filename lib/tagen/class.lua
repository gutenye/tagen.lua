-- class, mixin = require("tagen.class")
--
-- Dependencies: `tagen.core` `tagen.tablex`
-- global: Object

local tagen = require "tagen.core"
local tablex = require "tagen.tablex"
local METAMETHODS = {'__add', '__call', '__concat', '__div', '__le', '__lt', '__mod', '__mul', '__pow', '__sub', '__tostring', '__unm' }

local function _create_lookup_metamethod(klass, name)
  return function(...)
    local method = nil

    if klass.superclass then
      method = klass.superclass.__instance_methods[name]
    end

    assert( type(method)=='function', tostring(klass) .. " doesn't implement metamethod '" .. name .. "'" )

    return method(...)
  end
end

-- ¤class
local function class(name, superclass)
  superclass = superclass or Object
  local klass = {name = name, superclass = superclass} 
  klass.__mixins = {} -- {<mixin>=true, ..}
  klass.__methods = {}

  klass.__instance_methods = {
    __index = function(instance, key)
      local klass = instance.class

      -- property
      local v = klass.__instance_methods["get_"..key]
      if v then return v(instance) end

      -- method
      v = klass.__instance_methods[key]
      if v then return v end

      -- variable
      v = rawget(instance, key)
      if v ~= nil then return v end

      -- field
      return rawget(instance, '_'..key)
    end,

    __newindex = function(instance, key, value)
      local klass = instance.class

      -- property
      local v = klass.__instance_methods["set_"..key]
      if v then return v(instance, value) end

      -- variable or method
      return rawset(instance, key, value)
    end
  }

  for _,name in ipairs(METAMETHODS) do
    klass.__instance_methods[name] = _create_lookup_metamethod(klass, name)
  end

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

    __newindex = klass.__instance_methods,

    -- User
    --[[
    __tostring = function(t)
      return t.name
    end,
    --]]
  }

  local __methods_mt = {
    __newindex = function(t, key, value)
      -- property
      local v = t["set_"..key]
      if v then return v(t, value) end

      -- variable & method
      return rawset(t, key, value)
    end
  }

  if superclass then
    -- inherited
    local inherited = superclass.__methods["inherited"]
    if inherited then 
      inherited(superclass, c)
    end

    __methods_mt["__index"] = superclass.__methods
    setmetatable(klass.__methods, __methods_mt)
    setmetatable(klass.__instance_methods, {__index = superclass.__instance_methods})
  else
    setmetatable(klass.__methods, __methods_mt)
  end

  return setmetatable(klass, mt)
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
  local klass = self
  local instance = {class = klass}

  return setmetatable(instance, klass.__instance_methods)
end

function Object.static:super(...)
  local name = debug.getinfo(2, "n").name
  self.superclass.__methods[name](self, ...)
end

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

-- #<User: a=1, _b=2>
function Object:__tostring()
  local ret = "#<" .. self.class.name

  local ivars = {}
  local has_ivar = false
  for k, v in pairs(self) do
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

return class
