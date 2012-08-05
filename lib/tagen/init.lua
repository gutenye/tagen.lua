--- Entry point for loading all Tagen libraries only on demand.
-- Requiring "tagen" means that whenever a module is implicitly accesssed
-- (e.g. `tagen.split`)
-- then that module is dynamically loaded. The submodules are all brought into
-- the global space.
-- @module tagen

local modules = {
  core="tagen", class="class", mixin="mixin", 
  stringx="stringx", Array="array", Enumerable="enumerable", 
  Enumerator="enumerator", Hash="hash", Regexp="regexp",

  test="test", app="app", file="file", 
  path="path", dir="dir", tablex="tablex", stringio="stringio", sip="sip",
  input="input", seq="seq", lexer="lexer",
  config="config", pretty="pretty", data="data", func="func", text="text",
  operator="operator", lapp="lapp",
  comprehension="comprehension", xml="xml",
  Map="map", Set="set", OrderedMap="ordered_map", MultiMap="multi_map",
  date="date"
}
_G.tagen = require("tagen.core")

--[[
for name,klass in pairs(_G.tagen.stdmt) do
  klass.__index = function(t,key)
    return require ("tagen."..name)[key]
  end;
end
--]]

-- ensure that we play nice with libraries that also attach a metatable
-- to the global table; always forward to a custom __index if we don't
-- match

local _hook,_prev_index
local gmt = {} -- _G's mt
local prev_gmt = getmetatable(_G)
if prev_gmt then
  _prev_index = prev_gmt.__index
  if prev_gmt.__newindex then
    gmt.__index = prev_gmt.__newindex
  end
end

function gmt.hook(handler)
  _hook = handler
end

function gmt.__index(t, name)
  local fname = modules[name]
  -- either true, or the name of the module containing this class.
  -- either way, we load the required module and make it globally available.
  if fname then
    -- e..g pretty.dump causes tagen.pretty to become available as "pretty"
    -- compablity with return class, mixin
    rawset(_G, name, require("tagen."..fname))
    return _G[name]
  else
    local res
    if _hook then
      res = _hook(t,name)
      if res then return res end
    end
    if _prev_index then
      return _prev_index(t,name)
    end
  end
end

setmetatable(_G, gmt)

if rawget(_G, "PENLIGHT_STRICT") then require("tagen.strict") end
