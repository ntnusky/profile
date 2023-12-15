# Configures the puppetmaster-integrations to shiftleader for ENC and
# autosigning of certificates.
class profile::services::puppet::server::config::shiftleader {
  $sl_version = lookup('profile::shiftleader::major::version', {
    'default_value' => 1,
    'value_type'    => Integer,
  })

  if($sl_version == 1) {
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
  } else {
    include ::shiftleader::integration::puppet
  }
}
