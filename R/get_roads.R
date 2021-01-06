get_roads <- function(){
  tuscaloosa_roads_location <- '~/Dropbox/pkg.data/bike_lanes/data/clean/tuscaloosa_roads.rds'
  if(!file.exists(tuscaloosa_roads_location)){
    proj.wgs84 <- '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs' 
    roads <- rgdal::readOGR('~/Documents/Github/transparent_eyeballs/data/raw/tuscaloosa_roads/', layer = "tl_2013_01125_roads")
    roads <- spTransform(roads, proj.wgs84)
    roads@data$id <- as.integer(roads@data$LINEARID)
    roads@data$FULLNAME <- stringr::str_to_upper(roads@data$FULLNAME)
    roads$data$FULLNAME <- stringr::str_replace_all(roads@data$FULLNAME, 'STATE RTE', 'HWY')
    saveRDS(roads, tuscaloosa_roads_location)
  } else {
    roads <- readRDS(tuscaloosa_roads_location)
  }
  return(roads)
}