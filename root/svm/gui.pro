;+
;best with default sets, rbf, pca is c=3e3, g=1e-2, score=.73

pro gui_event, event
  common gui, state
  widget_control, event.id, get_uvalue = id
  ;- swallow events from drawcube, for which id is undefined
  if n_elements(id) eq 0 then return

  widget_control, /hourglass
  widget_control, event.top, get_uvalue = state
  widget_control, event.id, get_value = val
  case id of
     'run': run_svm, state
     'tr_p': begin
        state.tr_p = dialog_pickfile(/read, filter='train*sav')
        widget_control, event.id, set_value=state.tr_p
     end
     'tr_m': begin
        state.tr_m = dialog_pickfile(/read, filter='train*sav')
        widget_control, event.id, set_value=state.tr_m
     end
     'te_p': begin
        state.te_p = dialog_pickfile(/read, filter='train*sav')
        widget_control, event.id, set_value=state.te_p
     end
     'te_m': begin
        state.te_m = dialog_pickfile(/read, filter='train*sav')
        widget_control, event.id, set_value=state.te_m
     end
     'method': state.method = event.index
     'kernel': state.kernel = event.index
     'c': state.c = val
     'g': state.g = val
     'optimize_c':begin
        state.c = optimize_widget(state, /c, fitness = f)
        state.fitness = f
     end
     'optimize_g': begin
        state.g = optimize_widget(state, /g, fitness = f)
        state.fitness = f
     end
     'norm': state.norm = event.index
     'rescale':state.rescale = event.index
     'redraw': gui_redraw, state
     else: help, event, id
  endcase
  update_display, state

  widget_control, event.top, set_uvalue=state
end

pro update_display, state
  widget_control, state.ctext, set_value=string(state.c, format='(e0.3)')
  widget_control, state.gtext, set_value=string(state.g, format='(e0.3)')
  widget_control, state.fitness_lab, set_value=string(state.fitness, format='(e0.3)')
end

pro run_svm, state, fitness = fitness
  
  func=['edge_feature', 'edge2_feature', 'moment_feature', 'pca_feature', 'default_feature']
  ;-form a unique output name, and create features if needed
  out1 = state.tr_p+'_'+func[state.method]+'_'+strtrim(state.norm,2)+'.dat'
  out2 = state.tr_m+'_'+func[state.method]+'_'+strtrim(state.norm,2)+'.dat'
  out3 = state.te_p+'_'+func[state.method]+'_'+strtrim(state.norm,2)+'.dat'
  out4 = state.te_m+'_'+func[state.method]+'_'+strtrim(state.norm,2)+'.dat'
  ;print, out1, file_test(out1)
  if ~file_test(out1) then begin  
     if ~file_test(state.tr_p) then stop
     tr_p = mask2feature(state.tr_p, feature = func[state.method], $
                         bin = [2, 2, 5], label = 1, norm = state.norm)
  endif else tr_p = file2feature(out1)
  if ~file_test(out2) then begin
     tr_m = mask2feature(state.tr_m, feature = func[state.method], $
                         bin = [2, 2, 5], label = -1, norm = state.norm)
  endif else tr_m = file2feature(out2)
  if ~file_test(out3) then begin
     te_p = mask2feature(state.te_p, feature = func[state.method], $
                         bin = [2, 2, 5], label = 1, norm = state.norm)
  endif else te_p = file2feature(out3)
  if ~file_test(out4) then begin
     te_m = mask2feature(state.te_m, feature = func[state.method], $
                         bin = [2, 2, 5], label = -1, norm = state.norm)
  endif else te_m = file2feature(out4)

  ;- these default features may not be labeled correctly. Re-run feature2file
  tr_p.label = 1 & tr_m.label = -1 & te_p.label = 1 & te_m.label = -1
  out1 = feature2file(tr_p, outfile = out1)
  out2 = feature2file(tr_m, outfile = out2)
  out3 = feature2file(te_p, outfile = out3)
  out4 = feature2file(te_m, outfile = out4)
  
  ;- rescale, if requested
  if state.rescale then begin
     files = [strtrun(out1,'.dat')+'.sav', $
              strtrun(out2,'.dat')+'.sav', $
              strtrun(out3,'.dat')+'.sav', $
              strtrun(out4,'.dat')+'.sav']
     svm_rescale, files
     
     out1=strtrun(out1,'.dat')+'_r.dat'
     out2=strtrun(out2,'.dat')+'_r.dat'
     out3=strtrun(out3,'.dat')+'_r.dat'
     out4=strtrun(out4,'.dat')+'_r.dat'
  endif

  ;- run the svm on training set
  spawn, 'cat '+out1+' '+out2+' > train.dat'
  spawn, 'cat '+out3+' '+out4+' > test.dat'
  model = svm_learn('train.dat', outfile='/tmp/model.1', $
                    kernel = state.kernel eq 1 ? 2 : 0, $
                    c = state.c, g = state.g)
  
  ;- evaluate on test set
  test = [te_p, te_m]
  guess = svm_classify('test.dat', model)
  nl = npc('newline')
  fitness = sqrt(total(guess gt 0 and test.label eq 1)^2 / total(guess gt 0) / $
            total(test.label eq 1))
  str='  Correct Yes: '+string(total(guess gt 0 and test.label eq 1), format='(i0)')+$
      nl + 'Incorrect Yes: '+string(total(guess gt 0 and test.label eq -1), format='(i0)')+$
      nl + '  Correct No:  '+string(total(guess lt 0 and test.label eq -1), format='(i0)')+$
      nl + 'Incorrect No:  '+string(total(guess lt 0 and test.label eq 1), format='(i0)')+$
      nl+  '     Fitness:  '+string(fitness, format='(e0.2)')
  widget_control, state.summary, set_value=str
  state.fitness = fitness

  ;-update the mask
  *(state.mask) *= 0
  (*(state.mask))[test.x, test.y, test.z] = 2 * (test.label eq sign(guess)) - 1
  
  ;- display the mask
  gui_redraw, state
