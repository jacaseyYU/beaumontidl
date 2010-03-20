function readglimic, infile
;infile='/users/cnb/glimpse/glimic/GLIMIC_L011.tbl'
if ~file_test(infile) then message, 'Error- File DNE'

fmt='(A27, A18,I10, 2(2F11.6,2F7.1), I4, 14(F7.3), 22(E11.3), 7(F7.2), 4(F9.1), 8(I6), 7(I11), 4(I6))'
record={designation:' ',$
        tmass_desig:' ',$
        tmass_cntr:0ULL,$
        l:0D,$
        b:0D,$
        dl:0.0,$
        db:0.0,$
        ra:0D,$
        dec:0D,$
        dra:0.0,$
        ddec:0.0,$
        csf:0,$
        magj:0.0, dmagj:0.0, magh:0.0, dmagh:0.0, magk:0.0, dmagk:0.0,$
        mag1:0.0, dmag1:0.0, mag2:0.0, dmag2:0.0, mag3:0.0, dmag3:0.0,mag4:0.0, dmag4:0.0, $
        Fj:0.0, dFj:0.0, Fh:0.0, dFh:0.0, Fk:0.0, dFk:0.0, $
        F1:0.0, dF1:0.0, F2:0.0, dF2:0.0, F3:0.0, dF3:0.0, F4:0.0, dF4:0.0, $
        F1_rms:0.0, F2_rms:0.0, F3_rms:0.0,F4_rms:0.0,$
        sky1:0.0, sky2:0.0, sky3:0.0, sky4:0.0,$
        SNJ:0.0, SNH:0.0, SNK:0.0, $
        SN1:0.0, SN2:0.0, SN3:0.0, SN4:0.0,$
        srcdens1:0.0, srcdens2:0.0, srcdens3:0.0, srdens4:0.0,$
        M1:0L, M2:0L, M3:0L, M4:0L,$
        N1:0L, N2:0L, N3:0L, N4:0L,$
        SQFJ:0L,SQFH:0L,SQFK:0L, $
        SQF1:0L, SQF2:0L, SQF3:0L, SQF4:0L,$
        MF1: 0, MF2:0, MF3:0, MF4:0}


openr,lun,infile,/get_lun
;-read number of entries from line
skip_lun,lun,6,/lines
a=' '
readf,lun,a
nrec=long((strsplit(a,':',/extract))[1])

;-skip to beginning of data
skip_lun,lun,6,/lines
to=systime(/seconds)
data=replicate(record,nrec)

t0=systime(/seconds)
i=0L
while ~eof(lun) do begin
    readf,lun,record,format=fmt
    data[i]=record
    i++
endwhile
data=data[0:i-1]

free_lun,lun
return,data
end

