module GM

  # This class looks like a bunch of table view rows... but they're not! shhh...
  class FakeTableView < UIView
    attr_accessor :views

    attr :borderRadius
    attr :borderColor

    def initWithFrame(frame)
      super.tap do
        @borderRadius = 6
        @borderColor = UIColor.lightGrayColor
        self.backgroundColor = UIColor.clearColor
        self.opaque = false

        @border_layer = CALayer.layer
        @border_layer.borderWidth = 1.pixel
        self.layer << @border_layer
        self.update_border_layer
      end
    end

    def update_border_layer
      if @border_layer
        layoutIfNeeded
        @border_layer.frame = self.layer.bounds.inset(self.insets)
        @border_layer.borderColor = @borderColor.CGColor
        @border_layer.cornerRadius = @borderRadius
      end
    end

    def setFrame(value)
      super
      self.update_border_layer
    end

    def insets
      @insets ||= UIEdgeInsetsMake(0, 0, 0, 0)
    end

    def insets=(insets)
      @insets = SugarCube::CoreGraphics::EdgeInsets(insets)
      self.setNeedsLayout
      self.update_border_layer
    end

    def borderRadius=(value)
      @borderRadius = value
      self.update_border_layer
    end

    def borderColor=(value)
      @borderColor = value
      self.update_border_layer
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

      table_bounds = self.bounds.inset(self.insets)
      row_top = table_bounds.y
      row_width = table_bounds.width
      row_height = table_bounds.height / self.views.length
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

        table_row_frame = CGRect.new([table_bounds.x, row_top], [row_width, row_height])
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

    # def drawRect(rect)
    #   context = UIGraphicsGetCurrentContext()
    #   CGContextSaveGState(context)

    #   CGContextRestoreGState(context)
    # end

  end


  class FirstFakeTableRowView < FakeTableRowView
  end


  class MiddleFakeTableRowView < FakeTableRowView
  end


  class LastFakeTableRowView < FakeTableRowView
  end


  class OnlyFakeTableRowView < FakeTableRowView
  end

end
