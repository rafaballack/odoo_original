#!/bin/bash
################################################################################
# Script for Installation: ODOO Saas4/Trunk server on Ubuntu 16.04 LTS
# Author: Fabio Negrini
#-------------------------------------------------------------------------------
#  
# This script will install ODOO Server on
# clean Ubuntu 16.04 Server
#-------------------------------------------------------------------------------
# USAGE:
#
# odoo_install
#
# EXAMPLE:
# ./odoo_install 
#
################################################################################
 
##fixed parameters
#openerp
OE_USER="Servidor001"
OE_HOME="/opt/Servidor001/$OE_USER"
OE_HOME_EXT="/opt/$OE_USER/$OE_USER-server"
OE_REPORT_HOME="$OE_HOME/report"
OE_REPORT_ENGINE="$OE_REPORT_HOME/engine"
OE_REPORT_JASPER="$OE_REPORT_HOME/jasper"
OE_MODULES_HOME="$OE_HOME/custom/addons"
OE_THEME_HOME="/opt/$OE_USER/themes"

#Enter version for checkout "8.0" for version 8.0, "7.0 (version 7), saas-4, saas-5 (opendays version) and "master" for trunk
OE_VERSION="10.0"

#set the superadmin password
OE_SUPERADMIN="admin"
OE_CONFIG="$OE_USER-server"


#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y


#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
sudo apt-get install postgresql -y
	
echo -e "\n---- PostgreSQL $PG_VERSION Settings  ----"
sudo sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = '*'"/g /etc/postgresql/9.5/main/postgresql.conf

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true


#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo apt-get install wget subversion git bzr bzrtools python-pip npm -y
	
echo -e "\n---- Install python packages ----"
sudo apt-get install python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-mock python-unittest2 python-jinja2 python-pypdf python-decorator python-requests python-passlib python-pil nodejs-legacy node-less python-apt lxc -y
	
echo -e "\n---- Install python libraries ----"
sudo pip install --upgrade pip
sudo pip install gdata
sudo pip install dbf
sudo pip install py3o.template
sudo pip install py3o.formats

echo -e "\n---- Install npm libraries    ----"
sudo npm install -g less

echo -e "\n--- Install libreoffice libraries ---"
sudo apt-get install default-jre ure libreoffice-java-common libreoffice-writer -y

echo -e "\n---- Install wkhtmltopdf  ----"
sudo add-apt-repository ppa:ecometrica/servers -y
sudo apt-get update
sudo apt-get install wkhtmltopdf -y

echo "==== Instalando dependências da Localização Brasileira ===="
sudo -H pip install pytrustnfe
sudo -H pip install python-boleto
sudo -H pip install python-cnab


echo "==== Instalando dependências da Localização Brasileira ===="
sudo apt-get install --no-install-recommends python-libxml2 -y
sudo apt-get install --no-install-recommends libxmlsec1-dev -y
sudo apt-get install --no-install-recommends python-openssl -y
sudo apt-get install --no-install-recommends python-cffi -y


echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'Servidor001' --group $OE_USER

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER



#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server from OCA ===="
sudo mkdir $OE_REPORT_HOME
sudo mkdir $OE_REPORT_ENGINE
sudo mkdir $OE_REPORT_JASPER
sudo mkdir $OE_THEME_HOME

sudo git clone --branch $OE_VERSION https://github.com/OCA/OCB $OE_HOME_EXT/
sudo git clone --branch $OE_VERSION https://github.com/OCA/reporting-engine.git $OE_REPORT_ENGINE/
sudo git clone --branch $OE_VERSION https://github.com/Openworx/backend_theme $OE_THEME_HOME/backend_theme
sudo git clone --branch $OE_VERSION https://github.com/fnegrini/jasper_odoo.git $OE_REPORT_JASPER/

echo -e "\n---- Create custom module directory ----"
sudo su $OE_USER -c "mkdir $OE_HOME/custom"
sudo su $OE_USER -c "mkdir $OE_HOME/custom/addons"

echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_REPORT_HOME/*


echo -e "\n---- Creating modules folder ----"
sudo mdkdir $OE_MODULES_HOME
sudo ln -s $OE_REPORT_ENGINE/base_report_assembler $OE_MODULES_HOME
sudo ln -s $OE_REPORT_ENGINE/report_py3o $OE_MODULES_HOME
sudo ln -s $OE_REPORT_ENGINE/report_qweb_element_page_visibility $OE_MODULES_HOME
sudo ln -s $OE_REPORT_ENGINE/report_xls $OE_MODULES_HOME
sudo ln -s $OE_REPORT_ENGINE/report_xlsx $OE_MODULES_HOME
sudo ln -s $OE_REPORT_ENGINE/setup $OE_MODULES_HOME
sudo ln -s $OE_REPORT_JASPER/odoo/report_jasper_base $OE_MODULES_HOME
sudo ln -s $OE_THEME_HOME/backend_theme/backend_theme_v10 $OE_MODULES_HOME

echo -e "* Create server config file"
sudo cp $OE_HOME_EXT/debian/odoo.conf /etc/$OE_CONFIG.conf
sudo chown $OE_USER:$OE_USER /etc/$OE_CONFIG.conf
sudo chmod 640 /etc/$OE_CONFIG.conf

echo -e "* Change server config file"
sudo sed -i s/"db_user = .*"/"db_user = $OE_USER"/g /etc/$OE_CONFIG.conf
sudo sed -i s/"; admin_passwd.*"/"admin_passwd = $OE_SUPERADMIN"/g /etc/$OE_CONFIG.conf
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONFIG$1.log' >> /etc/$OE_CONFIG.conf"
sudo su root -c "echo 'addons_path=$OE_HOME_EXT/addons,$OE_HOME/custom/addons' >> /etc/$OE_CONFIG.conf"

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/openerp-server --config=/etc/$OE_CONFIG.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh




#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------

echo -e "* Create init file"
echo '#!/bin/sh' >> ~/$OE_CONFIG
echo '### BEGIN INIT INFO' >> ~/$OE_CONFIG
echo '# Provides: $OE_CONFIG' >> ~/$OE_CONFIG
echo '# Required-Start: $remote_fs $syslog' >> ~/$OE_CONFIG
echo '# Required-Stop: $remote_fs $syslog' >> ~/$OE_CONFIG
echo '# Should-Start: $network' >> ~/$OE_CONFIG
echo '# Should-Stop: $network' >> ~/$OE_CONFIG
echo '# Default-Start: 2 3 4 5' >> ~/$OE_CONFIG
echo '# Default-Stop: 0 1 6' >> ~/$OE_CONFIG
echo '# Short-Description: Enterprise Business Applications' >> ~/$OE_CONFIG
echo '# Description: ODOO Business Applications' >> ~/$OE_CONFIG
echo '### END INIT INFO' >> ~/$OE_CONFIG
echo 'PATH=/bin:/sbin:/usr/bin' >> ~/$OE_CONFIG
echo "DAEMON=$OE_HOME_EXT/odoo-bin" >> ~/$OE_CONFIG
echo "NAME=$OE_CONFIG" >> ~/$OE_CONFIG
echo "DESC=$OE_CONFIG" >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Specify the user name (Default: odoo).' >> ~/$OE_CONFIG
echo "USER=$OE_USER" >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Specify an alternate config file (Default: /etc/openerp-server.conf).' >> ~/$OE_CONFIG
echo "CONFIGFILE=\"/etc/$OE_CONFIG.conf\"" >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# pidfile' >> ~/$OE_CONFIG
echo 'PIDFILE=/var/run/$NAME.pid' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Additional options that are passed to the Daemon.' >> ~/$OE_CONFIG
echo 'DAEMON_OPTS="-c $CONFIGFILE"' >> ~/$OE_CONFIG
echo '[ -x $DAEMON ] || exit 0' >> ~/$OE_CONFIG
echo '[ -f $CONFIGFILE ] || exit 0' >> ~/$OE_CONFIG
echo 'checkpid() {' >> ~/$OE_CONFIG
echo '[ -f $PIDFILE ] || return 1' >> ~/$OE_CONFIG
echo 'pid=`cat $PIDFILE`' >> ~/$OE_CONFIG
echo '[ -d /proc/$pid ] && return 0' >> ~/$OE_CONFIG
echo 'return 1' >> ~/$OE_CONFIG
echo '}' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'case "${1}" in' >> ~/$OE_CONFIG
echo 'start)' >> ~/$OE_CONFIG
echo 'echo -n "Starting ${DESC}: "' >> ~/$OE_CONFIG
echo 'start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONFIG
echo '--exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE_CONFIG
echo 'echo "${NAME}."' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo 'stop)' >> ~/$OE_CONFIG
echo 'echo -n "Stopping ${DESC}: "' >> ~/$OE_CONFIG
echo 'start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--oknodo' >> ~/$OE_CONFIG
echo 'echo "${NAME}."' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'restart|force-reload)' >> ~/$OE_CONFIG
echo 'echo -n "Restarting ${DESC}: "' >> ~/$OE_CONFIG
echo 'start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--oknodo' >> ~/$OE_CONFIG
echo 'sleep 1' >> ~/$OE_CONFIG
echo 'start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONFIG
echo '--exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE_CONFIG
echo 'echo "${NAME}."' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo '*)' >> ~/$OE_CONFIG
echo 'N=/etc/init.d/${NAME}' >> ~/$OE_CONFIG
echo 'echo "Usage: ${NAME} {start|stop|restart|force-reload}" >&2' >> ~/$OE_CONFIG
echo 'exit 1' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'esac' >> ~/$OE_CONFIG
echo 'exit 0' >> ~/$OE_CONFIG

echo -e "* Security Init File"
sudo mv ~/$OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG

echo -e "* Start ODOO on Startup"
sudo update-rc.d $OE_CONFIG defaults
 
sudo service $OE_CONFIG start
echo "Done! The ODOO server can be started with: service $OE_CONFIG start"































