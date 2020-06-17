# A sensu check that checks if nova-compute has increasing failed builds
class profile::sensu::checks::openstack::failedbuilds {
  $db_host = lookup('ntnuopenstack::nova::mysql::ip')
  $db_user = lookup('ntnuopenstack::nova::mysql::user', {
    'default_value' => 'nova',
    'value_type'    => String,
  })

  sensu::check { 'openstack-compute-failed-builds':
    command     => "/etc/sensu/plugins/extra/check_failed_builds.py --host ${db_host} --user ${db_user} --password :::os.nova-db-pw:::",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-compute' ],
  }

  $pymysql_pkg = $::osfamily ? {
    'RedHat' => 'python36-PyMySQL',
    'Debian' => 'python3-pymysql'
    default  => '',
  }

  ensure_packages( [$pymysql_pkg] , {
    'ensure' => 'present',
  })
}
