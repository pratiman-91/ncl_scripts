function wrf_rain(file_path_1[*]:string)
  local rain,rainnc,rainc,a_1

  begin

  	a_1=addfile(file_path_1,"r")
    print("Processing: "+file_path_1)

    rainc=wrf_user_getvar(a_1,"RAINC",-1)
    rainnc=wrf_user_getvar(a_1,"RAINNC",-1)

    rain=rainc+rainnc

    return(rain)

  end


begin

;---Adding files and Processing Variables
txt_file = ("Rain.csv")

files = (/"wrfout_d04_2014-07-13_18:00:00"/)

in  = addfiles(files ,"r")
numFILES = dimsizes(files)

; What times and how many time steps are in the data set?
times = wrf_user_getvar(in,"times",-1)  ; get all times in the file
ntimes = dimsizes(times)         ; number of times in the file

;---Defining common resources
res = True
res@returnInt = True

;---Read in file as array of strings so we can parse each line
  lines = asciiread("lat_lo.csv",-1,"string")
  delim = ","
  
a=NewList("lifo")

  lat   = tofloat(str_get_field(lines,2,delim)) ;Second column of CSV should be lat
  lon   = tofloat(str_get_field(lines,3,delim)) ;Third column of CSV should be lon
  rain1 = new(dimsizes(lat)-1,float)

do it1=0,ntimes-1

	rain=wrf_rain(files(it1))


;---Read fields lat and long

  print("Processing Points")
  do it=1,dimsizes(lat)-1
    point = wrf_user_ll_to_ij(in,lon(it),lat(it),res)
    x = point(1)
    y = point(0)
    
    rain1(it-1)=rain(0,x,y)
  end do
    print("Writing File")
    write_table(txt_file, "w", [/"Lat","Lon","Rain"/], "%s,%s,%s")
    write_table(txt_file, "a",[/lat(1:), lon(1:), rain1/],"%f,%f,%f")
    txt_file = ("Rain_"+((it1)+1)+".csv")
end do

end
