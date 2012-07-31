require "spec_helper" 

local User
local user

describe["tagen"] = function()
  describe [".instance_of"] = function()
    before = function()
      User = class("User")
      user = User:new()
    end

    it ["return true when x is an instance of a class"] = function()
      expect(tagen.instance_of(user, User)).to_equal(true)
    end

    it ["return false otherwise"] = function()
      expect(tagen.instance_of({}, User)).to_equal(false)
      expect(tagen.instance_of(1, User)).to_equal(false)
    end
  end

  describe [".kind_of"] = function()
    before = function()
      User = class("User")
      user = User:new()
    end

    it ["return true when x is kind of a class"] = function()
      expect(tagen.kind_of(user, Object)).to_equal(true)
    end

    it ["return false otherwise"] = function()
      expect(tagen.kind_of({}, User)).to_equal(false)
      expect(tagen.kind_of(1, User)).to_equal(false)
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
end
