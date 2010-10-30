pro dendrogui_3dmodel, state

  polys = dendrogui_polygons(state, alpha = .5, shading = 1)
  if ~obj_valid(polys[0]) then return

;  poly = dendro_mask2poly(*state.mask, $
;                          colors = state.subplot_colors, $
;                          alpha = 0.5)

  ;- shift polygon vertices so that the cube center is at origin
  sz = size(*state.mask)
 
  for i = 0, n_elements(polys) - 1, 1 do begin
     poly = polys[i]
     poly->getProperty, data = d
     d[0,*] -= sz[1]/2.
     d[1,*] -= sz[2]/2.
     d[2,*] -= sz[3]/2.
     poly->setProperty, data = d
  endfor

  ;- add some lights
  l1 = obj_new('idlgrlight', type = 2, loc = [sz[1], sz[2], 2*sz[3]], $
               color=[255,255,255], inten=.7)
  l2 = obj_new('idlgrlight', type = 0, inten = 0.5, $
               color = [255,255,255])
  l3 = obj_new('idlgrlight', type = 2, loc = [-sz[1], -sz[2], -2*sz[3]], inten=.7)
  

  ;- axes
  a1 = obj_new('idlgraxis', 0, range=[0,sz[1]]-sz[1]/2., title=obj_new('idlgrtext', 'X'))
  a2 = obj_new('idlgraxis', 1, range=[0,sz[2]]-sz[2]/2., title=obj_new('idlgrtext', 'Y'))
  a3 = obj_new('idlgraxis', 2, range=[0,sz[3]]-sz[3]/2., title=obj_New('idlgrtext', 'Z'))
  m = obj_new('idlgrmodel')
  m->add, l1
  m->add, l2
  m->add, l3
  for i = 0, n_elements(polys) -1 do m->add, polys[i]
  m->add, a1
  m->add, a2
  m->add, a3
  if obj_valid(state.isowin) then begin
     state.isowin->set_model, m
     state.isowin->request_redraw
  endif else begin
     state.isowin = obj_new('interwin', m, /standalone, $
                            /rotate, /depth_test_disable, $
                            eye = 2 * max(sz[1:3]), shading=1, $
                            xrange = [0, sz[1]]-sz[1]/2., $
                            yrange = [0, sz[2]]-sz[2]/2., group_leader = state.tlb)
  endelse

end
