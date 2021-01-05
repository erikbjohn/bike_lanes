get_training_data_johnson <- function(){
  training_data_location <- '~/Dropbox/pkg.data/bike_lanes/data/raw/training_data/'
  training_places <- fread('~/Dropbox/pkg.data/bike_lanes/data/raw/johnson_locs.csv')
  training_places <- data.table::as.data.table(training_places)
  training_places <- training_places[, location_id:=seq(1:nrow(training_places))]
  training_places <- training_places[, location_id:=paste0('_ej', location_id)]
  setnames(training_places, 'dist', 'width')
  saveRDS(training_places, '~/Dropbox/pkg.data/bike_lanes/data/raw/training_places_ej.rds')
  # Check for uniqueness
  table(training_places$location_id)[table(training_places$location_id)>1]
  
  load('~/Dropbox/pkg.data/api.keys/raw/l.pkg.rdata')
  api.key <- l.pkg$google
  zoom_level <- 21
  
  for(i_loc in 1:nrow(training_places)){
    training_place <- training_places[i_loc]
    location_id <- training_place$location_id
    point_lat <- training_place$lat
    point_lon <- training_place$lon
    gloc <- paste0('https://maps.googleapis.com/maps/api/staticmap?zoom=',
                   zoom_level, 
                   '&center=', point_lat, ',', point_lon, 
                   '&size=640x640&maptype=satellite',
                   '&key=', api.key)
    fDest_sat <- paste0( training_data_location, 'locationid_', location_id, '_sat_zoom_', zoom_level, '.png')
    download.file(gloc, destfile=fDest_sat)
    
  }
}