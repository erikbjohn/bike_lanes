create_training_data <- function(){
  
  l <- list()
  # First set of training data measurement (name, lat/long, width, location_id)
  dt_first <- readxl::read_xlsx('~/Dropbox/pkg.data/bike_lanes/data/raw/ MidPntRdWdt.xlsx')
  dt_first <- data.table::as.data.table(dt_first)
  dt_first <- dt_first[, location_id:=stringr::str_to_lower(Name)]
  dt_first <- dt_first[, location_id:=stringr::str_replace_all(location_id, ' ', '-')]
  setnames(dt_first, c('RoadWidth(ft)', 'longitude', 'Latitude'), 
           c('width', 'lon', 'lat'))
  dt_first <- dt_first[, .(location_id, lon, lat, width)]
  dt_first <- dt_first[, location_id:=str_replace_all(location_id, "[[:punct:]]", "")]
  dt_first$training_sample <- 'first'
  l$first <- dt_first
  
  # Second set of training data 
  dt_second <- fread('~/Dropbox/pkg.data/bike_lanes/data/raw/johnson_locs.csv')
  dt_second <- data.table::as.data.table(dt_second)
  dt_second <- dt_second[, location_id:=seq(1:nrow(dt_second))]
  dt_second <- dt_second[, location_id:=paste0('ej', location_id)]
  dt_second <- dt_second[, .(location_id, lon=long, lat, width=dist)]
  dt_second$training_sample <-'second'
  l$second <- dt_second
  
  # Third set of training data
  dt_third <- fread('~/Dropbox/pkg.data/bike_lanes/data/raw/roads_in_the_west_side_sample.csv')
  dt_third <- dt_third[, .(location_id=paste0('westside', id),
                           lon, lat, width=Road_width)]
  dt_third$training_sample <- 'third'
  l$third <- dt_third
  
  # Stack the data
  dt_training_data <- rbindlist(l, use.names=TRUE, fill=TRUE)
  
  # Check for existing pictures and download if they do not currently exist
  training_image_folder <- '~/Dropbox/pkg.data/bike_lanes/data/raw/training_images/'
  training_image_list <- list.files(training_image_folder)
  
  load('~/Dropbox/pkg.data/api.keys/raw/l.pkg.rdata')
  api.key <- l.pkg$google
  zoom_level <- 21
  bearings <- c(0, 90, 180, 270)
  
  for(i_loc in 1:nrow(dt_training_data)){
    cat(i_loc, '\n')
    training_place <- dt_training_data[i_loc]
    location_id <- training_place$location_id
    point_lat <- training_place$lat
    point_lon <- training_place$lon
    
    # satellite images
    fDest_name <- paste0('locationid-', location_id,
                         '_imagetype-sat_persp-zoom21.png')
    fDest_path <- paste0(training_image_folder, fDest_name)
    file_check <- fDest_name %in% training_image_list
    
    if(!file_check){
      cat(fDest_name, '\n')
      gloc <- paste0('https://maps.googleapis.com/maps/api/staticmap?zoom=',
                     zoom_level, 
                     '&center=', point_lat, ',', point_lon, 
                     '&size=640x640&maptype=satellite',
                     '&key=', api.key)
      download.file(gloc, destfile=fDest_path)
    }
    
    # streetview images
    for(bearing in bearings){
      fDest_name <- paste0('locationid-', location_id,
                           '_imagetype-street', 
                           '_persp-bearing', bearing, 
                           '.jpg')
      fDest_path <- paste0(training_image_folder, fDest_name)
      file_check <- fDest_name %in% training_image_list
      
      
      location_id <- str_replace_all(location_id, "[[:punct:]]", "")
      if(!file_check){
        cat(fDest_name, '\n')
        shotLoc <- paste0('https://maps.googleapis.com/maps/api/streetview?size=1200x600&location=',
                          point_lat, ',', point_lon,
                          '&heading=', bearing,
                          '&pitch=-40&fov=', 80,'&key=', api.key)
        download.file(shotLoc, destfile=fDest_path)
      }
    }
  }
  training_image_folder <- '~/Dropbox/pkg.data/bike_lanes/data/raw/training_images/'
  f_list <- list.files(training_image_folder)
  dt_flist <- data.table::data.table(fname = f_list,
                                     fpath = paste0(training_image_folder, f_list))
  dt_flist <- dt_flist[, location_id:=stringr::str_extract(fname, '(?<=locationid\\-).+(?=\\_imagetype)')]
  dt_flist <- dt_flist[, imagetype:=stringr::str_extract(fname, '(?<=imagetype\\-).+(?=\\_persp)')]
  dt_flist <- dt_flist[, persp:=stringr::str_extract(fname, '(?<=persp\\-).+(?=\\.)')]
  dt_flist_cast <- data.table::dcast(dt_flist, locationid ~ imagetype + persp, value.var=c('fpath'))
  setkey(dt_training_data, location_id)
  setkey(dt_flist_cast, location_id)
  dt_training_data <- dt_training_data[dt_flist_cast]
  fwrite(dt_training, '~/Dropbox/pkg.data/bike_lanes/data/clean/df_training.csv')
}