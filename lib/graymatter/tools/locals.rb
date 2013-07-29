module GM
  class Locals
    @timer = NSTimer.every(1.second) do
      forget_eventually_storage.each do |object, time|
        if NSDate.new - time > 0
          forget_eventually_storage.delete(object)
        end
      end
    end

    class << self
      def [](key)
        retval = named_storage[key]
      end

      def []=(key, value)
        named_storage[key] = value
      end

      def forget(key)
        named_storage.delete(key)
      end
      alias :- forget

      def forget_eventually(object, offset=10)
        return if forget_eventually_storage.find { |o| o[0].object_id == object.object_id }
        forget_eventually_storage << [object, NSDate.new + offset]
      end
      alias :- forget

  private
      def storage
        @storage ||= []
      end

      def named_storage
        @named_storage ||= {}
      end

      def forget_eventually_storage
        @forget_eventually_storage ||= []
      end
    end
  end
end
