describe 'Parallax module' do
  tests ParallaxDemoController

  before do
    controller.scroll_view.contentOffset = [100, 0]
  end

  it "should have all the elements" do
  end

end
