module GM
  class KeyboardState
    NSNotificationCenter.defaultCenter.addObserver(self,
            selector: 'willShow:',
            name: UIKeyboardWillShowNotification,
            object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self,
            selector: 'willHide:',
            name: UIKeyboardWillHideNotification,
            object: nil)
    @visible = false
    @last_notification = nil

    class << self
      attr :last_notification

      def visible?
        @visible
      end

      def height
        if @visible
          kbd_rect = @last_notification.userInfo[UIKeyboardFrameEndUserInfoKey].CGRectValue
          return kbd_rect.height
        else
          return 0
        end
      end

      def willShow(notification)
        @last_notification = notification
        @visible = true
      end

      def willHide(notification)
        @last_notification = notification
        @visible = false
      end
    end

  end
end
