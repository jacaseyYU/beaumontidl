pro dendroviz, ptr, data = data, ppp = ppp, log = log, match = match

  if n_params() ne 1 then begin
     print, 'calling sequence'
     print, ' dendroviz, ptr, [data = data, /log], OR'
     print, ' dendrofiz, file, [data = data, /log]'
     print, ' ptr: dendrogram pointer (returned from TOPOLOGIZE'
     print, ' file: Filename of a dendrogram generated from C++ code'
     print, ' data: a catalog (Array of structures, 1 per dendrogram struct)'
     return
  endif

  ;- if ptr is actually a file name, treat it as a C++ dendro file
  if size(ptr, /type) eq 7 then begin
     if ~file_test(ptr) then $
        message, 'Could not find input file: ' + ptr
     ptr = dendrocpp2cloudviz(ptr)
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
  
  if keyword_set(log) then (*ptr).height = alog10((*ptr).height)
  if keyword_set(match) then begin
     c_def = byte(transpose(fsc_color( $
             ['red', 'teal', 'orange', 'purple', 'yellow', 'brown', 'royalblue', 'green'], $
             /triple)))
     c1 = bytarr(4, 8)
     c1[0:2, 3:*] = c_def[*, 3:*]
     c1[3,*] = 128B
     c2 = c1
     c2[0:2, 0:2] = byte([ [255, 0, 0], [163, 103, 26], [255, 165, 0]])
     c1[0:2, 0:2] = byte([ [63, 0, 125], [127, 205, 186], [0, 101, 82]])
  endif

  ;- create guis
  hub = obj_new('cloudviz_hub', ptr, colors = c1)
  panel = obj_new('cloudviz_panel', hub, data = data, ppp = ppp)
  plot = obj_new('dendroplot', hub)
  listen = obj_new('dendroviz_listener', hub)

  hub->addClient, panel
  hub->addClient, plot
  hub->addListener, listen

  if keyword_set(match) then begin
     hub2 = obj_new('cloudviz_hub', match.ptr, colors = c2)
     panel2 = obj_new('cloudviz_panel', hub2, ppp = ppp)
     plot2 = obj_new('dendroplot', hub2)
     listen2 = obj_new('dendroviz_listener', hub2)

     hub2->addClient, panel2
     hub2->addClient, plot2
     hub2->addListener, listen2
     bridge = obj_new('cloudviz_bridge', hub, hub2, match.match)
     v2 = plot2->get_view()
     v2->setProperty, color=[254, 240, 230]
     v1 = plot->get_view()
     v1->setProperty, color=[232, 241, 255]
  endif
end 

pro test

  restore, '~/stella_sims/dendroviz_example.sav'
  dendroviz, ptr, ppp = ppp, data = data

end
