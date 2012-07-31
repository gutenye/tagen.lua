-- class, mixin = require("tagen.class")
--
-- Dependencies: `tagen.core` `tagen.tablex`
-- global: Object

local tagen = require "tagen.core"
local tablex = require "tagen.tablex"
local METAMETHODS = {"__add", "__call", "__concat", "__div", "__le", "__lt", "__mod", "__mul", "__pow", "__sub", "__tostring", "__unm" }

local function _create_lookup_metamethod(klass, name)
  return function(...)
    local method = nil

    if klass.superclass then
      method = klass.superclass.__instance_methods[name]
    end

    assert( type(method)=="function", tostring(klass) .. " doesn't implement metamethod '" .. name .. "'" )

    return method(...)
  end
end

-- ¤class
local function class(name, superclass)
  superclass = superclass or Object
  local klass = {name = name, superclass = superclass} 
  klass.__class_variables = {}
  klass.__methods = {}
  klass.__mixins = {} -- {<mixin>=true, ..}
  klass.__instance_methods = { -- also __instance_methods_mt
    __index = function(instance, key)
      if key == "def" then  -- for define a object method
        return instance.__object_methods
      elseif key == "var" then
        return instance.__instance_variables
      else
        -- property
        local v = instance.class.__instance_methods["get_"..key]
        if v then return v(instance) end

        -- variable
        v = rawget(instance.__instance_variables, key)
        if v ~= nil then return v end

        -- object method
        v = instance.__object_methods[key]
        if v then return v end

        -- instance method
        v = instance.class.__instance_methods[key]
        if v then return v end

        -- field
        return rawget(instance, "_"..key)
      end
    end,

    __newindex = function(instance, key, value)
      -- property
      local v = instance.class.__instance_methods["set_"..key]
      if v then return v(instance, value) end

      -- variable
      return rawset(instance.__instance_variables, key, value)
    end
  }

  for _,name in ipairs(METAMETHODS) do
    klass.__instance_methods[name] = _create_lookup_metamethod(klass, name)
  end

  local klass_mt = {
    __index = function(klass, key)
      if key == "def" then  -- for define a class method
        return klass.__methods
      elseif key == "var" then
        return klass.__class_variables
      else
        -- property
        v = klass.__methods["get_"..key]
        if v then return v(klass) end

        -- variable
        local v = klass.__class_variables[key]
        if v ~= nil then return v end

        -- method
        v = klass.__methods[key]
        if v ~= nil then return v end

        -- field
        return rawget(klass.__class_variables, "_"..key)
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

  local __variables_mt = {
    __newindex = function(t, key, value)
      -- use outer 'klass'
      -- property
      local v = klass.__methods["set_"..key]
      if v then return v(klass, value) end

      -- variable
      return rawset(t, key, value)
    end
  }

  local __methods_mt = {}

  if superclass then
    -- inherited
    local inherited = superclass.__methods["inherited"]
    if inherited then 
      inherited(superclass, c)
    end

    __methods_mt["__index"] = superclass.__methods
    __variables_mt["__index"] = superclass.__class_variables
    setmetatable(klass.__class_variables, __variables_mt)
    setmetatable(klass.__methods, __methods_mt)
    setmetatable(klass.__instance_methods, {__index = superclass.__instance_methods})
  else
    setmetatable(klass.__class_variables, __variables_mt)
    setmetatable(klass.__methods, __methods_mt)
  end

  return setmetatable(klass, klass_mt)
end

Object = class("Object", nil)

-- ¤instance

-- self is User, not User.def. because User:new() -> User.def:new()
function Object.def:new(...)
  local instance = self:allocate()
  instance:initialize(...)
  return instance
end

function Object.def:allocate()
  local klass = self
  local instance = {class=klass}
  instance.__instance_variables = {}
  instance.__object_methods = {}

  return setmetatable(instance, klass.__instance_methods)
end

function Object.def:super(...)
  local name = debug.getinfo(2, "n").name
  self.superclass.__methods[name](self, ...)
end

function Object:initialize() end

function Object:super(...) 
  local name = debug.getinfo(2, "n").name
  self.class.superclass.__instance_methods[name](self, ...)
end

-- ¤Object

function Object.def:class_variables()
  return self.__class_variables
end

function Object.def:methods()
  return self.__methods
end

function Object.def:instance_methods()
  return self.__instance_methods
end

function Object:instance_variables()
  return self.__instance_variables
end

function Object:object_methods()
  return self.__object_methods
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
  for k, v in pairs(self.__instance_variables) do
    has_ivar = true
    table.insert(ivars, k.."="..tostring(v))
  end
  if has_ivar then
    ret = ret .. ": " .. table.concat(ivars, ", ")
  end

  return ret .. ">"
end

return class
