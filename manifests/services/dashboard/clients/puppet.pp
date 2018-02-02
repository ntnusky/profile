# Configure the dashboard for puppet
class profile::services::dashboard::clients::puppet {
  require ::profile::services::dashboard::install

  cron { 'Dashboard-client puppet report clean':
    command => "/opt/shiftleader/manage.py puppet_report_clean",
    user    => 'root',
    minute  => '*',
  }
}
