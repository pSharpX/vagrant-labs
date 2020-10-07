#!/bin/sh

## NGINX Installation
## Compiling and Installing from Source

DOWNLOAD_DIRECTORY=/vagrant_resources
WORKSPACE_DIRECTORY=/nginx_installation
NGINX_VERSION=1.18.0
NGINX_FOLDER=nginx-$NGINX_VERSION
NGINX_DOWNLOAD_PATH=https://nginx.org/download/$NGINX_FOLDER.tar.gz
NGINX_PATH=$WORKSPACE_DIRECTORY/$NGINX_FOLDER

mkdir $WORKSPACE_DIRECTORY

## Change dir to the working directory.
cd $DOWNLOAD_DIRECTORY

# Installing NGINX Dependencies
installing_dependencies(){    
    # PCRE – Supports regular expressions. Required by the NGINX Core and Rewrite modules.
    wget -nv https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz && tar -C $WORKSPACE_DIRECTORY -zxf pcre-8.44.tar.gz
    
    # cd pcre-8.44
    # ./configure
    # make
    # sudo make install

    # zlib – Supports header compression. Required by the NGINX Gzip module.
    wget -nv http://zlib.net/zlib-1.2.11.tar.gz && tar -C $WORKSPACE_DIRECTORY -zxf zlib-1.2.11.tar.gz
    
    # cd zlib-1.2.11
    # ./configure
    # make
    # sudo make install

    # OpenSSL – Supports the HTTPS protocol. Required by the NGINX SSL module and others.
    wget -nv http://www.openssl.org/source/openssl-1.1.1g.tar.gz && tar -C $WORKSPACE_DIRECTORY -zxf openssl-1.1.1g.tar.gz
    
    # cd openssl-1.1.1g
    # ./Configure darwin64-x86_64-cc --prefix=/usr
    # make
    # sudo make install

    # Clean up all .tar.gz files. We don't need them anymore
    # rm -rf *.tar.gz
}

nginx_installation(){
    # To download and unpack source files for the latest stable version
    wget -nv $NGINX_DOWNLOAD_PATH && tar -C $WORKSPACE_DIRECTORY -zxf $NGINX_FOLDER.tar.gz
    cd $NGINX_PATH
    echo "Current Directoy: "
    echo "$(pwd)"
    tree -L 2 .

    # Copy NGINX manual page to /usr/share/man/man8/ directory
    echo "******** Copy NGINX manual page to /usr/share/man/man8/ directory"
    sudo cp "$NGINX_PATH"/man/nginx.8 /usr/share/man/man8
    sudo gzip /usr/share/man/man8/nginx.8
    ls /usr/share/man/man8/ | grep nginx.8.gz
    # Check that Man page for NGINX is working:
    man nginx

    # Configure, compile and install NGINX
    echo "******** Configure, compile and install NGINX"
    sudo ./configure --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib/nginx/modules \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --user=vagrant \
            --group=vagrant \
            --build=Ubuntu \
            --builddir=$NGINX_FOLDER \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_xslt_module=dynamic \
            --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_auth_request_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_degradation_module \
            --with-http_slice_module \
            --with-http_stub_status_module \
            --with-http_perl_module=dynamic \
            --with-perl_modules_path=/usr/share/perl/5.26.1 \
            --with-perl=/usr/bin/perl \
            --http-log-path=/var/log/nginx/access.log \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --with-mail=dynamic \
            --with-mail_ssl_module \
            --with-stream=dynamic \
            --with-stream_ssl_module \
            --with-stream_realip_module \
            --with-stream_geoip_module=dynamic \
            --with-stream_ssl_preread_module \
            --with-compat \
            --with-pcre=../pcre-8.44 \
            --with-pcre-jit \
            --with-zlib=../zlib-1.2.11 \
            --with-openssl=../openssl-1.1.1g \
            --with-openssl-opt=no-nextprotoneg \
            --with-debug
    
    # Running making command
    echo "******** Running making command - NGINX"
    sudo make
    # Running make install command
    echo "******** Running make install command - NGINX"
    sudo make install
    # Running nginx
    echo "******** Running NGINX"
    sudo nginx

    # Symlink /usr/lib/nginx/modules to /etc/nginx/modules directory. etc/nginx/modules is a standard place for NGINX modules:
    sudo ln -s /usr/lib/nginx/modules /etc/nginx/modules
}

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'sudo apt update && sudo apt upgrade -y'"
  exit
fi

lsb_release -ds

# Installing optional NGINX dependencies
echo "******** Installing optional NGINX dependencies"
add-apt-repository -y ppa:maxmind/ppa

# sudo apt update && sudo apt upgrade -y
apt update && apt upgrade -y 
apt install -y perl libperl-dev libgd3 libgd-dev libgeoip1 libgeoip-dev geoip-bin libxml2 libxml2-dev libxslt1.1 libxslt1-dev

#  install a compiler tools. Install build-essential, git and tree packages
apt install -y build-essential git tree

# Installing dependencies
echo "******** Installating NGINX Dependencies..."
installing_dependencies

echo "******** Installating NGINX Dependencies..."
nginx_installation

# Print the NGINX version, compiler version, and configure script parameters
echo "******** Print the NGINX version, compiler version, and configure script parameters"
sudo nginx -V

# Create NGINX systemd unit file
echo "******** Create NGINX systemd unit file"

sudo cat << EOF >>/etc/systemd/system/nginx.service
[Unit]
Description=nginx - high performance web server
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=multi-user.target
EOF

# Enable NGINX to start on boot and start NGINX immediately:
echo "******** Enabling NGINX to start on boot and start NGINX immediately:"
sudo systemctl enable nginx.service
sudo systemctl start nginx.service

# Check if NGINX will automatically initiate after a reboot
echo "******** Checking if NGINX will automatically initiate after a reboot"
sudo systemctl is-enabled nginx.service

# Checking if NGINX is running by running one of the following commands 
echo "******** Checking if NGINX is running by running one of the following commands"
sudo systemctl status nginx.service

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"