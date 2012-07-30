require "spec_helper"

describe ["mixin"] = function()
  before = function()
    User = class("User")
  end

  it ["have a name"] = function()
    Fooable = mixin("Fooable")
    expect(Fooable.name).to_equal("Fooable")
  end

  it ["#tostring"] = function()
    Fooable = mixin("Fooable")
    expect(tostring(Fooable)).to_equal("Fooable")
  end

  it ["includes class methods"] = function()
    Fooable = mixin("Fooable", {
      static = {
        foo = function(self)
          self.static.age = 1
          return "User.foo"
        end
      }
    })

    User:include(Fooable)

    expect(User:foo()).to_equal("User.foo")
    expect(User.age).to_equal(1)
  end

  it ["includes instance methods"] = function()
    Fooable = mixin("Fooable", {
      foo = function(self)
        self.age = 1
        return "User#foo"
      end
    })

    User:include(Fooable)
    user = User:new()

    expect(user:foo()).to_equal("User#foo")
    expect(user.age).to_equal(1)
  end

  it ["called static.included method"] = function()
    Fooable = mixin("Fooable", {
      static = {
        included = function(self)
          self.static.age = 1
        end
      }
    })

    User:include(Fooable)

    expect(User.age).to_equal(1)
  end
end
