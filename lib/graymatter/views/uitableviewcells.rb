module GM
  CellStylesheet = Teacup::Stylesheet.new {
    style :cell_label,
      background: :clear,
      color: '#526691',
      font: :system.uifont(12),
      alignment: :right
    if device_is? iPhone
      style :cell_label,
        frame: [[0, 15], [67, 15]]
    else
      raise "todo: make this the right size for an iPad"
      style :cell_label,
        frame: [[0, 15], [67, 15]]
    end

    style :cell_input,
      color: :black,
      font: :bold.uifont(15),
      borderStyle: :none,
      edgeInsets: [11.5, 3, 0, 0],
      autoresizing: :fill,
      frame: [[67, 0], [230, 45]]

    style :long_cell_label, extends: :cell_label,
      frame: [[0, 15], [180, 15]]

    style :cell_switch,
      frame: [[209, 8], [79, 27]]
  }

  class GMCellClass < UITableViewCell
    class << self
      attr_accessor :stylesheet

      # override the default stylesheet by assigning it to
      # `TextFieldCellClass.stylesheet` or `BooleanCellClass`.stylesheet
      def stylesheet
        @stylesheet ||= CellStylesheet
      end
    end
  end

  class TextFieldCellClass < GMCellClass
    attr_accessor :textLabel, :input

    def initWithStyle(style, reuseIdentifier:identifier)
      super(:value2.uitablecellstyle, reuseIdentifier:identifier).tap do
        self.stylesheet = self.class.stylesheet

        layout(self.contentView, :cell) do
          @textLabel = self.subview(UILabel, :cell_label)
          @input = self.subview(InsetTextField, :cell_input)
        end
      end
    end

    def didMoveToSuperview
      self.frame = self.frame.height(superview.height)
    end

  end


  class BooleanCellClass < GMCellClass
    attr_accessor :textLabel, :input

    def initWithStyle(style, reuseIdentifier:identifier)
      super(:value2.uitablecellstyle, reuseIdentifier:identifier).tap do
        self.stylesheet = self.class.stylesheet

        layout(self.contentView, :cell) do
          @textLabel = self.subview(UILabel, :long_cell_label)
          @input = self.subview(UISwitch, :cell_switch)
        end
        self.selectionStyle = UITableViewCellSelectionStyleNone
      end
    end
  end
end
