# This class reads a list of mounts from hiera, and makes sure to define them.
class profile::baseconfig::mounts {
  $mounts = hiera_hash('profile::mounts', {})

  $mounts.each | $path, $options | {
    file { $path:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0700',
    }

    mount { $path:
      require => File[$path],
      *       => $options,
    }
  }
}
