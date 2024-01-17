#' Run a built dockerfile locally, accessed through the 8787 port
#' Assumes your built image is named after your dockerhub username
#'
#' @param dockerhub_username username for dockerhub
#' @param project_name built image name
#'
#' @return Opens url with container running
#' @export
#'
#' @examples run_local_dockerfile('my_username', 'my_project')
run_local_dockerfile <- function (dockerhub_username, project_name) {

  system(paste0('docker run -v $(pwd):/home/rstudio/ -p 8787:8787 -e DISABLE_AUTH=true ',
                dockerhub_username, '/', project_name))

  utils::browseURL('localhost:8787')

}
