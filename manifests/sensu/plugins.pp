# Base plugins for all sensu-clients
class profile::sensu::plugins {

  $baseplugins = hiera_array('profile::sensu::plugins')

  sensu::plugin { $baseplugins:
    type => 'package',
  }

  sensu::plugin { 'plugins':
    name         => 'puppet:///modules/profile/files/sensuplugins',
    type         => 'directory',
    install_path => '/etc/sensu/plugins/extra',
  }
}
