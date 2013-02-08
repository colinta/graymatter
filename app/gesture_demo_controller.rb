class GestureDemoController < UIViewController
  attr :horizontal
  attr :vertical

  def viewDidLoad
    @horizontal = false
    @vertical = false

    self.view.on_gesture(GM::HorizontalPanGestureRecognizer) {
      @horizontal = true
    }
    self.view.on_gesture(GM::VerticalPanGestureRecognizer) {
      @vertical = true
    }
  end

end
