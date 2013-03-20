module GM
  class Locals
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

  private
      def storage
        @storage ||= []
      end

      def named_storage
        @named_storage ||= {}
      end

    end
  end
end
