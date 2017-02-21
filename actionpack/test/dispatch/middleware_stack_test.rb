require "abstract_unit"

class MiddlewareStackTest < ActiveSupport::TestCase
  class FooMiddleware; end
  class BarMiddleware; end
  class BazMiddleware; end
  class QuxMiddleware; end
  class HiyaMiddleware; end
  class BlockMiddleware
    attr_reader :block
    def initialize(&block)
      @block = block
    end
  end

  def setup
    @stack = ActionDispatch::MiddlewareStack.new
    @stack.use FooMiddleware
    @stack.use BarMiddleware
  end

  def test_delete_works
    assert_difference "@stack.size", -1 do
      @stack.delete FooMiddleware
    end
  end

  test "deletes all instances of the given middleware" do
    @stack.use FooMiddleware
    @stack.use FooMiddleware
    assert_equal 4, @stack.size
    assert_difference "@stack.size", -3 do
      @stack.delete FooMiddleware
    end
  end

  test "use should push middleware as class onto the stack" do
    assert_difference "@stack.size" do
      @stack.use BazMiddleware
    end
    assert_equal BazMiddleware, @stack.last.klass
  end

  test "use should push middleware class with arguments onto the stack" do
    assert_difference "@stack.size" do
      @stack.use BazMiddleware, true, foo: "bar"
    end
    assert_equal BazMiddleware, @stack.last.klass
    assert_equal([true, { foo: "bar" }], @stack.last.args)
  end

  test "use should push middleware class with block arguments onto the stack" do
    proc = Proc.new {}
    assert_difference "@stack.size" do
      @stack.use(BlockMiddleware, &proc)
    end
    assert_equal BlockMiddleware, @stack.last.klass
    assert_equal proc, @stack.last.block
  end

  test "insert inserts middleware at the integer index" do
    @stack.insert(1, BazMiddleware)
    assert_equal BazMiddleware, @stack[1].klass
  end

  test "insert_after inserts middleware after the integer index" do
    @stack.insert_after(1, BazMiddleware)
    assert_equal BazMiddleware, @stack[2].klass
  end

  test "insert_before inserts middleware before another middleware class" do
    @stack.insert_before(BarMiddleware, BazMiddleware)
    assert_equal BazMiddleware, @stack[1].klass
  end

  test "insert_after inserts middleware after another middleware class" do
    @stack.insert_after(BarMiddleware, BazMiddleware)
    assert_equal BazMiddleware, @stack[2].klass
  end

  test "swaps one middleware out for another" do
    assert_equal FooMiddleware, @stack[0].klass
    @stack.swap(FooMiddleware, BazMiddleware)
    assert_equal BazMiddleware, @stack[0].klass
  end

  test "swaps one middleware out for same middleware class" do
    assert_equal FooMiddleware, @stack[0].klass
    @stack.swap(FooMiddleware, FooMiddleware, Proc.new { |env| [500, {}, ["error!"]] })
    assert_equal FooMiddleware, @stack[0].klass
  end

  test "unshift adds a new middleware at the beginning of the stack" do
    @stack.unshift MiddlewareStackTest::BazMiddleware
    assert_equal BazMiddleware, @stack.first.klass
  end

  test "raise an error on invalid index" do
    assert_raise RuntimeError do
      @stack.insert(HiyaMiddleware, BazMiddleware)
    end

    assert_raise RuntimeError do
      @stack.insert_after(HiyaMiddleware, BazMiddleware)
    end
  end

  test "can check if Middleware are equal - Class" do
    assert_equal @stack.last, BarMiddleware
  end

  test "includes a class" do
    assert_equal true, @stack.include?(BarMiddleware)
  end

  test "can check if Middleware are equal - Middleware" do
    assert_equal @stack.last, @stack.last
  end

  test "includes a middleware" do
    assert_equal true, @stack.include?(ActionDispatch::MiddlewareStack::Middleware.new(BarMiddleware, nil, nil))
  end

  test "allow adding middleware after a middleware that was already removed" do
    @stack.delete FooMiddleware
    @stack.insert_after FooMiddleware, BazMiddleware
    assert_equal BazMiddleware, @stack.first.klass
    assert_equal BarMiddleware, @stack[1].klass
    assert_equal false, @stack.include?(FooMiddleware)
  end

  test "adds middleware right after the previous middleware of the deleted target" do
    @stack.use BazMiddleware
    @stack.delete BarMiddleware
    @stack.insert_after BarMiddleware, HiyaMiddleware
    assert_equal FooMiddleware, @stack.first.klass
    assert_equal HiyaMiddleware, @stack[1].klass
    assert_equal BazMiddleware, @stack[2].klass
    assert_equal false, @stack.include?(BarMiddleware)
  end

  test "adds middleware right after where the deleted middleware would have been" do
    @stack.use BazMiddleware
    @stack.delete BarMiddleware
    @stack.insert_after FooMiddleware, QuxMiddleware
    @stack.insert_after BarMiddleware, HiyaMiddleware

    # Hiya comes after Qux because Bar would have been after both Qux and Foo
    assert_equal FooMiddleware, @stack.first.klass
    assert_equal QuxMiddleware, @stack[1].klass
    assert_equal HiyaMiddleware, @stack[2].klass
    assert_equal BazMiddleware, @stack[3].klass
  end

  test "allow adding middleware before a middleware that was already removed" do
    @stack.delete FooMiddleware
    @stack.insert_before FooMiddleware, BazMiddleware
    assert_equal BazMiddleware, @stack.first.klass
    assert_equal BarMiddleware, @stack[1].klass
    assert_equal false, @stack.include?(FooMiddleware)
  end

  test "adds middleware right before the next middleware of the deleted target" do
    @stack.use BazMiddleware
    @stack.delete BarMiddleware
    @stack.insert_before BarMiddleware, HiyaMiddleware
    assert_equal FooMiddleware, @stack.first.klass
    assert_equal HiyaMiddleware, @stack[1].klass
    assert_equal BazMiddleware, @stack[2].klass
    assert_equal false, @stack.include?(BarMiddleware)
  end

  test "adds middleware right before where the deleted middleware would have been" do
    @stack.use BazMiddleware
    @stack.delete BarMiddleware
    @stack.insert_before BazMiddleware, QuxMiddleware
    @stack.insert_before BarMiddleware, HiyaMiddleware

    # Hiya comes before Qux because Bar would have been before both Qux and Baz
    assert_equal FooMiddleware, @stack.first.klass
    assert_equal HiyaMiddleware, @stack[1].klass
    assert_equal QuxMiddleware, @stack[2].klass
    assert_equal BazMiddleware, @stack[3].klass
  end

  test "adds middleware to the end if the deleted middlewere was in the end" do
    @stack.use BazMiddleware
    @stack.delete BazMiddleware
    @stack.insert_before BazMiddleware, HiyaMiddleware
    assert_equal FooMiddleware, @stack.first.klass
    assert_equal BarMiddleware, @stack[1].klass
    assert_equal HiyaMiddleware, @stack[2].klass
    assert_equal false, @stack.include?(BazMiddleware)
  end

  test "adds relative to the original (deleted) location, not the new location" do
    @stack.delete BarMiddleware
    @stack.unshift BarMiddleware
    @stack.insert_after BarMiddleware, QuxMiddleware

    # Qux comes immediately after Bar's original location, not after Bar's new location
    assert_equal BarMiddleware, @stack.first.klass
    assert_equal FooMiddleware, @stack[1].klass
    assert_equal QuxMiddleware, @stack[2].klass
  end

end
