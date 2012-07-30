require "spec_helper"

local User, Student, Foo, Userable, Studentable, Fooable
local user, student

describe ["class"] = function()
  describe ["class"] = function()
    before = function()
      User = class("User")
    end

    it ["have a name"] = function()
      expect(User.name).to_equal("User")
    end
  end

  describe ["define method & variable"] = function()
    before = function()
      User = class("User")
    end

    describe ["(class)"] = function()
      it ["can define and invoke"] = function()
        function User.static:foo()
          self.name = "User.name"
          return "User.foo"
        end

        expect(User:foo()).to_equal("User.foo")
        expect(User.name).to_equal("User.name")
      end
    end

    describe ["(instance)"] = function()
      it ["will invoke #initialize when create an instance"] = function()
        function User:initialize(name)
          self.initialize = "User#initialize"
        end

        user = User:new()
        expect(user.initialize).to_equal("User#initialize")
      end

      it ["have class variable"] = function()
        user = User:new()

        expect(user.class).to_equal(User)
      end

      it ["can define and invoke"] = function()
        function User:foo()
          self.name = "User#name"
          return "User#foo"
        end

        user = User:new()
        expect(user:foo()).to_equal("User#foo")
        expect(user.name).to_equal("User#name")
      end
    end
  end

  describe ["inheritance"] = function()
    before = function()
      User = class("User")
      Student = class("Student", User)
    end

    it ["superclass is Object when not given"] = function()
      expect(User.superclass).to_equal(Object)
    end

    it ["superclass is User when given"] = function()
      expect(Student.superclass).to_equal(User)
    end

    it ["Class.inherited is called when defined"] = function()
      function User.static:inherited(child)
        child.static.superclass2 = self
      end

      Teacher = class("User", Teacher)
      expect(Teacher.superclass2, User)
    end

    describe ["(class)"] = function()
      it ["can invoke superclass's method & variable"] = function()
        function User.static:foo()
          return "User.foo"
        end

        User.static.age = 1

        expect(Student:foo()).to_equal("User.foo")
        expect(Student.age).to_equal(1)
      end

      it ["have super method"] = function()
        function User.static:foo(name)
          self.static.user_foo = name
        end

        function Student.static:foo()
          self:super("User.foo")
          self.static.student_foo = "Student.foo"
        end

        Student:foo()
        expect(Student.user_foo).to_equal("User.foo")
        expect(Student.student_foo).to_equal("Student.foo")
      end
    end

    describe ["(instance)"] = function()
      it ["can invoke superclass's method & variable"] = function()
        function User:foo()
          self.age = 1
          return "User#foo"
        end

        student = Student:new()

        expect(student:foo()).to_equal("User#foo")
        expect(student.age).to_equal(1)
      end

      it ["have super method"] = function()
        function User:foo(name)
          self.user_foo = name
        end

        function Student:foo()
          self:super("User#foo")
          self.student_foo = "Student#foo"
        end

        student = Student:new()
        student:foo()

        expect(student.user_foo).to_equal("User#foo")
        expect(student.student_foo).to_equal("Student#foo")
      end
    end

    describe ["property"] = function()
      it ["(class) call get_x and set_x"] = function()
        function User.static:get_b()
          return self._b
        end

        function User.static:set_b(value)
          self._b = value + 1
        end

        User.static.a = 1
        User.static.b = 2

        expect(User.a).to_equal(1)
        expect(User.b).to_equal(3)
      end

      it ["(instance) call get_x and set_x"] = function()
        function User:get_b()
          return self._b
        end

        function User:set_b(value)
          self._b = value + 1
        end

        user = User:new()
        user.a = 1
        user.b = 2

        expect(user.a).to_equal(1)
        expect(user.b).to_equal(3)
      end
    end
  end

  describe ["#instance_of"] = function()
    before = function()
      User = class("User")
      user = User:new()
    end

    it ["returns true if user was created from User"] = function()
      expect(user:instance_of(User)).to_equal(true)
    end

    it ["returns false otherwise"] = function()
      expect(user:instance_of(Object)).to_equal(false)
    end
  end

  describe ["#kind_of"] = function()
    before = function()
      User = class("User")
      Userable = mixin("Userable")
      Student = class("Student", User)
      Studentable = mixin("Studentable")
      Foo = class("Foo")
      Fooable = class("Fooable")

      User:include(Userable)
      Student:include(Studentable)
      student = Student:new()
    end

    it ["returns true if x was create from it's class"] = function()
      expect(student:kind_of(Student)).to_equal(true)
    end

    it ["returns true if x is in it's inheritance"] = function()
      print("--")
      expect(student:kind_of(User)).to_equal(true)
    end

    it ["returns true if x is a module included by it's class"] = function()
      expect(student:kind_of(Studentable)).to_equal(true)
    end

    it ["returns true if x is a module included by it's acenstores"] = function()
      expect(student:kind_of(Userable)).to_equal(true)
    end

    it ["returns false otherwise"] = function()
      expect(student:kind_of(Foo)).to_equal(false)
      expect(student:kind_of(Fooable)).to_equal(false)
    end
  end
end

