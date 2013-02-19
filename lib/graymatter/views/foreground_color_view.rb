# @requires module:SetupView
module GM
  class ForegroundColorView < UIView
    include SetupView

    attr_accessor :color
    attr_accessor :path

    def setup
      self.opaque = false
      self.color = self.backgroundColor
      self.backgroundColor = :clear.uicolor
    end

    def color=(color)
      @color = color
      setNeedsDisplay
    end

    def path=(path)
      @path = path
      setNeedsDisplay
    end

    def drawRect(rect)
      return unless color

      context = UIGraphicsGetCurrentContext()

      if path
        CGContextSaveGState(context)  # save before clipping
        path.addClip
      end

      color.setFill
      CGContextAddRect(context, self.bounds)
      CGContextDrawPath(context, KCGPathFill)

      if path
        CGContextRestoreGState(context)  # restore after clipping
      end
    end

  end
end