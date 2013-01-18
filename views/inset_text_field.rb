module GM
  class InsetTextField < UITextField
    include SetupView

    attr_accessor :edge_insets

    def setup
      @edge_insets = SugarCube::CoreGraphics::EdgeInsets(10, 10, 10, 10)
    end

    def edge_insets=(val)
      @edge_insets = SugarCube::CoreGraphics::EdgeInsets(val)
    end

    # placeholder position
    def placeholderRectForBounds(bounds)
      UIEdgeInsetsInsetRect(bounds, @edge_insets)
    end

    # text position
    def textRectForBounds(bounds)
      UIEdgeInsetsInsetRect(bounds, @edge_insets)
    end

    # editing position
    def editingRectForBounds(bounds)
      # super
      UIEdgeInsetsInsetRect(bounds, @edge_insets)
    end

  end
end
