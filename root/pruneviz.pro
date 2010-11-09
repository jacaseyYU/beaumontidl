pro pruneviz_event, event
  widget_control, event.top, get_uvalue = sptr
  case event.tag of 
     'NPIX': (*sptr).npix = event.value
     'DELTA': (*sptr).delta = event.value
     'MINVAL': (*sptr).minval = event.value
     'UPDATE':begin
        kernels = prune((*sptr).ptr, delta = (*sptr).delta, $
                        npix = (*sptr).npix, $
                        minval = (*sptr).minval, /kernels_only)
        mask = (*sptr).mask
        ptr = (*sptr).ptr
        (*mask) and= not 2B
        if kernels[0] eq -1 then return
        for i = 0, n_elements(kernels) - 1, 1 do begin
           inds = substruct(kernels[i], ptr, count = ct)
           if ct eq 0 then continue
           top = max((*ptr).t[inds], loc)
           loc = inds[loc]
           (*mask)[(*ptr).x[loc], (*ptr).y[loc], (*ptr).v[loc]] or= 2B
        endfor
        (*sptr).slice3->request_redraw
     end
     else:
  endcase
end

pro pruneviz_cleanup, tlb
  widget_control, tlb, get_uvalue = sptr
  obj_destroy, (*sptr).slice3
  ptr_free, (*sptr).mask
  ptr_free, sptr
end

pro pruneviz, ptr

  ;- make a cube
  cube = dendro2cube(ptr)
  cube = ptr_new(cube, /no_copy)
  mask = ptr_new(byte(*cube * 0), /no_copy)
  clusters = (*ptr).clusters
  nleaf = n_elements(clusters[0,*])+1
  for i = 0, nleaf - 1, 1 do begin
     inds = substruct(i, ptr, count = ct)
     if ct eq 0 then continue
     hit = max((*ptr).t[inds], loc)
     loc = inds[loc]
     (*mask)[(*ptr).x[loc], (*ptr).y[loc], (*ptr).v[loc]] = 3B
  endfor


  slice3 = obj_new('slice3', cube, slice = 2)
  slice3->add_image, obj_new('cnbgrmask', mask, nmask = 2, slice = 2, $
                             /noscale, alpha = 1, blend=[3,4], color=[[255,0,0],[0,255,0]])

  ;-guis
  tlb = widget_base()
  desc = [ $
         '0, FLOAT, 0, LABEL_LEFT=Delta:, width=6, tag=delta', $
         '0, INTEGER, 0, LABEL_LEFT=Npix:, WIDTH=6, TAG=npix', $
         '0, FLOAT, 0, label_left=Minval:, width=6, tag=minval', $
         '1, BASE,, ROW', $
         '0, BUTTON, UPDATE, TAG=update']
  b = CW_FORM(tlb, desc, /COLUMN)

  slice3->run         
  state={mask:mask, slice3:slice3, ptr:ptr, npix:0, delta:0., minval:0.}
  widget_control, tlb, set_uvalue = ptr_new(state), /realize
  xmanager, 'pruneviz', tlb, cleanup='pruneviz_cleanup'
end

pro test
  restore, '~/dendro/ex_ptr_small.sav'
  pruneviz, ptr
  ptr_Free, ptr
end
