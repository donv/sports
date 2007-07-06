module Localization
  CONFIG = {
    :default_language => 'no',
    :web_charset => 'utf-8'
  }

  if CONFIG[:web_charset] == 'utf-8'
    $KCODE = 'u'
  end
end
