module GM
  # A modal overlay.
  module HideShowModal
    class << self
      attr_accessor :modal_view
      attr_accessor :modal_is_visible
    end

    # call this method from your controller's `viewDidLoad` method
    def prepare_hide_show_modal
      unless HideShowModalModule.modal_view
        modal_view = UIView.alloc.initWithFrame(App.window.bounds)
        modal_view.backgroundColor = :black.uicolor(0.5)
        spinner = UIActivityIndicatorView.large
        spinner.center = [modal_view.bounds.width / 2, modal_view.bounds.height / 2]
        spinner.startAnimating
        modal_view << spinner
        HideShowModalModule.modal_view = modal_view
      end
      unless HideShowModalModule.modal_view.isDescendantOfView(App.window)
        App.window << HideShowModalModule.modal_view
      end

      HideShowModalModule.modal_view.alpha = 0.0
      HideShowModalModule.modal_is_visible = false
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

      App.window.bringSubviewToFront(HideShowModalModule.modal_view)
      unless HideShowModalModule.modal_is_visible
        FuncTools.CFMain {
          HideShowModalModule.modal_view.alpha = 0.0
          HideShowModalModule.modal_view.show
          HideShowModalModule.modal_view.fade_in
        }
        HideShowModalModule.modal_is_visible = true
      end
    end

    def hide_modal
      @timer.invalidate if @timer
      @timer = nil

      FuncTools.CFMain {
        HideShowModalModule.modal_view.fade_out
      }
      HideShowModalModule.modal_is_visible = false
    end

  end
end
