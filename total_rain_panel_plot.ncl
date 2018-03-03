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
b=addfile("wrfout_d04_2014-07-13_17_00_00","r")
lat1d=b->XLAT(0,:,0)
lon1d=b->XLONG(0,0,:)

;---Opening worksation and graphics for plotting
wks  = gsn_open_wks("pdf","rain_panel") 
gsn_define_colormap(wks,"precip3_16lev")

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
res_cn@cnInfoLabelOn          = False
res_cn@cnLevelSelectionMode = "ManualLevels"
res_cn@cnLevelSpacingF	=	5
res_cn@cnMinLevelValF	=	0
res_cn@cnMaxLevelValF	=	150
res_cn@lbLabelBarOn         = False
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

FILES=(/ "wrfout_d04_2014-07-13_18_00_00", "wrfout_d04_2014-07-16_18_00_00", "wrfout_d04_2014-07-13_18_00_00", "wrfout_d04_2014-07-16_18_00_00" /)

numFILES = dimsizes(FILES)
plots = new(4,graphic)
do it=0,numFILES-1
    
	rain_1=wrf_rain(FILES(it))
	
	rain=rain_1(0,:,:)

;---Assiginig lat/long for variables to be plotted. 
	rain!0="lat"
	rain!1="lon"
	rain&lat=lat1d
	rain&lon=lon1d

;---Masking data
rain_mask=shapefile_mask_data(rain,shp,True)

;---PLotting countour and vector maps using overlay
contour_mask  = gsn_csm_contour_map(wks,rain_mask,res_cn)

plt=it
plots(plt)=contour_mask
delete (rain)
delete (contour_mask)
end do

;---Panel the plots
  pres                        = True 
  pres@gsnMaximize            = True
  pres@gsnPanelFigureStrings  = "("+(/"a","b","c","d"/) + ")"
  pres@txString               = "Total Rainfall"
  pres@gsnPanelLabelBar    = True                ; add common colorbar
  pres@gsnPanelBottom  = 0.07	; shrink panel plot so that there is extra room for the left y-axis label
     pres@gsnPanelXWhiteSpacePercent = 2	; set a bit of extra white space between panels in the x and y directions
     pres@gsnPanelYWhiteSpacePercent = 4
     pres@lbTitlePosition = "Bottom"	; put it below the plot
     pres@lbTitleString = "Total Rainfall (mm)" ; give the labelbar a title
     pres@lbTitleFontHeightF = 0.018	; tweak the size of the labelbar title
     pres@lbTitleOffsetF = 0.2		; positive values are up when the labelbar is under the plot
     pres@pmLabelBarOrthogonalPosF = -0.03	; move the labelbar down a bit so we have room for the overall x-axis
     pres@lbFontHeightF = 0.02
     pres@gsnPanelDebug = True
     pres@lbLabelFontHeightF=0.02
     pres@vpWidthF	=0.7
     pres@gsnPanelFigureStringsFontHeightF=0.01
  polygon_mask = gsn_add_shapefile_polylines(wks,plots,shp,lnres) ;Adding polygon of shapefile.
  gsn_panel(wks,plots,(/2,2/),pres) ;2 rows and 2 column panel plot

end
