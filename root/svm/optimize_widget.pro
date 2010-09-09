;+
; Wrapper function for use with brent
;  x: Scalar value for c or g
;  config: The svm config structure (state variable in gui.pro)
function optimize_widget_func, x, state = config, c = c, gam = g
  s = config
  ;- update state variable with correct svm params
  if keyword_set(c) then begin
     s.c = x 
     assert, ~keyword_set(g)
  endif else begin
     assert, keyword_set(g)
     s.g = x
  endelse
  run_svm, s, fitness = f
  return, 1 - f
end

pro optimize_widget_event, event
  widget_control, event.top, get_uvalue = state

  ;- ignore events changing value of brackets
  if event.id ne state.run && $
     event.id ne state.run_bracket then return

  ;- calculate the bracket values
  if event.id eq state.run then begin
     widget_control, state.v1, get_value = v1 & ax = float(v1)
     widget_control, state.v2, get_value = v2 & bx = float(v2)
     widget_control, state.v3, get_value = v3 & cx = float(v3)
     fa = optimize_widget_func(ax, state = state.config, c = state.c, gam=state.g)
     fb = optimize_widget_func(bx, state = state.config, c = state.c, gam=state.g)
     fc = optimize_widget_func(cx, state = state.config, c = state.c, gam=state.g)
  endif else begin
     a = state.c ? state.config.c : state.config.g
     print, a
     bracket, 'optimize_widget_func', a, a * 1.1, ax, bx, cx, fa, fb, fc, $
              state = state.config, c = state.c, gam = state.g
  endelse

  if (bx - ax) * (cx - bx) le 0 || $
     fb ge fa || fb ge fc then begin
     print, 'Bad bracket'
     print, ax, bx, cx
     print, fa, fb, fc
     return
  endif

  ;- minimize
  result = brent('optimize_widget_func', ax, bx, cx, fa, fb, fc, $
                 tol = .1, fmin = fmin, state = state.config, c = state.c, gam=state.g)

  ;- update the state information
  *state.min = result & *state.fmin = fmin
  widget_control, event.top, set_uvalue = state ;- not needed

  ;- destroy widget
  widget_control, event.top, /destroy
end


; widget definition
; state: gui state variable (svm config)
; c: optimize on c?
; g: optimize on g?
; fitness: Output keyword will hold best fitness
function optimize_widget, state, c = c, g = g, fitness = fitness
  tlb = widget_base(col = 2)
  l1 = widget_label(tlb, value='Value 1')
  l2 = widget_label(tlb, value='Value 2')
  l3 = widget_label(tlb, value='Value 3')
  run = widget_button(tlb, value='go')

  v1 = widget_text(tlb, value='      ', /edit)
  v2 = widget_text(tlb, value='      ', /edit)
  v3 = widget_text(tlb, value='      ', /edit)
  run_bracket = widget_button(tlb, value='bracket+go')

  widget_control, tlb, /realize
  min_ptr = ptr_new(0.)
  fmin_ptr = ptr_new(0.)

  info={v1:v1, v2:v2, v3:v3, $
        c:keyword_set(c), g:keyword_set(g), $
        config:state, run:run, run_bracket:run_bracket, $
        min:min_ptr, fmin:fmin_ptr}

  widget_control, tlb, set_uvalue=info
  xmanager, 'optimize_widget', tlb

  ;- get the new state info
  min = *min_ptr & ptr_Free, min_ptr
  fitness = *fmin_ptr & ptr_free, fmin_ptr
  fitness = 1 - fitness
  return, min

end
