# #' Tries to figure out where siblings go to school
# #'
# #'
# #' \code{getSiblings} uses address and grade info to figure out where older siblings attend school. In production, this info should be provided
# #'
# #' @param z a student distance data frame
#
# #' @return the student distance dataframe with a column SIBLINGS showing where siblings attend school
# # @examples
# # function(kg)
# #
#'
# #' @export
# getSiblings <- function(z)
# {
#
#   tmp <- z[z$Grade >=0 & z$Grade <= 5 & z$School != "Off", ]
#   x <- by(tmp, tmp$family, function(z) z )
#
#   x <- lapply(x, function(z) {
#
#     firstThruFifth <- z$Grade > 0
#
#     if( any(firstThruFifth) )
#       z$SIBLINGS <- z$School[which(firstThruFifth)][1]
#
#     z
#   })
#
#   x <- do.call("rbind", x)
#   x
# }
