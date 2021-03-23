get_university_blvd_predictions.R <- function(){
  dt_predicts <- fread('predictions/university_blvd_predictions.csv')
  dt_predicts <- dt_predicts[, str_loc:=stringr::str_extract(fname, '(?<=id\\_).+(?=\\_sat)')]
  dt_predicts <- dt_predicts[, lat:=stringr::str_extract(str_loc, '.+(?=\\_)')]
  dt_predicts <- dt_predicts[, lon:=stringr::str_extract(str_loc, '(?<=\\_).+')]
  university_predicts_updates <- '~/Dropbox/pkg.data/bike_lanes/data/clean/university_predicts_udpates.csv'
  if(!file.exists(university_predicts_updates)){
    fwrite(dt_predicts, university_predicts_updates)
  }
}