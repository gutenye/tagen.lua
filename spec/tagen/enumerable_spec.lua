require "spec_helper"
require "tagen.mixin" -- for include


local User = class("User")
local user = User:new()
local ret
function User:each(func)
  local ret, a,b,c
  for i, v in ipairs(self.data) do
    ret, a,b,c = func(v, i)
    if ret == BREAK then
      return a, b, c
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

  describe ["#max"] = function()
    it ["return max value"] = function()
      user.data = {2, 7, 3, 1}
      expect(user:max()).to_be(7)
    end

    it ["can call with func"] = function()
      user.data = {2, 7, 3, 1}

      ret = user:max(function(max,v)
        if v == 3 then
          return 1
        else
          return -1
        end
      end)

      expect(ret).to_equal(3)
    end
  end

  describe ["#min"] = function()
    it ["return min value"] = function()
      user.data = {2, 7, 3, 1}
      expect(user:min()).to_be(1)
    end

    it ["can call with a function"] = function()
      user.data = {2, 7, 3, 1}

      ret = user:min(function(min,v)
        if v == 7 then
          return -1
        else
          return 1
        end
      end)

      expect(ret).to_equal(7)
    end
  end

  describe ["#count"] = function()
    it ["a object"] = function()
      user.data = {2, 1, 1, 3, 1}
      expect(user:count(1)).to_equal(3)
    end

    it ["can call with a function"] = function()
      user.data = {2, 1, 1, 3, 1}

      ret = user:count(function(v)
        return v >= 2
      end)

      expect(ret).to_equal(2)
    end
  end

  describe ["#map"] = function()
    it ["works"] = function()
      user.data = {1,2,3}
      ret = user:map(function(v)
        return v + 1
      end)

      expect(ret).to_equal(Array:new{2, 3, 4})
    end
  end

  describe ["#each_cons"] = function()
    it ["iterate for consecutive elements"] = function()
      user.data = {1,2,3}
      ret = Array{}

      user:each_cons(2, function(v)
        ret:append(v)
      end)

      expect(ret).to_equal(Array{Array{1,2}, Array{2,3}})
    end

    it ["return an enumerator when func not given"] = function()
      user.data = {1,2,3}
      expect(tagen.instance_of(user:each_cons(2), Enumerator)).to_be_true()
    end
  end

  describe ["#each_slice"] = function()
    it ["iterate for each slice of <n> elemnts"] = function()
      user.data = {1,2,3}
      ret = Array{}

      user:each_slice(2, function(v)
        ret:append(v)
      end)

      expect(ret).to_equal(Array{Array{1,2},Array{3}})
    end

    it ["return an enumerator when func not given"] = function()
      user.data = {1,2,3}
      expect(tagen.instance_of(user:each_slice(2), Enumerator)).to_be_true()
    end
  end

  describe ["#first"] = function()
    it ["return first <n> elements"] = function()
      user.data = {1,2,3}
      expect(user:first(2)).to_equal(Array{1,2})
    end

    it ["default n is 1"] = function()
      user.data = {1,2,3}
      expect(user:first()).to_equal(1)
    end
  end

  describe ["#find"] = function()
    it ["find an element"] = function()
      user.data = {1,2,3}

      ret = user:find(function(v)
        return v == 2
      end)

      expect(ret).to_equal(2)
    end

    it ["return false when not found"] = function()
      user.data = {1,2,3}

      ret = user:find(function(v)
        return v > 4
      end)

      expect(ret).to_be_nil()
    end
  end

  describe ["#find_all"] = function()
    it ["find all element"] = function()
      user.data = {1, 3, 2}

      ret = user:find_all(function(v)
        return v < 3 
      end)

      expect(ret).to_equal(Array{1,2})
    end

    it ["return an empty array when not found"] = function()
      user.data = {1, 3, 2}

      ret = user:find_all(function(v)
        return v > 3
      end)

      expect(ret).to_equal(Array{})
    end
  end

  describe ["#find_index"] = function()
    it ["find first index of the element"] = function() 
      user.data = {11, 12, 13, 12}

      ret = user:find_index(12)
      expect(ret).to_equal(2)
    end

    it ["can call with func"] = function() 
      user.data = {11, 12, 13, 12}

      ret = user:find_index(function(v)
        return v == 12
      end)

      expect(ret).to_equal(2)
    end

    it ["return nil when not found"] = function()
      user.data = {11, 12, 13, 12}

      ret = user:find_index(function(v)
        return v == 14
      end)

      expect(ret).to_be_nil()
    end
  end
end

