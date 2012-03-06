pro cloudviz_panel_event, event
  widget_control, event.top, get_uvalue = sptr
  junk = (*sptr).obj->event(event)
end

pro cloudviz_cleanup, top
  widget_control, top, get_uvalue = sptr
  obj_destroy, (*sptr).obj
  ptr_Free, sptr
end

function cloudviz_panel::event, event

  widget_control, event.id, get_uvalue = uval
  widget_control, self.tlb, get_uvalue = sptr

  case uval of
     'select': begin
        for i = 0, self.ncolor-1 do if event.id eq (*sptr).selects[i] then break
        assert, i lt self.ncolor
        self.hub->setCurrentID, i
     end
     'color': begin
        for i = 0, self.ncolor-1 do if event.id eq (*sptr).colors[i] then break
        assert, i lt self.ncolor
        old = self.hub->getColors(i)
        new = cnb_pickcolor(/brewer, cancel = cancel, $
                            red = old[0], green = old[1], blue=old[2], $
                            alpha = old[3] / 255.)
        if cancel then break
        self.hub->setColor, i, new
     end
     'slice_b': begin
        self.hub->addClient, obj_new('cloudslice', self.hub, ncolor=self.ncolor, header=self.header)
     end
     'iso_b': begin
        self.hub->addClient, obj_new('cloudiso', self.hub, ncolor=self.ncolor)
     end
     'scatter_b': begin
        self.hub->addClient, obj_new('cloudscatter', self.hub, *self.data, $
                                     ncolor=self.ncolor)
     end
     'ppp_b': begin
        self.hub->addClient, obj_new('cloudiso_deprojector', self.hub, (*self.ppp).v, (*self.ppp).vc)
     end
     'mbar': self->menu_event, event
     else: print, "unrecognized event"
  endcase
  return, 1
end

pro cloudviz_panel::menu_event, event
  case event.value of
     'Subsets.Save': begin
        desc = ['0, INTEGER, 0, LABEL_LEFT=ID (0 indexed), '$
                +'width=12, tag=id', $
                '1, BASE,, ROW, FRAME', $
                '0, BUTTON, OK, QUIT, tag=ok', $
                '2, BUTTON, Cancel, QUIT, tag=cancel']
        a = cw_form(desc, /column, title='Select a subset to save')
        if a.cancel then return
        ids = self.hub->getStructure(a.id)
        file = dialog_pickfile(title='Save as', default_extension='dat', $
                               /write, /overwrite_prompt)
        openw, lun, file, /get_lun
        printf, lun, ids, format='(i0)'
        free_lun, lun
     end
     'Subsets.Load':begin
        file = dialog_pickfile(title='Open', default_extension='dat', $
                               filter='*dat', /read)
        if file eq '' then return
        readcol, file, ids, format='i', /silent
        self.hub->setCurrentStructure, ids
     end
     'Subsets.Combine': begin
        desc = ['1, BASE,, ROW, ', $
                '0, INTEGER, 7, tag=target,', $
                '0, LABEL, =,,', $
                '0, INTEGER, 0, tag=sub1', $
                '0, DROPLIST, and|or|and not|xor, tag=comb', $
                '2, INTEGER, 1, tag=sub2',$
                '1, BASE,, ROW, ', $
                '0, BUTTON, OK, QUIT, tag=ok', $
                '2, BUTTON, Cancel, QUIT, tag=cancel']
        a = cw_form(desc, /column, title='Specify a Combination')
        if a.cancel then return
        target = a.target
        sub1 = self.hub->getStructure( a.sub1)
        sub2 = self.hub->getStructure(a.sub2)
        id1 = bytarr(max([sub1, sub2])+1)
        id2 = id1
        id1[sub1] = 1
        id2[sub2] = 1
        case a.comb of
           0: ids = id1 and id2
           1: ids = id1 or id2
           2: ids = id1 and not id2
           3: ids = id1 xor id2
        endcase
        hit = where(ids)
        self.hub->setCurrentId, target
        self.hub->setCurrentStructure, hit
     end
  else:
  endcase
