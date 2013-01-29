module GM
  class MaskedImageView < UIView

    # [UIImage]
    attr_accessor :image
    # [UIBezierPath]
    attr_accessor :path

    def drawRect(rect)
      return unless image

      if path
        context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)  # save before clipping
        path.addClip
        self.image.drawInRect(self.bounds)
        CGContextRestoreGState(context)  # restore after clipping
      else
        self.image.drawInRect(self.bounds)
      end
    end

  end
end
