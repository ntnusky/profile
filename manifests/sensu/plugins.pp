# Base plugins for all sensu-clients
class profile::sensu::plugins {

  $baseplugins = hiera_array('profile::sensu::plugins')

  sensu::plugin { $baseplugins:
    type => 'package',
  }
}