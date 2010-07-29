;+
; PURPOSE:
;  A gui to practice guessing 7 letter words from a scrambled list of
;  letters
;-
pro bingo_practice, scramble, answers
  compile_opt idl2
  common bingo, scrambles, words, uniq, us, ind, h, good, ct
  if n_elements(scrambles) eq 0 then begin
     readcol, 'bingos.txt', scrambles, words, format='a, a'
     uniq = uniq(scrambles)
     us = scrambles[uniq]
     ind = value_locate(us, scrambles)
     h = histogram(ind, loc = l, min = 0)
     good = where(h gt 5, ct)
  endif

  r = floor(randomu(seed) * ct)
  hit = where(scrambles eq us[good[r]])
  scramble = us[good[r]]
  answers = words[hit]
  return
end

pro bingogame_event, event
  widget_control, event.id, get_uvalue = id
  widget_control, event.top, get_uvalue = st
  if id eq 'next' then begin

     ;- new round
     bingo_practice, scramble, answers
     info = {scramble : scramble, answers : answers, cluebox : st.cluebox, answerbox : st.answerbox, $
            guessed : replicate(0, n_elements(answers))}
     widget_control, event.top, set_uvalue = info
     widget_control, st.cluebox, set_value = scramble
     widget_control, st.answerbox, set_value=''
     widget_control, st.answerbox, set_uvalue=''

     ;- switch to answer button
     widget_control, event.id, set_value = 'answer ('+strtrim(n_elements(answers),2)+')'
     widget_control, event.id, set_uvalue = 'answer'
  endif
  if id eq 'answer' then begin
     widget_control, st.answerbox, set_value = strflat(st.answers)
     
     ;- switch to a next button
     widget_control, event.id, set_value='next'
     widget_control, event.id, set_uvalue='next'
  endif
  if id eq 'guess' then begin
     widget_control, event.id, get_value = guess
     guess = guess[0]
     ;print, guess
     ;print, st.answers
     ;help, st.answers
     hit = where(guess eq st.answers, ct)
     ;print, hit, ct

     if ct ne 0 then st.guessed[hit] = 1
     display=''
     for i = 0, n_elements(st.answers) - 1 do $
        display += st.guessed[i] ? st.answers[i]+npc('newline') : npc('newline')
     widget_control, st.answerbox, set_value=display
;     if ct ne 0 then begin
;        widget_control, st.answerbox, get_uvalue = ans
;        help, ans
;        widget_control, st.answerbox, set_value= ans+npc('newline')+guess
;        widget_control, st.answerbox, set_uvalue= ans+npc('newline')+guess
;        widget_control, st.answerbox, get_uvalue = ans
;        help, ans
;     endif
     widget_control, event.id, set_value = ''
     widget_control, event.top, set_uvalue=st
  endif
end


pro bingogame

  font = '-adobe-helvetica-bold-o-normal--12-120-75-75-p-69-iso8859-13'
  font = '-adobe-times-medium-r-normal--48-120-75-75-p-64-iso8859-15'
  font = '-adobe-times-bold-r-normal--34-240-100-100-p-177-iso8859-15'

  tlb = widget_base(column = 1, xsize = 300, ysize = 700)
  clue = widget_label(tlb, uvalue='clue', font=font, xsize = 300,value='')
  answer = widget_label(tlb, uvalue='', font = font, xsize = 300, ysize = 400,value='')

  guess = widget_text(tlb, /edit, font = font, uvalue='guess')
  

  bingo_practice, scramble, answers
  widget_control, clue, set_value=scramble

  button = widget_button(tlb, uvalue='answer', font = font, value='answer('+strtrim(n_elements(answers),2)+')')

  info = {scramble : scramble, answers : answers, cluebox : clue, answerbox : answer, $
          guessed : replicate(0, n_elements(answers))}
  widget_control, tlb, set_uvalue = info
  

  widget_control, tlb, /realize
  xmanager, 'bingogame', tlb, event='bingogame_event'
end
