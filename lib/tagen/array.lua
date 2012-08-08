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
-- <h3>call-seq:</h3>
--
--    Array.wrap(obj)      -> new_ary
--
-- @param obj obj,table,array
--
-- @usage
--
--  Array:wrap(1)          => [1]
--  Array:wrap({1,2})      => [1,2]
--  Array:wrap(Array{1,2}) => [1,2]
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
--
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
-- <h3>call-seq:</h3>
--  
--    ary:dup()           -> new_ary
--
function Array:dup()
  return Array:new(self)
end

--- Replace self.
--
-- <h3>call-seq:</h3>
--
--    ary:replace(other_ary) -> self
--
function Array:replace(ary)
  self.__instance_variables = ary.__instance_variables

  return self
end

-- Returns the number of elements in self.
--
-- alias: size
--
-- @usage
--
--   a = Array{ 1, 2, 3, 4, 5 }
--   a:length                  #=> 5
--   a = Array{ }
--   a:length                  #=> 0
--
-- @return number
function Array:length()
  return #self.__instance_variables
end

Array:ialias("size", "length")

--- tostring metamethod.
--
-- alias: to_s, inspect
--
-- @usage
--
--  tostring(Array{1,"a"}) #=> [1, "a"]
function Array:__tostring()
  return "[" .. table.concat(self:map(tagen.inspect).__instance_variables, ", ") .. "]"
end

Array:ialias("to_s", "__tostring")
Array:ialias("inspect", "__tostring")

--- Compare two arrays.
--
-- <h3>call-seq:</h3>
--   
--    ary1 == ary2   -> true or false
--
-- @param other array
-- @return true or false
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
-- <h3>call-seq:</h3>
--   
--    ary1 .. ary2 -> new_ary
--
-- alias: __add, concat
--
-- @param other array
-- @return a new array.
function Array:__concat(other)
  local ary = Array:new(self)

  for i=1,other:length() do
    ary:push(other[i])
  end

  return ary
end

Array:ialias("__add", "__concat")
Array:ialias("concat", "__concat")


--- Returns true if self contains no elements.
--
-- <h3>call-seq:</h3>
--
--   ary:is_empty() -> true or flase
--
-- @usage
--
--   a = Array{}
--   a:is_empty()   #=> true
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
-- object `==` object, otherwise returns false.
--
-- <h3>call-seq:</h3>
--
--   ary:include(obj)     -> true or false
--   ary:contains(obj)    -> true or false
--
-- alias: contains
-- @param obj object
--
-- @usage
--
--   a = Array{ "a", "b", "c" }
--   a:include("b")   #=> true
--   a:include("z")   #=> false
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
--
--     ary:count(obj)            -> int
--     ary:count(func{|item|})   -> int
--
-- If a object is given, counts the number of elements which equal obj using ==
--
-- If a function is given, counts the number of elements for which the function
--  returns a true value.
--
-- @usage
--
--   ary = Array{1, 2, 4, 2}
--   ary:count()                #=> 4
--   ary:count(2)               #=> 2
--   ary:count(function(x) return x%2 == 0 end) #=> 3
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
--
--     ary:slice(index)            -> obj or nil
--     ary:slice(start, length)    -> new_ary or nil
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
-- Returns the deleted object (or objects), or nil if the index is out of
-- range.
--
-- <h3>call-seq:</h3>
--
--    slice1(index)         -> obj or nil
--    slice1(start, length) -> new_ary or nil
--
-- @usage
--
--    a = Array{ "a", "b", "c" }
--    a:slice1(2)     #=> "b"
--    a               #=> ["a", "c"]
--    a:slice1(100)   #=> nil
--    a               #=> ["a", "c"]
--
--    a = Array{ "a", "b", "c" }
--    a:slice1(1, 2)  #=> ["a", "b"]
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

-- Returns the element at index. A negative index counts from the end of
-- self. Returns nil if the index is out of range. 
--
-- @param index number
--
-- @usage
--
--    a = Array{ "a", "b", "c", "d", "e" }
--    a:at(1)     #=> "a"
--    a:at(-1)    #=> "e"
--
-- @return obj or nil
function Array:at(index)
  assert_arg(1, index, "number")

  return entry(self, index)
end

