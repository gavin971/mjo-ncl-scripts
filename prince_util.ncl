;
;      $Id: prince_util.ncl,v 7.25 2006/07/25 22:07:38 haley Exp $
;
; ******************** NOTE *******************************
; These are my personal functions/procedures. They do things
; the way I want them. If u want to modify one to suit
; your tastes then I suggest u copy this file or an 
; individual routine, rename it and then modify it as u wish.
; 
; I will try to help people out but these routines are NOT
; meant to be general purpose.
; ********************************************************
; ********************************************************
; Function/Procedures included here can call built-in functions
; and functions contained within the gsn*.ncl and contributed.ncl
; libraries. 
; ------------------------------------------------------------

function read_ctl(ctlname)
begin

	 s = (/"'dims "+ ctlname + "'","quit"/)
  	asciiwrite ("dummy.gs" , s)
	
	info = systemfunc("grads -lbc dummy.gs" )
	;print(info)
	
	col1 = systemfunc("cut -f1 -d ' ' info.out")	
	binname = col1(0)
 	   slon = stringtofloat(col1(1))
	   slat = stringtofloat(col1(2))
	   slev = stringtofloat(col1(3))
	   stim = stringtofloat(col1(4))
	   var  = col1(5)

	col2 = systemfunc("cut -f2 -d ' ' info.out")	; Binary grads file name
	   elon = stringtofloat(col2(1))
	   elat = stringtofloat(col2(2))
	   elev = stringtofloat(col2(3))
	   etim = stringtofloat(col2(4))

	col3 = systemfunc("cut -f3 -d ' ' info.out")	; Binary grads file name
	   nlon = stringtoint(col3(1))
	   nlat = stringtoint(col3(2))
	   nlev = stringtoint(col3(3))
	   ntim = stringtoint(col3(4))

	udef = systemfunc("cut -f2 -d ' ' " + ctlname)

	fillval = stringtofloat(udef(1))
	
	; Defining coordinates
	  lon  = fspan(slon,elon,nlon)
      	  lon@units = "degrees_east"

	  lat  = fspan(slat,elat,nlat)
      	  lat@units = "degrees_north"

	  lev  = fspan(slev,elev,nlev)

	  time  = fspan(stim,ntim,ntim)

	; Read Binary data 
	  data = fbindirread(binname,0,(/ntim,nlev,nlat,nlon/),"float")

	  data!0   = "time"
	  data!1   = "lev"
	  data!2   = "lat"
	  data!3   = "lon"

	  data&time =  time
	  data&lev =  lev
	  data&lat =  lat
	  data&lon =  lon
	  data@_FillValue = fillval
	
	
return(data)
end

; ================================================
; A set of routines for easy reading of nc data
; written on 23/11/2007
; ================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procedure contour(var)
 begin
dims = dimsizes(var)
 if(dimsizes(dims).eq.2) then
   	wks = gsn_open_wks("X11","")            ; open an ps plot
	gsn_define_colormap(wks,"gui_default")

	plot = gsn_csm_contour(wks,var,False)
else
	print("VARIABLE IS NOT 2D! IT HAS "+dimsizes(dims)+" DIMENSIONS")
	print("CONTOURING FAILED!")
 end if             
 end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procedure shade(var)
 begin
dims = dimsizes(var)
 if(dimsizes(dims).eq.2) then

   	wks = gsn_open_wks("X11","")            ; open an ps plot
	gsn_define_colormap(wks,"gui_default")

	res = True
	res@cnFillOn = True
        res@cnFillOn = True
	res@gsnSpreadColors = True
	plot = gsn_csm_contour(wks,var,res) 
else
	print("VARIABLE IS NOT 2D! IT HAS "+dimsizes(dims)+" DIMENSIONS")
	print("CONTOURING FAILED!")
 end if            
 end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procedure fill(var)
 begin
dims = dimsizes(var)
 if(dimsizes(dims).eq.2) then

   	wks = gsn_open_wks("X11","")            ; open an ps plot
	gsn_define_colormap(wks,"gui_default")

	res = True
	res@cnLinesOn           = False         ; Turn lines off
	res@cnFillOn = True
	res@cnFillMode          = "CellFill"
	plot = gsn_csm_contour(wks,var,res) 
