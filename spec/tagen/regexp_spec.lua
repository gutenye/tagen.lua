require "spec_helper"

local reg 

describe ["Regexp"] = function()
  describe ["#__tostring"] = function()
    it ["print /x/"] = function()
      reg = Regexp:new("guten")

      expect(tostring(reg)).to_equal("/guten/")
    end
  end
end
