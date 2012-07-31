require "spec_helper"

local a

describe ["Array"] = function()
  describe ["#index"] = function()
    before = function()
      a = Array:new({"a", "b", "cd"})
    end

    it ["return index when found"] = function()
      expect(a:index("b")).to_equal(2)
    end

    it ["can call with function"] = function()
    end

    it ["reutrn nil when not found"] = function()
    end
  end
end

