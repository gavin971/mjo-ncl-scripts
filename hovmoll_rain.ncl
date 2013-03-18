load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/prince_util.ncl"

function read_data(filenames)
; Function to read data for the given phase
begin
  fall = addfiles (filenames, "r")   ; note the "s" of addfile
  ;========================
  ; choose how files are combined and read in variable across files
  ;========================  
  ListSetType (fall, "join")             ; concatenate or "merge" (default)
  hov = dim_avg_n_Wrap(fall[:]->r(:,{-15:15},{80:130}),1)

  return( hov )
end


; Main script
begin
 
    diri   = "/host/pxavier/data/TRMM/data/daily/SEAsia/"        ; input directory
    ; Reading the RMM values

    rmmfile = "RMM1RMM2.74toRealtime.txt"
    nheaders = 2
    data = asciiread(rmmfile,-1,"string")
    headers = data(0:nheaders-1) 
    year    = stringtointeger(str_get_field(data(nheaders::), 1, " "))
    month   = stringtointeger(str_get_field(data(nheaders::), 2, " "))
    day     = stringtointeger(str_get_field(data(nheaders::), 3, " "))
    rmm1    = stringtofloat  (str_get_field(data(nheaders::), 4, " "))
    rmm2    = stringtofloat  (str_get_field(data(nheaders::), 5, " "))
    phase   = stringtointeger(str_get_field(data(nheaders::), 6, " "))
    amp     = stringtofloat  (str_get_field(data(nheaders::), 7, " "))
    ;print(year+" " + month+" "+day+" "+rmm1+" "+rmm2+" "+phase+" "+amp)

    inds  = ind( (year.eq.1999.or.year.eq.2000).and.(month.ge.11.or.month.le.3) ) 

    comp_dates = year(inds)+"."+sprinti("%0.2i", month(inds))+"."+sprinti("%0.2i",day(inds))

    ; Create a list of filenames to read
    filenames  = diri+"3B42_daily."+comp_dates+".7.nc"

    ; read the data using the subroutine at the top
    hov = read_data(filenames)
    
    printVarSummary(hov)


    ;dums   = dimsizes(mean)
    ;nlat   = dums(0)
    ;nlon   = dums(1)

    ; An array to hold 8 composite phases
    ;comp   = new((/8,nlat,nlon/),"float")    
    
    ;do p = 1,8
      ; Get the indices of the dates that match phases p and amplitude > 1.5
    ;  inds = ind( (year.ge.1998).and.(year.le.2012).and.(month.ge.11.or.month.le.3).and.(phase.eq.p).and.(amp.gt.2.0) )   
    ;  ; Create composites
    ;  print("Creating composites for phase "+p+" using "+dimsizes(inds)+" values")     
    ;  comp(p-1,:,:) = composite(diri, inds, year, month, day)    
    ;  delete(inds)
    ;end do

;************************************************
; plot resources
;************************************************
  wks = gsn_open_wks("eps","hovmoll_rain")            ; open a ps file
  gsn_define_colormap(wks,"WhBlGrYeRe")       ; choose colormap
  plot = new(8,graphic)

  res                     = True               ; plot mods desired
  res@cnFillOn            = True               ; turn on color   
  ;res@cnFillMode          = "CellFill"
  res@gsnSpreadColors     = True               ; use full color map
  res@gsnSpreadColorStart = 0
  res@cnLinesOn           = False              ; no contour lines
  res@cnLineLabelsOn      = False              ; no line labels
  res@gsnAddCyclic        = False

  ;res@mpMinLatF           = -10 
  ;res@mpMaxLatF           = 20                 ; choose map range
  ;res@mpMinLonF            = 90
  ;res@mpMaxLonF            = 120               ; zoom in over australia

  res@gsnDraw             = False              ; don't draw yet
  res@gsnFrame            = False              ; don't advance frame yet


  res@cnLevelSelectionMode =  "ManualLevels"   ; manual levels
  res@cnMinLevelValF       = 2.0                 ; min level
  res@cnMaxLevelValF       = 20.                  ; max level
  res@cnLevelSpacingF      = 2.                ; interval
  
  ;res@cnMinLevelValF       = 0.0                 ; min level
  ;res@cnMaxLevelValF       = 2.                  ; max level
  ;res@cnLevelSpacingF      = 0.1                ; interval
  
  res@tmXBLabelFontHeightF     = 0.014         ; adjust some font heights
  res@tmYLLabelFontHeightF     = 0.014 
  res@tiMainFontHeightF        = 0.022
  res@txFontHeightF            = 0.017

  res@lbLabelBarOn             = False        ; turn off label bar
  ;res@mpDataBaseVersion   = "MediumRes" 

  ;res@tiMainString        = "Mean"\
  plot(0) = gsn_csm_hov(wks, hov, res) 
  ;do p = 0, 7
  ;   res@tiMainString        = "Phase "+(p+1)
  ;   plot(p) = gsn_csm_contour_map_ce(wks, comp(p,:,:), res)  ; create the plot
  ;end do
  
;************************************************
; create panel
;************************************************
  pres                  = True
  pres@gsnPanelLabelBar = True                   ; common label bar
  pres@lbLabelStride        = 1
  gsn_panel(wks,plot,(/1,1/),pres)
end
