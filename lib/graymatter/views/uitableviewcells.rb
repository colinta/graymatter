module GM
  class TextFieldCellClass < UITableViewCell
    attr_accessor :textLabel, :input

    def initWithStyle(style, reuseIdentifier:identifier)
      super(:value2.uitablecellstyle, reuseIdentifier:identifier).tap do
        @textLabel = UILabel.alloc.initWithFrame([[0, 15], [67, 15]])
        @textLabel.backgroundColor = :clear.uicolor
        @textLabel.textColor = '#526691'.uicolor
        @textLabel.font = :system.uifont(12)
        @textLabel.textAlignment = :right.uitextalignment
        self.contentView.addSubview(@textLabel)

        @input = InsetTextField.alloc.initWithFrame([[67, 0], [230, 45]])
        @input.textColor = :black.uicolor
        @input.font = :bold.uifont(15)
        @input.borderStyle = :none.uiborderstyle
        @input.edgeInsets = [11.5, 3, 0, 0]
        @input.autoresizingMask = :fill.uiautoresizemask
        self.contentView.addSubview(@input)
      end
    end

    def didMoveToSuperview
      self.frame = self.frame.height(superview.height)
    end

  end


  class BooleanCellClass < UITableViewCell
    attr_accessor :textLabel, :input

    def initWithStyle(style, reuseIdentifier:identifier)
      super(:value2.uitablecellstyle, reuseIdentifier:identifier).tap do
        self.selectionStyle = UITableViewCellSelectionStyleNone

        @textLabel = UILabel.alloc.initWithFrame([[0, 15], [180, 15]])
        @textLabel.backgroundColor = :clear.uicolor
        @textLabel.textColor = '#526691'.uicolor
        @textLabel.font = :system.uifont(12)
        @textLabel.textAlignment = :right.uitextalignment
        self.contentView.addSubview(@textLabel)

        @input = UISwitch.alloc.initWithFrame([[209, 8], [79, 27]])
        self.contentView.addSubview(@input)
      end
    end
  end
end
