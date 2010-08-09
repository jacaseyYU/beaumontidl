function scrabble_event, event
  child = widget_info(event.handler, /child)
  widget_control, child, get_uvalue = state, /no_copy
  case event.id of
     state.wid: begin
        ;- left MB changes coordinate
        if event.type eq 0 && event.press eq 1 then begin
           c = convert_coord(event.x, event.y, /device, /to_data)
           c = floor(c)

           ;- ignore oob values
           if min(c, max=hi) lt 0 || hi gt 14 then break
           c[1] = 14 - c[1]
           c = 0 > c < 14

           ;- re-clicking on same square changes direction
           if state.x eq c[0] && state.y eq c[1] then $
              state.dir = ~state.dir

           state.x = c[0] & state.y = c[1]           
        endif
        
        ;-keyboard changes board
        if event.type eq 5 && event.release eq 1 then begin
           char = event.ch
                                
           ;- backspace
           isBS = event.ch eq byte(npc('backspace'))
           if isBS then begin
              state.board[state.x, state.y] = ''
              scrabble_move, state, state.dir eq 1 ? 1 : 2
           endif

           ;- arrow keys
           if event.key eq 5 then scrabble_move, state, 2
           if event.key eq 6 then scrabble_move, state, 0
           if event.key eq 7 then scrabble_move, state, 1
           if event.key eq 8 then scrabble_move, state, 3

           isLower = event.ch ge byte('a') and event.ch le byte('z')
           isUpper = event.ch ge byte('A') and event.ch le byte('Z')
           if isUpper then char += (byte('a') - byte('A'))
           if ~isUpper && ~isLower then break
           char = string(char)
           state.board[state.x, state.y] = char
           scrabble_move, state, state.dir ? 3 : 0
        endif
     end
     state.ai: begin
        widget_control, state.tiles, get_value=tiles
        tiles = tiles[0]
        len = strlen(tiles)
        t = strarr(len)
        for i = 0, len - 1, 1 do t[i] = strmid(tiles, i,1)
        best = get_best_move(state.board, t)
        state.board = best->fetch_best()
        obj_destroy, best
     end
     state.reset:state.board[*]=''
     state.scramble:begin
        widget_control, state.letters, get_value=v
        v = v[0]
        new = strarr(strlen(v))
        s = sort(randomu(seed, strlen(v)))
        for i = 0, strlen(v)-1 do new[i] = strmid(v, s[i], 1)
        widget_control, state.letters, set_value=strjoin(new)
     end
     else:
  endcase
  scrabble_redraw, state
  widget_control, child, set_uvalue = state, /no_copy
  
  ;-generate an event
  return, {scrabble_event, id:event.handler, top:event.top, handler:0L}
end

function scrabble_get_value, id
  child = widget_info(id, /child)
  widget_control, child, get_uvalue = result
  return, result
end

pro scrabble_set_value, id, value
  child = widget_info(id, /child)
  widget_control, child, set_uvalue = value
  scrabble_redraw, value
end

pro scrabble_move, state, dir
  dx = 0 & dy = 0
  if dir eq 0 then dx = 1
  if dir eq 1 then dy = -1
  if dir eq 2 then dx = -1
  if dir eq 3 then dy = 1

  state.x = 0 > (state.x + dx) < 14
  state.y = 0 > (state.y + dy) < 14
end

pro scrabble_redraw, state
  widget_control, state.wid, get_value = wid
  wset, wid
  draw_board, state.board, wid = wid, pstruct = p
  !p = p
  oplot, [state.x, state.x+1, state.x+1, state.x, state.x], $
         14-[state.y, state.y, state.y-1, state.y-1, state.y], $
         thick = 3
  dx = state.dir ? 0 : .25
  dy = state.dir ? .25 : 0
  oplot, state.x+.5+[-dx, dx], 14-state.y+.5-[-dy, dy], thick=2, $
         color = fsc_color('red')
  state.p = !p
end

function scrabble, parent
  font='-monotype-arial-medium-r-normal--0-0-0-0-p-0-iso8859-1'


  if n_elements(parent) ne 0 then begin
     tlb = widget_base(parent, row = 1, event_func = 'scrabble_event', $
                       pro_set_value='scrabble_set_value', $
                       func_get_value='scrabble_get_value')
  endif else begin
     tlb = widget_base(row = 1, event_func = 'scrabble_event', $
                       pro_set_value='scrabble_set_value', $
                       func_get_value='scrabble_get_value')
  endelse
     
  board = widget_draw(tlb, xsize = 800, ysize = 800, /keyboard_events, $
                     /button_events)

  base = widget_base(tlb, col = 1, xsize = 200)
  r1 = widget_base(base, /row)
  r2 = widget_base(base, /row)
  r3 = widget_base(base, /row)
  r4 = widget_base(base, /row)
  
  temp = widget_label(r1, value= 'Player 1 Score:', font=font)
  score1 = widget_label(r1, value=' 0   ', font=font)
  temp = widget_label(r2, value = 'Player 2 Score:', font=font)
  score2 = widget_label(r2, value=' 0   ', font=font)

  l = widget_label(r3, value = 'Tiles', font=font)
  tiles = widget_text(r3, value='', xsize = 10, /edit, font=font)
  ai = widget_button(r4, value='AI')
  scramble = widget_button(r4, value='Scramble')
  reset = widget_button(r4, value='Reset')

  game_board = strarr(15, 15)
  info = {wid:board, score1:score1, score2:score2, letters:tiles, $
          board:game_board, x:7, y:7, p:!p, ai:ai, reset:reset, $
          dir:0B, scramble:scramble}
  child = widget_info(tlb, /child)
  widget_control, child, set_uvalue = info, /no_copy
  return, tlb

;  widget_control, tlb, /realize
;  scrabble_redraw, info
;  xmanager, 'scrabble', tlb
end
  
