module GM
  class ModalView < UIView
    attr_accessor :spinner

    def layoutSubviews
      super
      modal_size = bounds.size
      spinner.center = [modal_size.width / 2, modal_size.height / 2]
    end
  end

  # A modal overlay.
  module HideShowModal
    class << self
      attr_accessor :modal_view
      attr_accessor :modal_is_visible
    end

    # call this method from your controller's `viewDidLoad` method
    def prepare_hide_show_modal(target=nil)
      @hide_show_modal_target = target || App.window

      unless HideShowModal.modal_view
        modal_view = ModalView.new
        modal_view.backgroundColor = :black.uicolor(0.5)
        modal_view.autoresizingMask = :full.uiautoresizingmask
        modal_view.spinner = UIActivityIndicatorView.large
        modal_view.spinner.center = [modal_view.bounds.width / 2, modal_view.bounds.height / 2]
        modal_view.spinner.startAnimating
        modal_view << modal_view.spinner
        HideShowModal.modal_view = modal_view
      end

      unless HideShowModal.modal_view.superview == @hide_show_modal_target
        @hide_show_modal_target << HideShowModal.modal_view
        HideShowModal.modal_view.frame = @hide_show_modal_target.bounds
        HideShowModal.modal_view.setNeedsLayout
      end

      HideShowModal.modal_view.alpha = 0.0
      HideShowModal.modal_is_visible = false
    end

    def show_modal_in(time_after)
      @timer.invalidate if @timer
      @timer = time_after.later do
        if @timer
          show_modal
        end
      end
    end

    def show_modal
      @timer.invalidate if @timer

      @hide_show_modal_target.bringSubviewToFront(HideShowModal.modal_view)
      unless HideShowModal.modal_is_visible
        FuncTools.CFMain {
          HideShowModal.modal_view.alpha = 0.0
          HideShowModal.modal_view.show
          HideShowModal.modal_view.fade_in
        }
        HideShowModal.modal_is_visible = true
      end
    end

    def hide_modal
      @timer.invalidate if @timer
      @timer = nil

      FuncTools.CFMain {
        HideShowModal.modal_view.fade_out
      }
      HideShowModal.modal_is_visible = false
    end

  end
end
