class PeoplePicker
  class << self
    def show &after
      raise "Cannot show two PeoplePickers" if @showing

      @delegate ||= self.new
      @after = after
      @showing = true

      people_picker_ctlr = ABPeoplePickerNavigationController.alloc.init
      people_picker_ctlr.peoplePickerDelegate = @delegate
      UIApplication.sharedApplication.keyWindow.rootViewController.presentViewController(people_picker_ctlr, animated:true, completion:nil)
    end

    def hide(person)
      UIApplication.sharedApplication.keyWindow.rootViewController.dismissViewControllerAnimated(true, completion:lambda{
        @after.call(person) if @after
        @showing = nil
      })
    end
  end

  def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:person)
    self.class.hide(person)
    false
  end

  def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:person, property:property, identifier:id)
    self.class.hide(person)
    false
  end

  def peoplePickerNavigationControllerDidCancel(people_picker)
    self.class.hide(nil)
  end

end
