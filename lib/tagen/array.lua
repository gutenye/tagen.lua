--- Array class.
--
-- **Note**: 1. use `Array#length()` instead of `#ary`
-- 2. use `Array#insert`, `Array#delete_at` instead of `table.insert`, `table.remove`
--
-- Array include Enumerable.
--
-- Array#[index] support -1.
--
-- Dependencies: `tagen.core`, `tagen.class`, `tagen.mixin`, `tagen.enumerable`
-- @module tagen.array

local tagen = require "tagen.core"
local class = require "tagen.class"
local mixin = require "tagen.mixin"
local Enumerable = require ("tagen.enumerable")
local pd = tagen.pd
local assert_arg = tagen.assert_arg

local Array = class("Array")

local original__index = Array.__instance_methods["__index"]
local original__newindex = Array.__instance_methods["__newindex"]

--- metamethod __index
-- support -1 index
Array.__instance_methods["__index"] = function(self, key)
  if type(key) == "number" and key < 0 then
    key = self:length() + key + 1 
  end

  return original__index(self, key)
end

--- metamethod __newindex
-- support -1 index
Array.__instance_methods["__newindex"] = function(self, key, value)
  if type(key) == "number" and key < 0 then
    key = self:length() + key + 1 
  end

  return original__newindex(self, key, value)
end

Array:include(Enumerable)

--- Return a new array.
-- 
-- <h3>call-seq:</h3>
--     Array(table)    
--     Array(array)   
--
-- @param  obj table or array
--
-- @return a new array.
function Array.def:__call(obj)
  return Array:new(obj)
end

--- wrap an object to Array
--
-- @usage
--
--  Array.wrap(1)          => [1]
--  Array.wrap({1,2})      => [1,2]
--  Array.wrap(Array{1,2}) => [1,2]
--
-- @return a new array.
function Array.def:wrap(obj)
  if tagen.kind_of(obj, Array) or tagen.kind_of(obj, "table") then
    return Array(obj)
  else
    return Array{obj}
  end
end

--- Returns a new array.
--
-- <h3>call-seq:</h3>
--     initialize()
--     initialize(table/array)
--
-- @usage
--  
--  Array:new{}
--  Array:new{"a", "b"}
--
-- @return a new array.
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

--- Duplicate self.
--
-- @return a new array.
function Array:dup()
  return Array:new(self)
end

--- Replace self.
--
-- @return self
function Array:replace(ary)
  self.__instance_variables = ary.__instance_variables
end

-- Returns the number of elements in self.
--
-- alias: size
--
-- @usage
--
--   [ 1, 2, 3, 4, 5 ].length   #=> 5
--   [].length                  #=> 0
--
-- @return number
function Array:length()
  return #self.__instance_variables
end

Array:ialias("size", "length")

function Array:__tostring()
  return "[" .. table.concat(self:map(tagen.inspect).__instance_variables, ", ") .. "]"
end

Array:ialias("to_s", "__tostring")
Array:ialias("inspect", "__tostring")

--- Compare two arrays.
--
-- @param other array
-- @return boolean
function Array:__eq(other)
  if not tagen.kind_of(other, Array) then return false end

  if self:length() ~= other:length() then return false end

  for i=1,self:length() do
    if self[i] ~= other[i] then return false end
  end

  return true
end

--- Concat two arrays.
--
-- alias: __add, concat
--
-- @param other array
-- @return a new array.
function Array:__concat(other)
  local ary = Array:new(self)

  for i=1,other:length() do
    ary:append(other[i])
  end

  return ary
end

Array:ialias("__add", "__concat")
Array:ialias("concat", "__concat")


--- Returns true if self contains no elements.
-- @usage
--
--   A{}.is_empty()   #=> true
--
-- @return boolean
function Array:is_empty()
  if self:length() == 0 then
    return true
  else
    return false
  end
end

