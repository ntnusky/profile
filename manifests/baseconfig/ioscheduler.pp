# This class switches to a simpler io-scheduler for disks listed in hiera. The
# purpose is to make scheduling to SSD's more efficient. 
class profile::baseconfig::ioscheduler {
  $ssds = lookup('profile::disk::ssds', Array[String], 'unique', [])
  $hdds = lookup('profile::disk::hdds', Array[String], 'unique', [])

  $ssds.each | $ssd | {
    exec { "set ${ssd} to SSD-scheduler":
      command => "echo noop > /sys/block/${ssd}/queue/scheduler",
      unless  => " [[ \
        $(cat /sys/block/${ssd}/queue/scheduler | \
        grep -Eo '\[(.*)\]' | grep -E '[a-z]+' -o) \
        == 'noop' ]]",
      path    => '/bin',
    }
  }

  $hdds.each | $hdd | {
    exec { "set ${hdd} to HDD-scheduler":
      command => "echo deadline > /sys/block/${hdd}/queue/scheduler",
      unless  => " [[ \
        $(cat /sys/block/${hdd}/queue/scheduler | \
        grep -Eo '\[(.*)\]' | grep -E '[a-z]+' -o) \
        == 'deadline' ]]",
      path    => '/bin',
    }
  }
}
