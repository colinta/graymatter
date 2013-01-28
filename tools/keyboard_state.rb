module GM
  class KeyboardState
    NSNotificationCenter.defaultCenter.addObserver(self,
            selector: :'didShow:',
            name: UIKeyboard_did_showNotification,
            object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self,
            selector: :'willHide:',
            name: UIKeyboardWillHideNotification,
            object: nil)
    @visible = false
    @last_notification = nil

    class << self
      attr :last_notification

      def visible?
        @visible
      end

      def didShow(notification)
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
