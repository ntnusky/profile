# Common parameters needed by API-checks
class profile::sensu::checks::openstack::params {
  $openstack_admin_api = lookup('ntnuopenstack::endpoint::admin')
  $openstack_public_api = lookup('ntnuopenstack::endpoint::public')

  $barbican = lookup('ntnuopenstack::barbican::keystone::password', {
    'default_value' => false,
  })
  $magnum = lookup('ntnuopenstack::magnum::keystone::password', {
    'default_value' => false,
  })
  $octavia = lookup('ntnuopenstack::octavia::keystone::password', {
    'default_value' => false,
  })
  $swift = lookup('ntnuopenstack::swift::keystone::password', {
    'default_value' => false,
  })

  if($swift) {
    $swiftname = lookup('ntnuopenstack::swift::dns::name', {
      'default_value' => false,
    })
    $certificate = lookup('profile::haproxy::services::webcert', {
      'default_value' => false,
    })
    if($swiftname) {
      if($certificate) {
        $proto='https'
      } else {
        $proto='http'
      }
      $swift_admin = "${proto}://${swiftname}"
      $swift_public = $swift_admin
    } else {
      $swift_admin =  "${openstack_admin_api}:7480"
      $swift_public = "${openstack_public_api}:7480"
    }
  }
}
