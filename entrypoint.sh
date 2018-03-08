#/bin/bash
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

# Enable mods
a2enmod ssl proxy proxy_http proxy_balancer

# Enable sites
a2ensite horizon.conf keystone.conf

# Restart apache
service apache2 restart

# Start keystone
/keystone/tools/with_venv.sh /keystone/bin/keystone-all -v

