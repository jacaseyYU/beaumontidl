pro fastrestore, filename

  commonblock = 'fastrestore_'+filename
  varnames = string(indgen(100), format='("v",i2.2", ")')+' v100'
  execute, 'common ' + commonblock + ' ' + varnames
  
