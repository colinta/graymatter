module GM
  # This code can be added to any UIView to emulate the functionality of
  # SugarCube's `UIControl#on` and `#off` methods.  It doesn't require the use
  # of the `UIControlEvent`s, you can just use any symbol names.
  #
  # @example
  #   class BamBoomView < UIView
  #     include GM::Triggerable
  #
  #     def initWithFrame(frame)
  #       super.tap do
  #         bam_button = UIButton.rounded
  #         bam_button.setTitle('Bam', forState: :normal.uicontrolstate)
  #         bam_button.sizeToFit
  #         bam_button.on :touch {
  #           self.trigger :bam
  #         }
  #         self << bam_button
  #
  #         boom_button = UIButton.rounded
  #         boom_button.setTitle('BOOM', forState: :normal.uicontrolstate)
  #         boom_button.sizeToFit
  #         boom_button.on :touch {
  #           self.trigger :boom
  #         }
  #         self << boom_button
  #       end
  #     end
  #   end
  #
  #   cell = BamBoomView.new
  #   cell.on :bam {
  #     puts "BAM!"
  #   }
  #   cell.on :boom {
  #     puts "BOOM!"
  #   }
  module Triggerable

    def triggerable_target_action(event=nil)
      if event
        # recursive call, which will run the code in `else` below
        triggerable_target_action[event] ||= []
      else
        @triggerable_target_action ||= {}
      end
    end

    def on(*events, &action)
      events.each do |event|
        triggerable_target_action(event).push(action)
      end
    end

    def off(*events)
      events.each do |event|
        triggerable_target_action[event] = nil
      end
    end

    def trigger(event, info)
      triggerable_target_action(event).each do |action|
        if action.arity == 0
          action.call
        else
          action.call(info)
        end
      end
    end

  end
end
