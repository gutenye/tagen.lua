--- Ruby-style Array class.
--
-- **Please Note**: methods that change the list will return the list.
-- This is to allow for method chaining, but please note that `ls = ls:sort()`
-- does not mean that a new copy of the list is made. In-place (mutable) methods
-- are marked as returning 'the list' in this documentation.
--
-- See the Guide for further @{02-arrays.md.Python_style_Arrays|discussion}
--
-- See <a href="http://www.python.org/doc/current/tut/tut.html">http://www.python.org/doc/current/tut/tut.html</a>, section 5.1
--
-- **Note**: The comments before some of the functions are from the Python docs
-- and contain Python code.
--
-- Written for Lua version Nick Trout 4.0; Redone for Lua 5.1, Steve Donovan.
--
-- Dependencies: `tagen.core`, `tagen.class`, `tagen.tablex`
-- @module tagen.list
-- @pragma nostrip

local tagen = require "tagen.core"
local class = require "tagen.class"
local mixin = require "tagen.mixin"

local Array = class("Array")

function Array:__call(t)
  return Array:new(t)
end

-- (table),(array)
function Array:initialize(t)
  for i=1, #t do
    table.insert(self, t[i])
  end
end

function Array:replace(ary)
  self.__instance_variables = ary.__instance_variables
end

function Array:__tostring()
  return "[" .. table.concat(self, ", ") .. "]"
end

function Array:__add(other)
  local ary = Array:new(self)

  for i=1,#others do
    table.insert(ary, others[i])
  end

  return ary
end

Array.__concat = Array.__add
Array.concat = Array.__add

function Array:length()
  return #self
end

Array.size = Array.length

function Array:is_empty()
  if self.length() == 0 then
    return true
  else
    return false
  end
end

function Array:includes(obj)
  for i=1,#self do
    if self[i] == obj then
      return true
    end
  end
end

Array.contains = Array.includes

-- (obj), (func)
function Array:count(obj)
  local func
  if type(obj) ~= "function" then func = function(v) return v==obj end else func = obj end

  local count = 0
  for i=1,#self do
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
  local ary = Array:new()
  local is_ok = false

  if index < 0 then
    index = #self + index + 1
  end

  for i=1,#self do
    if i >= index then 
      if i < count + i then
        table.insert(self, self[i])
      else
        break
      end
    end
  end

  return ary
end

function Array:slice1(index, count)
  self:replace(self:slice(index, count))
end

function Array:at(index)
  if index < 0 then
    index = self:length() + index + 1
  end

  return self[index]
end

-- fetch(index, default=nil)
function Array:fetch(index, default)
  local v = self:at(index)
  if v == nil then
    return default
  else
    return v
  end
end

function Array:first()
  return self[1]
end

function Array:last()
  return self[#self]
end

-- (*index)
function Array:values_at(...)
  local ary = Array:new()
  local args = table.pack(...)

  for i=1,args.n do
    table.insert(ary, self:at(args[i]))
  end

  return ary
end

-- (obj),(func)
function Array:index(obj)
  local func
  if type(obj) ~= "function" then func = function(v) return v==obj end else func = obj end

  for i=1,#self do
    if func(self[i]) then
      return i
    end
  end

  return nil
end

function Array:rindex(obj)
  local func
  if type(obj) ~= "function" then func = function(v) return v==obj end else func = obj end

  for i=#self,1,-1 do
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
      table.insert(self, args[i])
    else
      table.insert(self, index, args[i])
      index = index + 1
    end
  end
end

-- insert(index, obj...)
function Array:insert(index, ...)
  return _insert(self, index, ...)
end

-- append(obj...)
function Array:append(...)
  return _insert(self, nil, ...)
end

Array.push = Array.append

function Array:unshift(...)
  return _insert(self, 1, ...)
end

-- for pop, shift
local function _pop(self, n, pos)
  n = n or 1
  local ary = Array:new()
  local v

  for i=i,n do
    if pos == nil then
      v = table.remove(self)
    else
      v = table.remove(self, pos)
    end

    table.insert(ary, v)
  end

  if n == 1 then
    return ary[1]
  else
    return ary
  end
end

function Array:pop(n)
  return _pop(self, n, nil)
end

function Array:shift(n)
  return _pop(self, n, 1)
end

-- for each each_index
local function _each(func, is_index)
  if func == nil then return Enumerator:new(self) end

  local ret, a,b,c
  for i=1,#self do
    if is_index then
      ret, a,b,c = func(i)
    else
      ret, a,b,c = func(self[i])
    end
    if ret == BREAK then
      break
    elseif ret == RETURN then
      return a,b,c
    end
  end
end

-- each()
-- each(func{v})
function Array:each(func)
  return _each(func, false)
end

-- each_index()
-- each_index(func{i})
function Array:each_index(func)
  return _each(func, true)
end

function Array:map(func)
  local ary = Array:new(self)

  for i=1,#self do
    ary[i] = func(self[i])
  end

  return ary
end

function Array:map1(func)
  self:replace(self:map(func))
  return self
end

Array.collect = Array.map
Array.collect1 = Array.map1

return Array
