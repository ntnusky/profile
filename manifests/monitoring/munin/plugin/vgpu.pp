# This class installs munin-plugins used to monitor VGPU's
class profile::monitoring::munin::plugin::vgpu {
  require ::profile::monitoring::munin::plugin::vgpu::lib

  $gpus = lookup('nova::compute::vgpu::vgpu_types_device_addresses_mapping')

  $plugins = [
    'vgpu_memory',
    'vgpu_util_decoder',
    'vgpu_util_encoder',
    'vgpu_util_gpu',
    'vgpu_util_memory',
  ]

  $config_data = flatten($gpus.map | $vgpu_type, $addresses | {
    $addresses.map | $address | {
      $id = fqdn_rand(999, "${address} ${vgpu_type}")
      "env.GPU${id} ${address} ${vgpu_type}"
    }
  })

  $plugins.each | $plugin | {
    munin::plugin { $plugin:
      ensure => present,
      source => "puppet:///modules/profile/muninplugins/${plugin}",
      config => [ 'user nova' ] + $config_data,
    }
  }
}
