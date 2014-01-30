class ParallaxDemoController < UIViewController
  include GM::Parallax

  attr :scroll_view
  attr :fixed_inside_button
  attr :float_inside_button
  attr :fixed_outside_button
  attr :float_outside_button
  attr :bg_image
  attr :diagonal
  attr :moving_thing
  attr :another_scroller

  layout do |root|
    @scroll_view = subview(UIScrollView, :scroll_view,
      frame: root.bounds.thinner(20),
      autoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight,
      contentSize: [root.bounds.width * 1.5, 1500],
      backgroundColor: :white.uicolor,
      ) do

      @fixed_inside_button = subview(UIButton.rounded, :fixed_inside_button,
        title:'Hey.',
        origin: [10, 10],
        )
      @fixed_inside_button.sizeToFit

      @float_inside_button = subview(UIButton.rounded, :float_inside_button,
        title:'Hey.',
        origin: [110, 10],
        )
      @float_inside_button.sizeToFit

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

    @fixed_outside_button = subview(UIButton.rounded, :button,
      title:'Hey.',
      origin: [10, 50],
      )
    @fixed_outside_button.sizeToFit

    @float_outside_button = subview(UIButton.rounded, :button,
      title:'Hey.',
      origin: [110, 50],
      )
    @float_outside_button.sizeToFit

    @another_scroller = subview(UIScrollView, :another_scroller,
      frame: @scroll_view.frame.beside(0, width: 20),
      backgroundColor: :white.uicolor,
      ) do
      100.times do |i|
        subview(UILabel, "label_#{i}", frame: [[0, 15 * i], [20, 15]], text: (i % 100).to_s)
      end
    end
  end

  def layoutDidLoad
    prepare_parallax(@scroll_view,
      @fixed_inside_button => false,
      @float_inside_button => true,
      @fixed_outside_button => false,
      @float_outside_button => true,
      @bg_image => [-2, 2],
      @diagonal => ->(offset) { CGPoint.new(offset.y * 1.5, 0) },
      @moving_thing => ->(offset) { (120..400) === offset.y ? CGPoint.new(offset.y - 120, 0) : (offset.y < 120 ? CGPoint.new(0, 0) : CGPoint.new(280, 0)) },
      @another_scroller => [0, 1],  # contentOffset.y will be the same when scroll_view is changed
      )
  end

end
