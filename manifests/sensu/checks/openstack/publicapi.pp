# Sensu checks for monitoring public APIs externally
# Should be run on nodes outside of the infrastructure
class profile::sensu::checks::openstack::publicapi inherits profile::sensu::checks::openstack::params {
  $api = $::profile::sensu::checks::openstack::params::openstack_public_api

  sensu::check { 'openstack-identityv3-public-api':
    command     => "check-http.rb -u ${api}:5000/v3",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }
  sensu::check { 'openstack-identity-public-api':
    command     => "check-http.rb -u ${api}:5000/v2.0",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }
  sensu::check { 'openstack-network-public-api':
    command     => "check-http.rb -u ${api}:9696/v2.0 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }
  sensu::check { 'openstack-image-public-api':
    command     => "check-http.rb -u ${api}:9292/v2 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }
  sensu::check { 'openstack-orchestration-public-api':
    command     => "check-http.rb -u ${api}:8004/v1 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }
  sensu::check { 'openstack-volumev3-public-api':
    command     => "check-http.rb -u ${api}:8776/v3 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }
  sensu::check { 'openstack-compute-public-api':
    command     => "check-http.rb -u ${api}:8774/v2.1/v3 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-public-api-checks' ],
  }

  if ($::profile::sensu::checks::openstack::params::swift) {
    $swift_api = $::profile::sensu::checks::openstack::params::swift_public

    sensu::check { 'openstack-swift-public-api':
      command     => "check-http.rb -u ${swift_api}",
      interval    => 300,
      standalone  => false,
      subscribers => [ 'os-public-api-checks' ],
    }
  }
}