--- Returns true if the given obj is present in self (that is, if any
-- object `==` object+, otherwise returns false.
--
-- alias: `contains`
-- @param obj object
--
-- @usage
--
--   a = Array{ "a", "b", "c" }
--   a.include("b")   #=> true
--   a.include("z")   #=> false
--
-- @return boolean
function Array:include(obj)
  for i=1,self:length() do
    if self[i] == obj then
      return true
    end
  end

  return false
end

Array:ialias("contains", "include")

--- Returns the number of elements.
--
-- <h3>call-seq:</h3>
--     ary.count(obj)            -> int
--     ary.count(func{|item|})   -> int
--
-- If a object is given, counts the number of elements which equal obj using ==
--
-- If a function is given, counts the number of elements for which the function
--  returns a true value.
--
-- @param obj obj or func
--
-- @usage
--
--   ary = [1, 2, 4, 2]
--   ary.count                  #=> 4
--   ary.count(2)               #=> 2
--   ary.count { |x| x%2 == 0 } #=> 3
--
-- @return number
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

local function entry(ary, index)
  if index < 0 then index = ary:length() + index + 1 end

  return ary[index]
end

local function subseq(ary, beg, len)
  if beg > ary:length() then return nil end
  if beg < 0 or len < 0 then return nil end

  if ary:length() < len or ary:length() < beg + len then
    len = ary:length() - beg + 1
  end

  local ret = Array:new()

  if len == 0 then
    return ret
  else
    local j = beg + len

    for i=1,ary:length() do
      if i >= beg then
        if i < j then
          ret:push(ary[i])
          i = i + 1
        else
          break
        end
      end
    end
    return ret
  end
end

--- Element reference.
--
-- <h3>call-seq:</h3>
--     slice(index)            -> obj or nil
--     slice(start, length)    -> new_ary or nil
--
-- Returns the element at index, or returns a
-- subarray starting at the start index and continuing for lengthelements.
--
-- Negative indices count backward from the end of the array (-1 is the last
-- element).
--
-- Returns nil if the index are out of range.
--
-- @param start number
-- @param length number (optional)
--
-- @usage
--
--    a = Array{ "a", "b", "c", "d", "e" }
--    a:slice(1)            #=> "a"
--    a:slice(1, 1)         #=> ["a"]
--    a:slice(-2, 2)        #=> ["d", "e"]
--    a:slice(100)          #=> nil
function Array:slice(...)
  local args = table.pack(...)

  if args.n == 2 then
    beg = args[1]
    len = args[2]

    if beg < 0 then
      beg = self:length() + beg + 1
    end

    return subseq(self, beg, len)

  elseif args.n == 1 then
    index = args[1]

    return entry(self, index)
  end
end

-- Element slice in place.
-- Deletes the element(s) given by an index (optionally up to length
-- elements) or by a range.
--
-- Returns the deleted object (or objects), or +nil+ if the +index+ is out of
-- range.
--
-- <h3>call-seq:</h3>
--    slice1(index)         -> obj or nil
--    slice1(start, length) -> new_ary or nil
--
--    a = Array{ "a", "b", "c" }
--    a.slice1(2)     #=> "b"
--    a               #=> ["a", "c"]
--    a.slice1(100)   #=> nil
--    a               #=> ["a", "c"]
--
--    a = Array{ "a", "b", "c" }
--    a.slice1(1, 2)  #=> ["a", "b"]
--    a               #=> ["c"]
function Array:slice1(...)
  local args = table.pack(...)

  if args.n == 2 then
    beg = args[1]
    len = args[2]

    if len < 0 then return nil end
    if beg < 0 then
      beg = beg + self:length() + 1
      if beg < 0 then return nil end
    elseif self:length() < beg then 
      return  nil
    end

    if self:length() < beg + len then
      len = self:length() - beg + 1
    end

    if len == 0 then return Array:new() end

    local ary2 = subseq(self, beg, len)
    for i=1,len do
      self:delete_at(beg)
    end

    return ary2

  elseif args.n == 1 then
    local index = args[1] 

    return self:delete_at(index)
  end
end

function Array:at(index)
  assert_arg(1, index, "number")

  return entry(self, index)
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
Array:ialias("get", "fetch")

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
  local is_found = false

  for i=1,self:length() do
    if self[i] == obj then
      is_found = true
      self:delete_at(i)
    end
  end

  if is_found then
    return obj
  else
    return func()
  end
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
      return a, b, c
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
