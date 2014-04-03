module GM

  class SensibleFlowLayout < UICollectionViewFlowLayout

    def prepareForCollectionViewUpdates(update_items)
      @inserted_paths = []
      @deleted_paths = []
      update_items.each do |update_item|
        if update_item.updateAction == UICollectionUpdateActionInsert
          @inserted_paths << update_item.indexPathAfterUpdate
        elsif update_item.updateAction == UICollectionUpdateActionDelete
          @deleted_paths << update_item.indexPathBeforeUpdate
        end
      end

      super
    end

    def finalizeCollectionViewUpdates
      @inserted_paths = nil
      @deleted_paths = nil
      super
    end

    def initialLayoutAttributesForAppearingItemAtIndexPath(index_path)
      attrs = super
      if attrs && @inserted_paths.include?(index_path)
        self.appearing_attributes(attrs, for_path: index_path)
      end
      return attrs
    end

    def finalLayoutAttributesForDisappearingItemAtIndexPath(index_path)
      attrs = super
      if attrs && @deleted_paths.include?(index_path)
        self.disappearing_attributes(attrs, for_path: index_path)
      end
      return attrs
    end

    def appearing_attributes(attrs, for_path: index_path)
    end

    def disappearing_attributes(attrs, for_path: index_path)
    end

  end

end
