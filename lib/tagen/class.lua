--- class, mixin = require("tagen.class")
--
-- global: Object
--
-- Dependencies: `tagen.core` `tagen.tablex`
-- @module tagen.class

local tagen = require "tagen.core"
local tablex = require "tagen.tablex"
local pd = tagen.pd
local assert_arg = tagen.assert_arg

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

-- dymanic define method 'super', and call superclass's method.
--
-- @usage
--
--     User = class("User")
--     Student = class("Student", User)
--     Child = class("Child", Student)
--
--     define_super(Child, "__methods",  Child) -- define super method for class method
--     define_super2(Child, "__instance_methods", Child) -- define super method for instance method
--
--     function User.def:foo()
--     end
--
--     function Student.def:foo()
--       self:super(Student)
--       -- redefine Child.super      define_super(self, "__methods", User, "foo")
--       -- call User.foo(self)
--     end
--
--     function Child.def:foo()
--       self:super(Child)
--       -- redefine Child.super      define_super(self, "__methods", Student, "foo")
--       -- call Student.foo(self)   
--     end
local function define_super(at, place, klass, name)
  at[place]["super"] = function(self, curclass, ...)
    local superclass = klass.superclass
    local selfclass = self.class or self
    assert_arg(1, self, {"class", "instance"})
    assert_arg(2, curclass, "class")

    -- first time to call super()
    if selfclass == curclass then
      name = debug.getinfo(2, "n").name
      superclass = selfclass.superclass
    end

    meth = superclass[place][name]

    if not meth then
      error(("super: `%s' can't find class method `%s' in superclass `%s'.")
        :format(selfclass.name, name, superclass.name), 2)
    end

    -- redefine Child.super
    define_super(selfclass, place, superclass, name)

    -- call superclass's foo method
    meth(self, ...)
  end
end

-- ¤class

-- define a class
--
-- @usage
--
--  User = class("User")
--  Student = class("Student", User)
--
local function class(name, superclass, is_mixin)
  assert_arg(1, name, "string")

  superclass = superclass or Object
  local klass = {name = name, superclass = superclass}
  if is_mixin then
    klass["__IS_MIXIN"] = true
  else
    klass["__IS_CLASS"] = true
  end
  klass.__class_variables = {}
  klass.__instance_methods = {} -- also __instance_methods_mt
  klass.__methods = {}
  klass.__mixins = {} -- {<mixin>=true, ..}

  -- define some class/instance methods

  define_super(klass, "__methods", klass)
  define_super(klass, "__instance_methods", klass)

  klass.__instance_methods["__index"] = function(instance, key) 
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
  end

  klass.__instance_methods["__newindex"] =  function(instance, key, value)
    -- property
    local v = instance.class.__instance_methods["set_"..key]
    if v then return v(instance, value) end

    -- variable
    return rawset(instance.__instance_variables, key, value)
  end

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

    __call = function(klass, ...)
      local mth = klass.__methods["__call"]
      if mth then
        return mth(klass, ...)
      else
        error("attempt to call global '"..tostring(klass).."' (a table value)", 2)
      end
    end,

    -- User
    __tostring = function(t)
      return t.name
    end,
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
  assert_arg(1, self, "class")

  local instance = self:allocate()
  instance:initialize(...)
  return instance
end

function Object.def:allocate()
  local klass = self
  local instance = {class=klass, __IS_INSTANCE=true}
  instance.__instance_variables = {}
  instance.__object_methods = {}

  return setmetatable(instance, klass.__instance_methods)
end


function Object:initialize() end

-- ¤Object

function Object.def:alias(new, old)
  assert_arg(1, self, {"class", "mixin"})
  assert_arg(2, new, "string")
  assert_arg(3, old, "string")

  local meth = self.__methods[old]

  if meth == nil then
    error("class method '"..old.."' not found in '"..tostring(self).."'", 2)
  end

  self.__methods[new] = meth
end

-- instance alias
function Object.def:ialias(new, old)
  assert_arg(1, self, {"class", "mixin"})
  assert_arg(2, new, "string")
  assert_arg(3, old, "string")

  local meth = self.__instance_methods[old]

  if meth == nil then
    error("instance method '"..old.."' not found in '"..tostring(self).."'", 2)
  end

  self.__instance_methods[new] = meth
end

function Object.def:method(name)
  assert_arg(1, self, {"class", "mixin"})
  assert_arg(2, name, "string")

  return self.__methods[name]
end

function Object.def:instance_method(name)
  assert_arg(1, self, {"class", "mixin"})
  assert_arg(2, name, "string")

  return self.__instance_methods[name]
end

function Object:method(name)
  assert_arg(1, self, "instance")
  assert_arg(2, name, "string")

  local meth = self.__object_methods[name]
  if meth ~= nil then
    return meth
  else
    return self.class.__instance_methods[name]
  end
end

function Object.def:class_variables()
  assert_arg(1, self, {"class", "mixin"})

  return self.__class_variables
end

function Object.def:methods()
  assert_arg(1, self, {"class", "mixin"})

  return self.__methods
end

function Object.def:instance_methods()
  assert_arg(1, self, {"class", "mixin"})

  return self.__instance_methods
end

function Object:instance_variables()
  assert_arg(1, self, "instance")

  return self.__instance_variables
end

function Object:object_methods()
  assert_arg(1, self, "instance")

  return self.__object_methods
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

Object:ialias("to_s", "__tostring")
Object:ialias("inspect", "__tostring")

return class
