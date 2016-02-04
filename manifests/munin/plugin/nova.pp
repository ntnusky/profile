class profile::munin::plugin::nova {
  $admin_ip = hiera("profile::api::keystone::admin::ip")
  $admin_token = hiera("profile::keystone::admin_token")
  $admin_pass = hiera("profile::keystone::admin_password")
  $admin_url = "http://${admin_ip}:5000/v2.0/"
  

  munin::plugin { 'nova_cpu':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/nova_cpu',
	config => [ 'user nova',
	  "env.OS_TENANT_NAME admin",
	  "env.OS_USERNAME $admin_token",
	  "env.OS_PASSWORD $admin_pass",
	  "env.OS_AUTH_URL $admin_url"],
  }

  munin::plugin { 'nova_ram':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/nova_ram',
	config => [ 'user nova',
	  "env.OS_TENANT_NAME admin",
	  "env.OS_USERNAME $admin_token",
	  "env.OS_PASSWORD $admin_pass",
	  "env.OS_AUTH_URL $admin_url"],
  }

  munin::plugin { 'nova_disk':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/nova_disk',
	config => [ 'user nova',
	  "env.OS_TENANT_NAME admin",
	  "env.OS_USERNAME $admin_token",
	  "env.OS_PASSWORD $admin_pass",
	  "env.OS_AUTH_URL $admin_url"],
  }
}
