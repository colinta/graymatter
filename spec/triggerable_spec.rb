describe "Triggerable module" do
  describe "TriggerableDemoView" do
    before do
      @view = TriggerableDemoView.alloc.initWithFrame([[0, 0], [100, 100]])
      @event = nil
      @view.on :bam, :boom { |event|
        @event = event
      }
    end

    it "should have `on` and `off` methods" do
      @view.triggerable_target_action(:bam).length.should == 1
      @view.triggerable_target_action(:boom).length.should == 1
      @view.triggerable_target_action(:imaginary).length.should == 0
    end

    it "should have `trigger` method - bam" do
      @view.trigger :bam
      @event.should == :bam
      @view.trigger :boom
      @event.should == :boom
    end

    it "should ignore `trigger` events that weren't registered" do
      @view.trigger :ignored
      @event.should == nil
    end
  end

  describe "TriggerableDemoController" do
    tests TriggerableDemoController

    it "should respond to touch events - :bam" do
      tap('Bam')
      controller.event.should == :bam
      controller.bam.should == true
      controller.boom.should == false
    end

    it "should respond to touch events - :boom" do
      tap('BOOM')
      controller.event.should == :boom
      controller.boom.should == true
      controller.bam.should == false
    end
  end

end
