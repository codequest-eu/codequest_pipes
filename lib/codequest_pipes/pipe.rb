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
      return ctx if ctx.error
      _validate_ctx(_required_context_elements, ctx)
      new(ctx).call
      _validate_ctx(_provided_context_elements, ctx)
    end

    def self.require_context(*args, **kwargs)
      _merge_context_elements(_required_context_elements, args, kwargs)
    end

    def self.provide_context(*args, **kwargs)
      _merge_context_elements(_provided_context_elements, args, kwargs)
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
      @required_context_elements ||= {}
    end
    private_class_method :_required_context_elements

    def self._provided_context_elements
      @provided_context_elements ||= {}
    end
    private_class_method :_provided_context_elements

    def self._validate_ctx(collection, ctx)
      collection.each do |element, klass|
        _validate_value_presence(ctx, element)
        _validate_value_type(ctx, element, klass) if klass
      end
    end
    private_class_method :_validate_ctx

    def self._validate_value_presence(ctx, element)
      return if ctx.respond_to?(element)
      raise MissingContext, "context does not respond to '#{element}'"
    end
    private_class_method :_validate_value_presence

    def self._validate_value_type(ctx, element, klass)
      obj = ctx.public_send(element)
      return if obj.is_a?(klass)
      raise InvalidType,
        "'#{element}' has invalid type #{obj.class} (expected: #{klass})"
    end
    private_class_method :_validate_value_type

    def self._merge_context_elements(elements, args, kwargs)
      elements.merge!(
        **args.map { |a| [a, nil] }.to_h,
        **kwargs
      )
    end
    private_class_method :_merge_context_elements

    private

    def method_missing(name, *args, &block)
      context.send(name, *args, &block)
    end
  end # class Pipe
end # module Pipes
