# Configures the puppetmaster
class profile::services::puppet::server::config {
  $puppetca = lookup('profile::puppet::caserver', Stdlib::Fqdn)
  $usepuppetdb = lookup('profile::puppetdb::masterconfig', {
    'value_type'    => Boolean,
    'default_value' => true,
  })
  $puppetdb_hostname = lookup('profile::puppetdb::hostname', Stdlib::Fqdn)
  $management_if = lookup('profile::interfaces::management', String)
  $auto_ip = $::facts['networking']['interfaces'][$management_if]['ip']
  $master_ip = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $auto_ip,
  })
  $dash_url = lookup('profile::dashboard::name::v4only', Stdlib::Fqdn)

  include ::profile::services::puppet::altnames

  if($puppetca == $::fqdn) {
    $template = 'ca.enabled.cfg'
  } else {
    $template = 'ca.disabled.cfg'
  }

  file { '/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem':
    ensure  => 'link',
    owner   => 'puppet',
    group   => 'puppet',
    target  => '/etc/puppetlabs/puppet/ssl/crl.pem',
    replace => false,
    notify  => Service['puppetserver'],
    require => File['/etc/puppetlabs/puppet/ssl/ca'],
  }

  file { '/etc/puppetlabs/puppet/ssl/ca':
    ensure  => 'directory',
    mode    => '0755',
    owner   => 'puppet',
    group   => 'puppet',
    require => Package['puppetserver'],
  }

  file_line { 'Puppetserver listen IP':
    path    => '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
    line    => "    ssl-host: ${master_ip}",
    match   => '    ssl-host: .*',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  file { '/etc/puppetlabs/puppetserver/services.d/ca.cfg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/profile/puppet/${template}",
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  ini_setting { 'Puppetmaster report':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'reports',
    value   => 'http',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  ini_setting { 'Puppetmaster report url':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'reporturl',
    value   => "http://${dash_url}/puppet/report/",
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  ini_setting { 'Puppetmaster autosign':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'autosign',
    value   => '/opt/shiftleader/clients/puppetAutosign.sh',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  ini_setting { 'Puppetmaster node_terminus':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'node_terminus',
    value   => 'exec',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  ini_setting { 'Puppetmaster enc':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'external_nodes',
    value   => '/opt/shiftleader/clients/puppetENC.sh',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  if($usepuppetdb) {
    class { 'puppetdb::master::config':
      puppetdb_server                => $puppetdb_hostname,
      create_puppet_service_resource => false,
    }
  }
}
