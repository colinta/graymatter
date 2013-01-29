module GM
  class FabTabView < UIView
    attr_accessor :delegate
    attr_accessor :root_controller
    attr_accessor :enabled
    attr_accessor :location  # :top or :bottom.  default: bottom
    attr_accessor :selected_index
    attr_accessor :tabHeight  # if this is set, it overrides min_button_height as the offset for thes selectedView
    # attr :selected_view_controller

    def self.new(controller)
      alloc.initInRootController(controller)
    end

    # This is the preferred way of instantiating the view, because it defaults to
    # covering the view's bounds.
    def initInRootController(controller)
      initWithFrame(controller.view.bounds).tap do
        self.autoresizingMask =  UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight
        @root_controller = controller
      end
    end

    def initWithFrame(frame)
      super.tap do
        @location = :bottom
        @enabled = true

        @selectedView = nil
        # self << (@tabView = UIView.new)
        self << (@buttons_view = UIView.new)

        @tabHeight = nil
        @min_button_height = nil
        @max_button_height = 0
        @selected_index = nil
      end
    end

    def view_controllers
      root_controller.childViewControllers
    end

    def selected_index=(selected_index)
      previous_controller = self.selected_view_controller
      @selected_index = selected_index
      selected_controller = self.selected_view_controller
      return unless selected_controller

      @buttons_view.subviews.each_index do |index|
        view = @buttons_view.subviews[index]
        # enable all buttons that are not selected
        view.enabled = (selected_index != index)
      end

      if previous_controller && selected_controller
        @root_controller.transitionFromViewController(previous_controller,
          toViewController:selected_controller,
          duration:0,
          options:UIViewAnimationOptionTransitionNone,
          animations:lambda{
            tab_height = @tabHeight || @min_button_height
            selected_controller.view.frame = CGRect.new([0, 0], [self.bounds.width, self.bounds.height - tab_height])

            @selectedView.removeFromSuperview if @selectedView
            self.insertSubview(selected_controller.view, atIndex:0)
          },
          completion:lambda{ |finished|
            delegate.fabTabSelectedIndex(selected_index) if delegate and delegate.respond_to?(:fabTabSelectedIndex)
            delegate.fabTabSelectedController(selected_controller) if delegate and delegate.respond_to?(:fabTabSelectedController)
            })
      else
        @selectedView.removeFromSuperview if @selectedView
        self.insertSubview(selected_controller.view, atIndex:0)
      end
      @selectedView = selected_controller.view

      return @selected_index
    end

    def selected_view_controller
      return unless @selected_index
      self.view_controllers[@selected_index]
    end

    def selected_view_controller=(vc)
      index = self.view_controllers.index(vc)
      raise "Unknown viewController #{vc.inspect} (not in self.view_controllers)" unless index
      self.selected_index = index
      vc
    end

    def layoutSubviews
      super
      tab_height = @tabHeight || @min_button_height || 0
      if self.location == :top
        if @selectedView
          @selectedView.frame = CGRect.new([0, tab_height], [self.frame.size.width, self.frame.size.height - tab_height])
        end
        # @tabView.frame = @selectedView.frame
        @buttons_view.frame = CGRect.new([0, 0], [self.frame.size.width, @max_button_height])
      else
        if @selectedView
          @selectedView.frame = CGRect.new([0, 0], [self.frame.size.width, self.frame.size.height - tab_height])
        end
        # @tabView.frame = @selectedView.frame
        @buttons_view.frame = CGRect.new([0, self.frame.size.height - @max_button_height], [self.frame.size.width, @max_button_height])
      end

      x = 0
      @buttons_view.subviews.each do |button|
        f = button.frame
        f.origin.x = x
        if self.location == :top
          f.origin.y = 0
        else
          f.origin.y = @max_button_height - f.size.height
        end
        x += f.size.width
        button.frame = f
      end
    end

    def <<(view_or_controller)
      if view_or_controller.is_a? UIView
        addSubview(view_or_controller)
      else
        addTab(view_or_controller)
      end
    end

    def addTab(controller)
      self.view_controllers << controller
      @buttons_view << controller.fab_tab_button

      if @max_button_height < controller.fab_tab_button.frame.size.height
        @max_button_height = controller.fab_tab_button.frame.size.height
      end

      if not @min_button_height or @min_button_height > controller.fab_tab_button.frame.size.height
        @min_button_height = controller.fab_tab_button.frame.size.height
      end

      # button touch handler - select the view controller
      my_index = self.view_controllers.length - 1
      controller.fab_tab_button.on :touch do
        self.selected_index = my_index if self.enabled
      end

      # the selected view was JUST added, it needs to be added to @selectedView
      if @selected_index && self.view_controllers.length == @selected_index + 1
        self.selected_index = @selected_index
      end
    end

  end


  module FabTabViewController
    attr_accessor :fab_tab_button
  end
end
