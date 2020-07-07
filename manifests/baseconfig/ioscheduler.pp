# This class switches to a simpler io-scheduler for disks listed in hiera. The
# purpose is to make scheduling to SSD's more efficient. 
class profile::baseconfig::ioscheduler {
  $ssds = lookup('profile::disk::ssds', Array[String], 'unique', [])
  $hdds = lookup('profile::disk::hdds', Array[String], 'unique', [])

  require ::profile::baseconfig::ioscheduler::scripts

  $ssds.each | $ssd | {
    exec { "set ${ssd} to SSD-scheduler":
      command => "echo noop > /sys/block/${ssd}/queue/scheduler",
      unless  => "verify-io-scheduler.sh ${ssd} noop",
      path    => '/usr/local/bin:/bin',
    }
  }

  $hdds.each | $hdd | {
    exec { "set ${hdd} to HDD-scheduler":
      command => "echo deadline > /sys/block/${hdd}/queue/scheduler",
      unless  => "verify-io-scheduler.sh ${hdd} deadline",
      path    => '/usr/local/bin:/bin',
    }
  }
}
