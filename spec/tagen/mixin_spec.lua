require "spec_helper"

local User, Userable

describe ["mixin"] = function()
  before = function()
    User = class("User")
    Userable = mixin("Userable")
  end

  it ["have a name"] = function()
    expect(Userable.name).to_equal("Userable")
  end

  it ["it is mixin type"] = function()
    expect(Userable.__IS_MIXIN).to_be_true()
  end

  it ["includes class methods"] = function()
    function Userable.def:foo()
      self.var.age = 1
      return "User.foo"
    end

    User:include(Userable)

    expect(User:foo()).to_equal("User.foo")
    expect(User.age).to_equal(1)
  end

  it ["includes instance methods"] = function()
    function Userable:foo()
      self.age = 1
      return "User#foo"
    end

    User:include(Userable)
    user = User:new()

    expect(user:foo()).to_equal("User#foo")
    expect(user.age).to_equal(1)
  end

  it ["called def.included method"] = function()
    function Userable.def:included()
      self.var.age = 1
    end

    User:include(Userable)

    expect(User.age).to_equal(1)
  end
end
