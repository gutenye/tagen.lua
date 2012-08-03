require "spec_helper"

local a, b, reta, retb, rst

describe ["Hash"] = function()
  describe ["Hash()"] = function()
    it ["create a new hash"] = function()
      expect(tagen.instance_of(Hash(), Hash)).to_be_true()
    end
  end

  describe ["#initialize"] = function()
    it ["create a new instance"] = function()
      expect(tagen.instance_of(Hash:new(), Hash)).to_be_true()
    end

    it ["create a hash from table"] = function()
      a = Hash:new({a=1})

      expect(a.__instance_variables).to_equal({a=1})
    end

    it ["create a hash from hash"] = function()
      a = Hash:new({a=1})
      expect(Hash:new(a).__instance_variables).to_equal({a=1})
    end
  end

  describe ["#length"] = function()
    it ["return the length of the hash"] = function()
      expect(Hash{}:length()).to_equal(0)
      expect(Hash{a=1,b=2}:length()).to_equal(2)
    end
  end

  describe ["#__tostring"] = function()
    it ["pretty print hash elements"] = function()
      expect(tostring(Hash{})).to_equal("{}")
      expect(tostring(Hash{a=1,b=2})).to_equal('{"a":1, "b":2}')
    end
  end

  describe ["#__eq"] = function()
    it ["return true when each k,v in both hash are equal"] = function()
      a = Hash{a=1, b=2}
      b = Hash{a=1, b=2}

      expect(a==b).to_be_true()
    end

    it ["return false otherwise"] = function()
      a = Hash{a=1, b=2}
      c = Hash{a=2, b=2}

      expect(a==c).to_be_false()
      expect(a==1).to_be_false()
    end

    it ["support multi-dimensional hash"] = function()
      a = Hash{a=1, b=Hash{c=2}, c=3}
      b = Hash{a=1, b=Hash{c=2}, c=3}
      c = Hash{a=1, b=Hash{c=3}, c=3}

      expect(a==b).to_be_true()
      expect(a==c).to_be_false()
    end
  end

  describe ["#paris"] = function()
    it ["can be used by for-statement"] = function()
      a = Hash{a=1, b=2}
      b = {}

      for k,v in a:pairs() do
        b[k] = v
      end

      expect(b).to_equal({a=1, b=2})
    end
  end

  describe ["#dup"] = function()
    it ["duplicate the hash object"] = function()
      a = Hash{a=1}
      b = a:dup()

      a["b"] = 2
      b["b"] = 3

      expect(a).to_equal(Hash{a=1, b=2})
      expect(b).to_equal(Hash{a=1, b=3})
    end
  end

  describe ["#is_empty"] = function()
    it ["return true when hash is empty"] = function()
      expect(Hash{}:is_empty()).to_be_true()
      expect(Hash{a=1}:is_empty()).to_be_false()
    end
  end

  describe ["#get"] = function()
    it ["get an existing value"] = function()
      a = Hash{a=1}
      expect(a:get("a")).to_equal(1)
    end

    it ["return default if the value is not exist"] = function() 
      a = Hash{}
      expect(a:get("a", "default")).to_equal("default") 
    end

    it ["the default argument is nil if non-given"] = function()
      a = Hash{}

      expect(a:get("a")).to_equal(nil)
    end
  end

  describe ["#set"] = function()
    it ["set key to value"] = function()
      a = Hash{}
      a:set("a", 1)
      expect(a).to_equal(Hash{a=1})
    end
  end

  describe ["#has_key"] = function()
    it ["return true if hash contains the key, false otherwise"] = function() 
      a = Hash{a=1}
      expect(a:has_key("a")).to_be_true()
      expect(a:has_key("b")).to_be_false()
    end
  end

  describe ["#keys"] = function()
    it ["return all keys"] = function()
      a = Hash{a=1, b=2}
      expect(a:keys()).to_equal(Array{"a", "b"})
    end

    it ["return an empty array if hash is empty"] = function()
      a = Hash{}
      expect(a:keys()).to_equal(Array{})
    end
  end

  describe ["#values"] = function()
    it ["return all values"] = function()
      a = Hash{a=1, b=2}
      expect(a:values()).to_equal(Array{1, 2})
    end

    it ["return an empty array if hash is empty"] = function()
      a = Hash{}
      expect(a:values()).to_equal(Array{})
    end
  end

  describe ["#values_at"] = function()
    it ["return values at keys and skip non-exist key"] = function()
      a = Hash{a=1, b=2, c=3}
      expect(a:values_at("a","d", "c")).to_equal(Array{1,3})
    end

    it ["return an empty array if hash is empty"] = function()
      a = Hash{}
      expect(a:values_at("x")).to_equal(Array{})
    end
  end

  describe ["#each"] = function()
    it ["iterate each key and value"] = function()
      a = Hash{a=1, b=2}
      reta = {}
      retb = {}

      a:each(function(k, v)
        table.insert(reta, k)
        table.insert(retb, v)
      end)

      expect(reta).to_equal({"a", "b"})
      expect(retb).to_equal({1, 2})
    end

    it ["have BREAK"] = function()
      a = Hash{a=1, b=2}

      reta, retb = a:each(function(k, v)
        return BREAK, k, v
      end)

      expect(reta).to_equal("a")
      expect(retb).to_equal(1)
    end
  end

  describe ["#merge1"] = function()
    it ["merge another hash into self"] = function()
      a = Hash{a=1, b=2}
      b = Hash{a=2, c=3}
      rst = Hash{a=2, b=2, c=3}

      expect(a:merge1(b)).to_equal(rst)
      expect(a).to_equal(rst)
    end

    it ["can call a func"] = function()
      a = Hash{a=1, b=2}
      b = Hash{a=2, c=3}
      rst = Hash{a=1, b=2, c=3}

      a:merge1(b, function(k, v1, v2)
        if k == "a" then
          return v1
        else
          return v2
        end
      end)

      expect(a).to_equal(rst)
    end
  end

  describe ["#merge"] = function()
    it ["merge another hash and return a new hash"] = function()
      a = Hash{a=1, b=2}
      b = Hash{a=2, c=3}
      rst = Hash{a=2, b=2, c=3}
      a_dup = Hash{a=1, b=2}

      expect(a:merge(b)).to_equal(rst)
      expect(a).to_equal(a_dup)
    end
  end

  describe ["#invert"] = function()
    it ["reverse key and value"] = function()
      a = Hash{a="b", b="c"}
      rst = Hash{b="a", c="b"}

      expect(a:invert()).to_equal(rst)
    end
  end

  describe ["#delete"] = function()
    it ["return deleted value and take IN PLACE"] = function()
      a = Hash{a=1, b=2}
      rst = Hash{b=2}

      expect(a:delete("a")).to_equal(1)
      expect(a).to_equal(rst)
    end

    it ["return nil when key does not exists"] = function()
      a = Hash{a=1}

      expect(a:delete("c")).to_be_nil()
    end
  end

  describe ["#delete_if"] = function()
    it ["return self and delete all item which condition is true and take IN PLACE"] = function()
      a = Hash{a=1, b=3, c=2}
      rst = Hash{b=3}

      a:delete_if(function(k, v)
        return k == "a" or v == 2
      end)

      expect(a).to_equal(rst)
    end
  end

  describe ["#clear"] = function()
    it ["delete all items"] = function()
      a = Hash{a=1, b=2}
      rst = Hash{}

      a:clear()
      expect(a).to_equal(rst)
    end
  end

  describe ["#to_a"] = function()
    it ["return a array"] = function()
      a = Hash{a=1, b=2}
      rst = Array{Array{"a", 1}, Array{"b", 2}}

      expect(a:to_a()).to_equal(rst)
    end
  end
end

