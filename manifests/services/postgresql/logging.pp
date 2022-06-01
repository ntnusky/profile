# Configure filebeat for postgresql logs 
class profile::services::postgresql::logging {
  $duration = lookup('profile::postgres::log::slow::duration', {
    'default_value' => 1000,
    'value_type'    => Integer,
  })

  require ::profile::services::postgresql::server

  profile::utilities::logging::module { 'postgresql' : }

  postgresql::server::config_entry {
    'log_duration':               value => 'off';
    'log_statement':              value => 'none';
    'log_min_duration_statement': value => $duration;
    'log_checkpoints':            value => 'on';
    'log_connections':            value => 'on';
    'log_disconnections':         value => 'on';
    'log_lock_waits':             value => 'on';
  }
}
