#
# Cookbook:: consul_server
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

node.default['consul']['config']['server'] = true
node.default['consul']['config']['bind_addr'] = node['ipaddress']
node.default['consul']['config']['advertise_addr'] = node['ipaddress']
node.default['consul']['config']['advertise_addr_wan'] = node['ipaddress']
include_recipe 'consul'
