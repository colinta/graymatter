module KeyboardHandler
  def kb_handler_start(scroll_view)
    NSNotificationCenter.defaultCenter.addObserver(self,
            selector: :'keyboard_did_show:',
            name: UIKeyboardDidShowNotification,
            object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self,
            selector: :keyboard_will_hide,
            name: UIKeyboardWillHideNotification,
            object: nil)
    @keyboard_handler_scroll_view = scroll_view
  end

  def kb_handler_stop
    NSNotificationCenter.defaultCenter.removeObserver(self, name: UIKeyboardDidShowNotification, object:nil)
    NSNotificationCenter.defaultCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object:nil)
  end

  def keyboard_did_show(notification)
    scroll_view = @keyboard_handler_scroll_view
    bottom = scroll_view.convertPoint([0, scroll_view.bounds.size.height], toView:nil).y + scroll_view.contentOffset.y
    inset_from_bottom = App.window.bounds.size.height - bottom

    kbd_height = notification.userInfo[UIKeyboardFrameBeginUserInfoKey].CGRectValue.size.height
    kbd_height -= inset_from_bottom
    return if kbd_height < 0

    insets = [0, 0, kbd_height, 0]
    scroll_view.contentInset = insets
    scroll_view.scrollIndicatorInsets = insets

    first_responder = self.view.first_responder
    if first_responder && first_responder.is_a?(UITextField)
      scroll_origin = scroll_view.convertPoint([0, 0], fromView:first_responder)
      scroll_rect = [scroll_origin, first_responder.size]
      scroll_view.scrollRectToVisible(scroll_rect, animated:true)
    end
  end

  def keyboard_will_hide
    insets = [0, 0, 0, 0]
    scroll_view = @keyboard_handler_scroll_view
    scroll_view.contentInset = insets
    scroll_view.scrollIndicatorInsets = insets
  end

end
