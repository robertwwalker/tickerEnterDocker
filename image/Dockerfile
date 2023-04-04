# get shiny server plus tidyverse packages image
FROM rocker/shiny-verse:latest
# system libraries of general use
# FROM openanalytics/r-shiny
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libxml2-dev \
    libudunits2-dev \
    libsasl2-dev \
    libv8-dev
 
# install R packages required 
# (change it depending on the packages you need)
RUN R -e "install.packages(c('plotly','tidyquant','bslib','thematic'), repos='http://cran.rstudio.com/')"
# Copy configuration files into the Docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
# Copy the app
COPY /app /srv/shiny-server/
RUN rm /srv/shiny-server/index.html
# expose port on Docker container
EXPOSE 3838
# Copy further configuration files into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh
# Change permissions
RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]
# Start up and launch the app
CMD ["/usr/bin/shiny-server.sh"]