else
	print("VARIABLE IS NOT 2D! IT HAS "+dimsizes(dims)+" DIMENSIONS")
	print("CONTOURING FAILED!")
 end if            
 end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procedure map(var)
 begin
dims = dimsizes(var)
 if(dimsizes(dims).eq.2) then
	var!0 = "latitude"
	var!1 = "longitude"
	var&latitude@units = "degrees_north"
	var&longitude@units = "degrees_east"
	loni = min(var&longitude)
	lonf = max(var&longitude)
	lati = min(var&latitude)
	latf = max(var&latitude)

   	wks = gsn_open_wks("X11","")            ; open an ps plot
	gsn_define_colormap(wks,"gui_default")

	res = True
	res@cnFillOn = True
	res@gsnAddCyclic = False
	res@gsnSpreadColors = True
	res@mpMinLonF            = loni               ; select a subregion
        res@mpMaxLonF            = lonf
        res@mpCenterLonF         = loni+(lonf-loni)/2.
        res@mpMinLatF            = lati 
        res@mpMaxLatF            = latf

	plot = gsn_csm_contour_map_ce(wks,var,res)             
 else
	print("VARIABLE IS NOT 2D! IT HAS "+dimsizes(dims)+" DIMENSIONS")
	print("CONTOURING FAILED!")
 end if
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procedure mapfill(var)
 begin
dims = dimsizes(var)
 if(dimsizes(dims).eq.2) then

	var!0 = "latitude"
	var!1 = "longitude"
	var&latitude@units = "degrees_north"
	var&longitude@units = "degrees_east"
	loni = min(var&longitude)
	lonf = max(var&longitude)
	lati = min(var&latitude)
	latf = max(var&latitude)

   	wks = gsn_open_wks("X11","")            ; open an ps plot
	gsn_define_colormap(wks,"gui_default")

	res = True
	res@cnFillOn = True
	res@gsnAddCyclic = False
	res@gsnSpreadColors = True
	res@mpMinLonF            = loni               ; select a subregion
        res@mpMaxLonF            = lonf
        res@mpCenterLonF         = loni+(lonf-loni)/2.
        res@mpMinLatF            = lati 
        res@mpMaxLatF            = latf
	res@cnFillMode          = "CellFill"

	plot = gsn_csm_contour_map_ce(wks,var,res)             
 else
	print("VARIABLE IS NOT 2D! IT HAS "+dimsizes(dims)+" DIMENSIONS")
	print("CONTOURING FAILED!")
 end if
 end

procedure xy(origvar)
local var
 begin
var = origvar
dims = dimsizes(var)
print(dims)
 if(dimsizes(dims).eq.2) then
	dimx = dims(0)
	dimy = dims(1)
	if(dimx.lt.dimy)then
	  dimx = dims(1)
	  dimy = dims(0)
	end if
 else
	if(dimsizes(dims).eq.1) then
	dimx = dims(0)
	end if
 end if
;print(dimx+" "+dimy)
        wks = gsn_open_wks("X11","")            ; open an ps plot
        gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")

        res = True
	res@xyLineThickness = 1.0               ; make 2nd lines thicker
 	res@xyLineColors    = ispan(2,200,10)          ; change line color
	res@vpHeightF= 0.5                   ; change aspect ratio of plot
 	res@vpWidthF = 0.75      

 	plot  = gsn_csm_xy (wks,ispan(0,dimx,1),var,res) ; create plot

	delete(var)
 end

procedure plot_xy(x, y)
 begin
;print(dimx+" "+dimy)
        wks = gsn_open_wks("X11","")            ; open an ps plot
        gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")

    res = True
 	res@xyLineColors    = ispan(2,200,10)          ; change line color
	res@vpHeightF= 0.5                   ; change aspect ratio of plot
 	res@vpWidthF = 0.75      

 	plot  = gsn_csm_xy (wks,x,y,res) ; create plot

 end


