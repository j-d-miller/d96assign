#' Plots student assignments
#'
#'
#' \code{plotAssign} shows  on a map how students are assigned to schools. There are a number of options for what can be plotted,
#' inlcuding how the algorithm assigns students, the actual assignment of students, etc.
#'
#' @param sa a student assignment dataframe
#' @param what  kind of assignment to be plotted. Options are "AlgoAssign", "School" (actual assignment), "Final" (same as Algo except for Siblings)
#' @param ptitle title for plot
#' @param pcaption caption for plot
#' @param dsize size of points
#' @param djitter amount of jitter
#' @param print_map whether to print the map or return a ggmap object
#' @return a plot showing how students are assigned
# @examples
# function(kg, minA = 20, minB = 10, minC = 40, minH = 5, maxA = 40, maxB = 40, maxC = 60, maxH = 25)
#

#' @export
plotAssign <- function(sa, what = "AlgoAssign", ptitle = "", pcaption = "", dsize = 1, print_map = T, djitter = .0003)
{
  tuftePal <- c("#990033", "#367a37", "#cc6600", "#333333")
  shapePal <- c(16, 17)

  sa$Older_Sibling <- sa$Siblings != "No"

  mapAll <- riversideMap +geom_point(data = tschoolGeo[1:4,], aes(x = lon, y = lat ) ,  size = 3, color = "red", shape = 15 ) +
    scale_colour_manual(name = "Schools", values = tuftePal) + scale_shape_manual( values = shapePal) +
    geom_point( data = sa , aes_string(x = "lon", y = "lat", colour = what, shape = "Older_Sibling") ,
                position = position_jitter(w = djitter, h = djitter), size = dsize) +
    labs(
      title = ptitle,
      caption = pcaption
    )


  if(print_map) {
    print(mapAll) } else {
      mapAll
    }
}



