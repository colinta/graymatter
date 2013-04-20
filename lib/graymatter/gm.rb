module GM
  module_function

  def window
    UIApplication.sharedApplication.windows[0]
  end

  def app_frame
    UIScreen.mainScreen.applicationFrame
  end

end