function make_365_day_calendar(sday,smonth,syear,ntime)
; 	A function specially for the IPSL model
; 	this has 360 days in each year
	begin
	  ijour = sday
	  imois = smonth
	  annee = syear
	  jpms   = (/31,28,31,30,31,30,31,31,30,31,30,31/)
	  
	  date   = new((/ntime/),integer)

		do n = 0, ntime-1
			if ( mod(annee,4).eq.0 ) then
				jpms(1) = 29
			end if
	  	 jpm = jpms(imois-1)

		 date(n)  = annee*10000+imois*100+ijour

		 ijour=ijour+1
      		 if(ijour.gt.jpm)then
       		  ijour=1
       		  imois=imois+1
      		 end if

		 if(imois.gt.12)then
       		  imois=1
       		  annee=annee+1
      		 end if

	      	 ;if(mod(ANNEE,4).eq.0)then
         	 ; jpm(2)=29
        	 ;else
         	 ; jpm(2)=28
        	 ;end if
		end do
	return(date)
	end	


function make_360_day_calendar(sday,smonth,syear,ntime)
; 	A function specially for the IPSL model
; 	this has 360 days in each year
	begin
	  ijour = sday
	  imois = smonth
	  annee = syear
	  jpm   = 30
	date   = new((/ntime/),integer)

		do n = 0, ntime-1
	  	date(n)  = annee*10000+imois*100+ijour

		 ijour=ijour+1
      		 if(ijour.gt.jpm)then
       		  ijour=1
       		  imois=imois+1
      		 end if

		 if(imois.gt.12)then
       		  imois=1
       		  annee=annee+1
      		 end if

	      	 ;if(mod(ANNEE,4).eq.0)then
         	 ; jpm(2)=29
        	 ;else
         	 ; jpm(2)=28
        	 ;end if
		end do
	return(date)
	end	

function regrid(grid, togrid, lnflip1, lnflip2)

begin

	if (lnflip1) then
		grid = lonFlip(grid)
	end if	
	if (lnflip2) then
		togrid = lonFlip(togrid)
	end if	
		
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Treating the togrid
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	dimNames = getvardims(togrid)
	ndims = dimsizes(dimNames)
	
	latName = dimNames(ndims-2)
	lonName = dimNames(ndims-1)
	
	lats_togrid = togrid&$latName$
	lons_togrid = togrid&$lonName$
	delete(dimNames)
	delete(latName)
	delete(lonName)

	lati = min(lats_togrid)
	latf = max(lats_togrid)
	loni = min(lons_togrid)
	lonf = max(lons_togrid)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Treating the grid
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	dimNames = getvardims(grid)
	ndims = dimsizes(dimNames)
;print(ndims)	
	if (ndims.eq.2) then
		grid_temp = grid({lati:latf},{loni:lonf})
	end if
	if (ndims.eq.3) then
		grid_temp = grid(:,{lati:latf},{loni:lonf})
	end if
	if (ndims.eq.4) then
		grid_temp = grid(:,:,{lati:latf},{loni:lonf})
	end if
	if (ndims.eq.5) then
		grid_temp = grid(:,:,:,{lati:latf},{loni:lonf})
	end if
	
	;printVarSummary(grid_temp)
	;printVarSummary(togrid)
	latName = dimNames(ndims-2)
	lonName = dimNames(ndims-1)
	
	lats_grid = grid_temp&$latName$
	lons_grid = grid_temp&$lonName$
	;print(lats_grid)	
	;print(lats_togrid)	
	;print(lons_grid)	
	;print(lons_togrid)	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	newvar = linint2(lons_grid,lats_grid,grid_temp,True,lons_togrid,lats_togrid,0)
	
	copy_VarAtts(grid_temp,newvar)
	
	do i = 0, ndims-1
		newvar!i = dimNames(i)
	end do	
	
	do i = 0, ndims-3
		newvar&$dimNames(i)$ = grid_temp&$dimNames(i)$
	end do	
	newvar&$latName$ = lats_togrid
	newvar&$lonName$ = lons_togrid
;printVarSummary(grid_temp)
;printVarSummary(newvar)

	;delete(grid_temp)
	;delete(grid)
	;delete(togrid)
return(newvar)
end

