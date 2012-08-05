--- Ruby-style extended string library.
--
-- If you want to make these available as string methods, then say
-- `stringx.import()` to bring them into the standard `string` table.
--
-- See @{03-strings.md|the Guide}
--
-- Dependencies: `tagen.core`, `tagen.array`, `tagen.regexp`
-- @module tagen.stringx

local tagen = require("tagen.core")
local Array = require("tagen.array")
local Regexp = require("tagen.regexp")
local assert_arg = tagen.assert_arg

local stringx = {}

function stringx.import()
  tagen.import(stringx, string)
end

function stringx.dup(self)
  return self..""
end

stringx.length = string.len

function stringx.is_empty(self)
  assert_arg(1, self, "string")
  return #self == 0
end

-- slice(index, count=1)
function stringx.slice(self, index, count)
  count = count or 1
  assert_arg(1, self, "string")
  assert_arg(2, index, "number")
  assert_arg(3, count, "number")

  local j
  if index > 0 then
    j = index + count -1
  else
    j = index - count + 1
  end

  return string.sub(self, index, j)
end

local function _find_all(self, str, offset)
  local plain
  if tagen.kind_of(str, Regexp) then str = str.source; plain = false else plain = true end

  if str == "" then return #self+1,#self end
  local i1,i2 = string.find(self, str, offset, plain)
  local res
  local k = 0
  while i1 do
    res = i1
    k = k + 1
    i1,i2 = string.find(self, str, i2+1, plain)
  end
  return res,k
end

--- count all instances of substring in string.
-- count(string)
-- count(pattern)
function stringx.count(self, str)
  assert_arg(1, self, "string")
  assert_arg(2, str, "string")

  local i, k = _find_all(self, str, 1)
  return k
end

-- index(string, offset=1)
-- index(pattern, offset=1)
function stringx.index(self, str, offset)
  offset = offset or 1
  assert_arg(1, self, "string")
  assert_arg(3, offset, "number")

  if tagen.kind_of(str, Regexp) then
    return string.find(self, str.source, offset)
  else
    return string.find(self, str, offset, true)
  end
end

-- index(string, offset=1)
-- index(pattern, offset=1)
function stringx.rindex(self, str, offset)
  offset = offset or 1
  assert_arg(1, self, "string")
  assert_arg(3, offset, "number")

  self = string.sub(self, 1, -offset)
  local idx = _find_all(self,str,1)
  if idx then 
    return idx 
  else 
    return nil 
  end
end

-- include(str)
-- include(pat)
function stringx.include(self, str)
  assert_arg(1, self, "string")
  local ret

  if tagen.kind_of(str, Regexp) then
    ret = string.find(self, str.source)
  else
    ret = string.find(self, str, 1, true)
  end

  if ret then
    return true
  else
    return false
  end
end

stringx.contains = stringx.include
  
function stringx.start_with(self, ...)
  assert_arg(1, self, "string")
  local args = table.pack(...)

  for i=1,args.n do
    if string.find(self, args[i], 1, true) == 1 then
      return true
    end
  end

  return false
end

--- does string end with the given substring?.
-- @param s a string
-- @param send a substring or a table of suffixes
function stringx.end_with(self, ...)
  assert_arg(1, self, "string")
  local args = table.pack(...)

  for i=1,args.n do
    local arg = args[i]
    if #self >= #arg and string.find(self, arg, #self-#arg+1, true) then
      return true
    end
  end

  return false
end

-- chars(func)
function stringx.chars(self, func)
  assert_arg(1, self, "string")
  assert_arg(2, func, "function")
  for c in self:gmatch(".") do
    func(c)
  end
end
stringx.each_char = stringx.chars

function stringx.lines(self, func)
  for line in self:gmatch("[^\n]*\n?") do
    if line == "" then
      break
    end
    func(line)
  end
end
stringx.each_line = stringx.lines

-- delete(string)   -> rest,deleted
-- delete(pattern)  -> rest,deleted
-- NOT IN PLACE
function stringx.delete(self, str)
  assert_arg(1, self, "string")
  local plain, i, j
  if tagen.kind_of(str, Regexp) then str = str.source; plain = false else plain = true end

  i, j = string.find(self, str, 1, plain)

  if i == nil then
    return nil, nil
  else
    rest = string.sub(self, 1, i-1)..string.sub(self, j+1, -1)
    deleted = string.sub(self, i, j)
    return rest, deleted
  end
