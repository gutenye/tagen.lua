-- Note: for-statement:  for k,v in hash:pairs() do .. end
-- Dependencies: `tagen.class`, `tagen.enumerable`

local class = require("tagen.class")
local Enumerable = require("tagen.enumerable")

local Hash = class("Hash")

Hash.include(Enumerable)

-- Hash(table)
-- Hash(hash)
function Hash.def:__call(obj)
  return Hash:new(obj)
end

-- initialize()
-- initialize(table/hash)
function Hash:initialize(obj)
  obj = obj or {}

  if tagen.instance_of(obj, Hash) then
    obj = obj.__instance_variables
  end

  for k, v in pairs(obj) do
    self.__instance_variables[k] = v
  end
end

-- for-statment
function Hash:pairs()
  return pairs(self.__instance_variables)
end

function Hash:dup()
  return Hash:new(self)
end

-- expensive
function Hash:length()
  local count = 0
  for _ in pairs(self.__instance_variables) do
    count = count + 1
  end

  return count
end
Hash:ialias("size", "length")

function Hash:__tostring()
  local data = {}

  for k, v in self:pairs() do
    table.insert(data, ("%s:%s"):format(tagen.inspect(k), tagen.inspect(v)))
  end

  return "{" .. table.concat(data, ", ") .. "}"
end
Hash:ialias("to_s", "__tostring")
Hash:ialias("inspect", "__tostring")

function Hash:__eq(other)
  if not tagen.kind_of(other, Hash) then return false end

  if self:length() ~= other:length() then return false end

  for k, v in self:pairs() do
    if v ~= other[k] then return false end
  end

  return true
end

function Hash:is_empty()
  return self:length() == 0
end

-- get(key, default=nil)
function Hash:get(key, default)
  local v = self.__instance_variables[key]

  if v == nil then
    return default
  else
    return v
  end
end
Hash:ialias("fetch", "get")

function Hash:set(key, value)
  self.__instance_variables[key] = value

  return value
end
Hash:ialias("store", "set")

function Hash:has_key(key)
  return self.__instance_variables[key] ~= nil
end

function Hash:has_value(obj)
  for k, v in self:pairs() do
    if v == obj then
      return true
    end
  end

  return false
end

function Hash:keys()
  local ary = Array:new()

  for k, v in self:pairs() do
    ary:push(k)
  end

  return ary
end

function Hash:values()
  local ary = Array:new()

  for k, v in self:pairs() do
    ary:push(v)
  end

  return ary
end

-- values_at(key...)
function Hash:values_at(...)
  local args = table.pack(...)
  local ary = Array:new()
  local k, v

  for i=1,args.n do
    k = args[i]
    v = self:get(k)
    if v ~= nil then
      ary:push(v)
    end
  end

  return ary
end

function Hash:each(func)
  local ret, a,b,c
  for k, v in self:pairs() do
    ret, a,b,c = func(k, v)

    if ret == BREAK then
      return a,b,c
    end
  end
end

-- merge1(other)
-- merge1(other, func)
function Hash:merge1(other, func)
  func = func or function(k,v1,v2) return v2 end 

  for k, v in other:pairs() do
    if self:has_key(k) then
      self:set(k, func(k,self[k],v))
    else
      self:set(k, v)
    end
  end

  return self
end

-- merge1(other)
-- merge1(other, func)
function Hash:merge(other, func)
  return self:dup():merge1(other, func)
end

function Hash:invert()
  local hash = Hash:new()

  for k, v in self:pairs() do
    hash[v] = k
  end

  return hash
end

function Hash:delete(key)
  local v =  self.__instance_variables[key] 

  self.__instance_variables[key] = nil
  return v 
end

function Hash:delete_if(func)
  for k, v in self:pairs() do
    if func(k, v) then
      self:delete(k)
    end
  end

  return self
end

function Hash:clear()
  self.__instance_variables = {}

  return self
end


function Hash:to_a()
  local ary = Array:new()
  for k, v in self:pairs() do
    ary:push(Array:new{k,v})
  end

  return ary
end

return Hash
