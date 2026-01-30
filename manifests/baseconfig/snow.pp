# Installs the snow agent
class profile::baseconfig::snow {
  $installsnow = lookup('profile::snow::enabled', {
    'default_value' => false,
    'value_type'    => Boolean,
  })
  if($installsnow) {
    $source = lookup('profile::snow::source', {	
      'default_value' => 'https://repo.it.ntnu.no/snow/04341175_Linux_Standard_Agent-SSL-snowagent-7.4.0-x64.deb',
      'value_type'    => String,
    })
    file { '/opt/snow.deb':
      ensure => file,
      source => $source,
    }
    package { 'snowagent':
      ensure => installed,
      source => '/opt/snow.deb',
      require => File['/opt/snow.deb'],
    }
  }
}
