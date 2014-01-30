class Foo

  def bar
    @bar ? 'NOT BAR' : 'bar'
  end
  memoize :bar

  memoize :baz do
    @baz ? 'NOT BAZ' : 'baz'
  end

  memoize :qux do
    if @qux
      'NOT QUX'
    else
      @qux = 'qux'
    end
    :ok
  end

end


describe 'memoize' do

  it 'should have a `bar` method' do
    bar_test = Foo.new
    bar_test.should.respond_to?(:bar)
  end

  it 'should only call the `bar` method once' do
    bar_test = Foo.new
    bar_test.bar.should == 'bar'
    bar_test.bar.should == 'bar'
  end

  it 'should have a `baz` method' do
    baz_test = Foo.new
    baz_test.should.respond_to?(:baz)
  end

  it 'should only call the `baz` method once' do
    baz_test = Foo.new
    baz_test.baz.should == 'baz'
    baz_test.baz.should == 'baz'
  end

  it 'should let `qux` assign the ivar' do
    qux_test = Foo.new
    qux_test.qux.should == 'qux'
  end

  it 'should only call the `qux` method once' do
    qux_test = Foo.new
    qux_test.qux.should == 'qux'
    qux_test.qux.should == 'qux'
  end

end