--- Tries to return the element at position index. 
--
-- <h3>call-seq:</h3>
--
--    ary:fetch(index, default=nil)     -> obj
--    ary:fetch(index, func{|index|})   -> obj
--
-- Alternatively, if a func is given it will only be executed when an
-- invalid index is referenced.  Negative values of index count from the
-- end of the array.
--
-- @usage
--
--   a = Array{ 11, 22, 33, 44 }
--   a:fetch(2)               #=> 22
--   a:fetch(-1)              #=> 44
--   a:fetch(5, 'cat')        #=> "cat"
--   a:fetch(100, function(i) return i.." is out of bounds" end)
--                             #=> "100 is out of bounds"
--
function Array:fetch(index, default)
  assert_arg(1, index, "number")

  if index < 0 then
    index = self:length() + index + 1
  end

  if type(default) == "function" and (index < 1 or index > self:length()) then
    return default(index)
  end

  local v = self:at(index)
  if v == nil then
    return default
  else
    return v
  end
end
Array:ialias("get", "fetch")

--- Returns the first element, or the first n elements, of the array.
--
-- <h3>call-seq</h3>
--
--    ary:first()     ->   obj or nil
--    ary:first(n)    ->   new_ary
--
-- @usage
--
--   a = Array{ "q", "r", "s", "t" }
--   a:first()     #=> "q"
--   a:first(2)    #=> ["q", "r"]
--
-- @see Array:last
function Array:first(n)
  assert_arg(2, n, {"nil", "number"})

  if n == nil then
    return self[1]
  end

  n = math.min(n, self:length())
  local ary = Array:new()

  for i=1,n do
    ary:push(self[i])
  end

  return ary
end

--- Returns the last element(s) of self.
--
-- <h3>call-seq:</h3>
--
--    ary:last()     ->  obj or nil
--    ary:last(n)    ->  new_ary
--
-- @usage
--
--    a = Array{ "w", "x", "y", "z" }
--    a:last     #=> "z"
--    a:last(2)  #=> ["y", "z"]
--
-- @see Arry:first
function Array:last(n)
  assert_arg(2, n, {"nil", "number"})

  if n == nil then
    return self[self:length()]
  end

  n = math.max(self:length()-n+1, 0)
  local ary = Array:new()

  for i=n,self:length() do
    ary:push(self[i])
  end

  return ary
end

--- Returns the *index* of the first object in ary such that the object is
-- `==` to obj.
--
-- <h3>call-seq:</h3>
--
--    ary:index(obj)                      ->  int or nil
--    ary:index(function(item) block end) ->  int or nil
--
-- If a function is given instead of an argument, returns the *index* of first
-- the object for which the function returns true.  Returns nil if no match
-- is found.
--
-- alias: find_index
--
--    a = Array{ "a", "b", "c" }
--    a:index("b")              #=> 1
--    a:index("z")              #=> nil
--    a:index(function(x) return x=="b" end) #=> 1
--
-- @see Array:rindex
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

Array:ialias("find_index", "index")

--- Returns the *index* of the last object in self `==` to obj.
--
-- <h3>call-seq:</h3>
--
--    ary:rindex(obj)                      ->  int or nil
--    ary:rindex(function(item) block end) ->  int or nil
--
-- @usage
--
--  a = Array{ "a", "b", "b", "b", "c" }
--  a:rindex("b")             #=> 3
--  a:rindex("z")             #=> nil
--  a:rindex(function(x) return x == "b" end) #=> 3
--
-- @see Array:index
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

--- Returns an array containing the elements in self corresponding to the
-- given selector(s).
--
-- <h3>call-seq:</h3>
--
--    ary.values_at(selector, ...)  -> new_ary
--
-- @param ... (integer)
--
-- @usage
--
--  a = A{ "a", "b", "c", "d", "e", "f", }
--  a.values_at(1, 3, 5)
--  a.values_at(-1, -3, -5, -7)
--
-- @see Array:select
function Array:values_at(...)
  local ary = Array:new()
  local args = table.pack(...)

  for i=1,args.n do
    ary:push(self:at(args[i]))
  end

  return ary
end

-- for insert, push, unshift
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

--- Inserts the given values before the element with the given index.
--
-- <h3>call-seq:</h3>
--
--    ary:insert(index, obj...)  -> ary
--
-- Negative indices count backwards from the end of the array, where -1 is
-- the last element.
--
-- @usage
--
--   a = Array{ "a", "b", "c", "d" }
--   a:insert(2, 99)         #=> ["a", "b", 99, "c", "d"]
--   a:insert(-2, 1, 2, 3)   #=> ["a", "b", 99, "c", 1, 2, 3, "d"]
--
function Array:insert(index, ...)
  assert_arg(1, index, "number")
  return _insert(self, index, ...)
