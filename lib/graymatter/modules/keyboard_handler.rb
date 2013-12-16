module GM
  module KeyboardHandler

    # @param scroll_view [UIScrollView] The view that is going to be maintained
    # @param insets [UIEdgeInsets] When the view is restored to full size, these
    #   insets will be used for the `contentInset` property.
    #   Default: [0, 0, 0, 0]
    def prepare_keyboard_handler(scroll_view, insets=nil)
      @keyboard_handler_scroll_view = scroll_view
      @keyboard_handler_insets = insets || scroll_view.contentInset
    end

    def keyboard_handler_start
      NSNotificationCenter.defaultCenter.addObserver(self,
              selector: :'keyboard_handler_keyboard_did_show:',
              name: UIKeyboardDidShowNotification,
              object: nil)
      NSNotificationCenter.defaultCenter.addObserver(self,
              selector: :keyboard_handler_keyboard_will_hide,
              name: UIKeyboardWillHideNotification,
              object: nil)

      if KeyboardState.visible?
        keyboard_handler_keyboard_did_show(KeyboardState.last_notification)
      end
    end

    def keyboard_handler_stop
      NSNotificationCenter.defaultCenter.removeObserver(self, name: UIKeyboardDidShowNotification, object:nil)
      NSNotificationCenter.defaultCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object:nil)
    end

    def keyboard_handler_keyboard_did_show(notification)
      scroll_view = @keyboard_handler_scroll_view
      kbd_rect = notification.userInfo[UIKeyboardFrameEndUserInfoKey].CGRectValue
      kbd_rect = GM.window.convertRect(kbd_rect, toView:scroll_view)

      kbd_height = kbd_rect.size.height
      return if kbd_height < 0

      @keyboard_handler_insets = scroll_view.contentInset
      insets = scroll_view.contentInset
      insets.bottom = kbd_height
      scroll_view.contentInset = insets
      scroll_view.scrollIndicatorInsets = insets

      first_responder = self.view.first_responder
      if first_responder && (first_responder.is_a?(UITextField) || first_responder.is_a?(UITextView))
        scroll_origin = scroll_view.convertPoint([0, 0], fromView:first_responder)
        scroll_rect = [scroll_origin, first_responder.size]
        scroll_view.scrollRectToVisible(scroll_rect, animated:true)
      end
    end

    def keyboard_handler_keyboard_will_hide
      scroll_view = @keyboard_handler_scroll_view
      scroll_view.contentInset = @keyboard_handler_insets
      scroll_view.scrollIndicatorInsets = @keyboard_handler_insets
    end

  end

end
