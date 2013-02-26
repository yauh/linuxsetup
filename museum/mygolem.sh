#!/bin/bash
# Description: Set up your (virtual) linux server with essentials like LAMP or munin
# Author: Stephan Hochhaus <stephan@yauh.de
# Version: 0.1 initial development version
## initial install assumes no installed software 

# determine distro (so far only Debian works, but CentOS should follow sometime soon)

if [[ `cat /etc/issue` =~ "Debian" ]] ; then
	export MYDISTRO="Debian"
fi
export MYHOST=`echo $(hostname)`

echo "#########################################"
echo "# Mygolem.sh - set up your linux system #"
echo "#########################################"
echo 

# define the options/order for menu select
options=("all" "munin" "nginx" "php" "mysql" "gmail" "nodejs")

menu() {
    echo "Please select one or more tasks to install:"
    for i in ${!options[@]}; do 
        printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
    done
    [[ "$tasks" ]] && echo "$tasks"; :
}

prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
    [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#options[@]} )) || {
        tasks="Invalid option: $num"; continue
    }
    ((num--)); tasks="${options[num]} was ${choices[num]:+un}checked"
    [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
    #echo "DEBUG: $options[$i]: ${choices[$i]}"
done

printf "You selected"; tasks=" nothing"
for i in ${!options[@]}; do 
    [[ "${choices[i]}" ]] && { printf " %s" "${options[i]}"; tasks=""; }
done
echo "$tasks";

# the actual action begins here
case $MYDISTRO in
	Debian)
		# setting proper sources for Debian
		echo ## The golem appended the following sources >> /etc/apt/sources.list
		echo deb http://ftp.de.debian.org/debian squeeze main >> /etc/apt/sources.list
		echo deb-src http://ftp.de.debian.org/debian squeeze main >> /etc/apt/sources.list
		echo deb http://packages.dotdeb.org stable all >> /etc/apt/sources.list
		wget http://www.dotdeb.org/dotdeb.gpg
		cat dotdeb.gpg | apt-key add -
		rm dotdeb.gpg
		# get the deb stuff updated
		apt-get update
		apt-get -y install locales vim locate telnet
;;
esac


counter=0
for i in "${options[@]}"
do
	case $i in
	all|munin)
		if  [ "${choices[$counter]}" == "+" ] ; then
			echo "*** Let's install munin"
				case $MYDISTRO in
					Debian)
						echo "##### doing the debian setup for munin"
						echo "Please enter the hostname for munin: "
						read MYMUNININSTANCE
						apt-get -y install munin munin-node munin-plugins-extra libio-all-lwp-perl

						# enable munin plugins
wget --no-check-certificate https://github.com/munin-monitoring/contrib/raw/master/plugins/mysql/mysql_size_all --output-document=/usr/share/munin/plugins/mysql_size_all
wget --no-check-certificate #https://github.com/munin-monitoring/contrib/raw/master/plugins/nginx/php5-fpm_status --output-document=/usr/share/munin/plugins/php5-fpm_status
wget --no-check-certificate https://github.com/munin-monitoring/contrib/raw/master/plugins/nginx/nginx_memory --output-document=/usr/share/munin/plugins/nginx_memory
ln -s /usr/share/munin/plugins/df_abs  /etc/munin/plugins/
ln -s /usr/share/munin/plugins/mysql_bytes       /etc/munin/plugins/
ln -s /usr/share/munin/plugins/mysql_queries     /etc/munin/plugins/
ln -s /usr/share/munin/plugins/mysql_size_all /etc/munin/plugins/
ln -s /usr/share/munin/plugins/mysql_slowqueries /etc/munin/plugins/
ln -s /usr/share/munin/plugins/mysql_threads     /etc/munin/plugins/
ln -s /usr/share/munin/plugins/netstat /etc/munin/plugins/
ln -s /usr/share/munin/plugins/nginx_memory  /etc/munin/plugins/
ln -s /usr/share/munin/plugins/nginx_request /etc/munin/plugins/
ln -s /usr/share/munin/plugins/nginx_status  /etc/munin/plugins/
#ln -s /usr/share/munin/plugins/php5-fpm_status /etc/munin/plugins/
ln -s /usr/share/munin/plugins/ping_  /etc/munin/plugins/ping_google.com

