require "spec_helper" 

local User, Userable, Student, Studentable, Foo, Fooable
local user, student, foo, callable

describe["tagen"] = function()
  describe [".type"] = function()
    before = function()
      User = class("User")
      Userable = mixin("Userable")
    end
    
    it ["return the type"] = function()
      expect(tagen.type(User)).to_equal("class")
      expect(tagen.type(User:new())).to_equal("User")
      expect(tagen.type(Userable)).to_equal("mixin")
      expect(tagen.type("a")).to_equal("string")
      expect(tagen.type(1)).to_equal("number")
    end
  end

  describe [".kind_of"] = function()
    before = function()
      User = class("User")
      Userable = mixin("Userable")
      Student = class("Student", User)
      Studentable = mixin("Studentable")
      Foo = class("Foo")
      Fooable = class("Fooable")

      User:include(Userable)
      Student:include(Studentable)
      student = Student:new()

      callable = setmetatable({}, {__call = function() end})
    end

    it ["return true if x was create from it's class"] = function()
      expect(tagen.kind_of(student, Student)).to_be_true()
    end

    it ["return true if x is in it's inheritance"] = function()
      expect(tagen.kind_of(student, User)).to_be_true()
    end

    it ["return true if x is a module included by it's class"] = function()
      expect(tagen.kind_of(student, Studentable)).to_be_true()
    end

    it ["return true if x is a module included by it's acenstores"] = function()
      expect(tagen.kind_of(student, Userable)).to_be_true()
    end

    it ["support string, ..."]  = function()
      expect(tagen.kind_of("a", "string")).to_be_true()
      expect(tagen.kind_of(1, "number")).to_be_true()
    end

    it ["extra support class, ..."] = function()
      expect(tagen.kind_of(1, "object")).to_be_true()
      expect(tagen.kind_of(nil, "object")).to_be_false()

      expect(tagen.kind_of(User, "class")).to_be_true()
      expect(tagen.kind_of(User:new(), "instance")).to_be_true()

      expect(tagen.kind_of(Userable, "mixin")).to_be_true()

      expect(tagen.kind_of(callable, "callable")).to_be_true()
      expect(tagen.kind_of(function() end, "callable")).to_be_true()

      expect(tagen.kind_of(1, "integer")).to_be_true()
      expect(tagen.kind_of(1.1, "interger")).to_be_false()
    end
  end

  describe [".instance_of"] = function()
    before = function()
      User = class("User")
      user = User:new()
    end

    it ["return true if user was created from User"] = function()
      expect(tagen.instance_of(user, User)).to_be_true()
    end

    it ["return false otherwise"] = function()
      expect(tagen.instance_of(user, Object)).to_be_false()
      expect(tagen.instance_of({}, User)).to_be_false()
      expect(tagen.instance_of(1, User)).to_be_false()
    end
  end

  describe [".merge"] = function()
    it ["works"] = function()
      local a = {a=1, b=2}
      local b = {a=7, c=3}

      tagen.merge(a, b)

      expect(a.a).to_equal(7)
      expect(a.b).to_equal(2)
      expect(a.c).to_equal(3)
    end
  end

  describe [".to_s"] = function()
    it ["return empty string when nil"] = function()
      expect(tagen.to_s(nil)).to_equal("")
    end

    it ["call obj#to_s when an object"] = function()
      User = class("User")
      function User:to_s()
        return "User#to_s"
      end

      user = User:new()

      expect(tagen.to_s(user)).to_equal("User#to_s")
    end

    it ["call tostring otherwise"] = function()
      expect(tagen.to_s("a")).to_equal("a")
      expect(tagen.to_s(1)).to_equal("1")
      expect(tagen.to_s(true)).to_equal("true")
    end
  end

  describe [".inspect"] = function()
    it ["quote the string when string"] = function()
      expect(tagen.inspect("a")).to_equal('"a"')
    end

    it ["call obj#inspect when an object"] = function()
      User = class("User")
      function User:inspect()
        return "User#inspect"
      end

      user = User:new()

      expect(tagen.inspect(user)).to_equal("User#inspect")
    end

    it ["call tostring otherwise"] = function()
      expect(tagen.inspect(nil)).to_equal("nil")
      expect(tagen.inspect(1)).to_equal("1")
      expect(tagen.inspect(true)).to_equal("true")
    end
  end

  describe [".comp"] = function()
    it ["return 1 when a > b"] = function()
      expect(tagen.comp(2, 1)).to_equal(1)
      expect(tagen.comp("b", "a")).to_equal(1)
    end

    it ["return 0 when a == b"] = function()
      expect(tagen.comp(1, 1)).to_equal(0)
      expect(tagen.comp("a", "a")).to_equal(0)
    end

    it ["return -1 when a < b"] = function()
      expect(tagen.comp(1, 2)).to_equal(-1)
      expect(tagen.comp("a", "b")).to_equal(-1)
    end
  end
end

