#' Docker build local image
#' Assumes you want to build your image with dockerhub username as part of image name
#' Docker must be installed
#'
#' @param dockerhub_username username for dockerhub
#' @param project_name built image name
#'
#' @return NULL
#' @export
#'
#' @examples build_local_dockerfile('my_username', 'my_project_name')
build_local_dockerfile <- function (dockerhub_username,
                                    project_name) {

  system(paste0('docker build -t', dockerhub_username, '/', project_name, ' .'))

}
