# This class reads a list of mounts from hiera, and makes sure to define them.
class profile::baseconfig::mounts {
  $mounts = hiera_hash('profile::mounts', false)

  $mounts.each | $path, $options | {
    mount { $path:
      * => $options,
    }
  }
}
