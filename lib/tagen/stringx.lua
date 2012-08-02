--- Ruby-style extended string library.
--
-- If you want to make these available as string methods, then say
-- `stringx.import()` to bring them into the standard `string` table.
--
-- See @{03-strings.md|the Guide}
--
-- Dependencies: `tagen.core`, `tagen.array`
-- @module tagen.stringx

local tagen = require("tagen.core")
local Array = require("tagen.array")

local stringx = {}

function stringx.import()
  tagen.import(stringx, string)
end

function stringx.dup(self)
  return self..""
end

stringx.length = string.len

function stringx.is_empty(self)
  return #self == 0
end

-- slice(index, count=1)
function stringx.slice(self, index, count)
  count = count or 1
  local j
  if index > 0 then
    j = index + count -1
  else
    j = index - count + 1
  end

  return self:sub(index, j)
end

local function _find_all(self, str, first, last)
  local plain
  if tagen.kind_of(str, Regexp) then plain = false else plain = true end

  if str == "" then return #self+1,#self end
  local i1,i2 = find(self, str, first, plain)
  local res
  local k = 0
  while i1 do
    res = i1
    k = k + 1
    i1,i2 = find(self, str, i2+1, plain)
    if last and i1 > last then break end
  end
  return res,k
end

--- count all instances of substring in string.
-- count(string)
-- count(pattern)
function stringx.count(self, str)
  local i, k = _find_all(self, str, 1)
  return k
end

-- index(string, offset=1)
-- index(pattern, offset=1)
function stringx.index(self, str, offset)
  offset = offset or 1

  if tagen.kind_of(str, Regexp) then
    return self:find(str, offset)
  else
    return self:find(str, offset, true)
  end
end

-- index(string, offset=1)
-- index(pattern, offset=1)
function stringx.rindex(self, str, offset)
  offset = offset or 1

  i, j = stringx.index(self:reverse(), str, - offset)

  if i == nil then
    return nil
  else
    i = #self - i + 1
    j = #self - j + 1
    return i, j
  end
end

-- include(str)
-- include(pat)
function stringx.include(self, str)
  local ret

  if tagen.kind_of(str, Regexp) then
    ret = self:find(str)
  else
    ret = self:find(str, 1, true)
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
    if find(self, args[i], 1, true) == 1 then
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
    if #self >= #arg and self:find(arg, #self-#arg+1, true) then
      return true
    end
  end

  return false
end

-- chars(func)
function stringx.chars(self, func)
  for c in self:gmatch(".") do
    func(c)
  end
end
stringx.each_char = stringx.chars

function stringx.lines(self, func)
  for line in self:gmatch("[^\n]*\n?") do
    func(line)
  end
end
stringx.each_line = stringx.lines

-- delete(string)
-- delete(pattern)
function stringx.delete(self, str)
  local plain, i, j
  if tagen.kind_of(str, Regexp) then plain = false else plain = true end

  i, j = self:find(str, 1, plain)

  if i == nil then
    return nil
  else
    return self:sub(1,i)..self:sub(j,-1)
  end
end

function stringx.strip(self)
  return self:gsub("^%s*|%s*$", "")
end

function stringx.lstrip(self)
  return self:gsub("^%s*")
end

function stringx.rstrip(self)
  return self:gsub("%s*$")
end

stringx.upcase = string.upper
stringx.downcase = string.lower

function stringx.swapcase(self)
  return self:gsub("(%u+|%l+)", function(c)
    return c:gsub("%u+", function(v) return v:lower() end)
      :gsub("%l+", function(v) return v:upper() end)
  end)
end

--- iniital word letters uppercase ('title case').
-- Here 'words' mean chunks of non-space characters.
-- @param self the string
-- @return a string with each word's first letter uppercase
function stringx.capitalize(self)
  return self:gsub('(%S)(%S*)',function(f,r)
    return f:upper()..r:lower()
  end)
end

local function _split(self, pat, plain, limit)
end

-- (str, [limit])
-- (pat, [limit])
function stringx.split(self, pat, limit)
  local plain
  local idx, ary = 1, Array:new()
  if tagen.instance_of(pat, Regexp) then plain = false else plain = true end

  if pat == "" then return Array:new{self} end

  while true do
    local i, j = find(self, pat, idx, plain)

    if i == nil then
      ary:push(string.sub(self, idx))
      ary:delete('')
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


-- The partition functions split a string  using a delimiter into three parts:
-- the part before, the delimiter itself, and the part afterwards
local function _partition(p,delim,fn)
end

--- partition the string using first occurance of a delimiter
function stringx.partition(self, sep)
  assert_arg(1, self, "string")

  local i1,i2 = stringx.index(self, sep)
  if not i1 or i1 == -1 then
    return self,'',''
  else
    if not i2 then i2 = i1 end
    return sub(self,1,i1-1), sub(self,i1,i2), sub(self,i2+1)
  end
end

function stringx.insert(self, index, str)
  return self:sub(1, index-1)..str..self:sub(index-1, -1)
end

local function _just(s,w,ch,left,right)
  local n = #s
  if w > n then
    if not ch then ch = ' ' end
    local f1,f2
    if left and right then
      local ln = ceil((w-n)/2)
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
  assert_string(1,self, "string")
  assert_arg(2,w,'number')
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
