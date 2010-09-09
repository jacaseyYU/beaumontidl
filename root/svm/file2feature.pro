function file2feature, file
  restore, strtrun(file,'.dat')+'.sav'
  return, feature
end


