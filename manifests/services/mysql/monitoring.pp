# Sets up monitoring of the mysql server
class profile::services::mysql::monitoring {

  $install_munin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })
  $install_sensu = lookup('profile::sensu::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  if($install_munin) {
    include ::profile::monitoring::munin::plugin::mysql
  }

  if ($install_sensu) {
    include ::profile::sensu::plugin::mysql
    sensu::subscription { 'mysql': }
  }
}
