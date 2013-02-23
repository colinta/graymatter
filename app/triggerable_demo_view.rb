class TriggerableDemoView < UIView
  attr :bam_button
  attr :boom_button
  include GM::Triggerable

  def initWithFrame(frame)
    super.tap do
      bam_button = UIButton.rounded
      bam_button.setTitle('Bam', forState: :normal.uicontrolstate)
      bam_button.sizeToFit
      bam_button.on :touch {
        self.trigger :bam
      }
      self << bam_button

      boom_button = UIButton.rounded
      boom_button.setTitle('BOOM', forState: :normal.uicontrolstate)
      boom_button.frame = bam_button.frame.below
      boom_button.sizeToFit
      boom_button.on :touch {
        self.trigger :boom
      }
      self << boom_button
    end
  end
end


class TriggerableDemoController < UIViewController
  attr :triggerable
  attr :event
  attr :bam
  attr :boom

  layout do
    @triggerable = subview(TriggerableDemoView, frame: [[0, 0], [71, 88]])
  end

  def viewDidLoad
    super

    @triggerable.on :bam {
      @bam = true
      @boom = false
    }
    @triggerable.on :boom {
      @boom = true
      @bam = false
    }
    @triggerable.on :bam, :boom { |event|
      @event = event
    }
  end
end