end


pro cloudviz_panel::notifyColor, id, color
  widget_control, self.tlb, get_uvalue = sptr
  widget_control, (*sptr).colors[id], $
                  set_value = rebin(reform(byte(color[0:2]), 1, 1, 3), 20, 20, 3)
end

pro cloudviz_panel::notifyCurrent, id
  widget_control, self.tlb, get_uvalue = sptr
  for i = 0, self.ncolor-1, 1 do $
     widget_control, (*sptr).selects[i], $
                     set_value = (i eq id) ? (*sptr).check_bmp : $
                     (*sptr).uncheck_bmp
end

function cloudviz_panel::init, hub, data = data, ppp = ppp, header = header, _extra = extra
  if ~self->cloudviz_client::init(hub, _extra = extra) then return, 0
  ncolor = self.ncolor

  tlb = widget_base(/column, mbar=mbar) & self.tlb = tlb


  ;- read image of checkmark
  check = file_which('check.bmp')
  if ~file_test(check) then message, 'cannot find check.bmp'
  check = read_bmp(check)
  check = transpose(check, [1,2,0])
  red_check = check
  red_check[*,*,0]=255B
  check[*]= 255B

  ;- create each selector row
  rows = lonarr(ncolor)
  selects = lonarr(ncolor)
  colors = lonarr(ncolor)
  for i = 0, ncolor-1, 1 do begin
     c = self.hub->getColors(i)
     rows[i] = widget_base(tlb, /row)
     selects[i] = widget_button(rows[i], value=check, /bitmap, uvalue='select')
     colors[i] = widget_button(rows[i], $
                               value = rebin(reform(c[0:2], 1, 1, 3), 20, 20, 3), $
                               /bitmap, uvalue='color')
  endfor
  widget_control, selects[0], set_value=red_check

  ;- client buttons
  button_base = widget_base(tlb, /column)
  self.button_base = button_base
  slice_b = widget_button(button_base, value='Slice', uval = 'slice_b')

  sz = size(  (*(hub->getData())).value )
  if sz[0] eq 3 then $
     iso_b = widget_button(button_base, value='Isosurface', uval = 'iso_b')

  if keyword_set(data) then begin
     scatter_b = widget_button(button_base, value='Scatter Plot', uval = 'scatter_b')
     self.data = ptr_new(data)
  endif

  if keyword_set(ppp) then begin
     if ~ptr_valid(ppp) || size(*ppp, /type) ne 8 || $
        ~contains_tag(*ppp, 'v') || ~contains_tag(*ppp, 'vc') then $
        message, 'ppp must be a pointer to a structure with v and vc tags'
     ppp_b = widget_button(button_base, value='Deprojector', uval = 'ppp_b')
     self.ppp = ppp
  endif

  state={obj:self, rows:rows, selects:selects, colors:colors, $
         index:0, uncheck_bmp:check, check_bmp:red_check $
        }
  sptr = ptr_new(state, /no_copy)
  widget_control, tlb, set_uvalue = sptr
  self.widget_base = tlb
  if keyword_set(header) then self.header = ptr_new(header)


  ;- menu
  self.mbar = mbar
  mbar_desc = ['1\Subsets', $
               '0\Save', $
               '0\Load', $
               '0\Combine']
  menu = cw_pdmenu(mbar, mbar_desc, /mbar, /return_full_name)
  widget_control, mbar, set_uvalue = 'mbar'
  return, 1
end

pro cloudviz_panel::run
  widget_control, self.tlb, /realize
  xmanager, 'cloudviz_panel', self.tlb, cleanup='cloudviz_cleanup', /no_block
end

pro cloudviz_panel::cleanup
  self->cloudviz_client::cleanup
  ptr_free, self.header
  ptr_free, [self.ppp, self.data]
end

pro cloudviz_panel__define
  data = {cloudviz_panel, $
          inherits cloudviz_client, $
          data:ptr_new(), $
          ppp:ptr_new(), $
          button_base:0L, $
          tlb:0L, $
          mbar:0L, $
          header:ptr_new() $
         }
end
