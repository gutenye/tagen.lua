require "spec_helper"
require "tagen.mixin" -- for include


local User = class("User")
local user = User:new()
function User:each(func)
  local ret, a,b,c
  for i, v in ipairs(self.data) do
    ret, a,b,c = func(v, i)
    if ret == BREAK then
      break
    elseif ret == RETURN then
      return a,b,c
    end
  end
end
User:include(Enumerable)

describe ["Enumerable"] = function()
  describe ["#include"] = function()
    it ["return true if it includes an obj"] = function()
      user.data = {11, 12}
      expect(user:include(12)).to_be_true()
    end

    it ["return false otherwise"] = function()
      user.data = {11}
      expect(user:include(15)).to_be_false()
    end
  end

  describe ["#all"] = function()
    it ["return true if all the values are true"] = function()  
      user.data = {11, true}
      expect(user:all()).to_be_true()
    end

    it ["return false if one value is not true"] = function()
      user.data = {true, false}
      expect(user:all()).to_be_false()
    end
  end

  describe ["#none"] = function()
    it ["return true if none value is true"] = function()  
      user.data = {false, nil}
      expect(user:none()).to_be_true()
    end

    it ["return false if one value is true"] = function()
      user.data = {false, true}
      expect(user:none()).to_be_false()
    end
  end

  describe ["#any"] = function()
    it ["return true if any value is true"] = function()  
      user.data = {false, true}
      expect(user:any()).to_be_true()
    end

    it ["return false if none value is true"] = function()
      user.data = {false, false}
      expect(user:any()).to_be_false()
    end
  end

  describe ["#one"] = function()
    it ["return true if only one value is true"] = function()  
      user.data = {false, true, false}
      expect(user:one()).to_be_true()
    end

    it ["return false if more than one value is true or all values are false"] = function()
      user.data = {true, true}
      expect(user:one()).to_be_false()

      user.data = {false, false}
      expect(user:one()).to_be_false()

      user.data = {true, true, false}
      expect(user:one()).to_be_false()
    end
  end
end

