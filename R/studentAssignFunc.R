#' Assigns students to schools
#'
#'
#' \code{assignStudents} assigns students to schools to minimize total walking distance subject to constraints on class sizes and
#' the number of sections per school. The user specifies the minimum and maximum number of students that can be assigned to each school.
#' If \code{penalty} is not zero, the function that is minimized is the sum of all walking distances plus \code{penalty} times the sum of all walking distances squared
#'
#' @param kg a data frame containing the nx4 distance matrix
#' @param minA minimum number of kindergarten students to assign to Ames
#' @param minB minimum number of kindergarten students to assign to Blythe
#' @param minC minimum number of kindergarten students to assign to Central
#' @param minH minimum number of kindergarten students to assign to Hollywood
#' @param maxA maximum number of kindergarten students to assign to Ames
#' @param maxB maximum number of kindergarten students to assign to Blythe
#' @param maxC maximum number of kindergarten students to assign to Central
#' @param maxH maximum number of kindergarten students to assign to Hollywood
#' @param penalty adds a term that is quadtaric in distance squared to the walking distance matrix. makes solution more compact
#' @return assignment of students to schools which minimizes total walking distance subject to space constraints.
# @examples
# function(kg, minA = 20, minB = 10, minC = 40, minH = 5, maxA = 40, maxB = 40, maxC = 60, maxH = 25)
#

