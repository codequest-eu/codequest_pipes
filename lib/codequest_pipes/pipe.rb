module Pipes
  # Pipe is a mix-in which turns a class into a Pipes building block (Pipe).
  # A Pipe can only have class methods since it can't be instantiated.
  class Pipe
    attr_reader :context

    def initialize(ctx)
      @context = ctx
    end

    def call
      fail MissingCallMethod
    end

    def self.|(other)
      this = self
      Class.new(Pipe) do
        _combine(this, other)
      end
    end

    def self.call(ctx)
      return ctx if ctx.errors.any?
      _validate_ctx(_required_context_elements, ctx)
      new(ctx).call
      _validate_ctx(_provided_context_elements, ctx)
    end

    def self.require_context(*args)
      _required_context_elements.push(*args)
    end

    def self.provide_context(*args)
      _provided_context_elements.push(*args)
    end

    def self._combine(first, second)
      _check_interface(first)
      _check_interface(second)
      define_singleton_method(:call) do |ctx|
        first.call(ctx)
        second.call(ctx)
      end
    end
    private_class_method :_combine

    def self._check_interface(klass)
      fail MissingCallMethod unless klass.instance_methods.include?(:call)
    end
    private_class_method :_check_interface

    def self._required_context_elements
      @required_context_elements ||= []
    end
    private_class_method :_required_context_elements

    def self._provided_context_elements
      @provided_context_elements ||= []
    end
    private_class_method :_provided_context_elements

    def self._validate_ctx(collection, ctx)
      collection.each do |element|
        next if ctx.respond_to?(element)
        fail MissingContext, "context does not respond to '#{element}'"
      end
    end
    private_class_method :_validate_ctx

    private

    def method_missing(name, *args, &block)
      context.send(name, *args, &block)
    end
  end # class Pipe
end # module Pipes
