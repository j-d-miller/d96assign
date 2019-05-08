#' Uses Google to get walking times for each student to each school. Also geocodes addresses
#'
#' \code{getDistanceMatrix} Calls the Google API to get walkig times in minutes for each student to each school and also geocodes
#' each address. Requires a Google key. Google allows 2500 free queries per day. The function creates an Excel spreadsheet
#' "enrollDFwDist-(time stamp).xlsx containing all the info in the input object (enrollDF) plus six new columns: the
#' distance to each school (in minutes), the latitude and the longitude of each student address
#'
#' @param enrollDF a data frame containing the nx4 distance matrix
#' @return NULL
# @examples
#

#' @export
getDistanceMatrix <- function(enrollDF)
{
# test

  enrollDF$Zip <- as.integer(enrollDF$Zip)
  enrollDF$Address <- paste( enrollDF$Street, enrollDF$City, enrollDF$State, enrollDF$Zip, "USA" , sep = ", " )
  enrollDF$UID <- paste("S",1:nrow(enrollDF), sep = "")

  enrollDFUA <- enrollDF[!duplicated(enrollDF$Address),]
  uAdds  <- enrollDFUA$Address # unique( enrollDF$Address )

  Nk <- length(uAdds)
  tKgeocodes <- vector("list", Nk)
  aKDistA <- vector("list", Nk)
  aKDistB <- vector("list", Nk)
  aKDistC <- vector("list", Nk)
  aKDistH <- vector("list", Nk)

  for(i in 1:Nk)
  {
    try (  tKgeocodes[[i]] <- geocode( uAdds[i] )  )
    try ( aKDistA[[i]] <- mapdist(uAdds[i], tschoolGeo$address[1], mode = 'walking',  Sys.sleep(.21) ) )
    try ( aKDistB[[i]] <- mapdist(uAdds[i], tschoolGeo$address[2], mode = 'walking',  Sys.sleep(.21) ) )
    try ( aKDistC[[i]] <- mapdist(uAdds[i], tschoolGeo$address[3], mode = 'walking',  Sys.sleep(.21) ) )
    try ( aKDistH[[i]] <- mapdist(uAdds[i], tschoolGeo$address[4], mode = 'walking',  Sys.sleep(.21) ) )
  }

  # check for missing and retry

  misGC <- which( sapply(tKgeocodes, function(z) is.null(z) | (!is.null(z) & (is.na(z$lon) | is.na(z$lat)  ) )  ) ) # or is.na
  misA <- which( sapply(aKDistA, function(z) is.null(z)  ) )
  misB <- which( sapply(aKDistB, function(z) is.null(z)  ) )
  misC <- which( sapply(aKDistC, function(z) is.null(z)  ) )
  misH <- which( sapply(aKDistH, function(z) is.null(z)  ) )

  for(i in misGC)
    try (  tKgeocodes[[i]] <- geocode( tuadds[i] )  )
  for(i in misA)
    try ( aKDistA[[i]] <- mapdist(uAdds[i], tschoolGeo$address[1], mode = 'walking',  Sys.sleep(.21) ) )
  for(i in misB)
    try ( aKDistB[[i]] <- mapdist(uAdds[i], tschoolGeo$address[2], mode = 'walking',  Sys.sleep(.21) ) )
  for(i in misC)
    try ( aKDistC[[i]] <- mapdist(uAdds[i], tschoolGeo$address[3], mode = 'walking',  Sys.sleep(.21) ) )
  for(i in misH)
    try ( aKDistH[[i]] <- mapdist(uAdds[i], tschoolGeo$address[4], mode = 'walking',  Sys.sleep(.21) ) )

  # check for missing again; if any missing spit out an error message; ow proceed

  misGC <- which( sapply(tKgeocodes, function(z) is.null(z) | (!is.null(z) & (is.na(z$lon) | is.na(z$lat)  ) )  ) )
  misA <- which( sapply(aKDistA, function(z) is.null(z)  ) )
  misB <- which( sapply(aKDistB, function(z) is.null(z)  ) )
  misC <- which( sapply(aKDistC, function(z) is.null(z)  ) )
  misH <- which( sapply(aKDistH, function(z) is.null(z)  ) )

  misAll <- unique( c(misGC,misA,misB,misC,misH) )
  isOK <- !is.element(1:Nk, misAll)

  # either return values that are missing
  if( length(misAll) > 0  )
  {
    write_xlsx(enrollDFUA[misAll,], path = paste("missingDistanceData-", format(Sys.time(), "%Y%m%d-%H-%M-%S"), ".xlsx", sep = ""), col_names = TRUE)
  }

  # or if everything is OK, proceed

  gcK <- do.call("rbind", tKgeocodes[isOK])
  dAmesA <- do.call("rbind", aKDistA[isOK])
  dBlytheA <- do.call("rbind", aKDistB[isOK])
  dCentralA <- do.call("rbind", aKDistC[isOK])
  dHollywoodA <- do.call("rbind", aKDistH[isOK])


  tmatch <- match(enrollDF$Address, uAdds, nomatch = 0)

  distMatrix <- data.frame(Ames = dAmesA$minutes[tmatch],
                           Blythe = dBlytheA$minutes[tmatch],
                           Central = dCentralA$minutes[tmatch],
                           Hollywood = dHollywoodA$minutes[tmatch],
                           gcK[tmatch,])

  distMatrix[,1:4] <- round(distMatrix[,1:4], 1)

  enrollDFwDist <-  cbind(enrollDF[c("Student", "UID", "Siblings", "Street", "Apartment", "City",
                                     "State", "Zip")], distMatrix)

  write_xlsx(enrollDFwDist, path = paste("distMat-", format(Sys.time(), "%Y%m%d-%H-%M-%S"), ".xlsx", sep = ""), col_names = TRUE)

  return( ifelse( length(misAll) > 0 , 0, 1 )  )
}
