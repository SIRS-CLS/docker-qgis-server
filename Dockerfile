FROM opensuse/leap:15.0

# Add repo qgis/gdal
RUN zypper --non-interactive --no-gpg-checks addrepo https://download.opensuse.org/repositories/Application:Geo/openSUSE_Leap_15.0/Application:Geo.repo
RUN zypper --non-interactive --no-gpg-checks addrepo https://download.opensuse.org/repositories/home:Le_Docteur/openSUSE_Leap_15.0/home:Le_Docteur.repo

#Update priority repo
RUN zypper mr -p 97 home_Le_Docteur
RUN zypper mr -p 98 Application_Geo

# Update repo
RUN zypper --non-interactive --no-gpg-checks ref
RUN zypper --non-interactive --no-gpg-checks update

# Install qgis/gdal/apache2
#RUN zypper --non-interactive --no-gpg-checks install firewalld
RUN zypper --non-interactive --no-gpg-checks install qgis gdal apache2 apache2-mod_fcgid unzip

# Open Port 80 
#RUN firewall-cmd --zone=public --add-port=80/tcp --permanent
#RUN firewall-cmd --reload

#Install wfsOutputExtension plugin
RUN mkdir -p /opt/qgis-server && mkdir -p /opt/qgis-server/plugins
ADD https://github.com/3liz/qgis-wfsOutputExtension/archive/master.zip /opt/qgis-server/plugins
RUN unzip /opt/qgis-server/plugins/master.zip -d /opt/qgis-server/plugins/
RUN mv /opt/qgis-server/plugins/qgis-wfsOutputExtension-master /opt/qgis-server/plugins/wfsOutputExtension

# Add virtual host
ADD qgis-server.conf /etc/apache2/vhosts.d/qgis-server.conf

#Setting up Apache
RUN export LC_ALL="C" && a2enmod fcgid
RUN a2enmod qgis-server
EXPOSE 80
ADD start.sh /start.sh
RUN chmod +x /start.sh
CMD /start.sh
