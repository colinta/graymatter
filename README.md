GrayMatter
==========

A collection of useful tools, by Colin T.A. Gray.  Depends on [SugarCube][].
Tests require [Teacup][].

module namespace: `GM`

[SugarCube]: https://github.com/rubymotion/sugarcube
[Teacup]: https://github.com/rubymotion/teacup

GestureRecognizers
------------------

### GM::HorizontalPanGestureRecognizer
### GM::VerticalPanGestureRecognizer

These recognize a pan gesture in only one direction.  The default threshold is
`HorizontalPanGestureRecognizer::DefaultThreshold` (4), but can be changed with the
`threshold` attribute.

UIViews
-------

### GM::SetupView (module)

It infuriates me that there are two ways to setup a view: `initWithFrame` and
`awakeFromNib`.  There needs to be *one* place to put code for custom views.
`SetupView` provides that one place.

```ruby
class MyView < UIView
  include GM::SetupView

  def setup
    # this code will only be run once
  end
end
```

### GM::ForegroundColorView

Sometimes you need a background color that is part of your view hierarchy.  I
can't remember why **I** needed to, but this view does the trick.  Assign a
`color` attribute and it will fill a rect with that color.  Also supports a
`path` attribute, which is a `UIBezierPath` that clips the view.

Basically, you can draw a swath of color this way.

### GM::FabTabView

This is a very simple tab view.  It controls a list of controllers, which should
implement a `fab_tab_button` attribute (if you want to explicitly declare that
your controller is a FabTabController, you can `include GM::FabTabController`).
The `fab_tab_button` should be a subcalss of `UIControl`.

When you use a `FabTabView`, you must assign a `root_controller`, and its child
controllers must .  An example says it all I think:

```ruby
def viewDidLoad
  ctlr_a = CustomControllerA.new
  self.addChildViewController(ctlr_a)
  ctlr_b = CustomControllerB.new
  self.addChildViewController(ctlr_b)

  # the defaults that we take advantage of using this method:
  #   - assign the root_controller, obviously
  #   - the tab view will be sized to cover the entire view bounds of the root
  #     view controller
  self.view << FabTabView.alloc.initInRootController(self)
  # self.view << FabTabView.new(self) does the same thing
end
```

Why use a custom tab controller?  Because the built-in one does not support
custom buttons, that's the only reason.  This one is much less feature-rich, but
gets the job done!

TODO: support pressing the tab button to return to a navigation controller's
root view.

### GM::GradientView

This used to be a separate gem, but I've removed that.  It lives here now.

It's great as a background view!

TODO: implement the radial gradient.  I just haven't needed it.

### GM::TypewriterView

A `UICollectionView` can do everything that `TypewriterView` does, but with lots
more delegate methods to implement. ;-)

Add a bunch of subviews to `TypewriterView` and it will display them
left-to-right, top-to-bottom.  You can assign `scroll_view` and
`background_view` objects, too, and the `scroll_view` will get assigned the
appropriate `contentSize`, and the `background_view` will be ignored when it
lays out the subviews, and it will be sized to cover the entire view.

### GM::InsetTextField

I'm sure we've all implemented a subclass of `UITextField` that implements the
methods `placeholderRectForBounds`, `textRectForBounds`, `editingRectForBounds`

### GM::MaskedImageView

Masks a UIImageView using a UIBezierPath.  Assign an image to `image`, and a
bezier path to `path`, and that's it.

### GM::RoundedRectView

You can assign a different radius for each side.  Radius is attached to a *side*
(not per corner), so that means that there will be some symmetry.

UIViewController modules
------

These modules are all meant to enhance your custom `UIViewController` classes.

### GM::KeyboardHandler

This one is so handy!  I've tried to get it to be both simple and thorough.
Ideally, you can pass it your scroll view, and it will take care of setting the
contentInset when the keyboard is shown.  You must call `keyboard_handler_start`
and `keyboard_handler_stop` - these methods register (and unregister) keyboard
events.  You pass the scroll view into the `prepare_keyboard_handler` method
before the view is visible.

```ruby
class MyController
  include GM::KeyboardHandler

  def viewDidLoad
    prepare_keyboard_handler(@scroll_view)
  end

  def viewWillAppear(animated)
    super
    keyboard_handler_start
  end

  def viewDidDisappear(animated)
    super
    keyboard_handler_stop
  end
end
```

### GM::HideShowModal

When you prepare the modal (usually in `viewDidLoad`) a modal view is added to
the bottom of the window (making it the frontmost view) and immediately hidden.
When you call `show_modal`, the modal fades in with a spinner.  `hide_modal`
does the obvious.  You can also use `show_modal_in(time_interval)` to have the
modal appear after a second or two.  Best used with `TheEntireUI.disable`, but
that's up to you.

```ruby
class MyController < UIViewController

  def viewDidLoad
    prepare_hide_show_modal  # accepts a `target` - the view where the modal should be added
  end

  def submit_button_pressed
    show_modal
    submit_form {
      hide_modal
      UIAlertView.alert "Success!"
    }
  end

  def refresh
    show_modal_in(1.second)
    fetch_data {
      hide_modal
    }
  end
end
```

### GM::Parallax

Given a scrollview and a hash of views and rules, you can easily create really
neat parallax effects.  The two simplest rules - `true` and `false` - will
either fix the view's location relative to its initial origin (`false` rule,
e.g. `"Should I move?" => false`) or it will scroll with the scroll view
(`"Should I move?" => true`).

