module GM

  if false
    # declaring these functions here will make them available in the REPL.
    CATransform3DMakeRotation(0, 0, 0, 0)
    CATransform3DMakeTranslation(0, 0, 0)
    CATransform3DMakeScale(1.0, 1.0, 1.0)
    CATransform3DRotate(t, 0, 0, 0, 0)
    CATransform3DScale(t, 0, 0, 0)
    CATransform3DTranslate(t, 0, 0, 0)
  end


  # This class is meant to be created using the `Drawler` method, passing in a
  # frame and a block that is executed in the `drawRect` method.  You can either
  # accept the context as an argument to the block, or use the `@context`
  # instance variable.
  class Drawler < UIView
    class << self
      attr_accessor :draw_code
    end

    def drawRect(rect)
      @context = UIGraphicsGetCurrentContext()
      CGContextSaveGState(@context)
      draw_code = self.class.draw_code
      if draw_code
        if draw_code.arity == 0
          instance_exec(&draw_code)
        else
          instance_exec(@context, &draw_code)
        end
      end
      CGContextRestoreGState(@context)
    end

  end


  def Drawler(frame=nil, &draw_code)
    klass = Class.new(Drawler)
    klass.draw_code = draw_code
    return frame ? klass.alloc.initWithFrame(frame) : klass
  end


  class Drawing < UIView
    attr_accessor :draw

    def self.new(frame=nil, drawing=nil)
      if frame
        instance = self.alloc.initWithFrame(frame)
      else
        instance = self.alloc.init
      end
      instance.draw = drawing if drawing
      return instance
    end

    def initWithFrame(frame)
      super.tap do
        self.backgroundColor = :clear.uicolor
      end
    end

    def draw=(drawing_primitives)
      if drawing_primitives.is_a? Enumerable
        @draw = drawing_primitives
      else
        @draw = [drawing_primitives]
      end
      drawing_primitives
    end

    def drawRect(rect)
      context = UIGraphicsGetCurrentContext()
      @draw.each do |drawing|
        CGContextSaveGState(context)
        drawing.draw
        CGContextRestoreGState(context)
      end
    end

    def intrinsicContentSize
      rect = nil
      @draw.each do |drawing|
        next unless drawing.respond_to?(:frame)

        if rect
          rect = CGRectUnion(rect, drawing.frame)
        else
          rect = drawing.frame
        end
      end

      rect and rect.size or [0, 0]
    end

  end

  module D

    class Draw
      def self.attr_assigner(name, default=nil, &converter)
        # writer calls the setter
        define_method("#{name}=") do |value|
          self.send(name, value)
        end
        # combined getter/setter
        define_method(name) do |*args|
          if args.length == 1
            value = args[0]
            if converter
              value = converter.call(value)
            end
            instance_variable_set("@#{name}", value)
            return self
          elsif args.length > 1
            raise "Too many args on the dance floor"
          else
            return instance_variable_get("@#{name}") || default
          end
        end
      end

      def draw
        raise 'Implement the `draw` method'
      end
    end

    class Primitive < Draw
      attr_assigner(:line_width, 1)
      attr_assigner(:line_dash)
      attr_assigner(:stroke, UIColor.clearColor) { |val| val ? val.uicolor : UIColor.clearColor }
      attr_assigner(:fill, UIColor.clearColor) { |val| val ? val.uicolor : UIColor.clearColor }
      attr_assigner(:fill_phase) { |val| val && SugarCube::CoreGraphics::Size(val) }

      # setup the default drawing context, and perform your drawing in the block
      # you pass to this function
      def defaults(context)
        CGContextSaveGState(context)
        stroke.setStroke
        fill.setFill
        if fill_phase
          CGContextSetPatternPhase(context, fill_phase)
        end
        CGContextSetLineWidth(context, self.line_width)
        if line_dash
          CGContextSetLineDash(context, 0, line_dash.to_pointer(:float), line_dash.length)
        end
        yield
        CGContextRestoreGState(context)
      end

      def color(*args)
        NSLog('Draw#color is deprecated in favor of Draw#stroke')
        stroke(*args)
      end

      def background(*args)
        NSLog('Draw#background is deprecated in favor of Draw#fill')
        fill(*args)
      end

    end

    class Line < Primitive
      attr_assigner(:p1) { |pt| SugarCube::CoreGraphics::Point(pt) }
      attr_assigner(:p2) { |pt| SugarCube::CoreGraphics::Point(pt) }

      def initialize(p1, p2)
        self.p1(p1)
        self.p2(p2)
      end

      def draw
        context = UIGraphicsGetCurrentContext()
        defaults(context) {
          CGContextMoveToPoint(context, p1.x, p1.y)
          CGContextAddLineToPoint(context, p2.x, p2.y)
          CGContextStrokePath(context)
        }
      end

      def frame
        frame = CGRectStandardize(CGRectMake(p1.x, p1.y,  p2.x - p1.x, p2.y - p1.y))
        if frame.size.width == 0
          frame.size.width = self.line_width
        end
        if frame.size.height == 0
          frame.size.height = self.line_width
        end
        frame
      end

      # convert the current line to a rect
      def rect()
        Rect.new(p1, p2)
          .stroke(stroke)
          .fill(fill)
          .fill_phase(fill_phase)
          .line_width(line_width)
          .line_dash(line_dash)
      end

    end

    class Rect < Line
      attr_assigner(:rect) { |rect| SugarCube::CoreGraphics::Rect(rect) }
      attr_assigner(:corner)

      def initialize(*rect_args)
        @rect = SugarCube::CoreGraphics::Rect(*rect_args)
      end

      def draw
        context = UIGraphicsGetCurrentContext()
        defaults(context) {
          if corner
            path = UIBezierPath.bezierPathWithRoundedRect(CGRectStandardize(rect), cornerRadius:corner)
            CGContextAddPath(context, path.CGPath)
          else
            CGContextAddRect(context, rect)
          end
          CGContextDrawPath(context, KCGPathFillStroke)
        }
      end

    end

    class Circle < Primitive
      attr_assigner(:center) { |pt| SugarCube::CoreGraphics::Point(pt) }
      attr_assigner(:radius)

      def initialize(center, radius=nil, fill_color=nil)
        self.center(center)
        self.radius(radius)
        self.stroke(:clear)  # default to no border
        self.fill(fill_color) if fill_color
      end

      def draw
        context = UIGraphicsGetCurrentContext()
        defaults(context) {
          CGContextAddEllipseInRect(context, frame)
          CGContextDrawPath(context, KCGPathFillStroke)
        }
      end

      def frame
        CGRectStandardize(CGRectMake(center_x - radius, center_y - radius,  radius * 2, radius * 2))
      end

      def center_x ; @center[0] ; end
      def center_y ; @center[1] ; end

    end

    class Path < Primitive
      attr_assigner(:path)

      def initialize(pt_or_path=nil)
        if pt_or_path.is_a?(UIBezierPath)
          @path = pt_or_path
        else
          @path = UIBezierPath.bezierPath

          if pt_or_path
            @path.moveToPoint(SugarCube::CoreGraphics::Point(pt_or_path))
            @last = pt_or_path
          end
        end
      end

      def delta(pt_or_x, y=nil)
        raise "No previous point" unless @last

        if pt_or_x.is_a?(Numeric)
          pt = SugarCube::CoreGraphics::Point(pt_or_x, y)
        else
          pt = SugarCube::CoreGraphics::Point(pt_or_x)
        end

        line(@last + pt)
      end

      def line(pt_or_x, y=nil)
        if pt_or_x.is_a?(Numeric)
          pt = SugarCube::CoreGraphics::Point(pt_or_x, y)
        else
          pt = SugarCube::CoreGraphics::Point(pt_or_x)
        end

        @path.addLineToPoint(pt)
        @last = pt
        self
      end

      def curve(pt, control:control)
        curve(pt, control1:control, control2: control)
      end

      def curve(pt, control1:control1, control2:control2)
        @path.addCurveToPoint(pt, controlPoint1:control1, controlPoint2:control2)
        @last = pt
        self
      end

      def draw
        @path.lineWidth = self.line_width

        context = UIGraphicsGetCurrentContext()
        defaults(context) {
          CGContextAddPath(context, @path.CGPath)
          CGContextDrawPath(context, KCGPathFillStroke)
        }
      end

    end

    class LinearGradient < Line
      attr_assigner(:colors) { |colors| colors.map{ |c| c.uicolor }}
      attr_assigner(:points)
      attr_assigner(:extended, false)  # if true, gradient options are KCGGradientDrawsBeforeStartLocation | KCGGradientDrawsAfterEndLocation

      def initialize(p1, p2, colors, points=nil)
        super(p1, p2)
        if colors.is_a?(Hash)
          self.points(colors.keys)
          self.colors(colors.values)
        else
          self.colors(colors)
          self.points(points)
        end
      end

      def draw
        context = UIGraphicsGetCurrentContext()
        color_space = CGColorSpaceCreateDeviceRGB()
        cgcolors = self.colors.map { |color| color.CGColor }

        points = self.points
        unless points
          points = []
          colors.length.times do |index|
            points << (index / (colors.length - 1.0))
          end
        end

        gradient = CGGradientCreateWithColors(color_space, cgcolors, points.to_pointer(:float))
        options = 0
        if self.extended
          options |= KCGGradientDrawsBeforeStartLocation
          options |= KCGGradientDrawsAfterEndLocation
        end
        CGContextDrawLinearGradient(context, gradient, p1, p2, options)
      end
    end

    class RadialGradient < Primitive
      attr_assigner(:center) { |pt| SugarCube::CoreGraphics::Point(pt) }
      attr_assigner(:radius)
      attr_assigner(:colors) { |colors| colors.map{ |c| c.uicolor }}
      attr_assigner(:points)
      attr_assigner(:extended, false)  # if true, gradient options are KCGGradientDrawsBeforeStartLocation | KCGGradientDrawsAfterEndLocation

      def initialize(center, radius, colors, points=nil)
        self.center(center)
        self.radius(radius)
        if colors.is_a?(Hash)
          self.points(colors.keys)
          self.colors(colors.values)
        else
          self.colors(colors)
          self.points(points)
        end
      end

      def draw
        context = UIGraphicsGetCurrentContext()
        color_space = CGColorSpaceCreateDeviceRGB()
        cgcolors = self.colors.map { |color| color.CGColor }

        points = self.points
        unless points
          points = []
          colors.length.times do |index|
            points << (index / (colors.length - 1.0))
          end
        end

        gradient = CGGradientCreateWithColors(color_space, cgcolors, points.to_pointer(:float))
        CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, self.extended ? KCGGradientDrawsBeforeStartLocation|KCGGradientDrawsAfterEndLocation : 0)
      end
    end

    class Custom < Primitive

      def initialize(&block)
        @yield = block
      end

      def draw
        context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)

        if @yield
          defaults(context) {
            if @yield.arity == 1
              @yield.call(context)
            else
              @yield.call
            end
          }
        end

        CGContextRestoreGState(context)
      end

    end

    class Mask < Custom
      # UIBezierPath
      attr_assigner(:path)

      # array of D::Draw objects
      attr_assigner(:inside) { |inside| inside.is_a?(Enumerable) ? inside : [inside] }

      def initialize(path, inside=nil, &block)
        self.path(path)
        self.inside = inside || []
        super &block
      end

      def draw
        context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)  # save before clipping
        path.addClip

        @inside.each do |drawing|
          drawing.draw
        end

        super

        CGContextRestoreGState(context)  # restore after clipping
      end

    end

    module_function
    def line(*args)
      Line.new(*args)
    end

    def rect(*args)
      Rect.new(*args)
    end

    def circle(*args)
      Circle.new(*args)
    end

    def path(*args)
      Path.new(*args)
    end

    def linear_gradient(*args)
      LinearGradient.new(*args)
    end

    def radial_gradient(*args)
      RadialGradient.new(*args)
    end

    def custom(*args, &block)
      Custom.new(*args, &block)
    end

    def mask(*args, &block)
      Mask.new(*args, &block)
    end

  end

end
