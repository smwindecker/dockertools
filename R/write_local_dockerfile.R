#' Writes dockerfile
#'
#' @param maintainer_name Name of maintainer
#' @param maintainer_email Email address of maintainer
#' @param r_ver R version of base image
#'
#' @return Writes Dockerfile to current directory
#' @export
#'
#' @examples write_local_dockerfile('my_name', 'my_email', '3.5.0')
write_local_dockerfile <- function (maintainer_name,
                                    maintainer_email,
                                    r_ver = '3.6.1') {

  if (isNULL(r_ver)) {
    r_ver <- substr(gsub("R version ", "",
                         R.Version()$version.string,
                         fixed = TRUE), 1, 5)
  }

  fileConn <- file("Dockerfile")
  contents <- paste0('FROM rocker/verse:', r_ver, '\n',
                     'LABEL maintainer=', maintainer_name, '\n',
                     'LABEL email=', maintainer_email, '\n\n',

'# Install major libraries
RUN    apt-get update \
    && apt-get install -y --no-install-recommends \
        zip \
        unzip

# ---------------------------------------------

ENV NB_USER rstudio
ENV NB_UID 1000

# And set ENV for R! It doesn\'t read from the environment...
RUN echo \"PATH=${PATH}\" >> /usr/local/lib/R/etc/Renviron
RUN echo \"export PATH=${PATH}\" >> ${HOME}/.profile

# The `rsession` binary that is called by nbrsessionproxy to start R doesn\'t seem to start
# without this being explicitly set
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib

ENV HOME /home/${NB_USER}
WORKDIR ${HOME}

# ---------------------------------------------

# Install extra latex style files

## Saves downloading whenever tinytex runs
## Inspired by Yihui - https://github.com/yihui/tinytex/issues/135#issuecomment-514351695
## NB: tinytex extras installed at  /opt/TinyTeX/tlpkg/TeXLive/

RUN R --quiet -e \'tinytex::tlmgr_install(c(\"a4wide\", \"algorithms\", \"appendix\",
\"babel-english\", \"bbm-macros\", \"beamer\", \"breakurl\", \"catoptions\", \"charter\",
\"cite\", \"cleveref\", \"colortbl\", \"comment\", \"courier\", \"eepic\", \"enumitem\",
\"eso-pic\", \"eurosym\", \"extsizes\", \"fancyhdr\", \"floatrow\", \"fontaxes\", \"fpl\",
\"hardwrap\", \"koma-script\", \"lastpage\", \"lettrine\", \"libertine\", \"lineno\",
\"lipsum\",  \"ltxkeys\", \"ly1\", \"mathalpha\", \"mathpazo\", \"mathtools\", \"mdframed\",
\"mdwtools\", \"microtype\", \"morefloats\", \"ms\", \"multirow\", \"mweights\", \"ncctools\",
\"ncntrsbk\", \"needspace\", \"newtx\", \"ntgclass\", \"numname\", \"palatino\", \"pbox\",
\"pdfpages\", \"pgf\", \"picinpar\", \"preprint\", \"preview\", \"psnfss\", \"refstyle\",
\"roboto\", \"sectsty\", \"setspace\", \"siunitx\", \"srcltx\", \"standalone\", \"stmaryrd\",
\"sttools\", \"subfig\", \"subfigure\", \"symbol\", \"tabu\", \"textcase\", \"threeparttable\",
\"thumbpdf\", \"titlesec\", \"tufte-latex\", \"ucs\", \"ulem\", \"units\", \"varwidth\",
\"vmargin\", \"wallpaper\", \"wrapfig\", \"xargs\", \"xcolor\", \"xstring\", \"xwatermark\"))\';

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

RUN if [ -f DESCRIPTION ]; then R --quiet -e \"options(repos =
list(CRAN = \'http://mran.revolutionanalytics.com/snapshot/2019-08-26/\'));
devtools::install_deps()\"; fi

# Add further custom installations as needed')
  writeLines(c(contents), fileConn)
  close(fileConn)

}


