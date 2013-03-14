module GM
  class Locals
    class << self
      def store(item)
        storage << item
        10.seconds.later do
          if storage.include? item
            NSLog("Local.storage still includes: #{item.inspect}")
          end
        end
      end
      alias :+ store
      alias :<< store
      alias :& store

      def forget(item)
        len = storage.length
        storage.delete_if { |o| len == storage.length && o.object_id == item.object_id }
        if storage.length == len
          NSLog("Local.storage did not delete: #{item.inspect} @ #{item.object_id.to_s(16)}")
        end
      end
      alias :- forget
      alias :>> forget
      alias :^ forget

  private
      def storage
        @storage ||= []
      end

    end
  end
end
