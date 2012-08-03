-- Note: implement each() need BREAK.
-- Dependenies: `tagen.mixin` `tagen.enumerator`


local mixin = require("tagen.mixin")
local Enumerator = require("tagen.enumerator")

local Enumerable = mixin("Enumerable")

function Enumerable:include(obj)
  local ret = self:each(function(v)
    if v == obj then
      return BREAK, true
    end
  end)

  if ret == true then
    return true
  else
    return false
  end
end
Enumerable:ialias("contains", "include")

-- all()
-- all(func)
function Enumerable:all(func)
  func = func or function(v) return v end

  local ret = self:each(function(v)
    if not func(v) then
      return BREAK, false
    end
  end)

  if ret == false then
    return false
  else
    return true
  end
end

-- none()
-- none(func)
function Enumerable:none(func)
  return self:all(function(v)
    return not v 
  end)
end

-- any()
-- any(func)
function Enumerable:any(func)
  func = func or function(v) return v end

  local ret = self:each(function(v)
    if func(v) then
      return BREAK, true
    end
  end)

  if ret == true then
    return true
  else
    return false
  end
end

function Enumerable:one(func)
  func = func or function(v) return v end
  local true_count = 0

  self:each(function(v)
    if true_count > 1 then
      return BREAK
    end

    if func(v) then
      true_count = true_count + 1
    end
  end)

  if true_count == 1 then
    return true
  else
    return false
  end
end

-- max()
-- max(func)
function Enumerable:max(func)
  func = func or function(max, v) return tagen.comp(v, max) end
  local max = nil

  self:each(function(v)
    if max == nil then
      max = v
    else
      ret = func(max, v)
      if ret > 0 then
        max = v
      end
    end
  end)

  return max
end

function Enumerable:min(func)
  func = func or function(min, v) return tagen.comp(v, min) end
  local min = nil

  self:each(function(v)
    if min == nil then
      min = v
    else
      ret = func(min, v)
      if ret < 0 then
        min = v
      end
    end
  end)

  return min
end

-- count(obj)
-- count(func)
function Enumerable:count(obj)
  local func
  if type(obj) ~= "function" then func = function(v) return v==obj end else func = obj end

  local count = 0

  self:each(function(v) 
    if func(v) then
      count = count + 1
    end
  end)

  return count
end

-- return Array
function Enumerable:map(func)
  local ary = Array:new()

  self:each(function(v, i) 
    ary:append(func(v, i))
  end)

  return ary
end

Enumerable.collect = Enumerable.map

-- each_cons(n)
-- each_cons(n, func)
function Enumerable:each_cons(n, func)
  if func == nil then return self:to_enum() end
  local ary = Array:new()

  self:each(function(v)
    if ary:length() == n then
      ary:shift()
    end

    ary:push(v)

    if ary:length() == n then
      func(ary:dup())
    end
  end)
end

-- each_slice(n)
-- each_slice(n, func)
function Enumerable:each_slice(n, func)
  if func == nil then return self:to_enum() end
  local ary = Array:new()

  self:each(function(v)
    ary:push(v)

    if ary:length() == n then
      func(ary:dup())
      ary:clear()
    end
  end)

  if ary:length() > 0 then
    func(ary)
  end
end

-- first(n=1)
function Enumerable:first(n)
  n = n or 1
  local idx = 1
  local ary = Array:new()

  self:each(function(v)
    if idx > n then
      return BREAK
    end

    ary:push(v)

    idx = idx + 1
  end)

  if n == 1 then
    return ary[1]
  else
    return ary
  end
end

function Enumerable:find(func)
  local found

  ret = self:each(function(v, ...)
    found = func(v, ...) 
    if found then
      return BREAK, v 
    end
  end)

  if found then
    return ret
  else
    return nil
  end
end
Enumerable:ialias("detect", "find")

function Enumerable:find_all(func)
  local found
  local ary = Array:new()

  self:each(function(v, ...)
    found = func(v, ...) 
    if found then
      ary:push(v)
    end
  end)

  return ary
end

Enumerable:ialias("select", "find_all")

-- find_index(v)
-- find_index(func)
function Enumerable:find_index(arg)
  local func
  if type(arg) ~= "function" then func = function(v) return v==arg end else func = arg end

  local idx = nil
  local found

  self:each(function(...)
    found = func(...) 
    if found then
      return BREAK
    end

    idx = (idx or 1) + 1
  end)

  if found then
    return idx
  else
    return nil
  end
end

return Enumerable
