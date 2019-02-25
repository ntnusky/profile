# Base plugins for all sensu-clients
class profile::sensu::plugins {

  $baseplugins = lookup('profile::sensu::plugins', { merge => unique })

  sensu::plugin { $baseplugins:
    type => 'package',
  }

  sensu::plugin { 'plugins':
    name         => 'puppet:///modules/profile/sensuplugins',
    type         => 'directory',
    install_path => '/etc/sensu/plugins/extra',
  }
}
