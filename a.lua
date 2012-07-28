#!/usr/bin/env lua
package.path = "./lib/?.lua;./lib/?/init.lua;" .. package.path

tagen = require "tagen.core"
--tagen.import()
class = require "tagen.class"
pretty = require "pl.pretty"
pd2 = function(...) print(pretty.write(...)) end
pd = print

---
---
---
User = class("User")
Student = class("Student", User)
--pd2(Student)
tagen.pd(Student)

function User.static:echo()
  print("User.echo")
end

-- self is User.__methods
function User.static:set_b(v)
  print("User.set_b", self, v)
  pd2(self)
  self._b = v
  return v
end

function User.static:get_b()
  print("User.get_b", self)
  pd2(self)
  return self._b
end

User.echo()
Student.echo()

--[[ property
User.static.a = 1
print(User.a)

User.static.b = 2
print(User.b)
--]]

---

function User:initialize()
  self._ua = "a"
  self.ub = "b"
  print("User:initialize")
end

function User:echo2()
  print("User:echo2")
end

function User:set_b(v)
  print("User:set_b", self, v)
  self._b = v
  return v
end

function User:get_b()
  print("User:get_b", self)
  return self._b
end

function Student:initialize()
  self:super()
  print("Student:initialize")
end

function Student:echo2()
  self:super()
  print("Student:echo2")
end

local user = User:new()
local student = Student:new()
student:echo2()

---[[property
user.a = 11
pd(user.a)

user.b = 12
pd(user.b)
--]]




