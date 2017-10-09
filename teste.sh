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
OE_USER="Servidor01"




#--------------------------------------------------
# Install PostgreSQL Server /ALTERADO POR MIM, POSTGRE JÁ FOI INSTALADO
#--------------------------------------------------
echo -e "\n---- PostgreSQL $PG_VERSION Settings  ----"
sudo sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = '*'"/g /etc/postgresql/9.3/main/postgresql.conf

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true

echo -e "\n---- ALTERANDO SENHA DO POSTGRES  ----"

sudo su postgres

psql

alter user postgres with password '1q2w3e';

create user OE_USER superuser inherit createdb createrole noreplication;
alter user OE_USER with password '1q2w3e';

\q

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"


















