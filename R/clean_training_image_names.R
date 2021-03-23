# Only have to run this once.

training_image_list <- list.files('~/Dropbox/pkg.data/bike_lanes/data/raw/training_data')
training_image_dest_folder <- '~/Dropbox/pkg.data/bike_lanes/data/raw/training_images/'
dt_training_images <- data.table(name_orig=training_image_list)
dt_training_images $path_orig <- list.files('~/Dropbox/pkg.data/bike_lanes/data/raw/training_data', full.names = TRUE)
dt_training_images <- dt_training_images[, location_id:=stringr::str_extract(name_orig, '(?<=ationid\\_).+(?=\\_(sat|bearing))')]
dt_training_images <- dt_training_images[, location_id:=str_replace_all(location_id, "[[:punct:]]", "")]
dt_training_images$image_type <- 'sat'
dt_training_images <- dt_training_images[stringr::str_detect(name_orig, 'bearing'), 
                                         image_type:='street']
dt_training_images <- dt_training_images[!stringr::str_detect(name_orig, 'rotate')]
dt_training_images$image_perspective <- 'zoom21'
dt_training_images <- dt_training_images[stringr::str_detect(name_orig, 'bearing'),
                                         image_perspective := paste0('bearing', stringr::str_extract(name_orig,
                                                                                   '(?!.*?\\_).+(?=\\.jpg)'))]
dt_training_images <- dt_training_images[, image_format:=stringr::str_extract(name_orig, '(?<=\\.).+')]
dt_training_images <- dt_training_images[, name_new:=paste0('locationid-', location_id, '_',
                                                            'imagetype-', image_type, '_',
                                                            'persp-', image_perspective,
                                                            '.', image_format)]
dt_training_images <- dt_training_images[, path_new:=paste0(training_image_dest_folder, name_new)]
mapply(file.copy, dt_training_images$path_orig, dt_training_images$path_new)

for(i_image in 1:nrow(dt_training_images)){
  path_source <- paste0(training_image_list, name_orig)
}
