pro psopen, filename, $
            LANDSCAPE=landscape, $
            XSIZE=xsize, $
            YSIZE=ysize, $
            INCHES=inches, $
            COLOR=color, $
            ENCAPSULATED=encapsulated, $
            BITS_PER_PIXEL=bits_per_pixel, $
            _REF_EXTRA=_extra
;+
; NAME:
;       PSOPEN
;     
; PURPOSE:
;       To open the PostScript device for outputting graphics to a file.
;     
; CALLING SEQUENCE:
;       PSOPEN, FILENAME [, /LANDSCAPE] [, XSIZE=width] [, YSIZE=height] [,
;       /INCHES] [, /COLOR] [, BITS_PER_PIXEL={1 | 2 | 4 | 8}] [, 
;       /ENCAPSULATED]
;
; Other DEVICE keywords accepted:
;       [, /AVANTGARDE | , /BKMAN | , /COURIER | , /HELVETICA | ,
;          /ISOLATIN1 | , /PALATINO | , /SCHOOLBOOK | , /SYMBOL | , 
;          /TIMES | , /ZAPFCHANCERY | , /ZAPFDINGBATS ] [, 
;        /BOLD] [, /BOOK] [, /DEMI] [, FONT_INDEX=integer] [, 
;       FONT_SIZE=points] [,  GLYPH_CACHE=number_of_glyphs] [,
;       /ITALIC] [, /LIGHT] [, /MEDIUM] [, /NARROW] [, /OBLIQUE] [, 
;       OUTPUT=scalar string] [, SCALE_FACTOR=value] [, 
;       SET_CHARACTER_SIZE=[font size, line spacing]] [, 
;       SET_FONT=scalar string] [, /TT_FONT] [, 
;       XOFFSET=value] [, YOFFSET=value]
;
; INPUTS:
;       FILENAME : String with the name of the PostScript file to be opened.
;     
; OUTPUTS:
;       None.
;
; KEYWORDS:
;       /LANDSCAPE: If set, landscape orientation is used. Portrait 
;                   orientation is the default.
;
;       XSIZE = The width of output generated by IDL. XSIZE is specified 
;               in centimeters, unless /INCHES is set.
;
;       YSIZE = The height of output generated by IDL. YSIZE is specified 
;               in centimeters, unless /INCHES is set.
;       
;       XOFFSET = The X position, on the page, of the lower left corner of 
;                 output generated by IDL. XOFFSET is specified in 
;                 centimeters, unless /INCHES is set.
;
;       YOFFSET = The Y position, on the page, of the lower left corner of 
;                 output generated by IDL. YOFFSET is specified in 
;                 centimeters, unless /INCHES is set.
;
;       /INCHES : Normally, the XOFFSET, XSIZE, YOFFSET, and YSIZE keywords 
;                 are specified in centimeters. However, if INCHES is 
;                 present and non-zero, they are taken to be in inches 
;                 instead.
;
;       /COLOR: Set this keyword to enable color PostScript output.
;
;       BITS_PER_PIXEL = The number of bits per pixel to use. IDL is capable 
;                        of producing PostScript images with 1, 2, 4, or 8 
;                        bits per pixel. Using more bits per pixel gives 
;                        higher resolution at the cost of generating larger 
;                        files.  The default value is 8 bits per pixel.
;
;       /ENCAPSULATED: Set this keyword to create an encapsulated 
;                      PostScript file, suitable for importing into another 
;                      document (e.g., LaTeX). The file extension will be 
;                      ".eps" rather than the default ".ps".
;
;       See "Keywords Accepted by the IDL Devices" in the IDL Online Help.  
;       Only keywords followed by {PS} are applicable to the PostScript 
;       device.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;	The graphics device is set to PostScript.
;       If FILENAME is sent in without a ".ps" or ".eps" suffix, it is
;       returned with one appended to it.  Also, if the requested
;       filename has a ".ps" suffix and the /ENCAPSULATED keyword is
;       set, the file will be saved with a ".eps" suffix.  It is
;       standard operating procedure for encapsulated PostScript
;       files to end with ".eps" and this is enforced by ApJ, so
;       we make it so.
;
; RESTRICTIONS:
;       PSOPEN assumes letter-sized pages.
;       PSOPEN sets the graphics device to PostScript and leaves a
;       file open upon completion.  Therefore, after all graphics
;       have been created for this file, it is necessary to close
;       the file (DEVICE, /CLOSE_FILE) and set the graphics device
;       back to the default for your machine (probably X Windows).
;       PSCLOSE will do all of this for you.
;
; EXAMPLE:
;       Make a PostScript file 5in by 5in:
;         IDL> psopen, 'foo.ps', XSIZE=5, YSIZE=5, /INCHES
;         IDL> plot, findgen(30)^2
;         IDL> psclose
;
;       Make a color PostScript image:
;         IDL> psopen, 'foo.ps', /COLOR
;         IDL> setcolors, /SYSTEM_VARIABLES
;         IDL> plot, findgen(30), color=!red
;         IDL> oplot, findgen(30)^2, color=!blue
;         IDL> xyouts, 0.25, 0.5, /normal, 'Parabola', color=!green
;         IDL> xyouts, 0.55, 0.5, /normal, 'Line', color=!magenta
;         IDL> psclose
;         IDL> setcolors, /SYSTEM_VARIABLES
;
;       Make a PostScript image taking advantage of PostScript fonts
;       AND the ability (unique in IDL fontdom) of PS fonts to have
;       embedded formatting command indices changed:
;         IDL> psopen, 'foo.ps', /HELVETICA, /BOLD, /OBLIQU, /ISOLATIN1
;         IDL> device, /BKMAN, /DEMI, /ITALIC, /ISOLATIN1, FONT_INDEX=10
;         IDL> plot, findgen(3), FONT=0, $
;         IDL>   xtit='Galactic Radius !10'+string(174B)+'!X [kpc]', $
;         IDL>   ytit='Density !10'+string(181B)+'!X [cm!E-3!N]'
;         IDL> psclose
;
; NOTES:
;       Add device keywords if you want to change font characteristics
;       but remember that in order to use PostScript fonts you must either 
;       set the !P.FONT system variable to 0 (so that IDL uses the 
;       hardware fonts) or send any of the plotting routines the 
;       FONT keyword set to 0.
;       
;       Remember that the PostScript device is 8-bit and has exactly
;       256 color table indices.  So, on your X-windows device, if
;       you're running 8-bit PseudoColor, you've probably got less
;       than 256 color table indices available... if you're running
;       24-bit TrueColor or DirectColor, you've got 16 million color
;       indices and no color table at all.  If you're storing color
;       table indices in variables, you'll need to reassign these
;       variables with the correct color table indices after you've
;       opened the PostScript device (and again when you've closed
;       it!)
;
; RELATED PROCEDURES:
;       PSCLOSE
;
; MODIFICATION HISTORY:
;       Written by Tim Robishaw in ancient times.
;       27 Feb 2002  Spiffed up by TR
;       28 Jan 2004  Cosmetic changes. TR
;-

