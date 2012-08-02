require "spec_helper"

local ret
local ary = {data={}}
function ary:each(func)
  for _,v in ipairs(self.data) do
    func(v)
  end
end
local enum = Enumerator:new(ary)

describe ["Enumerator"] = function()
  describe ["with_index"] = function()
    it ["call with index"] = function()
      ary.data = {11, 12, 13}
      ret = 0

      enum:with_index(function(v, i)
        ret = ret + i
      end)

      expect(ret).to_equal(6)
    end
  end

  describe ["with_object"] = function()
    it ["call with an object"] = function()
      ary.data = {11, 12, 13}
      ret = {}

      enum:with_object(obj, function(v, memo)
        table.insert(memo, v)
      end)

      expect(ret).to_equal(ary.data)
    end
  end
end
