module Pipes
  class Context
    # ErrorCollector is Context's companion object for storing non-critical
    # errors.
    class ErrorCollector
      attr_reader :errors

      def initialize
        @errors = {}
      end

      def add(errors_hash)
        errors_hash.map do |key, errors|
          @errors[key] ||= []
          @errors[key] = @errors[key] | Array(errors)
        end
      end
    end # class ErrorColletor
  end # class Context
end # module Pipes
