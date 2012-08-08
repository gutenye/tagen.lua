--- Generally useful routines.
-- See  @{01-introduction.md.Generally_useful_functions|the Guide}.
--
-- @module tagen.core
BREAK = {}
RETURN = {}

local clock = os.clock
local stdout = io.stdout

local collisions = {}
local tagen = {
  VERSION = "0.5"
}
local global = {}
local lua51 = rawget(_G,'setfenv')

tagen.lua51 = lua51
if not lua51 then -- Lua 5.2 compatibility
  unpack = table.unpack
  loadstring = load
end

tagen.dir_separator = _G.package.config:sub(1,1)

-- ¤type --{{{1
--- a string representation of a type.
--
-- @usage
--
--   tagen.type(Array:new())   -> "Array"
--   tagen.type(Array)         -> "class"
--   tagen.type("x")           -> "string"
--
-- instance, class, mixin, file
function tagen.type(obj)
  local t = type(obj)

  if t == "table" or t == "userdata" then
    if obj.__IS_INSTANCE then
      return obj.class.name
    elseif obj.__IS_CLASS then
      return "class"
    elseif obj.__IS_MIXIN then 
      return "mixin"
    elseif getmetatable(obj) == getmetatable(io.stdout) then
      return "file"
    end
  end

  return t
end

local function _kind_of(obj, klass)
  local c = obj.class

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

--- Detect object's type
--
-- @param klass Class or String
--
-- @usage
--
--  tagen.kind_of(obj, Array)   
--  tagen.kind_of(obj, "string") 
--
-- "object", nil class, mixin, instance, file, callable, integer
--
-- @return true or false
function tagen.kind_of(obj, klass)
  if klass == "nil" then
    return obj == nil

  elseif klass == "object" then
    return obj ~= nil

  elseif klass == "class" then
    return type(obj) == "table" and obj.__IS_CLASS

  elseif klass == "mixin" then
    return type(obj) == "table" and obj.__IS_MIXIN

  elseif klass == "file" then
    return getmetatable(obj) == getmetatable(io.stdout)

  elseif klass == "callable" then
    return (type(obj) == "function") or 
      (getmetatable(obj) and getmetatable(obj).__call and true)

  elseif klass == "integer" then
    return type(obj) == "number" and  math.ceil(obj) == obj

  elseif type(obj) == "table" and obj.__IS_INSTANCE then
    if klass == "instance" then
      return true
    else
      return _kind_of(obj, klass)
    end

  else
    return type(obj) == klass
  end
end

function tagen.instance_of(obj, klass)
  if tagen.kind_of(obj, "instance") then
    return obj.class == klass

  else
    return false
  end
end
--}}}1

--- assert that the given argument is in fact of the correct type.
--
-- @param n argument index
-- @param val the value
-- @param type_s the types
-- @param lev optional stack position for trace, (default 2)
-- @param verify an optional verfication function
-- @param msg an optional custom message
--
-- @usage 
--
--   assert_arg(1, str, "string")
--   assert_arg(1, ary, Array)
--   assert_arg(1, str, {"string", Regexp})
--   assert_arg(n,val,'string',path.isdir,'not a directory')
--
function tagen.assert_arg(n, val, type_s, lev, verify, msg)
  if type(type_s) ~= "table" then
    types = {type_s}
  else
    types = type_s
  end

  local is_type = false

  for _, tp in ipairs(types) do
    if tagen.kind_of(val, tp) then
      is_type = true
      break
    end
  end

  if not is_type then
    local func_name = debug.getinfo(2).name
    error(("%s: wrong argument type `%s' #%d (expected `%s')")
      :format(func_name, tagen.type(val), n, table.concat(types, ","), lev or 2))
  end

  if verify and not verify(val) then
    error(("argument %d: '%s' %s"):format(n,val,msg),lev or 2)
  end
end