#' @export
assignStudents <- function( kg,
                            minA = 20, minB = 10, minC = 20, minH = 5,
                            maxA = 40, maxB = 40, maxC = 60, maxH = 1000, penalty = 0)
{

  tabS <- table(kg$Siblings)
  namesS <- names(tabS)

  sibA <- ifelse( any(namesS == "Ames") , tabS["Ames"], 0)
  sibB <- ifelse( any(namesS == "Blythe") , tabS["Blythe"], 0)
  sibC <- ifelse( any(namesS == "Central") , tabS["Central"], 0)
  sibH <- ifelse( any(namesS == "Hollywood") , tabS["Hollywood"], 0)

  # make minMax vector
  minMax <- c(minA,minB,minC,minH,maxA,maxB,maxC,maxH)

  # subtract the number of siblings at each school from the max; this should
  minMax[1] <- minMax[1] - sibA
  minMax[2] <- minMax[2] - sibB
  minMax[3] <- minMax[3] - sibC
  minMax[4] <- minMax[4] - sibH
  minMax[5] <- minMax[5] - sibA
  minMax[6] <- minMax[6] - sibB
  minMax[7] <- minMax[7] - sibC
  minMax[8] <- minMax[8] - sibH


  # break kg into assignable and not assignable (because of siblings) groups
  assignable <- kg$Siblings == "No"
  kga <- kg[assignable,]
  kgna <- kg[!assignable,]

  # find the optimal (least distance) assignment using lpSolve
  n <- nrow(kga)
  sch <- 4
  dat <- as.matrix( kga[,c("Ames","Blythe","Central","Hollywood")] )

  # add a quadratic penalty to suppress solutions with very large walking times
  if(penalty >0)
    dat <- dat + penalty * dat^2

  const.mat <- matrix (0, n * sch, n) # first, the students

  # Each student's constraint coefficients is a vector of 1's in the appropriate row.
  for (i in 1:n) {
    mat <- matrix (0, n, sch)  # matrix of 0's
    mat[i,] <- rep (1, sch) # constraint coefficients for row i
    const.mat[,i] <- c(mat)
  }
  clow.mat <- matrix (0, n * sch, sch) # school "lower" capacity
  cup.mat <- clow.mat # school "upper" capacity
  for (i in 1:sch) {
    mat <- matrix (0, n, sch)  # matrix of 0's
    mat[, i] <- rep (1, n) # constraint coefficients for column i
    clow.mat[,i] <- cup.mat [,i] <- c(mat)
  }

  # Put constraints together. Assemble signs and rhs values.

  const.mat<- cbind (const.mat, clow.mat, cup.mat)
  const.sign <- c(rep ("=", n), rep (">", sch), rep ("<", sch))
  const.rhs <- c(rep (1, n), minMax)

  out <- lpSolve::lp("min", c(dat), const.mat, const.sign, const.rhs,
                     transpose.constraints = FALSE, all.bin=TRUE)

  if(out$status==2){
    outlist <- list(assignment = NULL,
                    avgWalkingTime = NULL,
                    avgWalkingTimeAct = NULL,
                    avgWalkingTimeAssigned = NULL,
                    schoolStats = NULL,
                    schoolStatsAct = NULL,
                    schoolStatsAssigned = NULL,
                    walkingTimes = NULL,
                    status = 2)
    return(outlist)
  }

  # put the solution into a useful format

  sol <- data.frame( matrix( out$solution, n, sch ) )
  names(sol) <- c("A","B","C","H")

  sol2 <- rep("Ames",n)
  sol2[sol[,2] == 1] <- "Blythe"
  sol2[sol[,3] == 1] <- "Central"
  sol2[sol[,4] == 1] <- "Hollywood"
  ####

  kgsa <- data.frame(kga, AlgoAssign = sol2)

  kgs <- kgsa
  if(nrow(kgna) > 0 ) {
    kgsna <- data.frame(kgna, AlgoAssign = "Sibling")
    kgs <- rbind(kgs, kgsna)
  }

  kgs <- kgs[order(kgs$Student), ]

  final <- as.character( kgs$AlgoAssign )
  if(any(kgs$AlgoAssign == "Sibling") )
    final[kgs$AlgoAssign == "Sibling"] <- kgs$Siblings[kgs$AlgoAssign == "Sibling"]
  kgs$Assignment <- final
  kgs <- kgs[,c("Student", "UID", "Street", "Apartment", "City",
                    "State", "Zip", "Assignment", "Siblings", "Ames", "Blythe", "Central", "Hollywood", "lon",
                   "lat")]

  # calculate walking times for the final assignment (algo + siblings)
  walkingTimes <- list( Ames = kgs[kgs$Assignment == "Ames", "Ames"],
                        Blythe = kgs[kgs$Assignment == "Blythe", "Blythe"],
                        Central = kgs[kgs$Assignment == "Central", "Central"],
                        Hollywood = kgs[kgs$Assignment == "Hollywood", "Hollywood"] )

  averageTime <- round( mean( unlist(walkingTimes) ) , 1 )
  walkingTimes$All <- do.call("c", walkingTimes)
  names(walkingTimes$All) <- NULL

  # schoolStats is the summary of walking times
  schoolStats <- data.frame( round( rbind(
    sapply(walkingTimes, function(z) length(z)),
    sapply(walkingTimes, function(z) mean(z)),
    sapply(walkingTimes, function(z) suppressWarnings(max(z))),
    sapply(walkingTimes, function(z) sd(z))) ,1 ))
  row.names(schoolStats) <- c("students", "meanTime", "maxTime", "stdevTime")

  # added on dec 18. summary of walking times of the actual or attendance area school assignment
  if(!is.null(kgs$School))
  {
    walkingTimesAct <- list( Ames = kgs[kgs$School == "Ames", "Ames"],
                             Blythe = kgs[kgs$School == "Blythe", "Blythe"],
                             Central = kgs[kgs$School == "Central", "Central"],
                             Hollywood = kgs[kgs$School == "Hollywood", "Hollywood"] )

    averageTimeAct <- round( mean( unlist(walkingTimesAct) ) , 1 )
    walkingTimesAct$All <- do.call("c", walkingTimesAct)
    names(walkingTimesAct$All) <- NULL

    # schoolStatsAct is the summary of walking times for the actual assignment
    schoolStatsAct <- data.frame( round( rbind(
      sapply(walkingTimesAct, function(z) length(z)),
      sapply(walkingTimesAct, function(z) mean(z)),
      sapply(walkingTimesAct, function(z) suppressWarnings(max(z))),
      sapply(walkingTimesAct, function(z) sd(z))) ,1 ))
    row.names(schoolStatsAct) <- c("students", "meanTime", "maxTime", "stdevTime")
  } else {
    averageTimeAct <- NULL
    walkingTimesAct <- NULL
    schoolStatsAct <- NULL
  }

  # summary of walking times for the subset of students who are actually assigned by the algo

  kgsA <-  kgs[kgs$Siblings == "No", ]

  walkingTimesAssigned <- list( Ames = kgsA[kgsA$Assignment == "Ames", "Ames"],
                                Blythe = kgsA[kgsA$Assignment == "Blythe", "Blythe"],
                                Central = kgsA[kgsA$Assignment == "Central", "Central"],
                                Hollywood = kgsA[kgsA$Assignment == "Hollywood", "Hollywood"] )

  averageTimeAssigned <- round( mean( unlist(walkingTimesAssigned) ) , 1 )
  walkingTimesAssigned$All <- do.call("c", walkingTimesAssigned)
  names(walkingTimesAssigned$All) <- NULL

  # schoolStats is the summary of walking times for the final assignment
  schoolStatsAssigned <- data.frame( round( rbind(
    sapply(walkingTimesAssigned, function(z) length(z)),
    sapply(walkingTimesAssigned, function(z) mean(z)),
    sapply(walkingTimesAssigned, function(z) suppressWarnings(max(z))),
    sapply(walkingTimesAssigned, function(z) sd(z))) ,1 ))
  row.names(schoolStatsAssigned) <- c("students", "meanTime", "maxTime", "stdevTime")

  outlist <- list(assignment = kgs,
                  avgWalkingTime = averageTime,
                  avgWalkingTimeAct = averageTimeAct,
                  avgWalkingTimeAssigned = averageTimeAssigned,
                  schoolStats = schoolStats,
                  schoolStatsAct = schoolStatsAct,
                  schoolStatsAssigned = schoolStatsAssigned,
                  walkingTimes = walkingTimes,
                  status = 0)

  return(outlist)
}





