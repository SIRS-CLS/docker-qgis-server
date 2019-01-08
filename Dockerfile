FROM opensuse/leap:15

# Add repo qgis/gdal
RUN zypper addrepo https://download.opensuse.org/repositories/Application:Geo/openSUSE_Leap_15.0/Application:Geo.repo
RUN zypper addrepo -p 98 https://download.opensuse.org/repositories/home:Le_Docteur/openSUSE_Leap_15.0/home:Le_Docteur.repo
RUN zypper ref
# Install qgis/gdal/apache2
RUN zypper install -y qgis gdal apache2 apache2-mod_fcgid unzip
#Install wfsOutputExtension plugin
RUN mkdir -p /opt/qgis-server && mkdir -p /opt/qgis-server/plugins
ADD https://github.com/3liz/qgis-wfsOutputExtension/archive/master.zip /opt/qgis-server/plugins
RUN unzip /opt/qgis-server/plugins/master.zip -d /opt/qgis-server/plugins/
RUN mv /opt/qgis-server/plugins/qgis-wfsOutputExtension-master /opt/qgis-server/plugins/wfsOutputExtension
# Add virtual host
ADD qgis-server.conf /etc/apache2/vhosts.d/qgis-server.conf
#Setting up Apache
RUN export LC_ALL="C" && a2enmod fcgid && a2enconf serve-cgi-bin
RUN a2dissite 000-default
RUN a2ensite qgis-server
EXPOSE 80
ADD start.sh /start.sh
RUN chmod +x /start.sh
CMD /start.sh
