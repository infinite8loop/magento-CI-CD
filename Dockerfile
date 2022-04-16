FROM ubuntu
MAINTAINER manumanojkumar27@gmail.com

# Base Packages
RUN apt-get update
RUN apt-get -y install git
RUN apt-get -y install vim
RUN apt-get -y install curl

# SSH
ENV TZ=Asia/Kolkata \
    DEBIAN_FRONTEND=noninteractive   
#This prevents the installer from opening dialog boxes during the installation process. As a result, it stops the errors from displaying.
RUN apt-get -y install openssh-server
RUN service ssh start

# Apache
RUN apt-get -y install apache2
RUN service apache2 start
RUN a2enmod rewrite #enable your mod_rewrite module for Apache. Then go to /etc/apache2/sites-available and edit default file.
RUN rm -rf /etc/apache2/apache2.conf
COPY configs/apache2.conf /etc/apache2/
COPY ./sites-available /etc/apache2/
RUN service apache2 restart
RUN chmod go-rwx /var/www/html
RUN chmod go+x /var/www/html

# PHP
RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt-get -y update
RUN apt-get -y install php7.1 libapache2-mod-php7.1 php7.1-common php7.1-gd php7.1-mysql php7.1-mcrypt php7.1-curl php7.1-intl php7.1-xsl php7.1-mbstring php7.1-zip php7.1-bcmath php7.1-iconv php7.1-soap

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer self-update --1

#Copying Magento files
COPY . /var/www/html/
WORKDIR /var/www/html
RUN composer install
RUN chmod -R 777 /var/www/html

# Start
EXPOSE 80 10000 443
RUN cd /sbin
RUN touch run.sh
RUN echo "#!/bin/bash" >> run.sh
RUN echo "while /bin/true; do" >> run.sh
RUN echo "service apache2 start" >> run.sh
RUN echo "sleep 60" >> run.sh
RUN echo "done" >> run.sh
RUN chmod +x run.sh
ENTRYPOINT ["./run.sh"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
