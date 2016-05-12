#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Download Remi repository
remote_file "/tmp/remi-release-6.rpm" do
    source "http://rpms.famillecollet.com/enterprise/remi-release-6.rpm"
    action :create
end

# Install Remi repository
rpm_package "remi-release-6" do
    source "/tmp/remi-release-6.rpm"
    action :install
end

# Install Apache httpd and PHP
%w[
    httpd
    php
    php-mbstring
    php-pear
].each do |pkg|
    package "#{pkg}" do
        action :install
	options '--enablerepo=remi-php56'
    end
end

# make httpd.conf
template "httpd.conf" do
    source "httpd.conf.erb"
    path "/etc/httpd/conf/httpd.conf"
    group "root"
    owner "root"
    mode "0644"
    variables(
        :admin=>node['apache']['admin'],
	:servername=>node['apache']['servername']
    )
end

# start apache
service "httpd" do
    action [ : enable, :start ]
end

# place index.php
cookbook_file "/var/www/html/index.php" do
    source "index.php"
    group "root"
    owner "root"
    mode "0644"
end
