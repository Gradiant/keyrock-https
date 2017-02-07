#/bin/bash

# Enable mods
a2enmod ssl proxy proxy_http proxy_balancer

# Enable sites
a2ensite horizon.conf keystone.conf

# Restart apache
service apache2 restart

# Start keystone
/keystone/tools/with_venv.sh /keystone/bin/keystone-all -v

