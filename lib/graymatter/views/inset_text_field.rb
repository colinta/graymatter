module GM
  class InsetTextField < UITextField
    include SetupView

    attr_accessor :edgeInsets

    def setup
      @edgeInsets = SugarCube::CoreGraphics::EdgeInsets(10, 10, 10, 10)
    end

    def edgeInsets=(val)
      @edgeInsets = SugarCube::CoreGraphics::EdgeInsets(val)
    end

    # placeholder position
    def placeholderRectForBounds(bounds)
      UIEdgeInsetsInsetRect(bounds, @edgeInsets)
    end

    # text position
    def textRectForBounds(bounds)
      UIEdgeInsetsInsetRect(bounds, @edgeInsets)
    end

    # editing position
    def editingRectForBounds(bounds)
      # super
      UIEdgeInsetsInsetRect(bounds, @edgeInsets)
    end

  end
end
