pro cattest

file='/users/cnb/glimpse/glimic/glmic_l018.tbl'
; Open the file
OPENR, 1, file

A = ''
skip_lun,1,13,/lines


; Loop until EOF is found:
WHILE ~ EOF(1) DO BEGIN


   ; Read a line of text:


   READF, 1, A
   row=strsplit(A,'',/extract)
   ; Print the line:

ENDWHILE
; Close the file:
CLOSE, 1
end
