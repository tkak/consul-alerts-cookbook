resource_name :consul_alerts_service

property :user, String, default: lazy { node['consul_alerts']['service_user'] }
property :group, String, default: lazy { node['consul_alerts']['service_group'] }
property :alert_address, String, default: lazy { node['consul_alerts']['alert_address'] }
property :consul_address, String, default: lazy { node['consul_alerts']['consul_address'] }
property :datacenter, String, default: lazy { node['consul_alerts']['datacenter'] }
property :acl_token, String, default: lazy { node['consul_alerts']['acl_token'] }
property :log_level, String, default: lazy { node['consul_alerts']['log_level'] }
property :program, String, default: '/usr/local/bin/consul-alerts'

action :start do
  create_init

  service 'consul-alerts' do
    supports restart: true, reload: true, status: true
    provider Chef::Provider::Service::Init::Systemd
    action [:enable, :start]
  end
end

action :stop do
  service 'consul-alerts' do
    supports restart: true, reload: true, status: true
    provider Chef::Provider::Service::Init::Systemd
    action :stop
  end
end

action :restart do
  service 'consul-alerts' do
    supports restart: true, reload: true, status: true
    provider Chef::Provider::Service::Init::Systemd
    action :restart
  end
end

action :reload do
  service 'consul-alerts' do
    supports restart: true, reload: true, status: true
    provider Chef::Provider::Service::Init::Systemd
    action :reload
  end
end

action :enable do
  create_init

  service 'consul-alerts' do
    supports restart: true, reload: true, status: true
    provider Chef::Provider::Service::Init::Systemd
    action :enable
  end
end

action :disable do
  service 'consul-alerts' do
    supports restart: true, reload: true, status: true
    provider Chef::Provider::Service::Init::Systemd
    action :disable
  end
end

action_class do
  def create_init
    directory '/etc/systemd/system' do
      owner 'root'
      group 'root'
      mode '0755'
      recursive true
      action :create
    end

    systemd_unit 'consul-alerts.service' do
      content service_unit_content
      action :create
      notifies :restart, 'service[consul-alerts]', :delayed
    end

    service 'consul-alerts' do
      supports restart: true, reload: true, status: true
      provider Chef::Provider::Service::Init::Systemd
      action :nothing
    end
  end

  def service_unit_content
    {
      'Unit' => {
        'Description' => 'consul-alerts daemon',
        'Wants' => 'network.target',
        'After' => 'network.target',
      },
      'Service' => {
        'Restart' => 'on-failure',
        'ExecStart' => "#{new_resource.program} start --watch-events --watch-checks --alert-addr=#{new_resource.alert_address} --consul-addr=#{new_resource.consul_address} --consul-dc=#{new_resource.datacenter} --consul-acl-token='#{new_resource.acl_token}' --log-level=#{new_resource.log_level}",
        'ExecReload' => '/bin/kill -HUP $MAINPID',
        'KillSignal' => 'SIGINT',
      },
      'Install' => {
        'WantedBy' => 'multi-user.target',
      },
    }
  end
end