The other thing it can do which is great is keep *two* scroll views in sync, so
if you've got a speadsheet header and you need it to keep up with scrolling
inside the cells-view, that is pretty easy.

```ruby
class MyController < UIViewController

  layout do
    @scroll_view = subview(UIScrollView, :scroll_view) do
      @bg_image = subview(UIImage, :bg_image)
    end
  end

  def viewDidLoad
    prepare_parallax(@scroll_view,
      @bg_image => [-2, 2],  # scrolls horizontally at double rate, and
      @diagonal => ->(offset) { CGPoint.new(offset.y * 1.5, 0) },
      @moving_thing => ->(offset) { (120..400) === offset.y ? CGPoint.new(offset.y - 120, 0) : (offset.y < 120 ? CGPoint.new(0, 0) : CGPoint.new(280, 0)) },
      @another_scroller => [0, 1],  # contentOffset.y will be the same when scroll_view is changed
      )
    prepare_parallax(@another_scroller,
      @scroll_view => [0, 1],  # you do need to mirror the two scroll view rules
      )
  end
end
```

UIView modules
-----

### GM::Triggerable

This is one of my favorites because I tend to make a lot of custom `UIView`
subclasses.  If you have lots of buttons or controls in there, it's messy to
create attributes for those and then "reach into" the view to assign
touch/change events to those controls.

Instead, `include GM::Triggerable` in that subclass and trigger custom events
from those controls.  It looks like this:

```ruby
class BamBoomView < UIView
  include GM::Triggerable

  def initWithFrame(frame)
    super.tap do
      bam_button = UIButton.rounded
      bam_button.setTitle('Bam', forState: :normal.uicontrolstate)
      bam_button.sizeToFit
      bam_button.on :touch {
        self.trigger :bam
      }
      self << bam_button

      boom_button = UIButton.rounded
      boom_button.setTitle('BOOM', forState: :normal.uicontrolstate)
      boom_button.sizeToFit
      boom_button.on :touch {
        self.trigger :boom
      }
      self << boom_button
    end
  end
end

cell = BamBoomView.new
cell.on :bam {
  puts "BAM!"
}
cell.on :boom {
  puts "BOOM!"
}
```

Tools
-----

### GM::PeoplePicker

Easy to show the address book people picker.

```ruby
GM::PeoplePicker.show { |person|
  # an ABAddressBook person will be available here, or nil if the operation was
  # canceled.
}
```

### GM::ExposeController

This is a very simple 'slied-to-expose' controller (it's not a subclass of
`UIViewController`, I'm using the term controller loosely here), like facebook's
and google's slide-menu.  It's very low tech, but effective!  You need to supply
it with a `target` - the view that will control the slide, and a `slide_view` -
the view that is moved to expose whatever is beneath it.

If you want to squeeze some performance out of it, you can assign a delegate and
respond to `will_open_slide_menu` and `did_close_slide_menu`, and you can add/remove
the background view at that time, which should save some CPU cycles.

### GM::SelectOneController

This one is really handy for table-based forms.  Assign `items` and style them
with a `cell_handler` block, and an optional `include_other` boolean will
include a UITextField.  An `on_done` block is called with one of the objects in
`items` when it is selected.

### GM::KeyboardState

Tracks the keyboard throughout the lifetime of the app - you can always find out
whether the keyboard is visible or not.  It is **SILLY** that this is not
something easy to determine! (well, now it is, I guess)

```ruby
if KeyboardState.visible?
  KeyboardState.last_notification
end
```

### FuncTools

A bunch of useful functions for asynchronous programming

```ruby
after = GM::FuncTools.after(2) { puts "hi!" }
after.call  # =>
after.call  # => 'hi!'
after.call  # => 'hi!'

keep_it_up = GM::FuncTools.until(3) { puts 'boo!' }
keep_it_up.call  # => 'hi!'
keep_it_up.call  # => 'hi!'
keep_it_up.call  # => 'hi!'
keep_it_up.call
keep_it_up.call

once = GM::FuncTools.once { puts "i'm outta here" }
once.call  # => "i'm outta here"
once.call  # =>
once.call  # =>
```

### TheEntireUI

This class is for easily accessing, obviously, the entire UI.  For now that just
means `disable`-ing and `enable`-ing the UI:

```ruby
GM::TheEntireUI.disable  # a view is added to the UIWindow that intercepts UI events
GM::TheEntireUI.enable  # the view is removed
```

You can call these using notifications, too, if that just fits your app better
(I can't imagine a situation where it would... but I ported this thing from code
that was using notifications, so there it is).

```ruby
GM::DisableUI.post_notification  # => GM::TheEntireUI.disable
GM::EnableUI.post_notification  # => GM::TheEntireUI.enable
```

### Locals

I won't deny the fact that this is a very *hacky* little addition, but it does
gets the job done!

Problem: local variables drop out of scope, and are released, because the
callbacks/blocks that use them are called.

Old School Solution: Use instance variables.  This is not always an option
New School Solution: Use `Locals`

```ruby
::Locals = GM::Locals

date = NSDate.new
Locals[:date] = date  # you will need to use a unique global name here

10.seconds.later {
  # you should re-assign the local variable; even though the *contents* are
  # being stored, the variable itself can get released.
  date = Locals[:date]
  p date
  # and then remove it from Locals, or else it might never get removed!
  Locals - :date
  # Locals.forget date
}
```