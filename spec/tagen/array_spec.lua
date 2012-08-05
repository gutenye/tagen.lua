require "spec_helper"

local a,b,c,d,ret

describe ["Array"] = function()
  describe ["#initialize"] = function()
    it ["create a empty array"] = function()
      a = Array:new()
      expect(a:length()).to_equal(0)
    end

    it ["create an array from table"] = function()
      a = Array:new({1, 2})

      expect(a[1]).to_equal(1)
      expect(a[2]).to_equal(2)
    end

    it ["create an array from another array"] = function()
      a = Array:new({1, 2})
      b = Array:new(a)
      expect(b:length()).to_equal(2)
    end
  end


  --
  -- core methods
  --

  describe ["#[]"] = function()
    it ["return the index value"] = function()
      a = Array:new({11, 12})
      expect(a[2]).to_equal(12)
    end

    it ["support -1 index"] = function()
      a = Array:new{11, 12, 13}
      expect(a[-3]).to_equal(11)
    end
  end

  describe ["#[]="] = function()
    it ["set the index to the value"] = function()
      a = Array:new{11, 12, 13}

      a[3] = 9
      expect(a[3]).to_equal(9)
    end

    it ["support -1 index"] = function()
      a = Array:new{11, 12, 13}

      a[-3] = 9
      expect(a[1]).to_equal(9)
    end
  end

  describe ["#__tostring"] = function()
    it ["use inspect to print it's members"] = function()
      a = Array:new({"a", 1})
      b = '["a", 1]'

      expect(a:__tostring()).to_equal(b)
    end
  end

  describe ["#length"] = function()
    it ["return an array length"] = function()
      a = Array:new({1, 2})
      expect(a:length()).to_equal(2)
    end
  end

  describe ["#__eq"] = function()
    it ["return true if equal"] = function()
      a = Array:new({1, 2, 3})
      b = Array:new({1, 2, 3})
      c = Array:new({1, 2})

      expect(a == b).to_be_true()
      expect(a == c).to_be_false()
    end

    it ["return true if array is multi-dimensional"] = function()
      a = Array:new({1, Array:new{11, 12, Array:new{22}}, 2})
      b = Array:new({1, Array:new{11, 12, Array:new{22}}, 2})
      c = Array:new({1, Array:new{11, 12, Array:new{23}}, 2})

      expect(a == b).to_be_true()
      expect(a == c).to_be_false()
    end

    it ["return false otherwise"] = function()
      a = Array:new({1, 2})
      b = Array:new({1, 2, 3})

      expect(a == b).to_be_false()
      expect(a == 1).to_be_false()
    end
  end

  describe ["#insert"] = function()
    it ["insert obj.. into array at pos"] = function() 
      a = Array:new({1, 2})
      b = Array:new({1, 3, 4, 2})

      a:insert(2, 3, 4)
      expect(a).to_equal(b)
    end
  end

  describe ["#delete_at"] = function()
    it ["return delete obj at index and take IN PLACE"] = function()
      a = Array:new{11, 12, 13}
      b = Array:new{11, 13}

      expect(a:delete_at(2)).to_equal(12)
      expect(a).to_equal(b)
    end
  end

  --
  -- ¤begin
  --

  describe ["Array()"] = function()
    it ["call Array.new"] = function()
      a = Array()

      expect(tagen.instance_of(a, Array)).to_be_true()
    end
  end

  describe [".wrap"] = function()
    it ["wrap a single object"] = function()
      a = 1
      b = Array{1}

      expect(Array:wrap(a)).to_equal(b)
    end

    it ["wrap a table"] = function()
      a = {1, 2}
      b = Array{1, 2}

      expect(Array:wrap(a)).to_equal(b)
    end

    it ["wrap an array"] = function()
      a = Array{1, 2}
      b = Array{1, 2}

      expect(Array:wrap(a)).to_equal(b)
    end
  end

  describe ["#dup"] = function()
    it ["duplicate an array"] = function()
      a = Array:new({1, 2})
      b = a:dup()

      b:append("c")
      expect(a:length()).to_equal(2)
      expect(b:length()).to_equal(3)
    end
  end

  describe ["#replace"] = function()
    it ["replace the origin array"] = function()
      a = Array:new({1, 2})
      b = Array:new({1, 2, 3})

      a:replace(b)
      expect(a:length()).to_equal(3)
    end
  end

  describe ["#__add"] = function()
    it ["concat two arrays"] = function()
      a = Array:new{1, 2}
      b = Array:new{3, 4}
      c = Array:new{1, 2, 3, 4}

      d = a + b

      expect(a).to_equal(a)
      expect(b).to_equal(b)
      expect(d).to_equal(c)
    end
  end

  describe ["#is_empty"] = function()
    it ["return true if array is empty"] = function()
      a = Array:new()

      expect(a:is_empty()).to_be_true()
    end

    it ["return false otherwise"] = function()
      a = Array:new{1}

      expect(a:is_empty()).to_be_false()
    end
  end

  describe ["#include"] = function()
    it ["return true if obj is included in array"] = function()
      a = Array:new{1, 2}

      expect(a:include(1)).to_be_true()
    end

    it ["return false otherwise"] = function()
      a = Array:new{1, 2}

      expect(a:include(3)).to_be_false()
    end
  end

  describe ["#count"] = function()
    it ["count the obj's occurrence in an array"] = function()
      a = Array:new{1, 2, 1}

      expect(a:count(1)).to_equal(2)
    end

    it ["call func when given a func"] = function()
      a = Array:new{1, 2, 1, 10}

      ret = a:count(function(v)
        return v < 3
      end)

      expect(ret).to_equal(3)
    end
  end

  --[[
  describe ["#slice"] = function()
    it ["return a object when length is not given"] = function()
      a = Array:new{11, 12, 13}
      expect(a:slice(2)).to_equal(12)
    end

    it ["return a new array when length is given"] = function()
      a = Array:new{1, 2, 3}
      b = Array:new{2}

      ret = a:slice(2, 1)
      expect(a).to_equal(a)
      expect(ret).to_equal(b)
    end

    it ["return nil when index out of range"] = function()
      a = Array:new{11, 12}

      expect(a:slice(9)).to_be_nil()
      expect(a:slice(9,2)).to_be_nil()
    end

    it ["support -1 index"] = function()
      a = Array:new{1, 2, 3}
      b = Array:new{2, 3}

      expect(a:slice(-2, 2)).to_equal(b)
    end
  end

  describe ["#slice1"] = function()
    it ["slice IN PLACE"] = function()
      a = Array:new{1, 2, 3}
      b = Array:new{2, 3}

      a:slice1(2, 2)
      expect(a).to_equal(b)
    end
  end
  --]]

  describe ["at"] = function() 
    it ["return value at index"] = function()
      a = Array:new{11, 12}

      expect(a:at(2)).to_equal(12)
    end

    it ["return -1 index"] = function()
      a = Array:new{11, 12, 13}

      expect(a:at(-2)).to_equal(12)
    end
  end

  describe ["#fetch"] = function()
    it ["fetch an existing value"] = function()
      a = Array:new{11}

      expect(a:fetch(1)).to_equal(11)
    end

    it ["return default if the value is not exist"] = function() 
      a = Array:new{11}

      expect(a:fetch(2, "default")).to_equal("default") 
    end

    it ["the default argument is nil if non-given"] = function()
      a = Array:new{11}

      expect(a:fetch(2)).to_equal(nil)
    end
  end

  describe ["#first"] = function()
    it ["return first item"] = function()
      a = Array:new{11, 12}

      expect(a:first()).to_equal(11)
    end

    it ["return first n items"] = function()
      a = Array:new{11, 12, 13}
      b = Array:new{11, 12}

      expect(a:first(2)).to_equal(b)
    end

    it ["return all items if n > ary.length"] = function()
      a = Array:new{11, 12, 13}

      expect(a:first(10)).to_equal(a)
    end
  end

  describe ["#last"] = function()
    it ["return last item"] = function()
      a = Array:new{11, 12}

      expect(a:last()).to_equal(12)
    end

    it ["return last n items"] = function()
      a = Array:new{11, 12, 13}
      b = Array:new{12, 13}

      expect(a:last(2)).to_equal(b)
    end

    it ["return all items if n > ary.length"] = function()
      a = Array:new{11, 12, 13}

      expect(a:last(10)).to_equal(a)
    end
  end

  describe ["#values_at"] = function()
    it ["return values at each index"] = function()
      a = Array:new{11, 12, 13}
      b = Array:new{11, 13}

      expect(a:values_at(1, 3)).to_equal(b)
    end
  end

  describe ["#index"] = function()
    it ["return index of the object"] = function()
      a = Array:new{11, 12, 13, 12}

      expect(a:index(12)).to_equal(2)
    end

    it ["support func"] = function()
      a = Array:new{11, 12, 13, 12}

      ret = a:index(function(v)
        return v == 12
      end)

      expect(ret).to_equal(2)
    end

    it ["return nil if not found"] = function()
      a = Array:new{11}

      expect(a:index(15)).to_be_nil()
    end
  end

  describe ["#rindex"] = function()
    it ["return index of the object and search from right"] = function()
      a = Array:new{11, 12, 13, 12}

      expect(a:rindex(12)).to_equal(4)
    end

    it ["support func"] = function()
      a = Array:new{11, 12, 13, 12}

      ret = a:rindex(function(v)
        return v == 12
      end)

      expect(ret).to_equal(4)
    end

    it ["return nil if not found"] = function()
      a = Array:new{11}

      expect(a:rindex(15)).to_be_nil()
    end
  end

  describe ["#append"] = function()
    it ["append obj.. into array"] = function()
      a = Array:new({1, 2})
      b = Array:new({1, 2, 3, 4})

      a:append(3, 4)
      expect(a).to_equal(b)
    end
  end

  describe ["#unshift"] = function()
    it ["insert obj... into array at 1 pos"] = function()
      a = Array:new({1, 2})
      b = Array:new({3, 4, 1, 2})

      a:unshift(3, 4)
      expect(a).to_equal(b)
    end
  end

  describe ["#pop"] = function()
    it ["return array when n > 1"] = function()
      a = Array:new{1, 2, 3, 4}
      b = Array:new{3, 4}

      expect(a:pop(2)).to_equal(b)
    end

    it ["return item when n is 1"] = function()
      a = Array:new{1, 2, 3, 4}

      expect(a:pop()).to_equal(4)
    end
  end

  describe ["#shift"] = function()
    it ["return array when n > 1"] = function()
      a = Array:new{1, 2, 3, 4}
      b = Array:new{1, 2}

      expect(a:shift(2)).to_equal(b)
    end

    it ["return item when n is 1"] = function()
      a = Array:new{1, 2, 3, 4}

      expect(a:shift()).to_equal(1)
    end
  end

  describe ["#delete"] = function()
    it ["delete all matchs and return deleted obj and take IN PLACE"] = function()
      a = Array:new{11, 12, 13, 12}
      b = Array:new{11, 13}

      expect(a:delete(12)).to_equal(12)
      expect(a).to_equal(b)
    end

    it ["return func() if not found"] = function()
      a = Array:new{11}

      ret = a:delete(12, function()
        return "not-found"
      end)

      expect(ret).to_equal("not-found")
    end
  end

  describe ["#delete_if"] = function()
    it ["return self and delete all item which condition is true and take IN PLACE"] = function()
      a = Array:new{11, 12, 13, 12, 14}
      b = Array:new{13, 14}

      a:delete_if(function(v)
        return v <= 12
      end)

      expect(a).to_equal(b)
    end
  end

  describe ["#clear"] = function() 
    it ["delete all items"] = function()
      a = Array:new{11, 12}

      a:clear()
      expect(a:length()).to_equal(0)
    end
  end

  describe ["#each"] = function()
    it ["iterate each value"] = function()
      a = Array:new{11, 12}
      b = Array:new{}
      c = Array:new{21, 22}
      d = Array:new{}
      e = Array:new{1, 2}

      a:each(function(v, i)
        b:append(v+10)
        d:append(i)
      end)

      expect(a).to_equal(a)
      expect(b).to_equal(c)
      expect(d).to_equal(e)
    end

    it ["have BREAK"] = function()
      a = Array:new{11, 12}
      b = Array:new{}

      ret, ret2 = a:each(function(v)
        b:append(v+10)
        return BREAK, v+10, "ret2"
      end)

      expect(b).to_equal(Array:new{21})
      expect(ret).to_equal(21)
      expect(ret2).to_equal("ret2")
    end
  end

  describe ["#map1"] = function()
    it ["invoke IN PLACE"] = function()
      a = Array:new{11, 12}
      b = Array:new{12, 14}

      a:map1(function(v, i)
        return v+i
      end)

      expect(a).to_equal(b)
    end
  end

  describe ["#map"] = function()
    it ["return a new array"] = function()
      a = Array:new{11, 12}
      b = Array:new{12, 14}

      ret = a:map(function(v, i)
        return v+i
      end)

      expect(a).to_equal(a)
      expect(ret).to_equal(b)
    end
  end

  describe ["#join"] = function()
    it ["join array with sep"] = function()
      a = Array:new{11, 12}

      expect(a:join(",")).to_equal("11,12")
    end

    it ["default sep is empty string"] = function()
      a = Array:new{11, 12}


      expect(a:join()).to_equal("1112")
    end
  end

  describe ["#reverse"] = function()
    it ["an array"] = function()
      a = Array:new{11, 12, 13}
      b = Array:new{13, 12, 11}
      c = Array:new{11, 12, 13}

      expect(a:reverse()).to_equal(b)
      expect(a).to_equal(c)
    end
  end

  describe ["#reverse1"] = function()
    it ["an array IN PLACE"] = function()
      a = Array:new{11, 12, 13}
      b = Array:new{13, 12, 11}

      expect(a:reverse1()).to_equal(b)
      expect(a).to_equal(b)
    end
  end

  --[[
  describe ["#uniq1"] = function()
    it ["remove all duplicate items IN PLACE"] = function()
      a = Array:new{11, 12, 13, 12}
      b = Array:new{11, 12, 13}

      expect(a:uniq1()).to_equal(b)
      expect(a).to_equal(b)
    end
  end
  --]]

  describe ["#sort1"] = function()
    it ["the array IN PLACE"] = function()
      a = Array:new{11, 12, 13}
      b = Array:new{13, 12, 11}

      ret = a:sort1(function(a, b)
        return a > b
      end)

      expect(ret).to_equal(b)
      expect(a).to_equal(b)
    end
  end

  describe ["#sort"] = function()
    it ["the array"] = function()
      a = Array:new{11, 12, 13}
      b = Array:new{13, 12, 11}
      c = Array:new{11, 12, 13}

      ret = a:sort(function(a, b)
        return a > b
      end)

      expect(ret).to_equal(b)
      expect(a).to_equal(c)
    end
  end

end

