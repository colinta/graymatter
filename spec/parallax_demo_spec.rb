describe 'Parallax module' do
  tests ParallaxDemoController

  describe "should start off sensibly" do
    before do
      controller.scroll_view.contentOffset = [0, 0]
    end
    it "fixed_inside_button should be sensible" do
      CGPointEqualToPoint(controller.fixed_inside_button.frame.origin, CGPoint.new(10, 10)).should == true
    end
    it "float_inside_button should be sensible" do
      CGPointEqualToPoint(controller.float_inside_button.frame.origin, CGPoint.new(110, 10)).should == true
    end
    it "fixed_outside_button should be sensible" do
      CGPointEqualToPoint(controller.fixed_outside_button.frame.origin, CGPoint.new(10, 50)).should == true
    end
    it "float_outside_button should be sensible" do
      CGPointEqualToPoint(controller.float_outside_button.frame.origin, CGPoint.new(110, 50)).should == true
    end
    it "bg_image should be sensible" do
      CGPointEqualToPoint(controller.bg_image.frame.origin, CGPoint.new(50, 400)).should == true
    end
    it "diagonal should be sensible" do
      CGPointEqualToPoint(controller.diagonal.frame.origin, CGPoint.new(0, 200)).should == true
    end
    it "moving_thing should be sensible" do
      CGPointEqualToPoint(controller.moving_thing.frame.origin, CGPoint.new(0, 500)).should == true
    end
    it "another_scroller should be sensible" do
      CGPointEqualToPoint(controller.another_scroller.contentOffset, CGPoint.new(0, 0)).should == true
    end
  end

  describe "should move at [0, 50]" do
    before do
      controller.scroll_view.contentOffset = [0, 50]
    end
    it "fixed_inside_button at [0, 50]" do
      CGPointEqualToPoint(controller.fixed_inside_button.frame.origin, CGPoint.new(10, 60)).should == true
    end
    it "float_inside_button at [0, 50]" do
      CGPointEqualToPoint(controller.float_inside_button.frame.origin, CGPoint.new(110, 10)).should == true
    end
    it "fixed_outside_button at [0, 50]" do
      CGPointEqualToPoint(controller.fixed_outside_button.frame.origin, CGPoint.new(10, 50)).should == true
    end
    it "float_outside_button at [0, 50]" do
      CGPointEqualToPoint(controller.float_outside_button.frame.origin, CGPoint.new(110, 0)).should == true
    end
    it "bg_image at [0, 50]" do
      CGPointEqualToPoint(controller.bg_image.frame.origin, CGPoint.new(50, 300)).should == true
    end
    it "diagonal at [0, 50]" do
      CGPointEqualToPoint(controller.diagonal.frame.origin, CGPoint.new(75, 200)).should == true
    end
    it "moving_thing at [0, 50]" do
      CGPointEqualToPoint(controller.moving_thing.frame.origin, CGPoint.new(0, 500)).should == true
    end
    it "another_scroller at [0, 50]" do
      CGPointEqualToPoint(controller.another_scroller.contentOffset, CGPoint.new(0, 50)).should == true
    end
  end

  describe "should move at [0, 100]" do
    before do
      controller.scroll_view.contentOffset = [0, 100]
    end
    it "fixed_inside_button at [0, 100]" do
      CGPointEqualToPoint(controller.fixed_inside_button.frame.origin, CGPoint.new(10, 110)).should == true
    end
    it "float_inside_button at [0, 100]" do
      CGPointEqualToPoint(controller.float_inside_button.frame.origin, CGPoint.new(110, 10)).should == true
    end
    it "fixed_outside_button at [0, 100]" do
      CGPointEqualToPoint(controller.fixed_outside_button.frame.origin, CGPoint.new(10, 50)).should == true
    end
    it "float_outside_button at [0, 100]" do
      CGPointEqualToPoint(controller.float_outside_button.frame.origin, CGPoint.new(110, -50)).should == true
    end
    it "bg_image at [0, 100]" do
      CGPointEqualToPoint(controller.bg_image.frame.origin, CGPoint.new(50, 200)).should == true
    end
    it "diagonal at [0, 100]" do
      CGPointEqualToPoint(controller.diagonal.frame.origin, CGPoint.new(150, 200)).should == true
    end
    it "moving_thing at [0, 100]" do
      CGPointEqualToPoint(controller.moving_thing.frame.origin, CGPoint.new(0, 500)).should == true
    end
    it "another_scroller at [0, 100]" do
      CGPointEqualToPoint(controller.another_scroller.contentOffset, CGPoint.new(0, 100)).should == true
    end
  end

  describe "should move at [50, 200]" do
    before do
      controller.scroll_view.contentOffset = [50, 200]
    end
    it "fixed_inside_button at [50, 200]" do
      CGPointEqualToPoint(controller.fixed_inside_button.frame.origin, CGPoint.new(60, 210)).should == true
    end
    it "float_inside_button at [50, 200]" do
      CGPointEqualToPoint(controller.float_inside_button.frame.origin, CGPoint.new(110, 10)).should == true
    end
    it "fixed_outside_button at [50, 200]" do
      CGPointEqualToPoint(controller.fixed_outside_button.frame.origin, CGPoint.new(10, 50)).should == true
    end
    it "float_outside_button at [50, 200]" do
      CGPointEqualToPoint(controller.float_outside_button.frame.origin, CGPoint.new(60, -150)).should == true
    end
    it "bg_image at [50, 200]" do
      CGPointEqualToPoint(controller.bg_image.frame.origin, CGPoint.new(150, 0)).should == true
    end
    it "diagonal at [50, 200]" do
      CGPointEqualToPoint(controller.diagonal.frame.origin, CGPoint.new(300, 200)).should == true
    end
    it "moving_thing at [50, 200]" do
      CGPointEqualToPoint(controller.moving_thing.frame.origin, CGPoint.new(80, 500)).should == true
    end
    it "another_scroller at [50, 200]" do
      CGPointEqualToPoint(controller.another_scroller.contentOffset, CGPoint.new(0, 200)).should == true
    end
  end

end
