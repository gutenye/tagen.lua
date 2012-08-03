require "spec_helper"

local reg 

describe ["Regexp"] = function()
  describe ["Regexp()"] = function()
    it ["create a Regexp object"] = function()
      expect(tagen.instance_of(Regexp("foo"), Regexp)).to_be_true()
    end
  end

  describe ["#__tostring"] = function()
    it ["print /x/"] = function()
      reg = Regexp:new("guten")

      expect(tostring(reg)).to_equal("/guten/")
    end
  end
end
