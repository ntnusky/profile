# This class installs munin-plugins used to monitor VGPU's
class profile::monitoring::munin::plugin::vgpu {
  require ::profile::monitoring::munin::plugin::vgpu::lib

  $plugins = [
    'vgpu_memory',
    'vgpu_util_decoder',
    'vgpu_util_encoder',
    'vgpu_util_gpu',
    'vgpu_util_memory',
  ]

  $plugins.each | $plugin | {
    munin::plugin { $plugin:
      ensure => present,
      source => "puppet:///modules/profile/muninplugins/${plugin}",
      config => ['user nova'],
    }
  }
}
