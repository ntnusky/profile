# This class switches to a simpler io-scheduler for disks listed in hiera. The
# purpose is to make scheduling to SSD's more efficient. 
class profile::baseconfig::ioscheduler {
  $ssds = lookup('profile::disk::ssds', Array[String], 'unique', [])
  $ssdqueue = lookup('profile::disk::ssd::queue', Integer, 'first', 4096) 
  $ssdscheduler = lookup('profile::disk::ssd::scheduler', 
      Enum['noop', 'deadline', 'cfq'], 'first', 'noop')

  $hdds = lookup('profile::disk::hdds', Array[String], 'unique', [])
  $hddqueue = lookup('profile::disk::hdd::queue', Integer, 'first', 512) 
  $hddscheduler = lookup('profile::disk::hdd::scheduler', 
      Enum['noop', 'deadline', 'cfq'], 'first', 'cfq')

  $ssds.each | $ssd | {
    require ::profile::baseconfig::ioscheduler::scripts

    exec { "set ${ssd} to io-scheduler ${ssdscheduler}":
      command => "echo ${ssdscheduler} > /sys/block/${ssd}/queue/scheduler",
      unless  => "verify-io-scheduler.sh ${ssd} ${ssdscheduler}",
      path    => '/usr/local/bin:/bin',
    }
    exec { "set ${ssd} quelength to ${ssdqueue}":
      command => "echo ${ssdqueue} > /sys/block/${ssd}/queue/nr_requests",
      unless  => "verify-io-queue.sh ${ssd} ${ssdqueue}",
      path    => '/usr/local/bin:/bin',
    }
  }

  $hdds.each | $hdd | {
    require ::profile::baseconfig::ioscheduler::scripts

    exec { "set ${hdd} to io-scheduler ${hddscheduler}":
      command => "echo ${hddscheduler} > /sys/block/${hdd}/queue/scheduler",
      unless  => "verify-io-scheduler.sh ${hdd} ${hddscheduler}",
      path    => '/usr/local/bin:/bin',
    }
    exec { "set ${hdd} quelength to ${hddqueue}":
      command => "echo ${hddqueue} > /sys/block/${hdd}/queue/nr_requests",
      unless  => "verify-io-queue.sh ${hdd} ${hddqueue}",
      path    => '/usr/local/bin:/bin',
    }
  }
}