end

--- Append---Pushes the given object on to the end of this array. This
-- expression returns the array itself, so several appends
-- may be chained together.
--
-- <h3>call-seq:</h3>
--
--    ary:push(obj)              -> ary
--    ary:append(obj)            -> ary
--
-- alias: append
--
-- @usage
--
--    a = Array{1}
--    a:append("a"):append(unpack(Array{3, 4})) #=> [1, "a", 3, 4]
--     
function Array:push(...)
  return _insert(self, nil, ...)
end

Array:ialias("append", "push")

--- Prepends objects to the front of self, moving other elements upwards.
--
-- <h3>call-seq:</h3>
--
--    ary.unshift(obj, ...)  -> ary
--
-- @usage
--
--    a = Array{ "b", "c", "d" }
--    a.unshift("a")   #=> ["a", "b", "c", "d"]
--    a.unshift(1, 2)  #=> [ 1, 2, "a", "b", "c", "d"]
--
-- @see Array:shift
function Array:unshift(...)
  return _insert(self, 1, ...)
end

-- Removes the last element from self and returns it, or
-- nil if the array is empty.
--
-- <h3>call-seq:</h3>
--    ary:pop()     -> obj or nil
--    ary:pop(n)    -> new_ary
--
-- @usage
--
--    a = Array{ "a", "b", "c", "d" }
--    a:pop()    #=> "d"
--    a:pop(2)  #=> ["b", "c"]
--    a         #=> ["a"]
--
-- @see Array:push
function Array:pop(n)
  assert_arg(2, n, {"nil", "number"})

  if n == nil then
    return self:delete_at(self:length())
  end

  local ret = Array:new()
  for i=1,n do
    v = self:delete_at(self:length() - n + i)

    ret:push(v)
  end

  return ret
end

--- Removes the first element of self and returns it (shifting all
-- other elements down by one). Returns nil if the array
-- is empty.
--
-- <h3>call-seq:</h3>
--
--    ary:shift()    -> obj or nil
--    ary:shift(n)   -> new_ary
--
-- If a number n is given, returns an array of the first n elements
-- (or less). With ary containing only the remainder elements, 
-- not including what was shifted to new_ary.
--
-- @usage
--
--    args = Array{ "-m", "-q", "filename" }
--    args:shift()     #=> "-m"
--    args           #=> ["-q", "filename"]
--
--    args = Array{ "-m", "-q", "filename" }
--    args:shift(2)  #=> ["-m", "-q"]
--    args           #=> ["filename"]
--
-- @see Array:unshift
function Array:shift(n)
  assert_arg(2, n, {"nil", "number"})

  if n == nil then
    return self:delete_at(1)
  end

  local ret = Array:new()
  for i=1,n do
    v = self:delete_at(1)

    ret:push(v)
  end

  return ret
end

--- Deletes the element at the specified index, returning that element, or
-- nil if the index is out of range.
--
-- <h3>call-seq:</h3>
--
--    ary:delete_at(index)  -> obj or nil
--
-- @usage
--
--    a = Array{"ant", "bat", "cat", "dog"}
--    a:delete_at(2)    #=> "cat"
--    a                 #=> ["ant", "bat", "dog"]
--    a:delete_at(99)   #=> nil
--
-- @see Array:slice1
function Array:delete_at(index)
  assert_arg(1, index, "number")
  return table.remove(self.__instance_variables, index)
end

-- Deletes all items from self that are equal to obj.
--
-- <h3>call-seq:</h3>
--
--    ary:delete(obj)                        -> obj or nil
--    ary:delete(obj, func{=>"not found"})   -> obj or nil
--
-- If any items are found, returns obj, otherwise nil is returned instead.
--
-- If the func is given, the result of the func is returned if
-- the item is not found.  
--
-- @usage
--
--    a = Array{ "a", "b", "b", "b", "c" }
--    a:delete("b")                   #=> "b"
--    a                               #=> ["a", "c"]
--    a:delete("z")                   #=> nil
--    a:delete("z") { "not found" }   #=> "not found"
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

-- Deletes every element of self for which func evaluates to true.
--
-- <h3>call-seq:</h3>
--
--    ary:delete_if(func{|item|})  -> ary
--
-- The array is changed instantly every time the block is called, not after
-- the iteration is over.
--
-- @usage
--
--    a = Array{ "a", "b", "c" }
--    a:delete_if(function(x) return x >= "b" end)   #=> ["a"]
--
-- @see Array:reject1
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

