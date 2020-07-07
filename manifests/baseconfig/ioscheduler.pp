# This class switches to a simpler io-scheduler for disks listed in hiera. The
# purpose is to make scheduling to SSD's more efficient. 
class profile::baseconfig::ioscheduler {
  $ssds = lookup('profile::disk::ssds', Array[String], 'unique', [])
  $ssdscheduler = lookup('profile::disk::ssd::scheduler', 
      Enum['noop', 'deadline', 'cfq'], 'first', 'noop')
  $hdds = lookup('profile::disk::hdds', Array[String], 'unique', [])
  $hddscheduler = lookup('profile::disk::hdd::scheduler', 
      Enum['noop', 'deadline', 'cfq'], 'first', 'cfq')

  require ::profile::baseconfig::ioscheduler::scripts

  $ssds.each | $ssd | {
    exec { "set ${ssd} to SSD-scheduler":
      command => "echo ${ssdscheduler} > /sys/block/${ssd}/queue/scheduler",
      unless  => "verify-io-scheduler.sh ${ssd} ${ssdscheduler}",
      path    => '/usr/local/bin:/bin',
    }
  }

  $hdds.each | $hdd | {
    exec { "set ${hdd} to HDD-scheduler":
      command => "echo ${hddscheduler} > /sys/block/${hdd}/queue/scheduler",
      unless  => "verify-io-scheduler.sh ${hdd} ${hddscheduler}",
      path    => '/usr/local/bin:/bin',
    }
  }
}
