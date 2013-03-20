class FabTabDemoController < UIViewController

  layout do
    fab_tab = GM::FabTabView.new(self)
    fab_tab << Tab1Controller.new
    fab_tab << Tab2Controller.new
    fab_tab << Tab3Controller.new

    subview(fab_tab)
  end

end


class Tab1Controller < UIViewController
  include GM::FabTabViewController

  def init
    super.tap do
      self.title = 'tab 1'
      self.fab_tab_button = UIButton.rounded.style(title: 'Tab 1')
      self.fab_tab_button.sizeToFit
    end
  end

  layout do
    subview(UILabel,
      text: 'Tab 1',
      textColor: :white.uicolor,
      backgroundColor: :clear.uicolor,
      ).sizeToFit
  end

end


class Tab2Controller < UINavigationController
  include GM::FabTabViewController

  def init
    super.tap do
      self.title = 'tab 2'
      self.fab_tab_button = UIButton.rounded.style(title: 'Tab 2')
      self.fab_tab_button.sizeToFit

      self.viewControllers = [
        UIViewController.new.tap{|c|c.title='Tab 2 Page 1'},
        UIViewController.new.tap{|c|c.title='Tab 2 Page 2'},
        UIViewController.new.tap{|c|c.title='Tab 2 Page 3'},
      ]
    end
  end

end


class Tab3Controller < UINavigationController
  include GM::FabTabViewController

  def init
    super.tap do
      self.title = 'tab 3'
      self.fab_tab_button = UIButton.rounded.style(title: 'Tab 3')
      self.fab_tab_button.sizeToFit

      self.viewControllers = [
        UIViewController.new.tap{|c|c.title='Tab 3 Page 1'},
        UIViewController.new.tap{|c|c.title='Tab 3 Page 2'},
        UIViewController.new.tap{|c|c.title='Tab 3 Page 3'},
      ]
    end
  end

end
