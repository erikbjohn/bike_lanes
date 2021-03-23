sample_roads_points <- function(x, sdist=100){
  #sample_roads_points_location <- '~/Dropbox/pkg.data/bike_lanes/data/clean/sample_roads_points.rds'
  #if(!file.exists(sample_roads_points_location)){
  if (!require(sp)) stop("sp PACKAGE MISSING")
  if (!inherits(x, "SpatialLinesDataFrame")) stop("MUST BE SP SpatialLinesDataFrame OBJECT")
  lgth <- SpatialLinesLengths(x) 
  #lsub <- x[1,]
  # Check for extent. If small return centoid of shape.
  ns <- max(round( (lgth / sdist), digits=0),1)
  lsamp <- suppressWarnings(spsample(x, n=ns, type="regular", offset=c(0.5,0.5)))
  if(!is.null(lsamp)){
  results <- SpatialPointsDataFrame(lsamp, data=data.frame(ID=rep(1:length(lsamp)))) 
  coords.return <- results@coords
  } else {
    coords.return <- c(NA,NA)
  #}
  #} else {
    
  }
  return(coords.return)
}
