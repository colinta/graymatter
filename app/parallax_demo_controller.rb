
class ParallaxDemoController < UIViewController
  include GM::Parallax

  attr :scroll_view
  attr :button
  attr :bg_image
  attr :diagonal
  attr :moving_thing
  attr :another_scroller

  layout do |root|
    @scroll_view = subview(UIScrollView, :scroll_view,
      frame: root.bounds.thinner(20),
      autoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight,
      contentSize: [root.bounds.width - 20, 2000],
      backgroundColor: :white.uicolor,
      ) do

      @button = subview(UIButton.rounded, :button,
        title:'Hey.',
        origin: [10, 10],
        )
      @button.sizeToFit

      @bg_image = subview('funny-guy'.uiimageview, :bg_image,
        origin: [50, 400],
        )
      @diagonal = subview(UIView, :diagonal,
        frame: [[0, 200], [20, 20]],
        backgroundColor: :red.uicolor,
        )
      @moving_thing = subview(UIView, :moving_thing,
        frame: [[0, 500], [20, 20]],
        backgroundColor: :green.uicolor,
        )
    end

    @another_scroller = subview(UIScrollView, :another_scroller,
      frame: @scroll_view.frame.beside(0, width: 20),
      backgroundColor: :white.uicolor,
      ) do
      100.times do |i|
        subview(UILabel, :"label_#{i}", frame: [[0, 15 * i], [20, 15]], text: (i % 100).to_s)
      end
    end
  end

  def layoutDidLoad
    prepare_parallax(@scroll_view,
      @button => false,
      @bg_image => 2,
      @diagonal => {x:1},
      @moving_thing => ->(offset) { (500..1000) === offset.y ? [offset.y - 500, 0] : nil },
      @another_scroller => [0, 1],  # contentOffset.y will be the same when scroll_view is changed
      )
  end

end
