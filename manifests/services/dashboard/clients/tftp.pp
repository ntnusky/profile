# Configure the dashboard clients for TFTP 
class profile::services::dashboard::clients::tftp {
  require ::profile::services::dashboard::install

  cron { 'Dashboard-client tftp':
    command => "/opt/machineadmin/manage.py create_tftp",
    user    => 'root',
    minute  => '*',
  }
}
