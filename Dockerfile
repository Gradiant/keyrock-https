# Copyright (C) 2017  Gradiant <https://www.gradiant.org/>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

FROM ubuntu:14.04

MAINTAINER Lorenzo García Cortiñas <lgcortinas@gradiant.org> 

ENV HOME=/
ENV IDM_PASS=idm

# Install Ubuntu dependencies
RUN sudo apt-get update && \
    sudo apt-get install -y wget python git vim expect && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    sudo python get-pip.py

# Install Ubuntu project dependencies
RUN sudo apt-get install -y python-dev python-virtualenv libssl-dev libffi-dev libjpeg8-dev libxml2-dev libxslt1-dev libsasl2-dev libssl-dev libldap2-dev libffi-dev libsqlite3-dev libmysqlclient-dev python-mysqldb

# Install Apache2, mod_wsgi and mod_proxy
RUN sudo apt-get install -y apache2 libapache2-mod-wsgi libapache2-mod-proxy-html

# Download latest version of the code 
RUN git clone https://github.com/ging/keystone && \
    cd keystone && \
    git checkout tags/keyrock-5.4.0
    
RUN git clone https://github.com/ging/horizon && \
    cd horizon && \
    git checkout tags/keyrock-5.4.1

# Configuring settings files
RUN cp keystone/etc/keystone.conf.sample keystone/etc/keystone.conf && \
    cp horizon/openstack_dashboard/local/local_settings.py.example horizon/openstack_dashboard/local/local_settings.py && \
    sed -i s/\$\$IDM_PASS/${IDM_PASS}/g horizon/openstack_dashboard/local/local_settings.py
# Edit Django local_settings.pysed
RUN sed -i 's/SECRET_KEY =/SECRET_KEY = "asdasdasd"#/' /horizon/openstack_dashboard/local/local_settings.py
RUN sed -i 's/os.path.join(LOCAL_PATH/#os.path.join(LOCAL_PATH/' /horizon/openstack_dashboard/local/local_settings.py
# Change keystone endpoint to https
#RUN sed -i 's#OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3"#OPENSTACK_KEYSTONE_URL = "https://%s:5000/v3"#' /horizon/openstack_dashboard/local/local_settings.py

# Fix no module named six installation bug
#RUN sudo pip install six==1.9.0
#RUN cat keystone/tools/install_venv.py
COPY fix_createVenv_keystone.py /keystone/tools/fix_createVenv.py
COPY fix_createVenv_horizon.py /horizon/tools/fix_createVenv.py
RUN sudo chmod a+x /keystone/tools/fix_createVenv.py && \
    sudo chmod a+x /horizon/tools/fix_createVenv.py
RUN sudo python /keystone/tools/fix_createVenv.py && \
    sudo /keystone/tools/with_venv.sh pip install six==1.9.0 && \
    sudo python /horizon/tools/fix_createVenv.py && \
    sudo /horizon/tools/with_venv.sh pip install six==1.9.0
#RUN exit 1

# Install python dependecies
RUN sudo python keystone/tools/install_venv.py && \
    sudo python horizon/tools/install_venv.py

# Write Apache site configuration files
COPY horizon.conf /etc/apache2/sites-available/
COPY keystone.conf /etc/apache2/sites-available/

# Edit Apache general configuration file
RUN echo "<Directory /horizon>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride None\n\
        Require all granted\n\
</Directory>\n"\
>> /etc/apache2/apache2.conf

# Change workdir
WORKDIR /keystone

# Create certs directory and copy configuration
RUN mkdir /keystone/certs
#COPY keystone.conf /keystone/etc/

# Sync database
RUN sudo tools/with_venv.sh bin/keystone-manage db_sync && \
    sudo tools/with_venv.sh bin/keystone-manage db_sync --extension=endpoint_filter && \
    sudo tools/with_venv.sh bin/keystone-manage db_sync --extension=oauth2 && \
    sudo tools/with_venv.sh bin/keystone-manage db_sync --extension=roles && \
    sudo tools/with_venv.sh bin/keystone-manage db_sync --extension=user_registration && \
    sudo tools/with_venv.sh bin/keystone-manage db_sync --extension=two_factor_auth

# Prepare to set up idm password
COPY expect_idm_password .
RUN sed -i s/\$\$IDM_PASS/${IDM_PASS}/g expect_idm_password && \
    chmod +x expect_idm_password && \
    sudo ./expect_idm_password

# Change workdir
WORKDIR /horizon 

# Add new directories and collect horizon statics
RUN mkdir /horizon/certs
RUN tools/with_venv.sh python manage.py collectstatic --noinput
RUN tools/with_venv.sh python manage.py compress --force

# Generate ssl certificates
WORKDIR /root
COPY generate_certificates.sh /root/
RUN chmod +x generate_certificates.sh
RUN ./generate_certificates.sh

# Copy apache starter script
COPY entrypoint.sh /root/
RUN chmod +x entrypoint.sh

# Mount volumes to grant access from host
VOLUME /keystone/
VOLUME /horizon/

### Exposed ports
# - Keystone
EXPOSE 5000
# - Horizon (HTTPs)
EXPOSE 8000

# Change workdir
WORKDIR /keystone

CMD sudo /root/entrypoint.sh
