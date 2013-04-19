module GM
  class FabTabView < UIView
    include SetupView

    attr_accessor :delegate
    attr_accessor :root_controller
    attr_accessor :enabled
    attr_accessor :selected_index

    # :top or :bottom.  default: bottom
    attr_accessor :location

    # if this is set, it overrides min_button_height as the offset for the selected_view
    attr_accessor :tab_height

    # attr :selected_view_controller

    def self.new(controller=nil)
      if controller
        alloc.initInRootController(controller)
      else
        super()
      end
    end

    # This is the preferred way of instantiating the view, because it defaults to
    # covering the view's bounds.
    def initInRootController(controller)
      initWithFrame(controller.view.bounds).tap do
        @root_controller = controller
      end
    end

    def init
      app_size = UIScreen.mainScreen.applicationFrame.size
      initWithFrame([[0, 0], [app_size.width, 0]])
    end

    def setup
      self.autoresizingMask =  UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight
      @location = :bottom
      @enabled = true

      @selected_view = nil
      # self << (@tabView = UIView.new)
      self << (@buttons_view = UIView.new)

      @tab_height = nil
      @min_button_height = nil
      @max_button_height = 0
      @selected_index = nil
    end

    def root_controller=(ctlr)
      @root_controller = ctlr
      assign_default_index
    end

    def view_controllers
      unless root_controller
        raise "GM::FabTabView#root_controller is a required attribute"
      end
      root_controller.childViewControllers
    end

    def selected_index=(selected_index)
      previous_controller = self.selected_view_controller
      @selected_index = selected_index
      selected_controller = self.selected_view_controller
      return unless selected_controller

      if selected_controller == previous_controller
        # imitate UITabBarController
        # but give delegate a chance to intercept
        if delegate && delegate.respond_to?(:fabTabPopToRoot)
          delegate.fabTabPopToRoot(selected_controller)
        else
          nav_ctlr = selected_controller.is_a?(UINavigationController) ? selected_controller : selected_controller.navigationController
          if nav_ctlr
            nav_ctlr.popToRootViewControllerAnimated(true)
          end
        end

        # no need to proceed
        return
      end

      @buttons_view.subviews.each_index do |index|
        view = @buttons_view.subviews[index]
        # enable all buttons that are not selected
        view.selected = (selected_index == index)
      end

      @selected_view.removeFromSuperview if @selected_view

      tab_height = @tab_height || @min_button_height
      selected_controller.view.frame = CGRect.new([0, 0], [self.bounds.width, self.bounds.height - tab_height])

      self.insertSubview(selected_controller.view, atIndex:0)
      @selected_view = selected_controller.view

      delegate.fabTabSelectedIndex(selected_index) if delegate and delegate.respond_to?(:fabTabSelectedIndex)
      delegate.fabTabSelectedController(selected_controller) if delegate and delegate.respond_to?(:fabTabSelectedController)

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
      tab_height = @tab_height || @min_button_height || 0
      if self.location == :top
        if @selected_view
          @selected_view.frame = CGRect.new([0, tab_height], [self.frame.size.width, self.frame.size.height - tab_height])
        end
        # @tabView.frame = @selected_view.frame
        @buttons_view.frame = CGRect.new([0, 0], [self.frame.size.width, @max_button_height])
      else
        if @selected_view
          @selected_view.frame = CGRect.new([0, 0], [self.frame.size.width, self.frame.size.height - tab_height])
        end
        # @tabView.frame = @selected_view.frame
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
      root_controller.addChildViewController(controller)
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

      # the selected view was JUST added, it needs to be added to @selected_view
      if @selected_index && self.view_controllers.length == @selected_index + 1
        self.selected_index = @selected_index
      end
    end

    def didMoveToSuperview
      super
      assign_default_index
    end

    def assign_default_index
      if root_controller
        @selected_index ||= 0
        self.selected_index = @selected_index
      end
    end

  end


  module FabTabViewController
    attr_accessor :fab_tab_button
  end
end
