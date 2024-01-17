#' Writes dockerfile to .binder/ to be used to run a binder container
#' Assumes your built image is named after your dockerhub username,
#' and has been pushed to dockerhub
#'
#' @param dockerhub_username Username for dockerhub
#' @param project_name Built image name
#' @param maintainer_name Name of maintainer
#' @param maintainer_email Email address of maintainer
#'
#' @return Creates .binder folder and writes binder-enabled Dockerfile to it
#' @export
#'
#' @examples write_binder_dockerfile('my_username', 'my_project', 'my_name', 'my_email')
write_binder_dockerfile <- function (dockerhub_username,
                                     project_name,
                                     maintainer_name,
                                     maintainer_email) {


  if (is.null(dockerhub_username)) {
    gh_repo <- git2r::remote_url()
    gh_repo <- gsub(".git", "", gsub("https://github.com/", "", gh_repo, fixed = TRUE), fixed=TRUE)
    dockerhub_username <- gh_repo
  }


  dir.create('.binder')
  fileConn <- file(".binder/Dockerfile")
  contents <- paste0('FROM ', dockerhub_username, '/', project_name, '\n',
                     'LABEL maintainer=\"', maintainer_name, '\"\n',
                     'LABEL email=\"', maintainer_email, '\"\n\n',

'# This file copied from
# https://github.com/rocker-org/binder/blob/master/Dockerfile

## If extending this image, remember to switch back to USER root to apt-get

USER root

ENV NB_USER rstudio
ENV NB_UID 1000
ENV VENV_DIR /srv/venv

# Set ENV for all programs...
ENV PATH ${VENV_DIR}/bin:$PATH
# And set ENV for R! It doesn\'t read from the environment...
RUN echo \"PATH=${PATH}\" >> /usr/local/lib/R/etc/Renviron
RUN echo \"export PATH=${PATH}\" >> ${HOME}/.profile

# The `rsession` binary that is called by nbrsessionproxy to start R doesn\'t seem to start
# without this being explicitly set
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib

ENV HOME /home/${NB_USER}
WORKDIR ${HOME}

RUN apt-get update && \\
apt-get -y install python3-venv python3-dev && \\
apt-get purge && \\
apt-get clean && \\
rm -rf /var/lib/apt/lists/*

  # Create a venv dir owned by unprivileged user & set up notebook in it
  # This allows non-root to install python libraries if required
  RUN mkdir -p ${VENV_DIR} && chown -R ${NB_USER} ${VENV_DIR}

USER ${NB_USER}
RUN python3 -m venv ${VENV_DIR} && \\
# Explicitly install a new enough version of pip
pip3 install pip==9.0.1 && \\
pip3 install --no-cache-dir \\
jupyter-rsession-proxy

RUN R --quiet -e \"devtools::install_github(\'IRkernel/IRkernel\')\" && \\
R --quiet -e \"IRkernel::installspec(prefix=\'${VENV_DIR}\')\"

USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
USER ${NB_USER}

CMD jupyter notebook --ip 0.0.0.0
')
  writeLines(c(contents), fileConn)
  close(fileConn)

}


