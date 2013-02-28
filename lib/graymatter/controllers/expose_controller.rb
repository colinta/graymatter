module GM
  # given a target and slide_view, this class will manage a slide out view.
  #
  #     ExposeController.new(target, slide_view, options)
  #
  # target: this is the view that the pan gesture will be added to, can be the same as the slide_view.
  # slide_view: this is the view that will be moved to the right, should be a container view of some sort.
  # delegate: the expose controller delegate
  #
  # It is assumed that the *exposed view* is organized below the slide_view, and
  # so it will be exposed when the slide_view is moved.
  #
  # Options:
  #
  # margin: the minimum visible width of the slide_view.  default: 50
  # direction: `:left` or `:right`.  The direction the slide_view moves in order to expose the view beneath.
  #
  # Delegate methods:
  #
  #     :did_close_slide_menu
  #     :did_open_slide_menu
  #     :did_slide_menu
  #     :will_close_slide_menu
  #     :will_open_slide_menu
  #     :will_slide_menu
  #
  # Example:
  #
  #     # navbar is a UINavigationBar instance
  #     # containerView is the view you want to move out of the way
  #     @slidemenu = ExposeController.new(navbar, containerView, margin: SidemenuMargin)
  #
  # Memory:
  #
  # If you want good memory handling, I recommend you implement these two delegate methods:
  #     def will_open_slide_menu(menu)
  #       background_view.hide
  #     end
  #
  #     def did_close_slide_menu(menu)
  #       background_view.show
  #     end
  #
  # Todo:
  #
  # Add support for dragging from side of the screen, rather than using a target
  # view.  This can be 'faked' by having a transparent view on the top all your
  # other views, and passing that in as the target.
  #
  class ExposeController
    # When the slide_view is "exposing" the view beneath, this view covers the
    # visible portion of slide_view.  The horizontal pan gesture is attached to it
    attr :cover_view
    # The delegate gets notified before and after slide events
    attr_accessor :delegate

    def initialize(target, slide_view, options)
      default_options = {
        margin: 50,
        direction: :right,
        delegate: nil,
        }
      @options = default_options.merge(options)
      @slide_view = slide_view

      @cover_view = UIControl.alloc.initWithFrame(CGRect.empty)
      @cover_view.on :touch_down {
        toggle
      }

      target.on_gesture(HorizontalPanGestureRecognizer) { |event|
        case event.state
        when :began.uigesturerecognizerstate
          start_gesture(event)
        when :changed.uigesturerecognizerstate
          update_state(event)
        when :ended.uigesturerecognizerstate
          move_to_state(@last_direction)
        end
      }

      # reset state
      if open_direction == :right
        @state = :left
        @last_direction = :right
      else
        @state = :right
        @last_direction = :left
      end

      move_to_state(closed_direction)
    end

    def toggle
      delegate_send :will_slide_menu
      if @state == closed_direction
        delegate_send :will_open_slide_menu
        move_to_state open_direction
      else
        delegate_send :will_close_slide_menu
        move_to_state closed_direction
      end
    end

    def slide_closed
      return if @state == closed_direction
      delegate_send :will_slide_menu
      delegate_send :will_open_slide_menu
      move_to_state(closed_direction)
    end

    def slide_open
      return if @state == open_direction
      delegate_send :will_slide_menu
      delegate_send :will_close_slide_menu
      move_to_state(open_direction)
    end

  private
    def delegate_send(method, *args)
      # method = "#{method}:"
      @delegate && @delegate.respond_to?(method) && @delegate.send(method, self, *args)
    end

    def open_direction
      @options[:direction]
    end

    def closed_direction
      if open_direction == :right
        :left
      else
        :right
      end
    end

    def min_x
      case open_direction
      when :right
        @slide_view.superview.bounds.min_x
      when :left
        @slide_view.superview.bounds.min_x - @slide_view.bounds.width + @options[:margin]
      end
    end

    def max_x
      case open_direction
      when :right
        @slide_view.bounds.max_x - @options[:margin]
      when :left
        @slide_view.superview.bounds.min_x
      end
    end

    def start_gesture(event)
      @start = event.locationInView(@slide_view.superview).x
      @last_direction = nil

      # send 'will' event to delegate
      delegate_send :will_slide_menu
      if @state == open_direction
        delegate_send :will_close_slide_menu
      else
        delegate_send :will_open_slide_menu
      end
    end

    def update_state(event)
      panning_location = event.locationInView(@slide_view.superview).x
      position_delta = panning_location - @start
      if position_delta > 0
        movement = :right
      elsif position_delta < 0
        movement = :left
      else
        movement = nil
      end

      new_x = @slide_view.frame.min_x + position_delta

      if (movement == :right and new_x <= max_x) || (movement == :left and new_x >= min_x)
        @slide_view.slide(:right, {size: position_delta, duration: 0.1, options: UIViewAnimationOptionCurveLinear })
        @last_direction = movement
      end

      @start = panning_location
    end

    def cover_viewFrame
      cover_size = [@options[:margin], @slide_view.bounds.height]
      if open_direction == :right
        cover_frame = [[0, 0], cover_size]
      else
        cover_frame = [[@slide_view.bounds.width - @options[:margin], 0], cover_size]
      end
    end

    def move_to_state(direction)
      position = @slide_view.frame.origin
      original_x = position.x

      case direction
      when :left
        position.x = min_x
      when :right
        position.x = max_x
      end
      distance = (position.x - original_x).abs
      duration = distance / (@slide_view.bounds.width - @options[:margin]) * 0.25

      @slide_view.move_to(position, duration: duration, options: UIViewAnimationOptionCurveEaseOut) {
        # event is done, so send 'did' event to delegate
        if @state == open_direction
          delegate_send :did_open_slide_menu
        else
          delegate_send :did_close_slide_menu
        end
      }
      @state = direction

      #
      # also, add the cover view if the state is 'open'.  Touching the cover_view
      # will immediately close the slide_view
      delegate_send :did_slide_menu
      if @state == open_direction
        @cover_view.frame = cover_viewFrame
        @slide_view << @cover_view
      else
        @cover_view.removeFromSuperview
      end
    end

  end
end
