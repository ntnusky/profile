# Installs and configures the keystone identity API.
class profile::openstack::keystone {
  $region = hiera('profile::region')
  $admin_ip = hiera('profile::api::keystone::admin::ip')
  $public_ip = hiera('profile::api::keystone::public::ip')

  $admin_email = hiera('profile::keystone::admin_email')
  $admin_pass = hiera('profile::keystone::admin_password')

  require ::profile::openstack::repo
  require ::profile::openstack::keystone::base
  require ::profile::baseconfig::firewall
  contain ::profile::openstack::keystone::keepalived
  contain ::profile::openstack::keystone::ldap

  firewall { '500 accept incoming admin keystone tcp':
    proto       => 'tcp',
    destination => $admin_ip,
    dport       => [ '5000', '35357' ],
    action      => 'accept',
  }

  firewall { '500 accept incoming public keystone tcp':
    proto       => 'tcp',
    destination => $admin_ip,
    dport       => '5000',
    action      => 'accept',
  }


  class { '::keystone::roles::admin':
    email        => $admin_email,
    password     => $admin_pass,
    admin_tenant => 'admin',
    require      => Class['::keystone'],
  }

  class { '::keystone::endpoint':
    public_url   => "http://${public_ip}:5000",
    admin_url    => "http://${admin_ip}:35357",
    internal_url => "http://${admin_ip}:5000",
    region       => $region,
    require      => Class['::keystone'],
  }

  class { '::keystone::wsgi::apache':
    servername       => $public_ip,
    servername_admin => $admin_ip,
    ssl              => false,
  }
}