# let's configure the munin plugins a bit
echo "[nginx*]
env.url http://localhost/nginx_status
env.ua nginx-status-verifier/0.1
" > /etc/munin/plugin-conf.d/nginx
echo "[netstat]
user root
" > /etc/munin/plugin-conf.d/netstat
sed -i "s/\[localhost\.localdomain\]/[$MYMUNININSTANCE]/g" /etc/munin/munin.conf
chmod -R 755 /usr/share/munin/plugins/

# cron needs to be running
update-rc.d cron defaults
					;;
					*)
						echo "Don't know what to do for munin on this system"
					;;
				esac			
		fi
		;;
	all|nginx)
		if  [ "${choices[$counter]}" == "+" ] ; then
			echo "*** Let's install nginx"
				case $MYDISTRO in
					Debian)
						echo "##### doing the debian setup for nginx"
						# setting the sources for nginx
						echo deb http://nginx.org/packages/debian/ squeeze nginx >> /etc/apt/sources.list
						echo deb-src http://nginx.org/packages/debian/ squeeze nginx >> /etc/apt/sources.list
						wget http://nginx.org/keys/nginx_signing.key
						cat nginx_signing.key | apt-key add -
						rm nginx_signing.key
						# get the deb stuff updated
						apt-get update
						apt-get -y install nginx imagemagick

# set up fastcgi params
echo "fastcgi_connect_timeout 60;" >> /etc/nginx/conf.d/fastcgi_params
echo "fastcgi_send_timeout 180;" >> /etc/nginx/conf.d/fastcgi_params
echo "fastcgi_read_timeout 180;" >> /etc/nginx/conf.d/fastcgi_params
echo "fastcgi_buffer_size 128k;" >> /etc/nginx/conf.d/fastcgi_params
echo "fastcgi_buffers 4 256k;" >> /etc/nginx/conf.d/fastcgi_params
echo "fastcgi_busy_buffers_size 256k;" >> /etc/nginx/conf.d/fastcgi_params
echo "fastcgi_temp_file_write_size 256k;" >> /etc/nginx/conf.d/fastcgi_params
echo "fastcgi_intercept_errors on;" >> /etc/nginx/conf.d/fastcgi_params

# set up a sample host for nginx with php and rewrite rules
echo "server {
  listen 8080 ;  #could also be 1.2.3.4:80

  server_name $MYHOST; # Alternately: _
  root /var/www/html;

  index index.php index.html index.htm;
  try_files $uri $uri/ /index.php?$args;

  # serve static files directly
  location ~* \.(js|ico|gif|jpg|jpeg|png|css|html|htm|swf|htc|xml|bmp|cur|txt)$ {
     access_log off;
     expires max;
  }

  location ~ \.php$ {
      # Security: must set cgi.fix_pathinfo to 0 in php.ini!
      fastcgi_split_path_info ^(.+\.php)(/.+)$;
      fastcgi_pass 127.0.0.1:9000;
      fastcgi_index index.php;
      fastcgi_param SCRIPT_FILENAME         $document_root$fastcgi_script_name;
      fastcgi_param PATH_INFO $fastcgi_path_info;
      include /etc/nginx/fastcgi_params;
  }

  location ~ /\.ht {
    deny all;
  }
}" > /etc/nginx/conf.d/sample_conf

# munin will be served via nginx
touch /etc/nginx/conf.d/munin.conf
if [[ $MYMUNININSTANCE == "" ]] ; then
	echo "Please enter the hostname for munin: "
	read MYMUNININSTANCE
