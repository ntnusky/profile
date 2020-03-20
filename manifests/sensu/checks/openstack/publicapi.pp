# Sensu checks for monitoring public APIs externally
# Should be run on nodes outside of the infrastructure
class profile::sensu::checks::openstack::publicapi inherits profile::sensu::checks::openstack::params {

  $api = $::profile::sensu::checks::openstack::params::openstack_public_api
  $script = '/etc/sensu/plugins/extra/check_openstack_apis.sh'
  $auth = "${api}:5000/v3"
  $params = "-u :::os.apicheck.user::: -p :::os.apicheck.password::: -k ${auth}"

  sensu::check { 'openstack-identityv3-public-api':
    command     => "${script} ${params} -e ${api}:5000/v3",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }
  sensu::check { 'openstack-network-public-api':
    command     => "${script} ${params} -e ${api}:9696",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }
  sensu::check { 'openstack-image-public-api':
    command     => "${script} ${params} -e ${api}:9292/versions",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }
  sensu::check { 'openstack-orchestration-public-api':
    command     => "${script} ${params} -e ${api}:8004 -r 300",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }
  sensu::check { 'openstack-volumev3-public-api':
    command     => "${script} ${params} -e ${api}:8776",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }
  sensu::check { 'openstack-compute-public-api':
    command     => "${script} ${params} -e ${api}:8774",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }

  if ($::profile::sensu::checks::openstack::params::swift) {
    $swift_api = $::profile::sensu::checks::openstack::params::swift_public

    sensu::check { 'openstack-swift-public-api':
      command     => "${script} ${params} -e ${swift_api}",
      interval    => 300,
      standalone  => false,
      subscribers => [ 'os-public-api-checks' ],
    }
  }
}