procedure q(var)
begin
printVarSummary(var)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pp read functions
;---------------------------------------------------------
    ; Table for Field Codes:
    ;
    ; The small set of field codes. For detailed info see,
    ; http://badc.nerc.ac.uk/data/link/model_runs.html
    ; http://badc.nerc.ac.uk/help/formats/pp-format/files/stash_field.txt 
    ;---------------------------------------------------------

	
    ;---------------------------------------------------------
	; Read binary file in Hadley PP format
	;
	; For detailed info, see Appendix E in the following document
  	; http://precis.metoffice.com/docs/tech_man.pdf
  	;---------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function read_pp_head1(fin, nrec)
; reads the integer part of the headers
begin
	;print("-----------------------------------------------------------")
	;print("Reading pp file : "+ fin)	
	;print("-----------------------------------------------------------")
	
  	k = 0
	flag = True
	nrecd2 = nrec/2
	head1 = new( (/64,nrecd2/), "integer")
	kb2 = 0
  	do while (flag) 
    ;--- read header part (for integer ignore 46-64) ---
    head1(:,kb2) = fbinrecread(fin, k, 64, "integer")
	;print((k+1)+"/"+nrec)
    ;print(head(41,k)+" "+head(32,k))
	; rec1 = head
	;lbyr   = rec1(0)  ; time of field (year)
    ;lbmon  = rec1(1)  ; time of field (month)
    ;lbdat  = rec1(2)  ; time of field (day)
    ;lbhr   = rec1(3)  ; time of field (hour)
    ;lbmin  = rec1(4)  ; time of field (minute)
    ;lbyrd  = rec1(6)  ; data time or epoc (year)
    ;lbmond = rec1(7)  ; data time or epoc (month)
    ;lbdatd = rec1(8)  ; data time or epoc (day)
    ;lbhrd  = rec1(9)  ; data time or epoc (hour)
    ;lbmind = rec1(10) ; data time or epoc (minute)
    ;lblrec = rec1(14) ; length of data record in words
    ;lbrow  = rec1(17) ; number of rows in field (latitude)
    ;lbnpt  = rec1(18) ; number of grid points in each row (longitude)
    ;lbfc   = rec1(22) ; field code
    ;lbproc = rec1(24) ; Process code, 128 for daily data
    ;lbvc   = rec1(25) ; vertical coordinate type
	;stash  = rec1(41)
	;lblev  = rec1(32)
	k = k + 2
	kb2 = kb2 + 1
	;--- check end of file ---
   	if (k .eq. nrec) then
   		flag = False
   	end if 

	end do
    return(head1)
end

function read_pp_head2(fin, nrec)
; reads the integer part of the headers
begin
	
  	k = 0
	flag = True
	nrecd2 = nrec/2
	head2 = new( (/64,nrecd2/), "float")
	kb2 = 0
  	do while (flag) 
    ;--- read header part (for integer ignore 46-64) ---
    head2(:,kb2) = fbinrecread(fin, k, 64, "float")
	;print((k+1)+"/"+nrec)
    ;brsvd1 = rec2(45) ; higher boundary of layer (b value, lbvc == 9) 
    ;brsvd2 = rec2(46) ; higher boundary of layer (a value, lbvc == 9)
    ;bdatum = rec2(49) ; constant value subtracted from each value in field
    ;blev   = rec2(51) ; b-value of level 
    ;brlev  = rec2(52) ; lower boundary of layer (b value, lbvc == 9)
    ;bhlev  = rec2(53) ; a-value of level
    ;bhrlev = rec2(54) ; lower boundary of layer (a value, lbvc == 9) 
    ;bzy    = rec2(58) ; latitude of "zeroth" row in degrees
    ;bdy    = rec2(59) ; latitude interval between rows in degrees
    ;bzx    = rec2(60) ; longitude of ???zeroth??? point in row in degrees
    ;bdx    = rec2(61) ; longitude spacing of points in each row in degrees
    ;bmdi   = rec2(62) ; value used in the field to indicate missing data points
    ;bmks   = rec2(63) ; scaling factor
	;--- check end of file ---

	k = k + 2
	kb2 = kb2 + 1
	;--- check end of file ---
   	if (k .eq. nrec) then
   		flag = False
   	end if 

	end do
    return(head2)
end
function unique(x)
begin
     qsort(x)
	 nx = dimsizes(x)
     nux = num((x(1:)-x(0:nx-2)).ne.0) + 1
     print("Number of unique values = " + nux)
