#
# Cookbook Name:: uaitinode
# Recipe:: node_server
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe "uaitinode::_common"

package 'nginx' do
	action :install
end

service 'nginx' do
	supports :status => true, :restart => true, :reload => true
end


# template de configuracao do servidor http
directory node['uaitinode']['app_path'] do
	mode '0755'
	recursive true
	action :create
end

template '/etc/nginx/sites-enabled/' + node['uaitinode']['nginx_file'] do
	source 'project.erb'
end
template '/etc/nginx/sites-enabled/default' do
	source 'default.erb'
	manage_symlink_source true
	notifies :reload, 'service[nginx]', :immediately
end


# instala o nvm / nodejs
node.default['nodejs']['install_method'] = 'package'
include_recipe 'nodejs::npm'
nodejs_npm 'bower'
nodejs_npm 'grunt-cli'


# prepara a aplicação para rodar
application node['uaitinode']['project_name'] do
	path node['uaitinode']['app_path']
	owner 'www-data'
	group 'www-data'

	packages ["git"]

	repository node['uaitinode']['app_repository']

	nodejs do
		entry_point node['uaitinode']['entry_point']
	end
end