fi
echo "server {
  server_name $MYMUNININSTANCE;
  root /var/cache/munin/www/;
  # Restrict Munin access
  #auth_basic "Restricted";
  #auth_basic_user_file /etc/nginx/htpasswd;
  location / {
    index index.html;
    access_log off;
  }
}
 server {
       listen 127.0.0.1;
       server_name localhost;
       location /nginx_status {
               stub_status on;
               access_log   off;
               allow 127.0.0.1;
               deny all;
       }
}" >> /etc/nginx/conf.d/munin.conf
mkdir -p /var/www/html


					;;
					*)
						echo "Don't know what to do for nginx on this system"
					;;
				esac
			
		fi
		/etc/init.d/nginx restart
		;;
	all|php)
		if  [ "${choices[$counter]}" == "+" ] ; then
			echo "*** Let's install munin"
				case $MYDISTRO in
					Debian)
						echo "##### doing the debian setup for php"
						apt-get -y install php5 php5-fpm php-pear php5-common php5-mcrypt php5-mysql php5-cli php5-gd imagemagick
# configure phpfor nginx/fpm
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /etc/php5/fpm/php.ini 

						# tune up php-fpm
echo pm.max_children = 25 >> /etc/php5/fpm/php-fpm.conf
echo pm.start_servers = 4 >> /etc/php5/fpm/php-fpm.conf
echo pm.min_spare_servers = 2 >> /etc/php5/fpm/php-fpm.conf
echo pm.max_spare_servers = 10 >> /etc/php5/fpm/php-fpm.conf
echo pm.max_requests = 500 >> /etc/php5/fpm/php-fpm.conf
echo request_terminate_timeout = 90s >> /etc/php5/fpm/php-fpm.conf

					;;
					*)
						echo "Don't know what to do for php on this system"
					;;
				esac			
		fi
		;;
	all|mysql)
		if  [ "${choices[$counter]}" == "+" ] ; then
			echo "*** Let's install mysql"
				case $MYDISTRO in
					Debian)
						echo "##### doing the debian setup for mysql"
						
						# setting the MySQL root password
						echo "Please enter a MySQL root password: "
						read MYSQLROOTPASSWORD
						apt-get -y install mysql-server mysql-client

						echo mysql-server-5.1 mysql-server/root_password password $MYSQLROOTPASSWORD | debconf-set-selections
						echo mysql-server-5.1 mysql-server/root_password_again password $MYSQLROOTPASSWORD | debconf-set-selections
					;;
					*)
						echo "Don't know what to do for mysql on this system"
					;;
				esac			
		fi
		;;
	all|gmail)
		if  [ "${choices[$counter]}" == "+" ] ; then
			echo "*** Let's set up the system to use gmail"
				case $MYDISTRO in
					Debian)
						echo "##### doing the debian setup for gmail"
					;;
					*)
						echo "Don't know what to do for gmail on this system"
					;;
				esac			
		fi
		;;
		all|nodejs)
		if  [ "${choices[$counter]}" == "+" ] ; then
			echo "*** Let's install nodejs"
				case $MYDISTRO in
					Debian)
						echo "##### doing the debian setup for nodejs"
						
						apt-get -y install g++ curl libssl-dev apache2-utils git-core python make
						cd /etc
						git clone git://github.com/joyent/node
						cd /etc/node
						./configure
						make
						make install
						echo "Please enter the domain for your nodejs server"
						read NODEJSDOMAIN
						echo "server {
						  listen   80;
						  server_name $NODEJSDOMAIN;
						
						  location / {
							   proxy_set_header X-Real-IP \$remote_addr;
							   proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
							   proxy_set_header Host \$http_host;
							   proxy_set_header X-NginX-Proxy true;
							   proxy_pass http://127.0.0.1:8000/;
							   proxy_redirect off;
						  }
						}" > /etc/nginx/conf.d/node.conf
						
						
						echo "var http = require('http');
						  http.createServer(function (req, res) {
						  res.writeHead(200, {'Content-Type': 'text/plain'});
						  res.end('Rock on!\n');
						}).listen(8000, \"127.0.0.1\");
						console.log('Server running at http://127.0.0.1:8000/');" > /usr/local/bin/nodeserver.js
						
						nohup node /usr/local/bin/nodeserver.js > /var/log/nodejs.log &
					;;
					*)
						echo "Don't know what to do for nodejs on this system"
					;;
				esac			
		fi
		;;
	esac
	let counter=counter+1 
done