return(nux)
end
function read_pp(fin, res) 
begin

    setfileoption("bin","ReadByteOrder","BigEndian")
	;--- get number of records in binary file ---
  	nrec = fbinnumrec(fin)
  	;nrec = 340; fbinnumrec(fin)
	;;;;;;;;;;;;;;;;;;;;;;;;
	print("-----------------------------------------------------------")
	print("Reading pp file : "+ fin)	
	print("-----------------------------------------------------------")
	; read the integer headers
	head1 = read_pp_head1(fin, nrec)
	; read the float headers
    head2 = read_pp_head2(fin, nrec)
    print("Finished reading headers.")
    
	; Headers all read. Now sieve for stash
	if (isatt(res,"stash")) then
		sInd = ind(head1(41,:).eq.res@stash)

		; Manipulating levels
		bLevs = head2(51,sInd)
		nlevs = unique(bLevs)
		if (nlevs.gt.1) then
			levelData = True
			print("Multi-level data.")
			print(nlevs)
		else
			levelData = False
			print("Single level data.")
		end if	
		ntime = dimsizes(sInd)/nlevs

    end if ; (isatt(res,"stash"))

	if (all(ismissing(sInd))) then
        print("No fields matching the selection found...")
	else
	    print("oh, now read data")
		; read a first record to get the data dimensions
		;print(head1(:,0))
		;print(head2(:,0))

        lats = head2(58,0) + ispan(1,head1(17,0),1)*head2(59,0)
		lats@units = "degrees_north"
		lons = head2(60,0) + ispan(1,head1(18,0),1)*head2(61,0)
		lons@units = "degrees_east"

        ; create data dimensions
		if (levelData) then
            data = new( (/ntime, nlevs, head1(17,0), head1(18,0)/), "float")
		else	
            data = new( (/ntime, head1(17,0), head1(18,0)/), "float")
		end if	
		dum = fbinrecread(fin, 19, (/ head1(17,0), head1(18,0)/), "float")
		dum@_FillValue = head2(62,0)
		printVarSummary(dum)
		fill(dum)

        exit
		time_str = sprinti("%d",head1(0,:))+sprinti("%2.2d",head1(1,:))\
		          +sprinti("%2.2d",head1(2,:))+sprinti("%2.2d",head1(3,:))\
				  +sprinti("%2.2d",head1(4,:))
		;print(time_str)

	end if	

exit

	if ( (stash.eq.stashRead).and.(lbproc.eq.procCode) ) then 
			if (first) then 
				;dum = new( (/1, lbrow,lbnpt/), "float")
				;--- date string ---
	        	str_epoc = "days since "+sprinti("%d", lbyr)+"-"+sprinti("%2.2d", lbmon)+\
               	"-"+sprinti("%2.2d", lbdat)+" "+sprinti("%2.2d", lbhr)+\
               	":"+sprinti("%2.2d", lbmin)+":00"
				first = False
					;print(str_epoc)
				;--- read header part (for float ignore 1-45) ---
	            head2 = new( (/64,nrecd2/), "float")
               
				inds = (/k/)
				levels = (/lblev/)
			end if

				dd = array_append_record (inds, (/k/), 0)
				delete(inds)
				inds = dd
				delete(dd)
				
				dd = array_append_record (levels, (/lblev/), 0)
				delete(levels)
				levels = dd
				delete(dd)
				;print(levels)
				
			end if	
			


			print(dimsizes(inds))
			;do in = 0, dimsizes(inds)-1
			;	
			;end do	
		

			;print(lbrow+" "+bzy+" "+bdy)
			lats = bzy + ispan(1,lbrow,1)*bdy
			lats@units = "degrees_north"
			lons = bzx + ispan(1,lbnpt,1)*bdx
			lons@units = "degrees_east"
			
			 ;--- bug fix, see http://www.ncl.ucar.edu/known_bugs.shtml ---
    		dum_time = 17522904
    		dum_time@units = "hours since 1-1-1 00:00:0.0"
    		dum_date = ut_calendar(dum_time, 0)

    		;--- calculate date ---
    		option = 0
    		option@calendar = "360_day"
    		str_time = ut_inv_calendar(lbyr, lbmon, lbdat, lbhr, lbmin, 0, str_epoc, option)
			;--- set date index ---

    		if (str_time .ne. str_time_pre) then
		      itime = itime+1
		      str_time_pre = str_time
		      ;print("Date: "+sprinti("%d", lbyr)+"-"+sprinti("%2.2d", lbmon)+\
        	  ;	    "-"+sprinti("%2.2d", lbdat)+"_"+sprinti("%2.2d", lbhr)+\
		      ;      ":"+sprinti("%2.2d", lbmin)+" "+sprintf("%8.2f", str_time))
		    end if


			;--- read data ---
			;rec3 = new( (/1, lbrow,lbnpt/), "float")
			
			;printVarSummary(rec3)
			;printVarSummary(dum)
			
			;dum1  = array_append_record (dum, rec3, 0)
			;delete(dum)

			;dum = dum1

			;delete(dum1)
	
