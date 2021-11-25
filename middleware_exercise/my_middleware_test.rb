require 'minitest/autorun'
require_relative 'my_middleware'

class MyMiddlewareTest < MiniTest::Test
  class AddFooMiddleware
    def initialize(app, foo = 42)
      @app = app
      @foo = foo
    end

    def call(env)
      env[:foo] = @foo
      @app.call(env)
    end
  end

  class PrintFooMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      puts env[:foo]
      @app.call(env)
    end
  end

  def test_use
    stack = MyMiddleware.build do
      use AddFooMiddleware
      use PrintFooMiddleware
    end
    assert_output("42\n") { stack.call({}) }
  end

  def test_use_in_reverse_order
    stack = MyMiddleware.build do
      use PrintFooMiddleware
      use AddFooMiddleware
    end
    assert_output("\n") { stack.call({}) }
  end

  def test_insert_before
    stack = MyMiddleware.build do
      use PrintFooMiddleware
    end
    stack.insert_before PrintFooMiddleware, AddFooMiddleware
    assert_output("42\n") { stack.call({}) }
  end

  def test_insert_after
    stack = MyMiddleware.build do
      use PrintFooMiddleware
    end
    stack.insert_after PrintFooMiddleware, AddFooMiddleware
    assert_output("\n") { stack.call({}) }
  end

  def test_use_with_args
    skip
    stack = MyMiddleware.build do
      use AddFooMiddleware, 100
      use PrintFooMiddleware
    end
    assert_output("100\n") { stack.call({}) }
  end
end
