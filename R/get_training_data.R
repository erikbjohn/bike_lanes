get_training_data <- function(){
  
  # Load Original list
  training_data_location <- '~/Dropbox/pkg.data/bike_lanes/data/raw/training_data/'
  training_places <- readxl::read_xlsx('~/Dropbox/pkg.data/bike_lanes/data/raw/MidPntRdWdt.xlsx')
  training_places <- data.table::as.data.table(training_places)
  training_places <- training_places[, location_id:=stringr::str_to_lower(Name)]
  training_places <- training_places[, location_id:=stringr::str_replace_all(location_id, ' ', '-')]
  # Check for uniqueness
  # table(training_places$location_id)[table(training_places$location_id)>1]
  
  load('~/Dropbox/pkg.data/api.keys/raw/l.pkg.rdata')
  api.key <- l.pkg$google
  zoom_level <- 21
  bearings <- c(0, 90, 180, 270)
  
  for(i_loc in 1:nrow(training_places)){
    training_place <- training_places[i_loc]
    location_id <- training_place$location_id
    point_lat <- training_place$Latitude
    point_lon <- training_place$longitude
    fDest_sat <- paste0( training_data_location, 'locationid_', location_id, '_sat_zoom_', zoom_level, '.png')
    if(!file.exists(fDest_sat)){
      gloc <- paste0('https://maps.googleapis.com/maps/api/staticmap?zoom=',
                     zoom_level, 
                     '&center=', point_lat, ',', point_lon, 
                     '&size=640x640&maptype=satellite',
                     '&key=', api.key)
      download.file(gloc, destfile=fDest_sat)
    }
    for(bearing in bearings){
     
      location_id <- str_replace_all(location_id, "[[:punct:]]", "")
      fDest_street <- paste0( training_data_location, 'locationid_', location_id, '_bearing_', bearing, '.jpg')
      if(!file.exists(fDest_street)){
        shotLoc <- paste0('https://maps.googleapis.com/maps/api/streetview?size=1200x600&location=',
                          point_lat, ',', point_lon,
                          '&heading=', bearing,
                          '&pitch=-40&fov=', 80,'&key=', api.key)
        download.file(shotLoc, destfile=fDest_street)
      }
    }

  }
  
  # Create df for python (from all training data)
  
  # List all files in the training data folder
  
  f_list <- list.files(training_data_location)
  dt_flist <- data.table::data.table(fname = f_list,
                                     fpath = paste0(training_data_location, f_list))
  dt_flist <- dt_flist[, location_id:=stringr::str_extract(fname, '(?<=locationid\\_).+(?=\\_sat\\_zoom)')]
  dt_flist <- dt_flist[is.na(location_id), location_id:=stringr::str_extract(fname, '(?<=lcoationid\\_).+(?=\\_sat\\_zoom)')]
  dt_flist <- dt_flist[is.na(location_id), location_id:=stringr::str_extract(fname, '(?<=locationid\\_).+(?=\\_bearing)')]
  dt_flist <- dt_flist[, location_id:=stringr::str_replace_all(location_id, "[[:punct:]]", "")]
  dt_flist <- dt_flist[, location_id_count:=.N, by=.(location_id)]
  dt_flist <- dt_flist[location_id_count == 8]
  dt_flist <- dt_flist[, image_type:=stringr::str_extract(fname, 'sat_zoom_21-rotate_180')]
  dt_flist <- dt_flist[is.na(image_type), image_type:=stringr::str_extract(fname, 'sat_zoom_21-rotate_90')]
  dt_flist <- dt_flist[is.na(image_type), image_type:=stringr::str_extract(fname, 'sat_zoom_21-rotate_270')]
  dt_flist <- dt_flist[is.na(image_type), image_type:=stringr::str_extract(fname, 'sat_zoom_21')]
  dt_flist <- dt_flist[is.na(image_type), image_type:=stringr::str_extract(fname, 'bearing_0')]
  dt_flist <- dt_flist[is.na(image_type), image_type:=stringr::str_extract(fname, 'bearing_90')]
  dt_flist <- dt_flist[is.na(image_type), image_type:=stringr::str_extract(fname, 'bearing_180')]
  dt_flist <- dt_flist[is.na(image_type), image_type:=stringr::str_extract(fname, 'bearing_270')]
  dt_flist_cast <- data.table::dcast(dt_flist, location_id ~ image_type, value.var=c('fpath'))
  
  setnames(training_places, 'RoadWidth(ft)', 'width')
  training_places <- training_places[, .(location_id, width)]
  training_places_ej <- readRDS('~/Dropbox/pkg.data/bike_lanes/data/raw/training_places_ej.rds')
  training_places_ej <- training_places_ej[, .(location_id, width)]
  training_places_ej <- training_places_ej[, location_id:=stringr::str_replace(location_id, '\\_ej\\_', '')]
  training_places <- rbindlist(list(training_places, training_places_ej), use.names = TRUE)
  training_places <- training_places[, location_id:=stringr::str_replace_all(location_id, "[[:punct:]]", "")]
  setkey(training_places, location_id)
  setkey(dt_flist_cast, location_id)
  dt_training <- training_places[dt_flist_cast]
  dt_training <- dt_training[!is.na(width)]
  fwrite(dt_training, '~/Dropbox/pkg.data/bike_lanes/data/clean/df_training.csv')
}
