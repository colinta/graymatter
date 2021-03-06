module GM
  DisableUI = 'GM::DisableUI'.freeze
  EnableUI = 'GM::EnableUI'.freeze

  # This class can enable or disable the UI, either via notification or direct
  # method calling.
  class TheEntireUI
    class << self
      def enable_notification(notification)
        enable(notification.userInfo)
      end

      def enable(options={})
        return unless @blocking_view
        @count ||= 1
        @count -= 1
        if @count <= 0
          @count = 0
          @blocking_view.removeFromSuperview
          @blocking_view = nil
        end
      end

      def disable_notification(notification)
        disable(notification.userInfo)
      end

      def disable(options={})
        @count ||= 0
        @count += 1
        return if @blocking_view
        @blocking_view = UIView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
        @blocking_view.stylename = :block_ui
        UIApplication.sharedApplication.keyWindow << @blocking_view
      end
    end

    EnableUI.add_observer(self, :enable_notification)
    DisableUI.add_observer(self, :disable_notification)
  end
end
