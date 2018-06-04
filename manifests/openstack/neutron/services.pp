# Installs and configure neutron services
class profile::openstack::neutron::services {
  $fw_driver = hiera('profile::neutron::fwaas_driver')

  require ::profile::openstack::neutron::base
  require ::profile::openstack::repo

  class { '::neutron::services::fwaas':
    enabled => true,
    driver  => $fw_driver,
  }

  neutron_fwaas_service_config {
    'fwaas/agent_version': value => 'v1';
  }

  neutron_l3_agent_config {
    'AGENT/extensions': value => 'fwaas';
  }

  class { 'neutron::services::lbaas':
  }
}
