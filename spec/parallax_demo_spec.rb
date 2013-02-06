describe 'Parallax module' do
  tests ParallaxDemoController

  it "should start off sensibly" do
    controller.scroll_view.contentOffset = [0, 0]
    CGPointEqualToPoint(controller.button.frame.origin, CGPoint.new(10, 10)).should == true
    CGPointEqualToPoint(controller.bg_image.frame.origin, CGPoint.new(50, 400)).should == true
    CGPointEqualToPoint(controller.diagonal.frame.origin, CGPoint.new(0, 200)).should == true
    CGPointEqualToPoint(controller.moving_thing.frame.origin, CGPoint.new(0, 500)).should == true
    CGPointEqualToPoint(controller.another_scroller.contentOffset, CGPoint.new(0, 0)).should == true
  end

  it "should move at [0, 50]" do
    controller.scroll_view.contentOffset = [0, 50]
    CGPointEqualToPoint(controller.button.frame.origin, CGPoint.new(10, 60)).should == true
    CGPointEqualToPoint(controller.bg_image.frame.origin, CGPoint.new(50, 300)).should == true
    CGPointEqualToPoint(controller.diagonal.frame.origin, CGPoint.new(75, 200)).should == true
    CGPointEqualToPoint(controller.moving_thing.frame.origin, CGPoint.new(0, 500)).should == true
    CGPointEqualToPoint(controller.another_scroller.contentOffset, CGPoint.new(0, 50)).should == true
  end

  it "should move at [0, 100]" do
    controller.scroll_view.contentOffset = [0, 100]
    CGPointEqualToPoint(controller.button.frame.origin, CGPoint.new(10, 110)).should == true
    CGPointEqualToPoint(controller.bg_image.frame.origin, CGPoint.new(50, 200)).should == true
    CGPointEqualToPoint(controller.diagonal.frame.origin, CGPoint.new(150, 200)).should == true
    CGPointEqualToPoint(controller.moving_thing.frame.origin, CGPoint.new(0, 500)).should == true
    CGPointEqualToPoint(controller.another_scroller.contentOffset, CGPoint.new(0, 100)).should == true
  end

  it "should move at [50, 200]" do
    controller.scroll_view.contentOffset = [50, 200]
    CGPointEqualToPoint(controller.button.frame.origin, CGPoint.new(60, 210)).should == true
    CGPointEqualToPoint(controller.bg_image.frame.origin, CGPoint.new(150, 0)).should == true
    CGPointEqualToPoint(controller.diagonal.frame.origin, CGPoint.new(300, 200)).should == true
    CGPointEqualToPoint(controller.moving_thing.frame.origin, CGPoint.new(80, 500)).should == true
    CGPointEqualToPoint(controller.another_scroller.contentOffset, CGPoint.new(0, 200)).should == true
  end

end
