require "spec_helper"

describe ["stringx"] = function()
  describe ["#dup"] = function()
    it ["duplicate the string"] = function()
      a = "foo"
      b = "foo"
      expect(stringx.dup(a)).to_equal(b)
    end
  end

  describe ["#length"] = function()
    it ["get the string length"] = function()
      a = "foo"
      b = 3
      expect(stringx.length(a)).to_equal(3)
    end
  end

  describe ["#is_empty"] = function()
    it ["return true if string is empty"] = function()
      a = ""
      expect(stringx.is_empty(a)).to_be_true()
    end

    it ["return false otherwise"] = function()
      a = "guten"
      expect(stringx.is_empty(a)).to_be_false()
    end
  end

  describe ["#slice"] = function()
    it ["slice a string"] = function()
      a = "guten"
      b = "ut"
      expect(stringx.slice(a, 2, 2)).to_equal(b)
    end

    it ["default length is 1"] = function()
      a = "guten"
      b = "u"
      expect(stringx.slice(a, 2)).to_equal(b)
    end
  end

  describe ["#count"] = function()
    it ["count the substring"] = function()
      a = "gutengu"
      b = 2
      expect(stringx.count(a, "gu")).to_equal(b)
    end
  end

  describe ["#index"] = function()
    it ["return the index of substring"] = function()
      a = "guten"
      expect(stringx.index(a, "te")).to_equal(3, 4)
    end

    it ["can call with regexp"] = function()
      a = "guten"
      expect(stringx.index(a, Regexp("t."))).to_equal(3,4)
    end

    it ["have offset"] = function()
      a = "gutengu"
      expect(stringx.index(a, "g", 2)).to_equal(6,6)
    end
  end

  describe ["#rindex"] = function() 
    it ["return the index of substring from right"] = function()
      a = "gutengu"
      expect(stringx.rindex(a, "gu")).to_equal(6,7)
    end

    it ["can call with regexp"] = function()
      a = "gutengu"
      expect(stringx.rindex(a, Regexp("g."))).to_equal(6,7)
    end

    it ["have offset"] = function()
      a = "gutengu"
      expect(stringx.rindex(a, "g", 3)).to_equal(1,1)
    end
  end

  describe ["#include"] = function()
    it ["return true if string include a substring, otherwise false"] = function()
      a = "guten"
      expect(stringx.include(a, "te")).to_be_true()
      expect(stringx.include(a, "tn")).to_be_false()
    end

    it ["support regexp"] = function()
      a = "guten"
      expect(stringx.include(a, Regexp("n$"))).to_be_true()
      expect(stringx.include(a, Regexp("e$"))).to_be_false()
    end
  end

  describe ["#start_with"] = function()
    it ["return true if string start_with a substring, otherwise false"] = function()
      a = "guten"
      expect(stringx.start_with(a, "gu")).to_be_true()
      expect(stringx.start_with(a, "ga")).to_be_false()
    end

    it ["have multi-substring with or"] = function()
      a = "guten"
      expect(stringx.start_with(a, "ga", "gu")).to_be_true()
      expect(stringx.start_with(a, "ga", "gc")).to_be_false()
    end
  end

  describe ["#end_with"] = function()
    it ["return true if string end_with a substring, otherwise false"] = function()
      a = "guten"
      expect(stringx.end_with(a, "en")).to_be_true()
      expect(stringx.end_with(a, "an")).to_be_false()
    end

    it ["have multi-substring with or"] = function()
      a = "guten"
      expect(stringx.end_with(a, "an", "en")).to_be_true()
      expect(stringx.end_with(a, "an", "bn")).to_be_false()
    end
  end

  describe ["#chars"] = function()
    it ["iterate each char in string"] = function()
      a = "guten"
      b = {}
      rst = {"g", "u", "t", "e", "n"}

      stringx.chars(a, function(c)
        table.insert(b, c)
      end)

      expect(b).to_equal(rst)
    end
  end

  describe ["#lines"] = function()
    it ["iterate each line in the string"] = function()
      a = "guten\ntag"
      b = {}
      rst = {"guten\n", "tag"}

      stringx.lines(a, function(l)
        table.insert(b, l)
      end)

      expect(b).to_equal(rst)
    end
  end

  describe ["#delete"] = function()
    it ["return the deleted substring"] = function()
      a = "guten"
      expect(stringx.delete(a, "ten")).to_equal("gu", "ten")
    end


    it ["return nil when not found"] = function()
      a = "gutentag"
      expect(stringx.delete(a, "foo")).to_equal(nil, nil)
    end
  end

  describe ["#strip"] = function()
    it ["strip whitespace in both end"] = function()
      a = " \n\tgu ten\t\n "
      rst = "gu ten"

      expect(stringx.strip(a)).to_equal(rst)
    end
  end


  describe ["#rstrip"] = function()
    it ["strip whithspace at right"] = function()
      a = " \n\tgu ten\t\n "
      rst = " \n\tgu ten"

      expect(stringx.rstrip(a)).to_equal(rst)
    end
  end

  describe ["#lstrip"] = function()
    it ["strip whithspace at right"] = function()
      a = " \n\tgu ten\t\n "
      rst = "gu ten\t\n "

      expect(stringx.lstrip(a)).to_equal(rst)
    end
  end

  describe ["#swapcase"] = function()
    it ["swap the case"] = function()
      a = "guTeN"
      rst = "GUtEn"

      expect(stringx.swapcase(a)).to_equal(rst)
    end
  end

  describe ["#capitalize"] = function()
    it ["captialize the string"] = function()
      a = "guten tag"
      rst = "Guten Tag"

      expect(stringx.capitalize(a)).to_equal(rst)
    end
  end

  describe ["#split"] = function()
    it ["split a string by its seperator"] = function()
      a = "a:b"
      rst = Array{"a", "b"}

      expect(stringx.split(a, ":")).to_equal(rst)
    end

    it ["remove last empy strings"] = function()
      a = "::a::b::"
      rst = Array{"", "", "a", "", "b"}

      expect(stringx.split(a, ":")).to_equal(rst)
    end

    it ["limit to n"] = function()
      a = "a:b:c:d"
      rst = Array{"a", "b", "c:d"}

      expect(stringx.split(a, ":", 3)).to_equal(rst)
    end


    it ["can be a pattern"] = function()
      a = "a b\nc"
      rst = Array{"a", "b", "c"}

      expect(stringx.split(a, Regexp("%s"))).to_equal(rst)
    end
  end

  describe ["#partition"] = function()
    it ["partition the string into three parts"] = function()
      a = "a:b"
      rst = Array{"a", ":", "b"}

      expect(stringx.partition(a, ":")).to_equal(rst)
    end
  end

  describe ["#insert"] = function()
    it ["insert substring at index"] = function()
      a = "ab"
      rst = "a12b"

      expect(stringx.insert(a, 2, "12")).to_equal(rst)
    end
  end

  describe ["#ljust"] = function()
    it ["left-justify s with width w."] = function()
      a = "ab"
      rst = "ab111"

      expect(stringx.ljust(a, 5, "1")).to_equal(rst)
    end
  end

  describe ["#rjust"] = function()
    it ["left-justify s with width w."] = function()
      a = "ab"
      rst = "111ab"

      expect(stringx.rjust(a, 5, "1")).to_equal(rst)
    end
  end

  describe ["#center"] = function()
    it ["center-justify s with width w."] = function()
      a = "ab"
      rst = "11ab1"

      expect(stringx.center(a, 5, "1")).to_equal(rst)
    end
  end
end

