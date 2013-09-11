module GM
  class InsetTextField < UITextField
    include SetupView

    attr_updates :edgeInsets

    def setup
      @edgeInsets = SugarCube::CoreGraphics::EdgeInsets(10, 10, 10, 10)
    end

    def edgeInsets=(val)
      @edgeInsets = SugarCube::CoreGraphics::EdgeInsets(val)
      setNeedsDisplay
    end

    # placeholder position
    def placeholderRectForBounds(bounds)
      UIEdgeInsetsInsetRect(bounds, self.edgeInsets)
    end

    # text position
    def textRectForBounds(bounds)
      UIEdgeInsetsInsetRect(bounds, self.edgeInsets)
    end

    # editing position
    def editingRectForBounds(bounds)
      # super
      UIEdgeInsetsInsetRect(bounds, self.edgeInsets)
    end

  end
end
