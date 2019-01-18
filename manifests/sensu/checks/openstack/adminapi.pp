# Sensu checks for monitoring admin APIs internally
# Should be run on nodes inside of the infrastructure
class profile::sensu::checks::openstack::adminapi inherits profile::sensu::checks::openstack::params {

  $api = $::profile::sensu::checks::openstack::params::openstack_admin_api

  sensu::check { 'openstack-identityv3-admin-api':
    command     => "check-http.rb -u ${api}:35357/v3",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-identity-admin-api':
    command     => "check-http.rb -u ${api}:35357/v2.0",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-network-admin-api':
    command     => "check-http.rb -u ${api}:9696/v2.0 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-image-admin-api':
    command     => "check-http.rb -u ${api}:9292/v2 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-orchestration-admin-api':
    command     => "check-http.rb -u ${api}:8004/v1 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-volumev3-admin-api':
    command     => "check-http.rb -u ${api}:8776/v3 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-compute-admin-api':
    command     => "check-http.rb -u ${api}:8774/v2.1/v3 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }
  sensu::check { 'openstack-placement-admin-api':
    command     => "check-http.rb -u ${api}:8778/placement --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-admin-api-checks' ],
  }

  if ($::profile::sensu::checks::openstack::params::swift) {
    $swift_api = $::profile::sensu::checks::openstack::params::swift_admin

    sensu::check { 'openstack-swift-admin-api':
      command     => "check-http.rb -u ${swift_api}",
      interval    => 300,
      standalone  => false,
      subscribers => [ 'os-admin-api-checks' ],
    }
  }
}
