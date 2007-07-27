module ApplicationHelper
  include Localization
  
  def h(object)
    if object.is_a? Date
      object.strftime '%Y-%m-%d'
    elsif object.is_a? Time
      object.strftime '%H:%M:%S'
    else
      super object
    end
  end
  
end
