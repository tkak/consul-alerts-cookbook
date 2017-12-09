resource_name :consul_alerts_installation

default_action :create

property :version, String, name_attribute: true
property :archive_url, String, default: 'https://github.com/AcalephStorage/consul-alerts/releases/download/'
property :extract_to, String, default: '/opt/consul-alerts'

action :create do
  directory ::File.join(new_resource.extract_to, new_resource.version) do
    mode '0755'
    recursive true
  end

  url = ::File.join(new_resource.archive_url, "v#{new_resource.version}", binary_basename(node, new_resource.version))
  poise_archive url do
    destination ::File.join(new_resource.extract_to, new_resource.version)
    strip_components 0
    not_if { ::File.exist?(consul_alerts_program) }
  end

  link '/usr/local/bin/consul-alerts' do
    to ::File.join(new_resource.extract_to, new_resource.version, 'consul-alerts')
  end
end

action_class do
  def consul_alerts_program
    @program ||= ::File.join(new_resource.extract_to, new_resource.version, 'consul-alerts')
  end

  def binary_basename(node, version)
    case node['kernel']['machine']
    when 'x86_64', 'amd64' then ['consul-alerts', version, node['os'], 'amd64'].join('-')
    when /i\d86/ then ['consul-alerts', version, node['os'], '386'].join('-')
    else ['consul-alerts', version, node['os'], node['kernel']['machine']].join('-')
    end.concat('.tar')
  end
end
