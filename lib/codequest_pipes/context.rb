module Pipes
  # Context is an object used to pass data between Pipes. It behaves like an
  # OpenStruct except you can write a value only once - this way we prevent
  # context keys from being overwritten.
  class Context
    # Override is an exception raised when an attempt is made to override an
    # existing Context property.
    class Override < ::StandardError; end

    # Context constructor.
    #
    # @param values [Hash]
    def initialize(values = {})
      add(values)
    end

    # Method `add` allows adding new properties (as a Hash) to the Context.
    #
    # @param values [Hash]
    def add(values)
      values.each do |key, val|
        k_sym = key.to_sym
        fail Override, "Property :#{key} already present" if respond_to?(k_sym)
        define_singleton_method(k_sym) { val }
      end
    end
  end # class Context
end # module Pipes
