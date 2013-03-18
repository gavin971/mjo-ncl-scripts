load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/prince_util.ncl"
begin
;***************************************************************
; User Input
;***************************************************************
                                             
   diri   = "/host/pxavier/data/TRMM/data/daily/Global/"
   diro   = "/host/pxavier/data/TRMM/data/daily/SEAsia/"

   files  = systemfunc("ls "+diri+"*.nc")

   nfiles = dimsizes(files)
   do nf = 0, nfiles-1
      print("Subsetting "+ files(nf))
      f = addfile(files(nf), "r")      
      r = f->r(0,{-10:20},{80:130})

      fbasename = systemfunc("basename "+files(nf))
;      print(fbasename)

      ; Writing the subset out
      outfile = diro+fbasename
      system("/bin/rm -f "+outfile)   ; remove any pre-existing file
      ncdf     = addfile(outfile ,"c")  ; open output netCDF file
      ; make time and UNLIMITED dimension      ; recommended  for most applications
      ;filedimdef(ncdf,"time",-1,True) 
      ; output variables directly
      ncdf->r = r                         ; 2D
      delete(r)

   end do             
   

   
end