--- Removes all elements from self.
--
-- <h3>call-seq:</h3>
--
--    ary:clear()    -> ary
--
-- @usage
--
--    a = Array{ "a", "b", "c", "d", "e" }
--    a.clear    #=> [ ]
function Array:clear()
  self.__instance_variables = {}

  return self
end

-- Calls the given func once for each element in self.
--
-- call-seq:
--
--    ary:each(func{|item, index|})  -> ary
--    ary:each()                     -> Enumerator
--
-- An Enumerator is returned if no block is given.
--
-- @usage
--
--    a = Array{ "a", "b", "c" }
--    a:each(function(x) io.write(x.." -- ") end) 
--                  # produces: a -- b -- c --
--
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

--- Invokes the given func once for each element of self, replacing the
-- element with the value returned by the func.
--
-- <h3>call-seq:</h3>
--
--    ary:collect1(func{|item|})   -> ary
--    ary:map1(func{|item|})       -> ary
--
-- alias: collect1
--
-- @usage
--
--    a = Array{ "a", "b", "c", "d" }
--    a.map1(function(x) return x + "!" end)
--    a #=>  [ "a!", "b!", "c!", "d!" ]
--
function Array:map1(func)
  for i=1,self:length() do
    self[i] = func(self[i], i)
  end

  return self
end

Array:ialias("collect1", "map1")

--- Invokes the given block once for each element of self.
--
-- <h3>call-seq:</h3>
--
--    ary:collect(func{|item|})  -> new_ary
--    ary:map(func{|item|})      -> new_ary
--
-- Creates a new array containing the values returned by the block.
--
-- alias: collect
--
-- @usage
--
--    a = Array{ "a", "b" }
--    a.map(function(x) return x .. "!" end)   #=> ["a!", "b!" ]
--    a                       #=> ["a", "b" ]
--
function Array:map(func)
  return self:dup():map1(func)
end

Array:ialias("collect", "map")

--- Returns a string created by converting each element of the array to
-- a string, separated by the given separator.
--
-- <h3>call-seq:</h3>
--
--    ary.join(separator="")    -> str
--
-- It skip nil value and calls tagen.to_s
--
-- @usage
-- 
--    Array{ "a", "b", "c" }:join()      #=> "abc"
--    Array{ "a", "b", "c" }:join("-")   #=> "a-b-c"
--
function Array:join(sep)
  sep = sep or ""
  assert_arg(1, sep, "string")

  return table.concat(self:map(tagen.to_s).__instance_variables, sep)
end

-- Returns a new array containing self's elements in reverse order.
--
-- <h3>call-seq:</h3>
--
--    ary:reverse()    -> new_ary
--
-- @usage
--
--    Array{ "a", "b", "c" }:reverse()   #=> ["c", "b", "a"]
--    Array{ 1 }:reverse()               #=> [1]
--
function Array:reverse()
  local ary = Array:new()

  for i=self:length(),1,-1 do
    ary:push(self[i])
  end

  return ary
end

-- Reverses self in place.
--
-- <h3>call-seq:</h3>
--
--    ary:reverse1()   -> ary
--
-- @usage
--
--    a = array{ "a", "b", "c" }
--    a:reverse1()       #=> ["c", "b", "a"]
--    a                #=> ["c", "b", "a"]
--
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
    self:push(k)
  end

  return self
end

function Array:uniq()
  return self:dup():uniq1()
end
--]]

--- Sorts self in place.
--
-- <h3>call-seq:</h3>
--
--    ary:sort1()                -> ary
--    ary:sort1(func{|a,b|})     -> ary
--
-- Invoke table.sort
--
-- @usage
--
--    a = Array{ 3, 2, 1 }
--    a:sort1()                  #=> [1, 2, 3]
--    a:sort1(func{|x,y| x > y}  #=> [3, 2, 1]
--
function Array:sort1(func)
  table.sort(self.__instance_variables, func)
  return self
end


-- Returns a new array created by sorting self.
--
-- <h3>call-seq:</h3>
--
--    ary:sort()                -> new_ary
--    ary:sort(func{|a, b|})    -> new_ary
--
-- Invoke table.sort
--
-- @usage
--
--    a = Array{ 3, 2, 1 }
--    a:sort()                  #=> [1, 2, 3]
--    a:sort(func{|x,y| x > y}  #=> [3, 2, 1]
function Array:sort(func)
  return self:dup():sort1(func)
end

return Array
