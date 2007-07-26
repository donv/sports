module ApplicationHelper
  include Localization
  
  def h(object)
    if object.is_a? Time
      object.strftime '%Y-%m-%d'
    else
      super object
    end
  end
  
end
