pro forget_path
  path = expand_path('+./') + ':' + $
         expand_path('+/Applications/itt/idl71/')
  pref_set, 'IDL_PATH', path, /commit
end
