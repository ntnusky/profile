# Optionally install the openstack clients 
class profile::baseconfig::openstackclients {
  $install = lookup('profile::openstack::clients::install', {
    'default_value' => false,
    'value_type'    => Boolean,
  })
  if($install) {
    include ::ntnuopenstack::clients
  }
}
