module ApplicationHelper
  include Localization
  
  def h2(object)
    if object.is_a? Time
      object.strftime '%Y-%m-%d'
    else
      h object
    end
  end
  
end
