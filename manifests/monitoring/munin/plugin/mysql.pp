# This class installs the munin plugins which monitors mysql statistics 
class profile::monitoring::munin::plugin::mysql {
  ensure_packages ( [
      'libcache-cache-perl',
    ], {
      'ensure' => 'present',
    }
  )
  
  $plugins = [
    'bin_relay_log',
    'commands',
    'connections',
    'files_tables',
    'innodb_bpool',
    'innodb_bpool_act',
    'innodb_insert_buf',
    'innodb_io',
    'innodb_io_pend',
    'innodb_log',
    'innodb_rows',
    'innodb_semaphores',
    'innodb_tnx',
    'myisam_indexes',
    'network_traffic',
    'qcache',
    'qcache_mem',
    'replication',
    'select_types',
    'slow',
    'sorts',
    'table_locks',
    'tmp_tables',
  ]
  $plugins.each |$plugin| {
    munin::plugin { "mysql_${plugin}":
      ensure => link,
      target => 'mysql_',
    }
  }
  munin::plugin { 'mysql_bytes':
    ensure => link,
  }
  munin::plugin { 'mysql_innodb':
    ensure => link,
  }
  munin::plugin { 'mysql_queries':
    ensure => link,
  }
  munin::plugin { 'mysql_slowqueries':
    ensure => link,
  }
  munin::plugin { 'mysql_threads':
    ensure => link,
  }
}