--- end this program gracefully.
-- @param code The exit code or a message to be printed
-- @param ... extra arguments for message's format'
-- @see tagen.fprintf
function tagen.quit(code,...)
  if type(code) == 'string' then
    tagen.fprintf(io.stderr,code,...)
    code = -1
  else
    tagen.fprintf(io.stderr,...)
  end
  io.stderr:write('\n')
  os.exit(code)
end

--- print an arbitrary number of arguments using a format.
-- @param fmt The format (see string.format)
-- @param ... Extra arguments for format
function tagen.printf(fmt,...)
  tagen.assert_string(1,fmt)
  tagen.fprintf(stdout,fmt,...)
end

--- write an arbitrary number of arguments to a file using a format.
-- @param f File handle to write to.
-- @param fmt The format (see string.format).
-- @param ... Extra arguments for format
function tagen.fprintf(f,fmt,...)
  tagen.assert_string(2,fmt)
  f:write(string.format(fmt,...))
end

local function import_symbol(T,k,v,libname)
  local key = rawget(T,k)
  -- warn about collisions!
  if key and k ~= '_M' and k ~= '_NAME' and k ~= '_PACKAGE' and k ~= 'VERSION' then
    tagen.printf("warning: '%s.%s' overrides existing symbol\n",libname,k)
  end
  rawset(T,k,v)
end

local function lookup_lib(T,t)
  for k,v in pairs(T) do
    if v == t then return k end
  end
  return '?'
end

local already_imported = {}

--- take a table and 'inject' it into the local namespace.
-- tagen.import()
-- tagen.import(t, T)
-- @param t The Table
-- @param T An optional destination table (defaults to callers environment)
function tagen.import(t,T)
  T = T or _G
  t = t or global
  if type(t) == 'string' then
    t = require (t)
  end
  local libname = lookup_lib(T,t)
  if already_imported[t] then return end
  already_imported[t] = libname
  for k,v in pairs(t) do
    import_symbol(T,k,v,libname)
  end
end

tagen.patterns = {
  FLOAT = '[%+%-%d]%d*%.?%d*[eE]?[%+%-]?%d*',
  INTEGER = '[+%-%d]%d*',
  IDEN = '[%a_][%w_]*',
  FILE = '[%a%.\\][:%][%w%._%-\\]*'
}

