get_training_data <- function(){
  training_data_location <- '~/Dropbox/pkg.data/bike_lanes/data/raw/training_data/'
  training_places <- readxl::read_xlsx('~/Dropbox/pkg.data/bike_lanes/data/raw/MidPntRdWdt.xlsx')
  training_places <- data.table::as.data.table(training_places)
  training_places <- training_places[, location_id:=stringr::str_to_lower(Name)]
  training_places <- training_places[, location_id:=stringr::str_replace_all(location_id, ' ', '-')]
  # Check for uniqueness
  table(training_places$location_id)[table(training_places$location_id)>1]
  
  load('~/Dropbox/pkg.data/api.keys/raw/l.pkg.rdata')
  api.key <- l.pkg$google
  zoom_level <- 21
  
  for(i_loc in 1:nrow(training_places)){
    training_place <- training_places[i_loc]
    location_id <- training_place$location_id
    point_lat <- training_place$Latitude
    point_lon <- training_place$longitude
    gloc <- paste0('https://maps.googleapis.com/maps/api/staticmap?zoom=',
                   zoom_level, 
                   '&center=', point_lat, ',', point_lon, 
                   '&size=640x640&maptype=satellite',
                   '&key=', api.key)
    fDest_sat <- paste0( training_data_location, 'locationid_', location_id, '_sat_zoom_', zoom_level, '.png')
    download.file(gloc, destfile=fDest_sat)

  }
  
  # Create df for python
  f_list <- list.files(training_data_location)
  dt_flist <- data.table::data.table(fname = f_list,
                                     fpath = paste0(training_data_location, f_list))
  dt_flist <- dt_flist[, location_id:=stringr::str_extract(fname, '(?<=locationid\\_).+(?=\\_sat\\_zoom)')]
  setnames(training_places, 'RoadWidth(ft)', 'width')
  training_places <- training_places[, .(location_id, width)]
  training_places_ej <- readRDS('~/Dropbox/pkg.data/bike_lanes/data/raw/training_places_ej.rds')
  training_places_ej <- training_places_ej[, .(location_id, width)]
  training_places_ej <- training_places_ej[, location_id:=stringr::str_replace(location_id, '\\_ej\\_', '')]
  training_places <- rbindlist(list(training_places, training_places_ej), use.names = TRUE)
  
  setkey(training_places, location_id)
  setkey(dt_flist, location_id)
  dt_flist <- training_places[dt_flist]
  dt_flist <- dt_flist[!is.na(fname)]
  dt_flist <- dt_flist[!is.na(width)]
  fwrite(dt_flist, '~/Dropbox/pkg.data/bike_lanes/data/clean/df_training.csv')
}