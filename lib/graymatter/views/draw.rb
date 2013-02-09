module GM

  if false
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

    def self.new(frame, drawing=nil)
      self.alloc.initWithFrame(frame).tap do |instance|
        instance.draw = drawing if drawing
      end
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
        drawing.draw(context)
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
        define_method("#{name}=") { |value|
          self.send(name, value)
        }
        # combined getter/setter
        define_method(name) { |*args|
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
        }
      end

      def draw(context)
        raise 'Implement the `draw(context)` method'
      end
    end

    class Primitive < Draw
      attr_assigner(:line_width, 1)
      attr_assigner(:color, UIColor.blackColor) { |val| val.uicolor }
      attr_assigner(:background, UIColor.clearColor) { |val| val.uicolor }

      # setup the default drawing context, and perform your drawing in the block
      # you pass to this function
      def defaults(context)
        CGContextSaveGState(context)
        color.setStroke
        background.setFill
        CGContextSetLineWidth(context, self.line_width)
        yield
        CGContextRestoreGState(context)
      end

    end

    class Line < Primitive
      attr_assigner(:p1) { |pt| SugarCube::CoreGraphics::Point(pt) }
      attr_assigner(:p2) { |pt| SugarCube::CoreGraphics::Point(pt) }

      def initialize(p1, p2)
        self.p1(p1)
        self.p2(p2)
      end

      def draw(context)
        defaults(context) {
          CGContextMoveToPoint(context, p1_x, p1_y)
          CGContextAddLineToPoint(context, p2_x, p2_y)
          CGContextStrokePath(context)
        }
      end

      def frame
        frame = CGRectStandardize(CGRectMake(p1_x, p1_y,  p2_x - p1_x, p2_y - p1_y))
        if frame.size.width == 0
          frame.size.width = self.line_width
        end
        if frame.size.height == 0
          frame.size.height = self.line_width
        end
        frame
      end

      def p1_x ; @p1[0] ; end
      def p1_y ; @p1[1] ; end
      def p2_x ; @p2[0] ; end
      def p2_y ; @p2[1] ; end

    end

    class Circle < Primitive
      attr_assigner(:center) { |pt| SugarCube::CoreGraphics::Point(pt) }
      attr_assigner(:radius)

      def initialize(center, radius, color=nil)
        self.center(center)
        self.radius(radius)
        self.color(:clear)  # default to no border
        self.background(color) if color
      end

      def draw(context)
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

      def draw(context)
        @path.lineWidth = self.line_width

        defaults(context) {
          @path.stroke
        }
      end

    end

    class LinearGradient < Line
      attr_assigner(:colors) { |colors| colors.map{ |c| c.uicolor }}
      attr_assigner(:points)

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

      def draw(context)
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
        CGContextDrawLinearGradient(context, gradient, p1, p2, 0)
      end
    end

    class RadialGradient < Primitive
      attr_assigner(:center) { |pt| SugarCube::CoreGraphics::Point(pt) }
      attr_assigner(:radius)
      attr_assigner(:colors) { |colors| colors.map{ |c| c.uicolor }}
      attr_assigner(:points)

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

      def draw(context)
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
        CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, 0)
      end
    end

    class Mask < Draw
      # UIBezierPath
      attr_assigner(:path)

      # array of D::Draw objects
      attr_assigner(:draw) { |draw| draw.is_a?(Enumerable) ? draw : [draw] }

      def initialize(path, draw=nil, &block)
        self.path(path)
        @yield = block
        @draw = draw
      end

      def draw(context)
        CGContextSaveGState(context)  # save before clipping
        path.addClip

        if @draw
          @draw.each do |drawing|
            drawing.draw(context)
          end
        end
        @yield.call(context) if @yield

        CGContextRestoreGState(context)  # restore after clipping
      end

    end

    module_function
    def line(*args)
      Line.new(*args)
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

    def mask(*args, &block)
      Mask.new(*args, &block)
    end

  end

end
