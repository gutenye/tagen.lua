require "spec_helper"

local User, Student, Child, Foo, Userable, Studentable, Fooable
local user, student, child

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
        function User.def:foo()
          self.var.age = 2
          return "User.foo"
        end

        expect(User:foo()).to_equal("User.foo")
        expect(User.age).to_equal(2)
      end
    end

    describe ["(instance)"] = function()
      it ["will invoke #initialize when create an instance"] = function()
        function User:initialize(name)
          self.initialize = "User#initialize"
          self.var.a = 1
        end

        user = User:new()
        expect(user.initialize).to_equal("User#initialize")
        expect(user.a).to_equal(1)
      end

      it ["define object method"] = function()
        user = User:new()

        function user.def:foo()
          self.a = 1
          return "user#foo"
        end

        expect(user:foo()).to_equal("user#foo")
        expect(user.a).to_equal(1)
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

    it ["Object's superclass is nil"] = function()
      expect(Object.superclass).to_equal(nil)
    end

    it ["superclass is Object when not given"] = function()
      expect(User.superclass).to_equal(Object)
    end

    it ["superclass is User when given"] = function()
      expect(Student.superclass).to_equal(User)
    end

    it ["Class.inherited is called when defined"] = function()
      function User.def:inherited(child)
        child.var.superclass2 = self
      end

      Teacher = class("User", Teacher)
      expect(Teacher.superclass2, User)
    end

    describe ["(class)"] = function()
      it ["can invoke superclass's method & variable"] = function()
        function User.def:foo()
          return "User.foo"
        end

        User.var.age = 1

        expect(Student:foo()).to_equal("User.foo")
        expect(Student.age).to_equal(1)
      end

      it ["have super method"] = function()
        function User.def:foo(name)
          self.var.user_foo = name
        end

        function Student.def:foo()
          self:super("User.foo")
          self.var.student_foo = "Student.foo"
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
        function User.def:get_b()
          return rawget(self.var, "b")
        end

        function User.def:set_b(value)
          rawset(self.var, "b", value + 1)
        end

        User.var.a = 1
        User.var.b = 2

        expect(User.a).to_equal(1)
        expect(User.b).to_equal(3)
      end

      it ["(instance) call get_x and set_x"] = function()
        function User:get_b()
          return self.var.b
        end

        function User:set_b(value)
          self.var.b = value + 1
        end

        user = User:new()
        user.a = 1
        user.b = 2

        expect(user.a).to_equal(1)
        expect(user.b).to_equal(3)
      end
    end
  end


  describe ["metamethods"] = function()
    describe ["(class)"] = function()
      before = function()
        User = class("User")
      end

      it ["have __call"] = function()
        function User.def:__call() 
          return "User.__call"
        end

        expect(User()).to_equal("User.__call")
      end
    end

    describe ["(instance)"] = function()
      before = function()
        User = class("User")
        Student = class("Student", User)
        Child = class("Child", Student)
      end

      it ["will invoke when defined as an instance_method"] = function()
        function User:__add()
          return "User#__add"
        end

        user = User:new()
        expect(user+1).to_equal("User#__add")
      end

      it ["supports inheritance"] = function()
        function User:__add()
          return "User#__add"
        end

        child = Child:new()
        expect(child+1).to_equal("User#__add")
      end
    end
  end
end

-- ¤Object
describe ["Object"] = function()
  describe [".alias"] = function()
    it ["a class method"] = function()
      User = class("User")
      function User.def:foo()
        return "User.foo"
      end

      User:alias("bar", "foo")
      expect(User:bar()).to_equal("User.foo")
    end
  end

  describe [".ialias"] = function()
    it ["an instance method"] = function()
      User = class("User")
      function User:foo()
        return "User#foo"
      end

      User:ialias("bar", "foo")
      user = User:new()
      expect(user:bar()).to_equal("User#foo")
    end
  end

  describe [".method"] = function()
    before = function()
      User = class("User")
    end

    it ["return a class method"] = function()
      function User.def:foo() end

      expect(type(User:method("foo"))).to_equal("function")
    end

    it ["return nil if not found"] = function()
      expect(User:method("foo")).to_be_nil()
    end
  end

  describe [".instance_method"] = function()
    before = function()
      User = class("User")
    end

    it ["return an instance method"] = function()
      function User:foo() end

      expect(type(User:instance_method("foo"))).to_equal("function")
    end

    it ["return nil if not found"] = function()
      expect(User:instance_method("foo")).to_be_nil()
    end
  end

  describe ["#method"] = function()
    before = function()
      User = class("User")
    end

    it ["return a instance method"] = function()
      function User:foo() end

      user = User:new()
      expect(type(user:method("foo"))).to_equal("function")
    end

    it ["return a object method"] = function()
      user = User:new()
      function user.def:foo() end

      expect(type(user:method("foo"))).to_equal("function")
    end

    it ["return nil if not found"] = function()
      user = User:new()
      expect(user:method("foo")).to_be_nil()
    end
  end

  describe [".methods"] = function()
    before = function()
      User = class("User")
    end

    it ["return class methods"] = function()
      function User.def:foo() end

      expect(User:methods()).to_equal(User.__methods)
    end
  end

  describe [".class_variables"] = function()
    before = function()
      User = class("User")
    end

    it ["return class variables"] = function()
      User.var.a  = 1

      expect(User:class_variables()).to_equal({a=1})
    end
  end

  describe [".instance_methods"] = function()
    before = function()
      User = class("User")
    end

    it ["return instance methods"] = function()
      function User:foo() end

      expect(User:instance_methods()).to_equal(User.__instance_methods)
    end
  end

  describe ["#instance_variables"] = function()
    before = function()
      User = class("User")
    end

    it ["return instance variables"] = function()
      user = User:new()
      user.a = 1

      expect(user:instance_variables()).to_equal({a=1})
    end
  end

  describe ["#object_methods"] = function()
    before = function()
      User = class("User")
    end

    it ["return object methods"] = function()
      user = User:new()
      function user:foo() end

      expect(user:object_methods()).to_equal(user.__object_methods)
    end
  end
end
