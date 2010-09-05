Rspec::Matchers.define :respond_with do |attributes|
  match do |obj|
    attributes.all?  do |k, v|
      @method = k.to_sym
      @expect, @actual = v, obj.send(@method)
      @expect == @actual
    end
  end
  failure_message_for_should do |obj|
    "expected: #{@expect.inspect},\n" +
    "     got: #{@actual.inspect} (calling #{@method})"
  end
  failure_message_for_should_not do |obj|
    "expected not: #{@expect.inspect} (calling #{@method})"
  end
end

