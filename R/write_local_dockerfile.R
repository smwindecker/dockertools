#' Writes basic dockerfile
#'
#' @param maintainer_name Name of maintainer
#' @param maintainer_email Email address of maintainer
#' @param r_ver optional to specify R version of base image
#' @param date optional to specify date for R package version installs
#'
#' @return Writes Dockerfile to current directory
#' @export
#'
#' @examples write_local_dockerfile('my_name', 'my_email', '4.3.0')
write_local_dockerfile <- function (maintainer_name,
                                    maintainer_email,
                                    r_ver = NULL,
                                    date = NULL) {

  if (is.null(r_ver)) {
    r_ver <- substr(gsub("R version ", "",
                         R.Version()$version.string,
                         fixed = TRUE), 1, 5)
  }
  if (is.null(date)) {
    date <- substr(gsub("R version ", "",
                        R.Version()$version.string,
                        fixed = TRUE), 8, 17)
  }

  fileConn <- file("Dockerfile")
  contents <- paste0('FROM rocker/rstudio:', r_ver, '\n',
                     'LABEL maintainer=\"', maintainer_name, '\"\n',
                     'LABEL email=\"', maintainer_email, '\"\n\n',

'
# Install major libraries
RUN    apt-get update \\
    && apt-get install -y --no-install-recommends \\
        zip \\
        unzip

# ---------------------------------------------

ENV NB_USER rstudio
ENV NB_UID 1000

# And set ENV for R
RUN echo \"PATH=${PATH}\" >> /usr/local/lib/R/etc/Renviron
RUN echo \"export PATH=${PATH}\" >> ${HOME}/.profile

# The `rsession` binary that is called by nbrsessionproxy to start R does not seem to start
# without this being explicitly set
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib

ENV HOME /home/${NB_USER}
WORKDIR ${HOME}

# ---------------------------------------------

USER root

# Copy only the description file for the project
# COPY ./DESCRIPTION ${HOME}
# Copy your entire repo to the container
COPY . ${HOME}

RUN chown -R ${NB_USER} ${HOME}

# --------------------------------------------

# Install packages based on DESCRIPTION file in repository.
## Date for package version can be modified
## Inspired from Holepunch package, by Karthik Ram: https://github.com/karthik/holepunch
RUN if [ -f DESCRIPTION ]; then R --quiet -e \"install.packages(\'remotes\'); options(repos = list(CRAN = \'https://packagemanager.posit.co/cran/', date, '/\')); remotes::install_deps()\"; fi

# --------------------------------------------

# Expose RStudio port
EXPOSE 8787

# Start RStudio Server on container startup
CMD [\"/init\"]

')
  writeLines(c(contents), fileConn)
  close(fileConn)

}


