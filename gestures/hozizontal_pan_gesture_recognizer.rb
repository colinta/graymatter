class HorizontalPanGestureRecognizer < UIPanGestureRecognizer
  DefaultThreshold = 4
  attr_accessor :threshold

  def initWithTarget(target, action: action)
    super.tap do
      @threshold = DefaultThreshold
      my_reset
    end
  end

  def touchesMoved(touches, withEvent:event)
    super
    return if self.state == UIGestureRecognizerStateFailed

    nowPoint = touches.anyObject.locationInView(self.view)
    prevPoint = touches.anyObject.previousLocationInView(self.view)
    @move_x += prevPoint.x - nowPoint.x
    @move_y += prevPoint.y - nowPoint.y
    if ! @dragging
      if @move_x.abs > @threshold
        @dragging = true
      elsif @move_y.abs > @threshold
        self.state = UIGestureRecognizerStateFailed
        @dragging = true
      end
    end
  end

  def reset
    super
    my_reset
  end

 private
  def my_reset
    @move_x = 0
    @move_y = 0
    @dragging = false
  end
end
