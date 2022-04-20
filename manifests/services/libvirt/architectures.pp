# This class installs custom CPU-architectures for libvirt guests. We use it to
# allow running modern-ish ISA on even more modern CPU's which have removed
# support for mpx :P
class profile::services::libvirt::architectures {
  $arch = [
    'x86_Icelake-Server-NTNU.xml',
    'x86_Skylake-Server-NTNU.xml',
  ]

  $arch.each | $cpuarch | {
    file { "/usr/share/libvirt/cpu_map/${cpuarch}":
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "puppet:///modules/profile/libvirt/cpu/${cpuarch}",
    }

    xml_fragment { "Libvirt index ${cpuarch}":
      ensure  => 'present',
      path    => '/usr/share/libvirt/cpu_map/index.xml',
      xpath   => "/cpus/arch[@name='x86']/include[@filename='${cpuarch}']",
      content => {
        attributes => {
          'filename' => $cpuarch,
        }
      },
    }
  }
}
