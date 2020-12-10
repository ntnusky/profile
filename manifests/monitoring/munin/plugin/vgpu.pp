# This class installs munin-plugins used to monitor VGPU's
class profile::monitoring::munin::plugin::vgpu {
  require ::profile::monitoring::munin::plugin::vgpu::lib

  $database_host = lookup('profile::anycast::management::ipv4', {
    'value_type'    => String,
  })
  $database_name = lookup('profile::munin::vgpu::database::name', {
    'value_type'    => String,
    'default_value' => 'munin-vgpu',
  })
  $database_user = lookup('profile::munin::vgpu::database::user', {
    'value_type'    => String,
    'default_value' => 'munin-vgpu',
  })
  $database_pass = lookup('profile::munin::vgpu::database::pass', {
    'value_type'    => String,
    'default_value' => '',
  })

  $gpus = lookup('nova::compute::vgpu::vgpu_types_device_addresses_mapping')

  $plugins = [
    'vgpu_memory',
    'vgpu_util_decoder',
    'vgpu_util_encoder',
    'vgpu_util_gpu',
    'vgpu_util_memory',
  ]

  $plugins.each | $plugin | {
    file { "/usr/share/munin/plugins/${plugin}":
      ensure => present,
      mode   => '0755',
      owner  => root,
      group  => root,
      source => "puppet:///modules/profile/muninplugins/${plugin}",
    }
  }

  $config_data = flatten($gpus.map | $vgpu_type, $addresses | {
    $addresses.map | $address | {
      $id = fqdn_rand(999, "${address} ${vgpu_type}")
      "env.GPU${id} ${address} ${vgpu_type}"
    }
  })

  $db_config = [
    "env.DBHOST ${database_host}",
    "env.DBNAME ${database_name}",
    "env.DBUSER ${database_user}",
    "env.DBPASS ${database_pass}",
  ]

  $plugins.each | $plugin | {
    munin::plugin { $plugin:
      ensure  => link,
      target  => $plugin,
      require => File["/usr/share/munin/plugins/${plugin}"],
      config  => [ 'user nova' ] + $config_data + $db_config,
    }
  }
}
