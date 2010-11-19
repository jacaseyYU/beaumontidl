pro maxviz_event, event
  widget_control, event.top, get_uvalue = sptr
  case event.tag of 
     'FRIENDS': (*sptr).friends = event.value
     'SPECFRIENDS': (*sptr).specfriends = event.value
     'MINVAL': (*sptr).minval = event.value
     'UPDATE':begin
        kernels = cnb_alllocmax( *(*sptr).ptr, friends = (*sptr).friends, $
                                specfriends = (*sptr).specfriends, minval = (*sptr).minval)
        mask = (*sptr).mask
        (*mask)[*] = 0B
        (*mask)[kernels] = 1B
        (*sptr).slice3->update_images
     end
     else:
  endcase
end

pro maxviz_cleanup, tlb
  widget_control, tlb, get_uvalue = sptr
  obj_destroy, (*sptr).slice3
  ptr_free, (*sptr).mask
  ptr_free, sptr
end

pro maxviz, cube

  ;- make a cube
  ptr = ptr_new(cube)
  mask = ptr_new(byte(cube)*0B, /no_copy)

  slice3 = obj_new('slice3', ptr, slice = 2)
  slice3->add_image, obj_new('cnbgrmask', mask, nmask = 1, slice = 2, $
                             /noscale, alpha = 1, blend=[3,4], color=[255,0,0])

  ;-guis
  tlb = widget_base()
  desc = [ $
         '0, INTEGER, 1, LABEL_LEFT=Friends:, width=6, tag=friends', $
         '0, INTEGER, 1, LABEL_LEFT=Specfriends:, WIDTH=6, TAG=specfriends', $
         '0, FLOAT, 0, label_left=Minval:, width=6, tag=minval', $
         '1, BASE,, ROW', $
         '0, BUTTON, UPDATE, TAG=update']
  b = CW_FORM(tlb, desc, /COLUMN)

  slice3->run         
  state={mask:mask, slice3:slice3, ptr:ptr, friends:1, specfriends:1, minval:0.}
  widget_control, tlb, set_uvalue = ptr_new(state), /realize
  xmanager, 'maxviz', tlb, cleanup='maxviz_cleanup'
end

pro test
  restore, '~/dendro/ex_ptr_small.sav'
  help, ptr
  cube = dendro2cube(ptr)
  maxviz, cube
  ptr_Free, ptr
end
