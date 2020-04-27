# Sensu checks for monitoring admin APIs internally
# Should be run on nodes inside of the infrastructure
class profile::sensu::checks::openstack::adminapi inherits profile::sensu::checks::openstack::params {

  $api = $::profile::sensu::checks::openstack::params::openstack_admin_api
  $script = '/etc/sensu/plugins/extra/check_openstack_api.sh'
  $auth = "${api}:5000/v3"
  $params = "-u :::os.apicheck.user::: -p :::os.apicheck.password::: -k ${auth}"

  sensu::check { 'openstack-identityv3-admin-api':
    command     => "${script} ${params} -e ${api}:5000/v3",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-network-admin-api':
    command     => "${script} ${params} -e ${api}:9696",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-image-admin-api':
    command     => "${script} ${params} -e ${api}:9292/versions",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-orchestration-admin-api':
    command     => "${script} ${params} -e ${api}:8004 -r 300",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-volumev3-admin-api':
    command     => "${script} ${params} -e ${api}:8776/v3/",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-compute-admin-api':
    command     => "${script} ${params} -e ${api}:8774",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-placement-admin-api':
    command     => "${script} ${params} -e ${api}:8778/placement",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }

  if ($::profile::sensu::checks::openstack::params::barbican) {
    sensu::check { 'openstack-key-manager-admin-api':
      command     => "${script} ${params} -e ${api}:9311/v1",
      interval    => 300,
      standalone  => false,
      subscribers => [ 'os-admin-api-checks' ],
    }
  }

  if ($::profile::sensu::checks::openstack::params::octavia) {
    sensu::check { 'openstack-load-balancer-admin-api':
      command     => "${script} ${params} -e ${api}:9876",
      interval    => 300,
      standalone  => false,
      subscribers => [ 'os-admin-api-checks' ],
    }
  }

  if ($::profile::sensu::checks::openstack::params::swift) {
    $swift_api = $::profile::sensu::checks::openstack::params::swift_admin

    sensu::check { 'openstack-swift-admin-api':
      command     => "${script} ${params} -e ${swift_api}",
      interval    => 300,
      standalone  => false,
      subscribers => [ 'os-admin-api-checks' ],
    }
  }

  if ($::profile::sensu::checks::openstack::params::octavia) {
    sensu::check { 'openstack-octavia-admin-api':
      command     => "check-http.rb -u ${api}:9876",
      interval    => 300,
      standalone  => false,
      subscribers => [ 'os-admin-api-checks' ],
    }
  }
}
