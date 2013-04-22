def draw_detail_disclosure(target)
  bounds = target.bounds

  # white border around button
  draws = [
    GM::D::circle(bounds.center, 11.5, :white).fill(:white),
  ]

  # the blue background consists of two radial gradients - the first is solid, the
  # second fades out a little
  blue_bg = GM::D::radial_gradient(bounds.center + CGPoint.new(0, 25), 48, {
    0.0  => [27,107,219],
    0.53 => [27,107,219],
    0.55 => [68,132,226],
    1.0  => [120,166,233],
  })

  # we'll mask inside this oval
  oval = bounds.center.rect_of_size([0, 0]).grow(9.5)
  # create the mask, with its contents
  draws << GM::D::mask(UIBezierPath.bezierPathWithOvalInRect(oval), [blue_bg])
  # draw the ">" shadow in dark blue
  # draws << GM::D::path(bounds.center + CGPoint.new(-1.5, -5.75)).stroke([2, 71, 182].uicolor(0.6)).delta(5, 5).delta(-5, 5).line_width(3)
  # and the white one on top
  # draws << GM::D::path(bounds.center + CGPoint.new(-1.5, -5)).stroke(:white).delta(5, 5).delta(-5, 5).line_width(3)

  drawing = GM::Drawing.new(bounds, draws).tap { |v|
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight
    v.contentMode = UIViewContentModeRedraw
  }
  $data = drawing.uiimage.nsdata
  target << drawing
end
