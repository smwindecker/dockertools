#' Pull or push image from dockerhub
#' Assumes your built image is named after your dockerhub username
#'
#' @param pull_push Specify 'pull' or 'push'
#' @param dockerhub_username username for dockerhub
#' @param project_name built image name
#'
#' @return NULL
#' @export
#'
#' @examples pull_push_local_dockerfile('push', 'my_username', 'my_project')
pull_push_local_dockerfile <- function (pull_push,
                                        dockerhub_username,
                                        project_name) {

  system(paste0('docker ', pull_push, ' ', dockerhub_username, '/', project_name))

}
