module GM

  class Hr < UIView

    def self.new(options={})
      color = (options[:color] || :line_white).uicolor
      height = options[:height] || 1.pixel
      if options[:bottom]
        top = options[:bottom] + height.round - height
      else
        top = options[:top] || 0
      end

      x = options[:x] || 0
      width = options[:width] || (App.window.bounds.width - x)
      hr = self.alloc.initWithFrame([[x, top], [width, height]])
      hr.backgroundColor = color
      return hr
    end

  end

end
