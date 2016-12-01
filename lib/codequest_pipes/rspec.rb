RSpec::Matchers.define :pipe_context do |expected_hash|
  def matches_or_equals?(actual, expected)
    return expected.matches?(actual) if expected.respond_to?(:matches?)
    expected == actual
  end

  match do |ctx|
    return false unless ctx.is_a?(Pipes::Context)
    expected_hash.all? do |key, val|
      next false unless ctx.respond_to?(key)
      matches_or_equals?(ctx.public_send(key), val)
    end
  end

  diffable
end
