get_university_blvd_points <- function(){
  university_blvd_points_location <- '~/Dropbox/pkg.data/bike_lanes/data/clean/university_blvd_points.rds'
  if(!file.exists(university_blvd_points_location)){
    source('R/get_roads.R')
    source('R/sample_roads_points.R')
    roads <- get_roads()
    roads_university_blvd <- roads[stringr::str_detect(roads@data$FULLNAME, '(?i)(university)'),]
    roads_university_blvd@data <- as.data.table(roads_university_blvd@data)
    roads_university_blvd@data <- roads_university_blvd@data[, .(LINEARID, 
                                                                 FULLNAME, 
                                                                 RTTYP=as.character(RTTYP),
                                                                 MTFCC=as.character(MTFCC))]
    
    roads_coords <- sample_roads_points(roads_university_blvd, sdist=0.002)
    roads_coords <- as.data.table(roads_coords)
    setnames(roads_coords, names(roads_coords), c('long', 'lat'))
    roads_coords <- roads_coords[lat>33.2055557]
    roads_coords <- roads_coords[long < -87.51271]
    roads_coords <- roads_coords[, location_id:=paste0(lat,'_', long)]
    dt <- copy(roads_coords)
    saveRDS(dt, university_blvd_points_location)
  } else {
    dt <- readRDS(university_blvd_points_location)
  }
  return(dt)
}
