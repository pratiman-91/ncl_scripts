load "shapefile_utils.ncl"

function wrf_rain(file_path_1[*]:string)
  local rain,rainnc,rainc,a_1

  begin

  	a_1=addfiles(file_path_1,"r")
    print("Processing: "+file_path_1)

    rainc=wrf_user_getvar(a_1,"RAINC",-1)
    rainnc=wrf_user_getvar(a_1,"RAINNC",-1)

    rain=rainc+rainnc

    return(rain)

  end


begin

;---Adding file for lat and long 
b=addfile("wrfout_d03_2012-06-29_03_00_00","r")
lat1d=b->XLAT(0,:,0)
lon1d=b->XLONG(0,0,:)

;---Opening worksation and graphics for plotting
wks  = gsn_open_wks("pdf","rain") 
gsn_define_colormap(wks,"precip2_17lev")

;---Defining common resources
res                     = True
res@gsnLeftString   = ""
res@gsnRightString  = ""
res@gsnCenterString = ""
res@gsnMaximize         = True
res@gsnDraw             = False
res@gsnFrame            = False
res@gsnAddCyclic        = False
res@mpFillOn            = False
res@mpOutlineOn         = False
res@mpMinLatF           = 
res@mpMaxLatF           = 
res@mpMinLonF           = 
res@mpMaxLonF           = 

;---Defining resources for contour map
res_cn						  = True
res_cn						  = res
res_cn@cnRasterModeOn		  = True
res_cn@cnFillOn               = True
res_cn@cnLinesOn              = False
res_cn@cnFillDrawOrder        = "PreDraw"
res_cn@cnInfoLabelOn          = True
res_cn@lbLabelBarOn         = True
res_cn@cnFillDrawOrder      = "PreDraw"
res_cn@cnLineLabelsOn       = False

;---Defining resources for line plotting
lnres                  = True
lnres@gsFillIndex		= -1
lnres@gsEdgesOn			= True
lnres@tfPolyDrawOrder	= "PostDraw"
;---Opening buffer shapefile for masking and plotting.  
shp="shapefile.shp"

;---Adding files and Processing Variables

FILES=(/ "wrfout_d03_2012-06-26_18_00_00"/)

numFILES = dimsizes(FILES)
plots = new(1,graphic)
	rain=wrf_rain(FILES(0))

;---Assiginig lat/long for variables to be plotted. 
	rain!0="lat"
	rain!1="lon"
	rain&lat=lat1d
	rain&lon=lon1d

;---Masking data
rain_mask=shapefile_mask_data(rain,shp,True)

;---PLotting countour and vector maps using overlay
contour_mask  = gsn_csm_contour_map(wks,rain_mask,res_cn)
polygon_mask = gsn_add_shapefile_polylines(wks,contour_mask,shp,lnres)

end