;  help, state, /struct
end
     
pro gui_redraw, state
  state.drawobj->redraw, mask=*(state.mask), lev=[-1, 1], c_color=fsc_color(['red','green'])
end

pro gui
  common gui, state
  tlb = widget_base(column = 1)

  r1 = widget_base(tlb, /row)
  r2 = widget_base(tlb, /row)
  r3 = widget_base(tlb, /row)
  r4 = widget_base(tlb, /row)
  r5 = widget_base(tlb, /row)
  r6 = widget_base(tlb, /row)
  r7 = widget_base(tlb, /row)
  r8 = widget_base(tlb, /row)
  r9 = widget_base(tlb, /row)
  r10 = widget_base(tlb, /row)
  r11 = widget_base(tlb, /row)
  r12 = widget_base(tlb, /row)

  l1 = widget_label(r1, value='Train +', /align_r)
  l2 = widget_label(r2, value='Train -', /align_r)
  l3 = widget_label(r3, value='Test +', /align_r)
  l4 = widget_label(r4, value='Test -', /align_r)
  l5 = widget_label(r5, value='Method', /align_r)
  l5 = widget_label(r6, value='Kernel', /align_r)
  l6 = widget_label(r7, value='C', /align_r)
  l7 = widget_label(r8, value='G', /align_r)
  l8 = widget_button(r9, value='Redraw', /align_r, uvalue='redraw')
  l9 = widget_label(r10)
  l10 = widget_label(r11, value='Normalize', /align_r)
  l12 = widget_label(r12, value='Fitness:', /align_r)
  fitness_lab = widget_label(r12, value='???         ')

  prefix='/Users/beaumont/m17loop/'
  b1 = widget_button(r1, value=prefix+'train_x_cloud.sav', uvalue='tr_p', /dynamic)
  b2 = widget_button(r2, value=prefix+'train_x_notcloud.sav', uvalue='tr_m', /dynamic)
  b3 = widget_button(r3, value=prefix+'train_y_cloud.sav', uvalue='te_p', /dynamic)
  b4 = widget_button(r4, value=prefix+'train_y_notcloud.sav', uvalue='te_m', /dynamic)
  
  methods = widget_droplist(r5, value=['edge', 'edge2', 'moment', 'pca', 'stamp'], $
                            uvalue = 'method')
  kernels = widget_droplist(r6, value=['Linear', 'RBF'], uvalue='kernel')
  
  c = widget_text(r7, /edit, value='1e-2', uvalue='c')
  copt = widget_button(r7, value='Optimize', uvalue='optimize_c')
  g = widget_text(r8, /edit, value='1e-2', uvalue='g')
  copt = widget_button(r8, value='Optimize', uvalue='optimize_g')

  run = widget_button(r9, value='run', uvalue='run')
  summary = widget_text(r10, value='', ysize = 5, xsize = 30)
  norm = widget_droplist(r11, value=['No', 'Yes'], uvalue='norm')
  junk = widget_label(r11, value='Rescale')
  rescale = widget_droplist(r11, value=['No', 'Yes'], uvalue='rescale')

  ;- read in data
  data = mrdfits('~/m17loop/mosaic.fits',0,h)
  nanswap, data, 0
  sz = size(data)
  mask = reform(data[*,*,50])
  mask = erode(mask ne 0, replicate(1B, 15, 15))
  data *= rebin(mask, sz[1], sz[2], sz[3])
  tlb2 = widget_base(group_leader = tlb, uvalue='draw', xoffset = 500)
  draw = cw_drawcube(data, tlb2)
  drawobj = obj_new('drawcube', id=draw)
  
  state = {tr_p:'', tr_m:'', te_p:'', te_m:'', method:0, kernel:0, $
           c:1e-2, g:1e-2, mask : ptr_new(byte(data) * 0), drawobj:drawobj, $
           summary:summary, norm: 0, fitness:0., ctext: c, gtext:g, $
           rescale:0B, $
           fitness_lab : fitness_lab}

  widget_control, b1, get_value = val & state.tr_p = val
  widget_control, b2, get_value = val & state.tr_m = val
  widget_control, b3, get_value = val & state.te_p = val
  widget_control, b4, get_value = val & state.te_m = val
  
  widget_control, tlb, set_uvalue = state
  widget_control, tlb, /realize
  widget_control, tlb2, /realize
  xmanager, 'gui', tlb2, /no_block
  xmanager, 'gui', tlb, /no_block
end
