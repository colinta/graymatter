module GM
  class GradientView < UIView
    include SetupView

    # list of colors, you can control spacing with the `points` array
    attr_updates :colors
    # alias for colors[0], ignored if you assign a `colors` array.
    attr_updates :startColor
    # alias for colors[points.length - 1], ignored if you assign a `colors` array.
    attr_updates :finalColor
    # :linear, :radial
    attr_updates :type
    # array of numbers from 0..1, indicating where the color begins.  the list
    # better be sorted!
    attr_updates :points

    # for linear gradient:
    attr_updates :angle  # 0..2.pi

    # for radial gradient:
    attr_updates :gradientCenter  # CGPoint

    def setup
      self.startColor = :white
      self.finalColor = :black
      self.colors = nil
      self.points = nil
      self.angle = Math::PI / 2
      self.type = :linear
      self.backgroundColor = UIColor.clearColor
    end

    def startColor=(value)
      @startColor = value.uicolor
      setNeedsDisplay
    end

    def finalColor=(value)
      @finalColor = value.uicolor
      setNeedsDisplay
    end

    def drawRect(rect)
      case self.type
      when :linear
        drawLinearGradient
      when :radial
        drawRadialGradient
      end
    end

    def colors
      if @colors
        @colors
      else
        [self.startColor, self.finalColor]
      end
    end

    def points
      if @points
        @points
      else
        colors.each_index.map do |i|
          i.to_f / (colors.length - 1).to_f
        end
      end
    end

    def drawLinearGradient
      w = CGRectGetWidth(self.frame)
      h = CGRectGetHeight(self.frame)
      if w == 0 or h == 0
        return
      end

      colors = self.colors.dup
      points = self.points.dup

      if colors.length != points.length
        raise "Number of points (#{points.inspect}) does not match number of colors (#{colors.inspect})"
      end

      # colors is a list of `UIColor`s, but we will need a list of `CGColorRef`s
      cgcolors = colors.map { |color|
        color = color.uicolor unless color.is_a? UIColor
        color.CGColor
      }

      # simplify things a little by getting an angle between 0...2π
      angle = self.angle % (Math::PI * 2)
      # CG coordinate system has angles increasing clockwise, but angles should
      # increase counter-clockwise
      angle = Math::PI * 2 - angle

      if angle > Math::PI
        angle = angle - Math::PI
        cgcolors.reverse!
        points = points.map{ |p| 1 - p }.reverse
      end

      # make sure all the points are ascending
      points.inject { |p1, p2|
        if p1 > p2
          raise "Points must be in ascending order (not #{points.inspect})"
        end
        p2
      }

      context = UIGraphicsGetCurrentContext()
      color_space = CGColorSpaceCreateDeviceRGB()

      center = CGPoint.new(w/2, h/2)
      radius = Math.hypot(center.x, center.y)
      r_angle = Math.atan2(center.y, center.x)
      if angle < Math::PI/2 || angle > 3*Math::PI/2
        inner_angle = r_angle - (angle)
      else
        inner_angle = r_angle - (Math::PI - angle)
      end
      l = radius * Math.cos(inner_angle)

      start_point = center + CGPoint.new(l * Math.cos(angle - Math::PI),
                                         l * Math.sin(angle - Math::PI))
      final_point = center + CGPoint.new(l * Math.cos(angle),
                                         l * Math.sin(angle))

      gradient = CGGradientCreateWithColors(color_space, cgcolors, points.to_pointer(:float))
      CGContextDrawLinearGradient(context, gradient, start_point, final_point, 0)
    end

    def drawRadialGradient
    end

    def to_s(options={})
      super options.merge(inner: {colors: colors, points: points, angle: angle})
    end

  end
end

if defined? Kiln
  Kiln::Log.info('Found kiln')
  class << GM::GradientView
    def kiln
      @kiln ||= {
        'Color' => {
          startColor: Kiln::ColorEditor,
          finalColor: Kiln::ColorEditor,
        },
      }
    end
  end
end
