# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'

# this is a way to share the package: build the tar file and then
# other people can install the package by calling
# install.packages("path/to/tar/file", source = TRUE, repos=NULL)
# install.packages("/Users/jeffmiller/Documents/Rprojs/d96assign_0.1.0.tar.gz", source = TRUE, repos=NULL)
# to build a source package (tarball) choose build source package in menu

# a way to build the tar file without going through the gui
# build(pkg = ".", path = NULL, binary = FALSE, vignettes = TRUE,      manual = FALSE, args = NULL, quiet = FALSE)


# getwd()


# use_gpl3_license(pkg = ".")
# use_testthat(pkg = ".")
# devtools::use_package("lpSolve")
# devtools::use_package("ggmap")
# devtools::use_package("readxl")
# devtools::use_package("writexl")

# devtools::document()
