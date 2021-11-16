# Install a simple python-lib for the vgpu munin plugins
class profile::monitoring::munin::plugin::vgpu::lib {
  $pkgpath = $facts['operatingsystem'] ? {
    'CentOS' => '/usr/lib/python3.6/site-packages',
    'Ubuntu' => '/usr/lib/python3/dist-packages'
  }

  file { "${pkgpath}/munin_vgpu.py":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/profile/utilities/munin_vgpu.py',
  }
}
