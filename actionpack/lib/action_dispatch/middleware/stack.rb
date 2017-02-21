require "active_support/inflector/methods"
require "active_support/dependencies"

module ActionDispatch
  class MiddlewareStack
    class Middleware
      attr_reader :args, :block, :klass

      def initialize(klass, args, block)
        @klass = klass
        @args  = args
        @block = block
      end

      def name; klass.name; end

      def deleted?
        false
      end

      def ==(middleware)
        case middleware
        when Middleware
          klass == middleware.klass
        when Class
          klass == middleware
        end
      end

      def inspect
        if klass.is_a?(Class)
          klass.to_s
        else
          klass.class.to_s
        end
      end

      def build(app)
        klass.new(app, *args, &block)
      end
    end

    class DeletedMiddleware
      attr_reader :klass
      def initialize(klass)
        @klass = klass
      end

      def deleted?
        true
      end
    end

    include Enumerable

    attr_accessor :middlewares

    def initialize(*args)
      @middlewares = []
      yield(self) if block_given?
    end

    def each
      undeleted_middlewares.each { |x| yield x }
    end

    def size
      undeleted_middlewares.size
    end

    def last
      undeleted_middlewares.last
    end

    def [](i)
      undeleted_middlewares[i]
    end

    def unshift(klass, *args, &block)
      middlewares.unshift(build_middleware(klass, args, block))
    end

    def initialize_copy(other)
      self.middlewares = other.middlewares.dup
    end

    def insert(target, klass, *args, &block)
      actual_index = assert_index(target, :before)
      direct_insert(actual_index, klass, args, block)
    end

    alias_method :insert_before, :insert

    def insert_after(target, klass, *args, &block)
      actual_index = assert_index(target, :after)
      direct_insert(actual_index + 1, klass, args, block)
    end

    def swap(target, klass, *args, &block)
      actual_index = assert_index(target, :before)
      direct_insert(actual_index, klass, args, block)
      middlewares.delete_at(actual_index + 1)
    end

    def delete(target)
      @middlewares.map! do |m, idx|
        m.klass == target ? DeletedMiddleware.new(m.klass) : m
      end
    end

    def use(klass, *args, &block)
      middlewares.push(build_middleware(klass, args, block))
    end

    def build(app = Proc.new)
      undeleted_middlewares.freeze.reverse.inject(app) { |a, e| e.build(a) }
    end

    private

      def undeleted_middlewares
        @middlewares.select { |m| !m.deleted? }
      end

      def direct_insert(actual_index, klass, args, block)
        @middlewares.insert(actual_index, build_middleware(klass, args, block))
      end

      def assert_index(target, where)
        if target.is_a?(Integer)
          # Translate to correct index
          undeleted_indices = @middlewares.each_index.select { |idx| !@middlewares[idx].deleted? }
          i = undeleted_indices[target]
        else
          i = deleted_middleware_index(target) || middleware_index(target)
        end

        raise "No such middleware to insert #{where}: #{target.inspect}" unless i

        i
      end

      def deleted_middleware_index(klass)
        middlewares.index { |m| m.deleted? && m.klass == klass }
      end

      def middleware_index(klass)
        middlewares.index { |m| !m.deleted? && m.klass == klass }
      end

      def build_middleware(klass, args, block)
        Middleware.new(klass, args, block)
      end
  end
end