; LOOK FOR A POSTSCRIPT EXTENSION...
filename = strtrim(filename,2)
dotpos = strpos(filename,'.',/reverse_search)
if (dotpos ge 0) then begin

    ; STRIP THE CURRENT SUFFIX SO WE CAN APPEND PROPER SUFFIX...
    suffix = strmid(filename,dotpos)
    if strcmp(suffix,'.ps',/FOLD_CASE) OR strcmp(suffix,'.eps',/FOLD_CASE) $
      then filename = strmid(filename,0,dotpos)

endif

; APPEND THE PROPER EXTENSION...
filename = filename + (keyword_set(ENCAPSULATED) ? '.eps' : '.ps')

; DEFAULT BITS_PER_PIXEL IS 8...
if (N_elements(BITS_PER_PIXEL) eq 0) then bits_per_pixel = 8

; IF /INCHES KEYWORD NOT SET, SIZES ARE IN CENTIMETERS...
inch2cm = keyword_set(INCHES) ? 1.0 : 2.54

; IF XSIZE, YSIZE, XOFFSET OR YOFFSET ARE SENT IN VIA _REF_EXTRA, 
; THOSE VALUES WILL OVERRIDE THE ONES BELOW...
if keyword_set(LANDSCAPE) then begin

    ; SET UP LANDSCAPE ORIENTATION...
    if (N_elements(XSIZE) eq 0) OR (N_elements(YSIZE) eq 0) then begin
        xsize = 10.5*inch2cm
        ysize =  8.0*inch2cm
    endif

    ; KEEP THE IMAGE CENTERED ON PAGE...
    xoffset = 0.5*( 8.5*inch2cm-ysize)
    yoffset = 0.5*(11.0*inch2cm-xsize) + xsize

endif else begin

    ; SET UP PORTRAIT ORIENTATION...
    if (N_elements(XSIZE) eq 0) OR (N_elements(YSIZE) eq 0) then begin
        xsize =  8.0*inch2cm
        ysize = 10.5*inch2cm
    endif

    ; KEEP THE IMAGE CENTERED ON PAGE...
    xoffset = 0.5*( 8.5*inch2cm-xsize)
    yoffset = 0.5*(11.0*inch2cm-ysize)

endelse

; SET THE OUTPUT DEVICE FOR IDL GRAPHICS TO POSTSCRIPT...
set_plot, 'PS'

; SET THE DEVICE PARAMETERS...
device, FILENAME  = filename, $
        LANDSCAPE = keyword_set(LANDSCAPE), $
        XSIZE     = xsize, $
        YSIZE     = ysize, $
        XOFFSET   = xoffset, $
        YOFFSET   = yoffset, $
        INCHES    = keyword_set(INCHES), $
        COLOR     = keyword_set(COLOR), $
        BITS_PER_PIXEL = bits_per_pixel, $
        ENCAPSULATED   = keyword_set(ENCAPSULATED), $
        _EXTRA    = _extra

end; psopen
