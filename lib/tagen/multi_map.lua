--- MultiMap, a Map which has multiple values per key.
--
-- Dependencies: `tagen.core`, `tagen.class`, `tagen.tablex`, `tagen.list`
-- @module tagen.multi_map

local classes = require 'tagen.class'
local tablex = require 'tagen.tablex'
local tagen = require 'tagen.core'
local List = require 'tagen.list'

local index_by,tsort,concat = tablex.index_by,table.sort,table.concat
local append,extend,slice = List.append,List.extend,List.slice
local append = table.insert
local is_type = tagen.is_type

local class = require 'tagen.class'
local Map = require 'tagen.map'

-- MultiMap is a standard MT
local MultiMap = tagen.stdmt.MultiMap

class(Map,nil,MultiMap)
MultiMap._name = 'MultiMap'

function MultiMap:_init (t)
  if not t then return end
  self:update(t)
end

--- update a MultiMap using a table.
-- @param t either a Multimap or a map-like table.
-- @return the map
function MultiMap:update (t)
  tagen.assert_arg(1,t,'table')
  if Map:class_of(t) then
    for k,v in pairs(t) do
      self[k] = List()
      self[k]:append(v)
    end
  else
    for k,v in pairs(t) do
      self[k] = List(v)
    end
  end
end

--- add a new value to a key.  Setting a nil value removes the key.
-- @param key the key
-- @param val the value
-- @return the map
function MultiMap:set (key,val)
  if val == nil then
    self[key] = nil
  else
    if not self[key] then
      self[key] = List()
    end
    self[key]:append(val)
  end
end

return MultiMap
