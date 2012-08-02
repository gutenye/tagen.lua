--- Ruby-style Array class.
--
-- See the Guide for further @{02-arrays.md.Python_style_Arrays|discussion}
--
-- Note: 
--  1. use ary#length() instead of #ary
--  2. use ary#insert, #delete_at instead of table.insert, remove
--
-- Dependencies: `tagen.core`, `tagen.class`, `tagen.mixin`, `tagen.enumerable`
-- @module tagen.list
-- @pragma nostrip

local tagen = require "tagen.core"
local class = require "tagen.class"
local mixin = require "tagen.mixin"
local Enumerable = require ("tagen.enumerable")
local assert_arg = tagen.assert_arg

local Array = class("Array")

original__index = Array.__instance_methods["__index"]
original__newindex = Array.__instance_methods["__newindex"]

-- index support -1
Array.__instance_method["__index"] = function(self, key)
  if type(key) == "number" and key < 0 then
    key = self:length() + key + 1 
  end

  return original__index(self, key)
end

Array.__instance_method["__newindex"] = function(self, key, value)
  if type(key) == "number" and key < 0 then
    key = self:length() + key + 1 
  end

  return original__newindex(self, key, value)
end

Array.include(Enumerable)

-- Array(table)
-- Array(array)
function Array.def:__call(obj)
  return Array:new(obj)
end

-- initialize()
-- initialize(table/array)
function Array:initialize(obj)
  obj = obj or {}
  local len

  if tagen.instance_of(obj, Array) then
    len = obj:length()
  else
    len = #obj
  end

  for i=1,len do
    table.insert(self.__instance_variables, obj[i])
  end
end

function Array:dup()
  return Array:new(self)
end

function Array:replace(ary)
  self.__instance_variables = ary.__instance_variables
end

-- to nil
function Array:length()
  return #self.__instance_variables
end

Array:ialias("size", "length")

function Array:__tostring()
  return "[" .. table.concat(self:map(tagen.inspect).__instance_variables, ", ") .. "]"
end

Array:ialias("to_s", "__tostring")
Array:ialias("inspect", "__tostring")

function Array:__eq(other)
  if not tagen.kind_of(other, Array) then return false end

  if self:length() ~= other:length() then return false end

  for i=1,self:length() do
    if self[i] ~= other[i] then return false end
  end

  return true
end

function Array:__concat(other)
  local ary = Array:new(self)

  for i=1,other:length() do
    ary:append(other[i])
  end

  return ary
end

Array:ialias("__add", "__concat")
Array:ialias("concat", "__concat")

function Array:is_empty()
  if self:length() == 0 then
    return true
  else
    return false
  end
end

function Array:include(obj)
  for i=1,self:length() do
    if self[i] == obj then
      return true
    end
  end

  return false
end

Array:ialias("contains", "include")

-- (obj), (func)
function Array:count(obj)
  local func
  if type(obj) ~= "function" then func = function(v) return v==obj end else func = obj end

  local count = 0
  for i=1,self:length() do
    if func(self[i]) then
      count = count + 1
    end
  end

  return count
end

-- (index, count=1)
-- support -1
function Array:slice(index, count)
  count = count or 1
  assert_arg(1, index, "number")
  assert_arg(2, count, "number")
  local ary = Array:new()

  if index < 0 then
    index = self:length() + index + 1
  end

  local j = count + index

  for i=1,self:length() do
    if i >= index then 
      if i < j then
        ary:append(self[i])
      else
        break
      end
    end
  end

  return ary
end

function Array:slice1(index, count)
  count = count or 1
  assert_arg(1, index, "number")
  assert_arg(2, count, "number")
  return self:replace(self:slice(index, count))
end

function Array:at(index)
  assert_arg(1, index, "number")
  if index < 0 then index = self:length() + index + 1 end

  return self[index]
end

-- fetch(index, default=nil)
function Array:fetch(index, default)
  assert_arg(1, index, "number")
  local v = self:at(index)
  if v == nil then
    return default
  else
    return v
  end
end
Array.ialias("get", "fetch")





-- first(n=1)
function Array:first(n)
  n = n or 1

  if n == 1 then
    return self[1]
  else
    n = math.min(n, self:length())
    local ary = Array:new()
    for i=1,n do
      ary:push(self[i])
    end
    return ary
  end
end

-- last(n=1)
function Array:last(n)
  n = n or 1

  if n == 1 then
    return self[self:length()]
  else
    n = math.max(self:length()-n+1, 0)
    local ary = Array:new()
    for i=n,self:length() do
      ary:push(self[i])
    end
    return ary
  end