end

function stringx.strip(self)
  assert_arg(1, self, "string")
  local ret = string.gsub(self, "^%s*", "")
  ret = string.gsub(ret, "%s*$", "")
  return ret
end

function stringx.lstrip(self)
  assert_arg(1, self, "string")
  return string.gsub(self, "^%s*", "")
end

function stringx.rstrip(self)
  assert_arg(1, self, "string")
  return string.gsub(self, "%s*$", "")
end

stringx.upcase = string.upper
stringx.downcase = string.lower

function stringx.swapcase(self)
  assert_arg(1, self, "string")
  return string.gsub(self, ".", function(c)
    if string.match(c, "%u") then
      return string.gsub(c, "%u", function(v) return string.lower(v) end)
    else
      return string.gsub(c, "%l", function(v) return string.upper(v) end)
    end
  end)
end

--- iniital word letters uppercase ('title case').
-- Here 'words' mean chunks of non-space characters.
-- @param self the string
-- @return a string with each word's first letter uppercase
function stringx.capitalize(self)
  assert_arg(1, self, "string")
  return string.gsub(self, '(%S)(%S*)',function(f,r)
    return string.upper(f)..string.lower(r)
  end)
end

-- (str, [limit])
-- (pat, [limit])
function stringx.split(self, pat, limit)
  assert_arg(1, self, "string")
  local plain
  local idx, ary = 1, Array:new()
  if tagen.instance_of(pat, Regexp) then pat = pat.source; plain = false else plain = true end

  if pat == "" then return Array:new{self} end

  while true do
    local i, j = string.find(self, pat, idx, plain)

    if i == nil then
      ary:push(string.sub(self, idx))
      local indexes = Array{}
      ary = ary:reverse()
      ary:each(function(v, i)
        if v ~= "" then
          return BREAK
        end

        indexes:push(i)
      end)

      indexes:each(function(i)
        ary:delete_at(1)
      end)
      ary = ary:reverse()

      return ary
    end

    ary:push(string.sub(self, idx, i-1))

    if limit and ary:length() == limit then
      ary[-1] = string.sub(self, idx)
      return ary
    end

    idx = j + 1
  end
end

--- partition the string using first occurance of a delimiter
function stringx.partition(self, sep)
  assert_arg(1, self, "string")
  assert_arg(2, sep, "string")

  local i1,i2 = stringx.index(self, sep)
  if not i1 or i1 == -1 then
    return self,'',''
  else
    if not i2 then i2 = i1 end
    return Array{string.sub(self,1,i1-1), string.sub(self,i1,i2), string.sub(self,i2+1)}
  end
end

function stringx.insert(self, index, str)
  assert_arg(1, self, "string")
  assert_arg(2, index, "number")
  return string.sub(self, 1, index-1)..str..string.sub(self, index, -1)
end

local function _just(s,w,ch,left,right)
  local n = #s
  if w > n then
    if not ch then ch = ' ' end
    local f1,f2
    if left and right then
      local ln = math.ceil((w-n)/2)
      local rn = w - n - ln
      f1 = string.rep(ch,ln)
      f2 = string.rep(ch,rn)
    elseif right then
      f1 = string.rep(ch,w-n)
      f2 = ''
    else
      f2 = string.rep(ch,w-n)
      f1 = ''
    end
    return f1..s..f2
  else
    return stringx.dup(s)
  end
end

--- left-justify s with width w.
-- @param self the string
-- @param w width of justification
-- @param ch padding character, default ' '
function stringx.ljust(self,w,ch)
  assert_arg(1, self, "string")
  assert_arg(2, w, "number")
  return _just(self,w,ch,true,false)
end

--- right-justify s with width w.
-- @param s the string
-- @param w width of justification
-- @param ch padding character, default ' '
function stringx.rjust(s,w,ch)
  assert_arg(1,s, "string")
  assert_arg(2,w,'number')
  return _just(s,w,ch,false,true)
end

--- center-justify s with width w.
-- @param s the string
-- @param w width of justification
-- @param ch padding character, default ' '
function stringx.center(s,w,ch)
  assert_arg(1,s, "string")
  assert_arg(2,w,'number')
  return _just(s,w,ch,true,true)
end

return stringx
