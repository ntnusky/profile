# Configures the puppetmaster
class profile::services::puppet::server::config {
  $strictness = lookup('profile::puppet::server::strcit', {
    'default_value' => 'warning',
    'value_type'    => String,
  })

  $usepuppetdb = lookup('profile::puppetdb::masterconfig', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  $jvm_memory = lookup('profile::puppet::server::jvm::memory', {
    'value_type' => String,
    'default_value' => '2g',
  })

  # Determine the management-IP for the server; either through the now obsolete
  # hiera-keys, or through the sl2-data:
  #  TODO: Remove the old-fashioned lookups. 
  $man_if = lookup('profile::interfaces::management', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })
  if($man_if) {
    $mip = $facts['networking']['interfaces'][$man_if]['ip']
    $management_ip = lookup("profile::baseconfig::network::interfaces.${man_if}.ipv4.address", {
      'value_type'    => Stdlib::IP::Address::V4,
      'default_value' => $mip,
    })
  } else {
    $management_ip = $::sl2['server']['primary_interface']['ipv4']
  }

  include ::profile::services::puppet::agent
  include ::profile::services::puppet::server::config::ca
  include ::profile::services::puppet::server::config::report
  include ::shiftleader::integration::puppet

  file_line { 'Puppetserver listen IP':
    path    => '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
    line    => "    ssl-host: ${management_ip}",
    match   => '    ssl-host: .*',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  file_line { 'Puppetserver JVM memory':
    path    => '/etc/default/puppetserver',
    line    => "JAVA_ARGS=\"-Xms${jvm_memory} -Xmx${jvm_memory} -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger\"",
    match   => 'JAVA_ARGS=.*',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  if($usepuppetdb) {
    $puppetdb_hostname = lookup('profile::puppetdb::hostname', Stdlib::Fqdn)
    file { '/etc/puppetlabs/puppet/routes.yaml':
      ensure  => 'file',
      mode    => '0644',
      content => stdlib::to_yaml( {
        master => {
          facts => {
            cache    => 'json',
            terminus => 'puppetdb',
          },
        },
      }),
      require => Package['puppetserver']
    }

    ini_setting { 'puppetserver-db-urls':
      ensure  => 'present',
      path    => '/etc/puppetlabs/puppet/puppetdb.conf',
      section => 'main',
      setting => 'server_urls',
      value   => "https://${puppetdb_hostname}:8081/",
      tag     => 'puppetserver-config',
    }

    ini_setting { 'puppetserver-db-softwritefail':
      ensure  => 'present',
      path    => '/etc/puppetlabs/puppet/puppetdb.conf',
      section => 'main',
      setting => 'soft_write_failure',
      value   => false,
      tag     => 'puppetserver-config',
    }

    puppet::config::server {
      'storeconfigs':         value => true;
      'storeconfigs_backend': value => 'puppetdb';
    }
  }

  puppet::config::server { 'strict':
    value => $strictness,
  }
}
