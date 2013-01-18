module SetupView

  def initWithFrame(frame)
    super.tap do
      _setup
    end
  end

  def init
    initWithFrame(CGRect.empty)
  end

  def awakeFromNib
    _setup
  end

  # if @_view_setup is nil, returns nil.  Next time, though, it will return true
  def _setup_once
    @_view_setup.tap {
      @_view_setup = true
    }
  end

  def _setup
    return if _setup_once
    setup
  end

  def setup
  end

end
