GrayMatter
==========

A collection of useful tools, by Colin T.A. Gray.  Depends on [SugarCube][].

[SugarCube]: https://github.com/rubymotion/sugarcube

GestureRecognizers
------------------

### HorizontalPanGestureRecognizer
### VerticalPanGestureRecognizer

These recognize a pan gesture in only one direction.  The default threshold is
`HorizontalPanGestureRecognizer::DefaultThreshold` (4), but can be changed with the
`threshold` attribute.

UIViews
-------

### SetupView (module)

It infuriates me that there are two ways to setup a view: `initWithFrame` and
`awakeFromNib`.  There needs to be *one* place to put code for custom views.
`SetupView` provides that one place.

```ruby
class MyView < UIView
  include SetupView

  def setup
    # this code will only be run once
  end
end
```

### ForegroundColorView

Sometimes you need a background color that is part of your view hierarchy.  I
can't remember why **I** needed to, but this view does the trick.  Assign a
`color` attribute and it will fill a rect with that color.  Also supports a
`path` attribute, which is a `UIBezierPath` that clips the view.

Basically, you can draw a swath of color this way.

### FabTabView

This is a very simple tab view.  It controls a list of controllers, which should
implement a `fab_tab_button` attribute (if you want to explicitly declare that
your controller is a FabTabController, you can `include FabTabController`).
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

### GradientView

This used to be a separate gem, but I've removed that.  It lives here now.

It's great as a background view!

TODO: implement the radial gradient.  I just haven't needed it.

### TypewriterView

A `UICollectionView` can do everything that `TypewriterView` does, but with lots
more methods to implement. ;-)

Add a bunch of subviews to `TypewriterView` and it will display them
left-to-right, top-to-bottom.  You can assign `scroll_view` and
`background_view` objects, too, and the `scroll_view` will get assigned the
appropriate `contentSize`, and the `background_view` will be ignored when it
lays out the subviews, and it will be sized to cover the entire view.

### InsetTextField

I'm sure we've all implemented a subclass of `UITextField` that implements the
methods `placeholderRectForBounds`, `textRectForBounds`, `editingRectForBounds`

### MaskedImageView

Masks a UIImageView using a UIBezierPath.  Assign an image to `image`, and a
bezier path to `path`, and that's it.

### RoundedRectView

You can assign a different radius for each side.  Radius is attached to a *side*
(not per corner), so that means that there will be some symmetry.


### KeyboardHandler

### PeoplePicker

### SelectOneTableViewController

This one is really handy for table-based forms.  Assign `items` and style them
with a `cell_handler` block, and an optional `include_other` boolean will
include a UITextField.  An `on_done` block is called with one of the objects in
`items` when it is selected.

