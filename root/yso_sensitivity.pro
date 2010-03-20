;+
; PURPOSE:
;  using the Robataille models, estimate the faintest protostar that
;  would be detected with the IRAC 8 micron band in GLIMPSE
;-
pro yso_sensitivity

dist = 3.;- kpc
av = 15  ;- magnitudes
dav = 5  ;- range
f0 = 64.13d3 ;- zero point of I4 in mJy

;- yso grid parameters
restore, 'param.sav'
restore, 'i4.sav'
good = where(abs(av_int - av) lt dav)

mass = massc
flux = i4[100,*]
mag = -2.5 * alog10(flux / dist^2 / f0)

;plot, mass[good], mag[good], psym = symcat(16), symsize = .3, xra = [0, 5]
;oplot, [0,5], [12, 12], color = fsc_color('crimson'), thick = 4

plot, mass[good], flux[good] / dist^2, psym = symcat(16), symsize = .3, xra = [0, 5], /ylog
oplot, [0,5], [2.5, 2.5], color = fsc_color('crimson'), thick = 4

;- estimate completeness
flux = flux[good] / dist^2
mass = mass[good]
get = where(flux ge 2.5, comp = miss)

bin = [20, 50, 100, 200, 500, 1000]
for i = 0, n_elements(bin) - 1, 1 do begin
   hg = histogram(mass[get], min = 0, max = 20, nbin = bin[i], loc = locg)
   hm = histogram(mass[miss], min = 0, max = 20, nbin = bin[i], loc = locm)
   imf = cnb_imf(locg, /muench)
   imf /= total(imf)
   comp = 1D * hg / (hg + hm)
   
   ;plot, locg, 1D * hg / (hg + hm), psym = 10
   
   nt = 1 / total((imf * comp),/nan)
   print, bin[i], nt
endfor

end
