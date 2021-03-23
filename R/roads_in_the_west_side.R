roads_in_the_west_side_sample <- function(){
  roads_in_the_west_side_sample_location <- '~/Dropbox/pkg.data/bike_lanes/data/clean/roads_in_the_west_side_sample.csv'
  if(!file.exists(roads_in_the_west_side_sample_location)){
  # Get some more sample data
  lat_max <- 33.209459
  lat_min <- 33.201128
  lon_min <- -87.577544
  lon_max <- -87.560421
  source('R/get_roads.R')
  source('R/sample_roads_points.R')
  roads <- get_roads()
  road_points <- sample_roads_points(roads, sdist=0.0005)
  road_points <- as.data.table(road_points)
  setnames(road_points, names(road_points), c('lon', 'lat'))
  west_side <- road_points[lon > lon_min & lon < lon_max & lat > lat_min & lat < lat_max]
  west_side_dists <- flexclust::dist2(west_side, west_side, method='euclidean')
  west_side$point_id <- 1:nrow(west_side)
  dt_unique_points <- data.table(lon=as.numeric(), lat=as.numeric())
  for(i in 1:(nrow(west_side)-1)){
    west_loc <- west_side[i, .(lon, lat)]
    west_loc_dist <- flexclust::dist2(west_loc, west_side[(i+1):nrow(west_side),.(lon, lat)])
    n_close <- length(which(west_loc_dist<0.0005))
    if(n_close == 0){
      dt_unique_point <- data.table(lon=west_loc$lon, lat=west_loc$lat)   
      dt_unique_points <- rbindlist(list(dt_unique_points, dt_unique_point), use.names = TRUE, fill=TRUE)
    }
  }
  fwrite(dt_unique_points, roads_in_the_west_side_sample_location)
  } else {
    dt_unique_points <- fread(roads_in_the_west_side_sample_location)
  }
  return(dt_unique_points)
}