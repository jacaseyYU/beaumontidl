pro sfFigureDriver

files = file_search('/users/cnb/glimpse/pro/shells/saved/*.sav', count=ct)
if ct eq 0 then begin
    print, 'no files'
    return
endif

set_plot, 'x'
window, xsize = 1100, ysize = 850, /pixmap
pageInfo = pswindow(/land)
set_plot, 'ps'

device, /color, bits = 8, file='~/paper/figs/sf_all.ps', $
  preview = 0, _extra = pageInfo,/inches

for i = 0, ct -1 , 1 do begin
    bubble = strsplit(files[i],'/',/extract)
    bubble = strsplit(bubble[n_elements(bubble)-1],'.',/extract)
    bubble = long(bubble[0]) 
    print, bubble, format="('Starting Bubble ', i3)"
    sffigure, bubble, /out, /nosetup
endfor

device,/close
set_plot,'x'
end
