require "spec_helper" 

describe["core"] = function()
  describe["#merge"] = function()
    it["works"] = function()
      local a = {a=1, b=2}
      local b = {a=7, c=3}

      tagen.merge(a, b)

      expect(a.a).to_equal(7)
      expect(a.b).to_equal(2)
      expect(a.c).to_equal(3)
    end
  end
end
