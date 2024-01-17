#' Writes dockerfile
#'
#' @param maintainer_name Name of maintainer
#' @param maintainer_email Email address of maintainer
#' @param r_ver optional to specify R version of base image
#'
#' @return Writes Dockerfile to current directory
#' @export
#'
#' @examples write_local_dockerfile('my_name', 'my_email', '3.5.0')
write_local_dockerfile <- function (maintainer_name,
                                    maintainer_email,
                                    r_ver = NULL) {

  if (is.null(r_ver)) {
    r_ver <- substr(gsub("R version ", "",
                         R.Version()$version.string,
                         fixed = TRUE), 1, 5)
  }

  fileConn <- file("Dockerfile")
  contents <- paste0('FROM rocker/rstudio:', r_ver, '\n',
                     'LABEL maintainer=\"', maintainer_name, '\"\n',
                     'LABEL email=\"', maintainer_email, '\"\n\n',

"
# Install major libraries
RUN    apt-get update \
    && apt-get install -y --no-install-recommends \
        zip \
        unzip

# ---------------------------------------------

ENV NB_USER rstudio
ENV NB_UID 1000

# And set ENV for R! It doesn't read from the environment...
RUN echo 'PATH=${PATH}' >> /usr/local/lib/R/etc/Renviron
RUN echo 'export PATH=${PATH}'' >> ${HOME}/.profile

# The `rsession` binary that is called by nbrsessionproxy to start R doesn't seem to start
# without this being explicitly set
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib

ENV HOME /home/${NB_USER}
WORKDIR ${HOME}

# ---------------------------------------------

# Add custom installations here

## Install packages based on DESCRIPTION file in repository.
## Inspired from Holepunch package, by Karthik Ram: https://github.com/karthik/holepunch

## Copies your description file into the Docker Container, specifying dependencies

USER root
COPY ./DESCRIPTION ${HOME}
# The above line adds only the description file for the project
# Uncomment the following line if you want the container to contain your entire repo

#COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}

RUN if [ -f DESCRIPTION ]; then R --quiet -e 'install.packages('remotes'); options(repos = list(CRAN = 'https://packagemanager.posit.co/cran/2023-06-16/')); remotes::install_deps()'; fi

# Add further custom installations as needed

")
  writeLines(c(contents), fileConn)
  close(fileConn)

}


