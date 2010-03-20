;+
; NAME:
;  NICER_CONTROL
;
; DESCRIPTION:
;  This function evaluates the covariance matrix of infrared colors
;  of stars unreddened by extinction (i.e. the control group). This 
;  information is needed as input to the NICER algorithm described 
;  by Lombardi and Alves 2001, and implemented in NICER.PRO. 
;
;  The tricky part about this is choosing stars which are unreddened.
;  Finding this, of course, requires measuring the Av, which would use
;  NICER. To get around this circularity, estimates for the covariance
;  factors are included in NICER by default. NICER_CONTROL feeds a set
;  of IR colors into NICER for a first estiamte of Av. The low Av
;  objects in this sample are then used by NICER_CONTROL to calculate
;  the covariance matrices.
;
; CALLING SEQUENCE:
;  NICER_CONTROL, covar, color
;  NICER_CONTROL, covar, color, j, dj, h, dh, k, dk, i1, di1, i2, di2,
;                 [/NOCLIP, /VERBOSE]
;
; OPTIONAL INPUTS:
;  j, h, k, i1, i2: Source magnitudes
;  dj - di2: Magnitude errors
;  If no arguments are given, the procedure loads sources from
;  a saved GLIMIC data file.
;
; OPTIONAL KEYWORDS:
;  NOCLIP: If set and nonzero, the input magnitudes are assumed to
;          correspond to un-reddened stars. In this case, all objects
;          are used to calculate the covariance matrix. This keyword
;          is ignored if input magnitudes are not given
;  VERBOSE: Print/plot information throughout the process
;
; OUTPUTS:
;  covar: The covariance matrix for the 4 IR colors (j-h, h-k, k-1,
;         1-2)
;  color: The average of each of the four colors
;-
  
pro nicer_control, covar, color, j, dj, h, dh, k, dk, i1, di1, i2, di2, noclip=noclip, verbose=verbose

;- check for input
if n_params() ne 12 && n_params() ne 2 then begin
    print, 'NICER_CONTROL calling sequence:'
    print, 'NICER_CONTROL, covar, color, j, dj, h, dh, j, dj, i1, di1, i2, di2, [/noclip,/verbose]'
    print, 'j h k i1 i2: Magnitudes'
    print, 'dj dh dk di1 di2: Magnitude Errors'
    return
endif

if ~keyword_set(noclip) then noclip = 0

;- read the default catalog if no magnitudes are supplied
if n_params() ne 12 then begin
    
    file = '/users/cnb/glimpse/pro/63.sav'
    if ~file_test(file) then message, 'Default Catalog Not Found: '+file
    restore, file ;- restores GLIMIC structure
  
    ;- remove missing data entries and copy over data
    good = where(glimic.magj le 50 and glimic.magh le 50 and glimic.magk le 50 $
                 and glimic.mag1 le 50 and glimic.mag2 le 50 and glimic.mag3 le 50)
    glimic = glimic[good]
    j   = glimic.magj
    dj  = glimic.dmagj
    h   = glimic.magh
    dh  = glimic.dmagh
    k   = glimic.magk
    dk  = glimic.dmagk
    i1  = glimic.mag1
    di1 = glimic.dmag1
    i2  = glimic.mag2
    di2 = glimic.dmag2
endif

if noclip eq 0 then begin
    av = nicer(j, dj, h, dh, k ,dk)
    low = (sort(av))[0:200]
    if av[low[200]] ge .01 then message, 'Could not find enough low-extinction objects'
    j   =   j[low]
    dj  =  dj[low]
    h   =   h[low]
    dh  =  dh[low]
    k   =   k[low]
    dk  =  dk[low]
    i1  =  i1[low]
    di1 = di1[low]
    i2  =  i2[low]
    di2 = di2[low]
endif

;- calculate colors
c1 = j - h
c2 = h - k
c3 = k - i1
c4 = i1 - i2

color = [mean(c1), mean(c2), mean(c3), mean(c4)]

covar = dblarr(4,4)
covar[0,0] = variance(c1)
covar[0,1] = mean((c1 - color[0]) * (c2 - color[1]))
covar[0,2] = mean((c1 - color[0]) * (c3 - color[2]))
covar[0,3] = mean((c1 - color[0]) * (c4 - color[3]))
covar[1,0] = covar[0,1]
covar[1,1] = variance(c2)
covar[1,2] = mean((c1 - color[1]) * (c3 - color[2]))
covar[1,3] = mean((c1 - color[1]) * (c4 - color[3]))
covar[2,0] = covar[0,2]
covar[2,1] = covar[1,2]
covar[2,2] = variance(c3)
covar[2,3] = mean((c2 - color[2]) * (c3 - color[3]))
covar[3,0] = covar[0,3]
covar[3,1] = covar[1,3]
covar[3,2] = covar[2,3]
covar[3,3] = variance(c4)

;- visualize and print results
if keyword_set(verbose) then begin
    old = !p.multi
    !p.multi = [0,2,1]
    plot, c1, c2, psym = 3, xtitle='J - H', ytitle='H - K', xra=[-1, 2.5], yra=[-.5,3], /xsty, /ysty
    plot, c3, c4, psym = 3, xtitle='K - I1', ytitle='I1 - I2'
    !p.multi = old
    print, 'Intrinsic Covariance Matrix: '
    print, covar, format='((4(f7.4)))'
    print, 'Mean Colors: '
    print, color, format='((4(f7.4)))'
endif

end
