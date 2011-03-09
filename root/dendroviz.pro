pro dendroviz, ptr, data = data, ppp = ppp

  if n_params() ne 1 then begin
     print, 'calling sequence'
     print, ' dendroviz, ptr, [data = data]'
     print, ' ptr: dendrogram pointer (returned from TOPOLOGIZE'
     print, ' data: a catalog (Array of structures, 1 per dendrogram struct)'
     return
  endif

  if ~contains_tag(*ptr, 'CLUSTER_LABEL_H') then begin
     message, /info, 'Pointer is out of date. Updating and overwriting'
     message, /info, 'Note, you can convert yourself using update_topo()'
     ptr = update_topo(ptr)
  endif

  ;- convert into cloudviz format, if needed
  if ~contains_tag(*ptr, 'value') then begin
     message, /info, 'Need to convert pointer into proper dendroviz format. Converting and overwriting'
     message, /info, 'Note: you can convert yourself using dendro2cloudviz'
     ptr = dendro2cloudviz(ptr)
  endif
  
  ;- create guis
  hub = obj_new('cloudviz_hub', ptr)
  panel = obj_new('cloudviz_panel', hub, data = data, ppp = ppp)
  plot = obj_new('dendroplot', hub)
  listen = obj_new('dendroviz_listener', hub)

  hub->addClient, panel
  hub->addClient, plot
  hub->addListener, listen

end 

pro test

  restore, '~/stella_sims/dendroviz_example.sav'
  dendroviz, ptr, ppp = ppp, data = data

end
