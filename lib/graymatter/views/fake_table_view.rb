module GM

  # This class looks like a bunch of table view rows... but they're not! shhh...
  class FakeTableView < UIView
    attr_accessor :views

    attr_updates :borderRadius
    attr_updates :borderColor

    def initWithFrame(frame)
      super.tap do
        @borderRadius = 6
        @borderColor = UIColor.lightGrayColor
        self.backgroundColor = UIColor.clearColor
        self.opaque = false
      end
    end

    def views
      @views ||= []
    end

    def addSubview(view)
      views << view
      setNeedsLayout
    end

    def removeView(view)
      views.delete(view)
      setNeedsLayout
    end

    # teacup support
    def restyle!(orientation=nil)
      if Teacup.should_restyle?
        layoutIfNeeded
      end
      super
    end

    def layoutSubviews
      super
      existing_views = self.subviews

      row_top = self.bounds.y
      row_width = self.bounds.width
      row_height = self.bounds.height / views.length
      views.each_with_index do |view, index|
        if views.length == 1
          table_row_class = OnlyFakeTableRowView
        elsif index == 0
          table_row_class = FirstFakeTableRowView
        elsif index + 1 == views.length
          table_row_class = LastFakeTableRowView
        else
          table_row_class = MiddleFakeTableRowView
        end

        table_row_frame = CGRect.new([self.bounds.x, row_top], [row_width, row_height])
        if existing_views[index] and existing_views[index].is_a? table_row_class
          table_row_view = existing_views[index]
          table_row_view.frame = table_row_frame
          # the existing_view might already contain the correct view
          if table_row_view.subviews != [view]
            table_row_view.subviews.each(&:removeFromSuperview)
            table_row_view << view
          end
        else
          if existing_views[index]
            existing_views[index].removeFromSuperview
          end

          table_row_view = table_row_class.alloc.initWithFrame(table_row_frame)
          table_row_view << view
          self.insertSubview(table_row_view, atIndex:index)
        end

        if index == 0
          row_top -= 1
        end
        row_top += row_height
      end

      if existing_views.length > views.length
        existing_views[views.length..-1].each(&:removeFromSuperview)
      end
    end
  end


  class FakeTableRowView < UIView
    attr_accessor :foregroundColor

    def initWithFrame(frame)
      super
      self.backgroundColor = UIColor.clearColor
      self.foregroundColor = UIColor.whiteColor
      self.opaque = false
      self
    end

    def borderRadius
      superview ? superview.borderRadius : 0
    end

    def borderColor
      superview ? superview.borderColor : nil
    end

    def willRemoveSubview(view)
      if superview
        superview.removeView(view)
      end
      super
    end

    def drawRect(rect)
      context = UIGraphicsGetCurrentContext()
      CGContextSaveGState(context)

      CGContextAddPath(context, border_path)
      CGContextSetFillColorWithColor(context, self.foregroundColor.CGColor)
      CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
      CGContextDrawPath(context, KCGPathFillStroke)

      CGContextRestoreGState(context)
    end

  end


  class FirstFakeTableRowView < FakeTableRowView

    def border_path
      g_path = CGPathCreateMutable()
      CGPathMoveToPoint(g_path, nil, self.bounds.x, self.bounds.height)
      CGPathAddArc(g_path, nil, self.bounds.x + borderRadius, borderRadius, borderRadius, Math::PI, 3*Math::PI/2, false)
      CGPathAddArc(g_path, nil, self.bounds.width - borderRadius, borderRadius, borderRadius, 3*Math::PI/2, 0, false)
      CGPathAddLineToPoint(g_path, nil, self.bounds.width, self.bounds.height)
      CGPathAddLineToPoint(g_path, nil, self.bounds.x, self.bounds.height)
      g_path
    end

  end


  class MiddleFakeTableRowView < FakeTableRowView

    def border_path
      g_path = CGPathCreateMutable()
      CGPathMoveToPoint(g_path, nil, self.bounds.x, self.bounds.y)
      CGPathAddLineToPoint(g_path, nil, self.bounds.width, self.bounds.y)
      CGPathAddLineToPoint(g_path, nil, self.bounds.width, self.bounds.height)
      CGPathAddLineToPoint(g_path, nil, self.bounds.x, self.bounds.height)
      CGPathAddLineToPoint(g_path, nil, self.bounds.x, self.bounds.y)
      g_path
    end

  end


  class LastFakeTableRowView < FakeTableRowView

    def border_path
      g_path = CGPathCreateMutable()
      CGPathMoveToPoint(g_path, nil, self.bounds.x, self.bounds.y)
      CGPathAddArc(g_path, nil, self.bounds.x + borderRadius, self.bounds.height - borderRadius, borderRadius, Math::PI, Math::PI/2, true)
      CGPathAddArc(g_path, nil, self.bounds.width - borderRadius, self.bounds.height - borderRadius, borderRadius, Math::PI/2, 0, true)
      CGPathAddLineToPoint(g_path, nil, self.bounds.width, self.bounds.y)
      CGPathAddLineToPoint(g_path, nil, self.bounds.x, self.bounds.y)
      g_path
    end

  end


  class OnlyFakeTableRowView < FakeTableRowView

    def border_path
      g_path = CGPathCreateMutable()
      CGPathMoveToPoint(g_path, nil, self.bounds.x, borderRadius)
      CGPathAddArc(g_path, nil, self.bounds.x + borderRadius, self.bounds.height - borderRadius, borderRadius, Math::PI, Math::PI/2, true)
      CGPathAddArc(g_path, nil, self.bounds.width - borderRadius, self.bounds.height - borderRadius, borderRadius, Math::PI/2, 0, true)
      CGPathAddArc(g_path, nil, self.bounds.width - borderRadius, borderRadius, borderRadius, 0, 3*Math::PI/2, true)
      CGPathAddArc(g_path, nil, self.bounds.x + borderRadius, borderRadius, borderRadius, 3*Math::PI/2, Math::PI, true)
      g_path
    end

  end

end
