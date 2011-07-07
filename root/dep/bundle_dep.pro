pro bundle_dep, file, output_dir

  dep = finddep_all(file, /only_source)

  src = dep.source
  s = s[uniq(s, sort(s))]

  
