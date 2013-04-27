module GM
  # "swoops" a view back, and loads another view as a modal
  module BackFiend

    def showFiend(show_view)
      return if @fiend_overlay

      if resigner = GM.window.first_responder
        resigner.resignFirstResponder
      end

      @fiend_hiders = GM.window.subviews.dup
      @fiend_target = GM.window.uiimage.uiimageview
      @fiend_gradient = @fiend_target.subview(GradientView,
        frame: @fiend_target.bounds.height(30).down(20),
        startColor: :black.uicolor,
        finalColor: :clear.uicolor,
        angle: -90.degrees,
        alpha: 0,
        )
      @fiend_gradient.fade_in

      GM.window << @fiend_target
      @fiend_hiders.each &:hide

      @fiend_overlay = UIScrollView.alloc.initWithFrame(GM.app_frame)
      @fiend_overlay.contentSize = [@fiend_overlay.bounds.width, 332]
      @fiend_overlay.alpha = 0
      @fiend_overlay.layer.opacity = 0
      @fiend_overlay.backgroundColor = :black.uicolor(0.25)
      GM.window << @fiend_overlay
      @fiend_overlay.fade_in

      @fiend_closer = UIControl.alloc.initWithFrame(@fiend_overlay.bounds)
      @fiend_closer.on :touch {
        hideForgotPassword
      }
      @fiend_overlay << @fiend_closer

      @fiend_modal = show_view
      @fiend_modal.frame = @fiend_modal.frame.down(@fiend_overlay.frame.height)
      @fiend_modal.layer.shadowOpacity = 1
      @fiend_modal.layer.shadowRadius = 10
      @fiend_overlay << @fiend_modal
      @fiend_modal.slide :up, 406

      scale = 0.6
      up = -140
      perspective = -0.0005
      UIView.animation_chain(duration:200.millisecs, options:UIViewAnimationOptionCurveLinear) {
        @fiend_target.layer.transform = CATransform3DTranslate(CATransform3DScale(CATransform3DPerspective(@fiend_target.layer.transform, 0, perspective), scale, scale, scale), 0, up, 0)
      }.and_then(duration:300.millisecs, options:UIViewAnimationOptionCurveLinear) {
        @fiend_target.layer.transform = CATransform3DTranslate(CATransform3DScale(CATransform3DIdentity, scale, scale, scale), 0, up, 0)
      }.start
    end

    def hideFiend
      return unless @fiend_overlay

      @fiend_modal.slide :down, 406
      @fiend_overlay.fade_out_and_remove do
        @forgot_password_ctlr.view.removeFromSuperview
        @forgot_password_ctlr = nil
        @fiend_overlay = nil
      end
      @fiend_gradient.fade_out

      UIView.animation_chain {
        @fiend_target.layer.transform = CATransform3DIdentity
      }.and_then {
        @fiend_hiders.each &:show
        @fiend_target.removeFromSuperview
      }.start
    end

  end
end
