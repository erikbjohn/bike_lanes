get_university_blvd_snapshots <- function(){
  university_blvd_snapshots_location <- '~/Dropbox/pkg.data/bike_lanes/data/raw/university_blvd_snapshots/'
  if(!dir.exists(university_blvd_snapshots_location)){
    source('R/get_university_blvd_points.R')
    dir.create(university_blvd_snapshots_location)
    dt_points <- get_university_blvd_points()
    
    load('~/Dropbox/pkg.data/api.keys/raw/l.pkg.rdata')
    api.key <- l.pkg$google
    zoom_level <- 21
    
    for(i_loc in 1:nrow(dt_points)){
      dt_point <- dt_points[i_loc]
      location_id <- dt_point$location_id
      point_lat <- dt_point$lat
      point_lon <- dt_point$long
      gloc <- paste0('https://maps.googleapis.com/maps/api/staticmap?zoom=',
                     zoom_level, 
                     '&center=', point_lat, ',', point_lon, 
                     '&size=640x640&maptype=satellite',
                     '&key=', api.key)
      fDest_sat <- paste0(university_blvd_snapshots_location, 'locationid_', location_id, '_sat_zoom_', zoom_level, '.png')
      download.file(gloc, destfile=fDest_sat)
  }  
}