;			dum1 = dum(1::,:,:);
			delete(dum)

			ntime = dimsizes(dum1(:,0,0))

	 		dum1!0 = "time"
	 		dum1!1 = "lat"
	 		dum1!2 = "lon"

			dum1&time = ispan(0,ntime-1,1)
			dum1&time@units = str_epoc
			dum1&lat = lats
			dum1&lon = lons

			
			; Data regridding to 2.5 degres
			newlat = fspan(-90.,90,73)
  			newlon = fspan(0.,357.5,144)
  			newlat@units = "degrees_north"
  			newlon@units = "degrees_east"

  			var = linint2(lons,lats,dum1,True,newlon,newlat,0)

  			var!0   = "time"
  			var!1   = "lat"
  			var!2   = "lon"
  			var&time = dum1&time
  			var&lat  = newlat
  			var&lon  = newlon
			printVarSummary(var)
			
			if (writeData) then
				system("/bin/rm -f "+outFile)   ; remove any pre-existing file
       			ncdf     = addfile(outFile ,"c")  ; open output netCDF file
				
				; make time and UNLIMITED dimension      ; recommended  for most applications
				filedimdef(ncdf,"time",-1,True) 
				; output variables directly
				ncdf->data  = var                       
				ncdf->time  = (/var&time/)
			end if

			return(var)

end


function day_of_year_360(year, month, day)
begin
     ddd = (month-1)*30 + day
    return(ddd)

end
procedure write_nc(outfile,var,varname)
begin
      system("/bin/rm -f "+outfile)   ; remove any pre-existing file
      ncdf     = addfile(outfile ,"c")  ; open output netCDF file
      ; make time and UNLIMITED dimension      ; recommended  for most applications
      filedimdef(ncdf,"time",-1,True) 
      ; output variables directly
      ncdf->$varname$  = var                          ; 4D               
end	 

function open(filename)
begin
    f=addfile(filename,"r")
    varnames = getfilevarnames(f)
    print("============================================================")
    print("File "+filename+" contains :")
	
    nvars = dimsizes(varnames)
    do nv = 0, nvars-1
        dimsiz = getfilevardimsizes(f,varnames(nv))
        dNames = getfilevardims(f,varnames(nv)) 
	ndims  = dimsizes(dimsiz)
        dimens = "" 
        do dm = 0, ndims-1
           if (dm.eq.0) then
	      dimens = dimens+" "+ dNames(dm)+"|"+ dimsiz(dm)
           else
   	      dimens = dimens+" x "+ dNames(dm)+"|"+ dimsiz(dm)
           end if
	end do
        print(varnames(nv)+" ("+dimens+" )")  
        delete(ndims)
        delete(dNames)
        delete(dimsiz)
    end do
        print("============================================================")
return(f)
end
function read(f,varname)
begin
    var = f->$varname$
    return(var)
end

procedure help(var)
begin
    printVarSummary(var)
end

function yyyymmdd_split(yyyymmdd)
begin
    datex = new(3, integer)
    datex(0) = yyyymmdd/10000
    mmdd    = yyyymmdd - datex(0)*10000
    datex(1) = mmdd/100
    dd      = mmdd - datex(1)*100
    datex(2) = dd

return(datex)
end
