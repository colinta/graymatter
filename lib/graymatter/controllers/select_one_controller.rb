# @requires module:KeyboardHandler
module GM
  # You can push this controller onto a navigation controller when you need the
  # user to pick from a list of items.
  #
  # @example
  #   ctlr = SelectOneController.new
  class SelectOneController < UIViewController
    include KeyboardHandler

    attr_accessor :items
    attr_accessor :include_other
    attr_accessor :selected
    attr_accessor :cell_handler
    attr_accessor :on_done

    def initialize(items)
      self.init
      self.items = items
      @include_other = false
    end

    def include_other=(val)
      if val == true
        val = "Other...".localized
      end
      @include_other = val
      self.view.reloadData if self.viewLoaded?
    end

    def loadView
      raise "An on_done callback is required" unless @on_done

      self.view = UITableView.grouped
      self.view.delegate = self
      self.view.dataSource = self
    end

    def viewDidLoad
      prepare_keyboard_handler(self.view)
    end

    def viewWillAppear(animated)
      super
      keyboard_handler_start
    end

    def viewWillDisappear(animated)
      super
      keyboard_handler_stop
    end

    def tableView(table_view, cellForRowAtIndexPath:index_path)
      if @include_other and index_path.row == @items.length
        cell_identifier = "SelectOneController - Other Cell"
        cell = table_view.dequeueReusableCellWithIdentifier(cell_identifier)

        if not cell
          cell = UITableViewCell.alloc.initWithStyle(:default.uitablecellstyle,
                              reuseIdentifier: cell_identifier)
          layout(cell.contentView) do |view|
            subview(InsetTextField, frame: view.bounds,
                                 delegate: self,
                            returnKeyType: :done)
          end
        end

        input = cell[UITextField]
        input.placeholder = @include_other

        if @selected and not @items.include?(@selected)
          cell.accessoryType = :checkmark.uitablecellaccessory
          input.text = @selected
        else
          cell.accessoryType = :none.uitablecellaccessory
          input.text = nil
        end
      else
        cell_identifier = "SelectOneController - Default Cell"
        cell = table_view.dequeueReusableCellWithIdentifier(cell_identifier)

        if not cell
          cell = UITableViewCell.alloc.initWithStyle(:default.uitablecellstyle,
                              reuseIdentifier: cell_identifier)
        end

        item = @items[index_path.row]

        if @selected && @selected == item
          cell.accessoryType = :checkmark.uitablecellaccessory
        else
          cell.accessoryType = :none.uitablecellaccessory
        end

        if @cell_handler
          @cell_handler.call(cell, item)
        else
          cell.textLabel.text = item.description
        end
      end

      return cell
    end

    def tableView(table_view, numberOfRowsInSection:section)
      @items.length + (@include_other ? 1 : 0)
    end

    def tableView(table_view, didSelectRowAtIndexPath:index_path)
      table_view.deselectRowAtIndexPath(index_path, animated:true)

      if @include_other && index_path.row == @items.length
        table_view.cellForRowAtIndexPath(index_path)[UITextField].becomeFirstResponder
      else
        @on_done.call(@items[index_path.row])
      end
    end

    ##|
    ##|  OTHER TEXT FIELD DELEGATE
    ##|
    def textFieldShouldReturn(text_field)
      text_field.resignFirstResponder
      if text_field.text.length
        @on_done.call(text_field.text)
      end
    end

  end
end
