#
# Cookbook:: consul-alerts
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

poise_service_user node['consul_alerts']['service_user'] do
  group node['consul_alerts']['service_group']
  shell node['consul_alerts']['service_shell'] unless node['consul_alerts']['service_shell'].nil?
  not_if { node['consul_alerts']['service_user'] == 'root' }
  not_if { node['consul_alerts']['create_service_user'] == false }
end

service_name = node['consul_alerts']['service_name']

consul_alerts_installation node['consul_alerts']['version']

consul_alerts_service service_name do |r|
  user node['consul_alerts']['service_user']
  group node['consul_alerts']['service_group']
  if node['consul_alerts']['service']
    node['consul_alerts']['service'].each_pair { |k, v| r.send(k, v) }
  end
end