--- escape any 'magic' characters in a string
-- @param s The input string
function tagen.escape(s)
  tagen.assert_string(1,s)
  return (s:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1'))
end

--- return either of two values, depending on a condition.
-- @param cond A condition
-- @param value1 Value returned if cond is true
-- @param value2 Value returned if cond is false (can be optional)
function tagen.choose(cond,value1,value2)
  if cond then return value1
  else return value2
  end
end

local raise

--- return the contents of a file as a string
-- @param filename The file path
-- @param is_bin open in binary mode
-- @return file contents
function tagen.readfile(filename,is_bin)
  local mode = is_bin and 'b' or ''
  tagen.assert_string(1,filename)
  local f,err = io.open(filename,'r'..mode)
  if not f then return tagen.raise (err) end
  local res,err = f:read('*a')
  f:close()
  if not res then return raise (err) end
  return res
end

--- write a string to a file
-- @param filename The file path
-- @param str The string
-- @return true or nil
-- @return error message
-- @raise error if filename or str aren't strings
function tagen.writefile(filename,str)
  tagen.assert_string(1,filename)
  tagen.assert_string(2,str)
  local f,err = io.open(filename,'w')
  if not f then return raise(err) end
  f:write(str)
  f:close()
  return true
end

--- return the contents of a file as a list of lines
-- @param filename The file path
-- @return file contents as a table
-- @raise errror if filename is not a string
function tagen.readlines(filename)
  tagen.assert_string(1,filename)
  local f,err = io.open(filename,'r')
  if not f then return raise(err) end
  local res = {}
  for line in f:lines() do
    table.insert(res,line)
  end
  f:close()
  return res
end

local lua51_load = load

if tagen.lua51 then -- define Lua 5.2 style load()
  function tagen.load(str,src,mode,env)
    local chunk,err
    if type(str) == 'string' then
      chunk,err = loadstring(str,src)
    else
      chunk,err = lua51_load(str,src)
    end
    if chunk and env then setfenv(chunk,env) end
    return chunk,err
  end
else
  tagen.load = load
  -- setfenv/getfenv replacements for Lua 5.2
  -- by Sergey Rozhenko
  -- http://lua-users.org/lists/lua-l/2010-06/msg00313.html
  -- Roberto Ierusalimschy notes that it is possible for getfenv to return nil
  -- in the case of a function with no globals:
  -- http://lua-users.org/lists/lua-l/2010-06/msg00315.html
  function setfenv(f, t)
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
    local name
    local up = 0
    repeat
      up = up + 1
      name = debug.getupvalue(f, up)
    until name == '_ENV' or name == nil
    if name then
      debug.upvaluejoin(f, up, function() return name end, 1) -- use unique upvalue
      debug.setupvalue(f, up, t)
    end
    if f ~= 0 then return f end
  end

  function getfenv(f)
    local f = f or 0
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
    local name, val
    local up = 0
    repeat
      up = up + 1
      name, val = debug.getupvalue(f, up)
    until name == '_ENV' or name == nil
    return val
  end
end


--- execute a shell command.
-- This is a compatibility function that returns the same for Lua 5.1 and Lua 5.2
-- @param cmd a shell command
-- @return true if successful
-- @return actual return code
function tagen.execute (cmd)
  local res1,res2,res2 = os.execute(cmd)
  if lua51 then
    return res1==0,res1
  else
    return res1,res2
  end
end

if lua51 then
  function table.pack (...)
    local n = select('#',...)
    return {n=n; ...}
  end
  local sep = package.config:sub(1,1)
  function package.searchpath (mod,path)
    mod = mod:gsub('%.',sep)
    for m in path:gmatch('[^;]+') do
      local nm = m:gsub('?',mod)
      local f = io.open(nm,'r')
      if f then f:close(); return nm end
    end
  end
end

if not table.pack then table.pack = _G.pack end
if not rawget(_G,"pack") then _G.pack = table.pack end

--- take an arbitrary set of arguments and make into a table.
-- This returns the table and the size; works fine for nil arguments
-- @param ... arguments
-- @return table
-- @return table size
-- @usage local t,n = tagen.args(...)

--[[
--- 'memoize' a function (cache returned value for next call).
-- This is useful if you have a function which is relatively expensive,
-- but you don't know in advance what values will be required, so
-- building a table upfront is wasteful/impossible.
-- @param func a function of at least one argument
-- @return a function with at least one argument, which is used as the key.
function tagen.memoize(func)
  return setmetatable({}, {
    __index = function(self, k, ...)
      local v = func(k,...)
      self[k] = v
      return v
    end,
    __call = function(self, k) return self[k] end
  })
end
--]]


tagen.stdmt = {
  List = {_name='List'}, Map = {_name='Map'},
  Set = {_name='Set'}, MultiMap = {_name='MultiMap'}
}

local _function_factories = {}

--- associate a function factory with a type.
-- A function factory takes an object of the given type and
-- returns a function for evaluating it
-- @param mt metatable
-- @param fun a callable that returns a function
function tagen.add_function_factory (mt,fun)
  _function_factories[mt] = fun
end

local function _string_lambda(f)
  local raise = tagen.raise
  if f:find '^|' or f:find '_' then
    local args,body = f:match '|([^|]*)|(.+)'
    if f:find '_' then
      args = '_'
      body = f
    else
      if not args then return raise 'bad string lambda' end
    end
    local fstr = 'return function('..args..') return '..body..' end'
    local fn,err = loadstring(fstr)
    if not fn then return raise(err) end
    fn = fn()
    return fn
  else return raise 'not a string lambda'
  end
end

--- an anonymous function as a string. This string is either of the form
-- '|args| expression' or is a function of one argument, '_'
-- @param lf function as a string
-- @return a function
-- @usage string_lambda '|x|x+1' (2) == 3
-- @usage string_lambda '_+1 (2) == 3
-- @function tagen.string_lambda
--tagen.string_lambda = tagen.memoize(_string_lambda)
tagen.string_lambda = tagen._string_lambda

local ops

--- process a function argument.
-- This is used throughout Penlight and defines what is meant by a function:
-- Something that is callable, or an operator string as defined by <code>tagen.operator</code>,
-- such as '>' or '#'. If a function factory has been registered for the type, it will
-- be called to get the function.
-- @param idx argument index
-- @param f a function, operator string, or callable object
-- @param msg optional error message
-- @return a callable
-- @raise if idx is not a number or if f is not callable
-- @see tagen.is_callable
function tagen.function_arg(idx,f,msg)
  tagen.assert_arg(1,idx,'number')
  local tp = type(f)
  if tp == 'function' then return f end  -- no worries!
  -- ok, a string can correspond to an operator (like '==')
  if tp == 'string' then
    if not ops then ops = require 'tagen.operator'.optable end
    local fn = ops[f]
    if fn then return fn end
    local fn, err = tagen.string_lambda(f)
    if not fn then error(err..': '..f) end
    return fn
  elseif tp == 'table' or tp == 'userdata' then
    local mt = getmetatable(f)
    if not mt then error('not a callable object',2) end
    local ff = _function_factories[mt]
    if not ff then
      if not mt.__call then error('not a callable object',2) end
      return f
    else
      return ff(f) -- we have a function factory for this type!
    end
  end
  if not msg then msg = " must be callable" end
  if idx > 0 then
    error("argument "..idx..": "..msg,2)
  else
    error(msg,2)
  end
end

--- bind the first argument of the function to a value.
-- @param fn a function of at least two values (may be an operator string)
-- @param p a value
-- @return a function such that f(x) is fn(p,x)
-- @raise same as @{function_arg}
-- @see tagen.func.curry
function tagen.bind1 (fn,p)
  fn = tagen.function_arg(1,fn)
  return function(...) return fn(p,...) end
end

--- bind the second argument of the function to a value.
-- @param fn a function of at least two values (may be an operator string)
-- @param p a value
-- @return a function such that f(x) is fn(x,p)
-- @raise same as @{function_arg}
function tagen.bind2 (fn,p)
  fn = tagen.function_arg(1,fn)
  return function(x,...) return fn(x,p,...) end
end



local err_mode = 'default'

--- control the error strategy used by Penlight.
-- Controls how <code>tagen.raise</code> works; the default is for it
-- to return nil and the error string, but if the mode is 'error' then
-- it will throw an error. If mode is 'quit' it will immediately terminate
-- the program.
-- @param mode - either 'default', 'quit'  or 'error'
-- @see tagen.raise
function tagen.on_error (mode)
  err_mode = mode
end

--- used by Penlight functions to return errors.  Its global behaviour is controlled
-- by <code>tagen.on_error</code>
-- @param err the error string.
-- @see tagen.on_error
function tagen.raise (err)
  if err_mode == 'default' then return nil,err
  elseif err_mode == 'quit' then tagen.quit(err)
  else error(err,2)
  end
end

raise = tagen.raise

-- ¤Object

function tagen.to_s(obj)
  if obj == nil then
    return ""
  elseif tagen.kind_of(obj, "instance") and obj.to_s then
    return obj:to_s()
  else
    return tostring(obj)
  end
end

function tagen.inspect(obj)
  if type(obj) == "string" then
    return string.format("%q", obj)
  elseif tagen.kind_of(obj, "instance") and obj.inspect then
    return obj:inspect()
  else
    return tostring(obj)
  end
end

-- <=>
function tagen.comp(a, b)
  if a > b then
    return 1
  elseif a == b then
    return 0
  else
    return -1
  end
end

-- table merge util.
-- @protected
function tagen.merge(t1, t2)
  for k, v in pairs(t2) do
    t1[k] = v
  end
end

-- Dependencies: `tagen.path`
function tagen.require_relative(path)
  local path = require("tagen.path")

  local source = debug.getinfo(2).short_src
  local path = path.absolute(path.dirname(source)..path)

  print("real_path", path)

  return require(path)
end

--
-- Pretty print / format class
--

-- TODO: print memoize func error.

local identifier = "^[_%a][_%w]*$"

-- trim whitespace from both ends of a string
local function trim(str)
    return str:gsub("^%s*(.-)%s*$", "%1")
end

-- function varsub(str, repl)
-- replaces variables in strings like "%20s{foo} %s{bar}" using the table repl
-- to look up replacements. use string:format patterns followed by {variable}
-- and pass the variables in a table like { foo="FOO", bar="BAR" }
-- variable names need to match Lua identifiers ([_%a][_%w]-)
-- missing variables or errors in formatting will result in empty strings
-- being inserted for the corresponding placeholder pattern
local function varsub(str, repl)
    return str:gsub("(%%.-){([_%a][_%w]-)}", function(f,k)
        local r, ok = repl[k]
        ok, r = pcall(format, f, r)
        return ok and r or ""
    end)
end

-- encodes a string as you would write it in code,
-- escaping control and other special characters
local function escape_string(str)
    local es_repl = { ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t",
        ["\\"] = "\\\\", ['"'] = '\\"' }
    str = str:gsub('(["\r\n\t\\])', es_repl)
    str = str:gsub("(%c)", function(c)
        return string.format("\\%d", c:byte())
    end) 
    return string.format('"%s"', str)
end


local Pretty = {}

Pretty.defaults = {
  items = 100,          -- max number of items to list in one table
  depth = 7,          -- max recursion depth when printing tables 
  len = 80,           -- max line length hint
  delim1 = ", ",        -- item delimiter (single line / compact)
  delim2 = ", ",        -- item delimiter (multiline)
  indent1 = "  ",       -- string repeated each indent level
  indent2 = "  ",       -- string used to indent final level
  indent3 = "  ",       -- string used to indent final level continuation
  empty = "{ }",        -- string used for empty table 
  bl = "{ ",          -- table braces, single line mode 
  br = " }",
  bl_m = "{\n",         -- table braces, multiline mode, substitution available:
  br_m = "\n%s{i}}",      -- %s{i}, %s{i1}, %s{i2}, %s{i3} are calulated indents 
  eol = "\n",           -- end of line (multiline)
  sp = " ",           -- used other places where spacing might be desired but optional 
  eq = " = ",           -- table equals string value (printed as key..eq..value)
  key = false,          -- format of key in field (set to pattern to enable)
  value = false,        -- format of value in field (set to pattern to enable)
  field = "%s",         -- format of field (which is either "k=v" or "v", with delimiter)
  tstr = true,          -- use to tostring(table) if table has meta __tostring
  table_info = false,       -- show the table info (usually a hex address)
  function_info = false,    -- show the function info (similar to table_info)
  metatables = false,       -- show metatables when printing tables
  multiline = true,       -- set to false to disable multiline output
  compact = true,         -- will compact leaf tables in multiline mode
}

Pretty.__call = function(self, ...)
  self:print(...)
end

function Pretty:new(params)
  local obj = {}
  params = params or {}
  setmetatable(obj, self)
  self.__index = self
  obj:init(params)
  return obj
end

function Pretty:init(params)
  for k, v in pairs(self.defaults) do
    self[k] = v
  end
  for k, v in pairs(params) do
    self[k] = v
  end
  self.print_handlers = self.print_handlers or {} 
  self:reset_seen()
end


function Pretty:reset_seen()
  self.seen = {}
  setmetatable(self.seen, { __do_not_enter = "<< ! >>" })
end

function Pretty:table2str(tbl, path, depth, multiline)
  -- don't print tables we've seen before
  for p, t in pairs(self.seen) do
    if tbl == t then
      local tinfo = self.table_info and tostring(tbl) or p
      return string.format("<< %s >>", tinfo)
    end
  end
  -- max_depth
  self.seen[path] = tbl
  if depth >= self.depth then
    return ">>>"
  end
  return self:table_children2str(tbl, path, depth, multiline)
end

-- this sort function compares table keys to allow a sort by key 
-- the order is: numeric keys, string keys, other keys(converted to string) 
function Pretty.key_cmp(a, b)
  local at = type(a)
  local bt = type(b)
  if at == "number" then
    if bt == "number" then
      return a < b
    else
      return true
    end
  elseif at == "string" then
    if bt == "string" then
      return a < b
    elseif bt == "number" then
      return false
    else
      return true
    end
  else
    if bt == "string" or bt == "number" then
      return false
    else
      return tostring(a) < tostring(b)
    end
  end
end

-- returns an iterator to sort by table keys using func
-- as the comparison func. defaults to Pretty.key_cmp
function Pretty.pairs_by_keys(tbl, func)
  func = func or Pretty.key_cmp
  local a = {}
  for n in pairs(tbl) do a[#a + 1] = n end
  table.sort(a, func)
  local i = 0
  return function ()  -- iterator function
    i = i + 1
    return a[i], tbl[a[i]]
  end
end

function Pretty:table_children2str(tbl, path, depth, multiline)
  local ind1, ind2, ind3  = "", "", ""
  local delim1, delim2 = self.delim1, self.delim2
  local sp, eol, eq = self.sp, self.eol, self.eq
  local bl, br = self.bl, self.br
  local bl_m, br_m = self.bl_m, self.br_m
  local tinfo = self.table_info and tostring(tbl)..sp or ""
  local key_fmt, val_fmt, field = self.key, self.val, self.field
  local compactable, cnt, c = 0, 0, {}
  -- multiline setup
  if multiline then
    ind1 = self.indent1:rep(depth)
    ind2 = ind1 .. self.indent2
    ind3 = ind1 .. self.indent3
    local irepl = { i=ind1, i1=ind1, i2=ind2, i3=ind3 }
    bl_m, br_m = varsub(bl_m, irepl), varsub(br_m, irepl)
  end
  -- metatable
  if self.metatables then
    local mt = getmetatable(tbl)
    if mt then
      table.insert(c, "<metatable>".. self.eq .. self:val2str(mt,
        path .. (path == "" and "" or ".") .. "<metatable>", depth + 1, multiline))
    end
  end

  -- process child nodes, sorted
  local last = nil
  for k, v in Pretty.pairs_by_keys(tbl, self.sort_function) do
    -- item limit
    if self.items and cnt >= self.items then
      table.insert(c, "...")
      compactable = compactable + 1
      break
    end      
    -- determine how to display the key. array part of table will show no keys
    local print_index = true
    local print_brackets = true
    if type(k) == "number" then
      if (last and k > 1 and k == last + 1) or (not last and k == 1) then
        print_index = false
        last = k
      else
        last = false
      end
    else
      last = nil
    end
    local key = tostring(k) 
    if type(k) == "string" then
      if k:match(identifier) then
        print_brackets = false
      else
        key = escape_string(key) 
      end
    end
    if print_brackets then
      key = '[' .. key .. ']'
    end
    -- format val
    local val = self:val2str(v,
      path .. (path == "" and "" or ".") .. key, depth + 1, multiline)
    if not val:match("[\r\n]") then
      compactable = compactable + 1
    end
    if val_fmt then
      val = val_fmt:format(val)
    end
    -- put the pieces together
    local out = ""
    if key_fmt then
      key = key_fmt:format(key)
    end
    if print_index then
      out = key .. eq .. val
    else
      out = val
    end
    table.insert(c, out)
    cnt = cnt + 1
  end

  -- compact
  if multiline and self.compact and #c > 0 and compactable == #c then
    local lines = {}
    local line = "" 
    for i, v in ipairs(c) do
      local f = field:format(v .. (i == cnt and "" or delim1))
      if line == "" then
        line = ind2 .. f
      elseif #line + #f <= self.len then
        line = line .. f 
      else
        table.insert(lines, line)
        line = ind3 .. f
      end
    end
    table.insert(lines, line)
    return tinfo .. bl_m .. table.concat(lines, eol) .. br_m
  elseif #c == 0 then -- empty
    return tinfo .. self.empty
  elseif multiline then -- multiline
    local c2 = {}
    for i, v in ipairs(c) do
      table.insert(c2, ind2 .. field:format(v .. (i == cnt and "" or delim2)))
    end
    return tinfo .. bl_m .. table.concat(c2, eol) .. br_m
  else -- single line
    local c2 = {}
    for i, v in ipairs(c) do
      table.insert(c2, field:format(v .. (i == cnt and "" or delim1)))
    end
    return tinfo .. bl .. table.concat(c2) .. br
  end
end

function Pretty:val2str(val, path, depth, multiline)
  local tp = type(val)
  if self.print_handlers[tp] then
    local s = self.print_handlers[tp](val)
    return s or '?'
  end
  if tp == 'function' then
    return self.function_info and tostring(val) or "function"
  elseif tp == 'table' then
    local mt = getmetatable(val)
    if mt and mt.__do_not_enter then
      return mt.__do_not_enter
    elseif self.tstr and mt and mt.__tostring then
      return tostring(val)
    else
      return self:table2str(val, path, depth, multiline)
    end
  elseif tp == 'string' then
    return escape_string(val)
  elseif tp == 'number' then
    -- we try only to apply floating-point precision for numbers deemed to be floating-point,
    -- unless the 3rd arg to precision() is true.
    if self.num_prec and (self.num_all or math.floor(val) ~= val) then
      return self.num_prec:format(val)
    else
      return tostring(val)
    end
  else
    return tostring(val)
  end
end

function Pretty:format(...)
  local out, v = "", nil
  -- first try single line output
  self:reset_seen()
  for i = 1, select("#", ...) do
    v = select(i, ...)
    out = string.format("%s%s ", out, self:val2str(v, "", 0, false))
  end
  -- if it is too long, use multiline mode, if enabled
  if self.multiline and #out > self.len then
    out = ""
    self:reset_seen()
    for i = 1, select("#", ...) do
      v = select(i, ...)
      out = string.format("%s%s\n", out, self:val2str(v, "", 0, true))
    end
  end
  self:reset_seen()
  return trim(out)
end

function Pretty:print(...)
  local output = self:format(...)
  if self.output_handler then
    self.output_handler(output)
  else
    if output and output ~= "" then
      print(output)
    end
  end
end

tagen.p = Pretty:new { output_handler = oh }
tagen.ls = Pretty:new { compact=true, depth=1, output_handler = oh }
tagen.dir = Pretty:new { compact=false, depth=1, key="%-20s",
    function_info=true, table_info=true, output_handler = oh }
tagen.pd = tagen.p

-- fill global
local globals = {
  "p", "pd", "ls", "dir", "printf", "sprintf", "quit",
  "assert_arg",
}
for _, meth in ipairs(globals) do
  global[meth] = tagen[meth]
end

--- load a code string or bytecode chunk.
-- @param code Lua code as a string or bytecode
-- @param name for source errors
-- @param mode kind of chunk, 't' for text, 'b' for bytecode, 'bt' for all (default)
-- @param env  the environment for the new chunk (default nil)
-- @return compiled chunk
-- @return error message (chunk is nil)
-- @function tagen.load


--- Lua 5.2 Compatible Functions
-- @section lua52

--- pack an argument list into a table.
-- @param ... any arguments
-- @return a table with field n set to the length
-- @return the length
-- @function table.pack

------
-- return the full path where a Lua module name would be matched.
-- @param mod module name, possibly dotted
-- @param path a path in the same form as package.path or package.cpath
-- @see path.package_path
-- @function package.searchpath

return tagen