end

-- (*index)
function Array:values_at(...)
  local ary = Array:new()
  local args = table.pack(...)

  for i=1,args.n do
    ary:append(self:at(args[i]))
  end

  return ary
end

-- (obj),(func) =>nil
function Array:index(obj)
  local func
  if type(obj) ~= "function" then func = function(v) return v==obj end else func = obj end

  for i=1,self:length() do
    if func(self[i]) then
      return i
    end
  end

  return nil
end

function Array:rindex(obj)
  local func
  if type(obj) ~= "function" then func = function(v) return v==obj end else func = obj end

  for i=self:length(),1,-1 do
    if func(self[i]) then
      return i
    end
  end

  return nil
end

-- for insert, append, unshift
local function _insert(self, index, ...)
	local args = table.pack(...)

  for i=1,args.n do
    if index == nil then
      table.insert(self.__instance_variables, args[i])
    else
      table.insert(self.__instance_variables, index, args[i])
      index = index + 1
    end
  end
end

-- insert(index, obj...)
function Array:insert(index, ...)
  assert_arg(1, index, "number")
  return _insert(self, index, ...)
end

-- append(obj...)
function Array:append(...)
  return _insert(self, nil, ...)
end

Array:ialias("push", "append")

function Array:unshift(...)
  return _insert(self, 1, ...)
end

-- for pop, shift
local function _pop(ary, n, is_last)
  local ret = Array:new()
  local v

  for i=1,n do
    if is_last then
      v = ary:delete_at(ary:length() - n + i)
    else
      v = ary:delete_at(1)
    end

    ret:append(v)
  end

  if n == 1 then
    return ret[1]
  else
    return ret
  end
end

-- pop(n=1)
function Array:pop(n)
  n = n or 1
  assert_arg(1, n, "number")
  return _pop(self, n, true)
end

-- shift(n=1)
function Array:shift(n)
  n = n or 1
  assert_arg(1, n, "number")
  return _pop(self, n, false)
end

function Array:delete_at(index)
  assert_arg(1, index, "number")
  return table.remove(self.__instance_variables, index)
end

-- delete(obj)
-- delete(obj, func)
function Array:delete(obj, func)
  if type(func) ~= "function" then func = function() return nil end end

  for i=1,self:length() do
    if self[i] == obj then
      return self:delete_at(i)
    end
  end

  return func()
end

function Array:delete_if(func)
  local i = 1
  while i <= self:length() do
    if func(self[i]) then
      self:delete_at(i)
    else
      i = i +1
    end
  end

  return self
end

function Array:clear()
  self.__instance_variables = {}

  return self
end

-- each()
-- each(func{v, i})
function Array:each(func)
  if func == nil then return self.to_enum() end

  local ret, a,b,c
  for i=1,self:length() do
    ret, a,b,c = func(self[i], i)
    if ret == BREAK then
      break
    elseif ret == RETURN then
      return a,b,c
    end
  end
end

-- map(func{v,i})
function Array:map1(func)
  for i=1,self:length() do
    self[i] = func(self[i], i)
  end

  return self
end

function Array:map(func)
  return self:dup():map1(func)
end

Array:ialias("collect1", "map1")
Array:ialias("collect", "map")

-- join(sep="")
--
-- remove nil, call tagen.to_s
function Array:join(sep)
  sep = sep or ""
  assert_arg(1, sep, "string")

  return table.concat(self:map(tagen.to_s).__instance_variables, sep)
end

function Array:reverse()
  local ary = Array:new()

  for i=self:length(),1,-1 do
    ary:append(self[i])
  end

  return ary
end

function Array:reverse1()
  local i, j =1, self:length()
  local tmp

  while i < j do
    tmp = self[i]
    self[i] = self[j]
    self[j] = tmp
    i = i+1
    j = j-1
  end

  return self
end

--[[ need ordered_table
local function _make_hash(ary)
  local hash = {}

  for i=1,ary:length() do
    --hash[ary[i = true
  end

  return hash
end

function Array:uniq1()
  local hash = _make_hash(self)

  self:clear()

  for k,v in pairs(hash) do
    self:append(k)
  end

  return self
end

function Array:uniq()
  return self:dup():uniq1()
end
--]]

-- sort1()
-- sort1(func)
function Array:sort1(func)
  table.sort(self.__instance_variables, func)
  return self
end

function Array:sort(func)
  return self:dup():sort1(func)
end

return Array
