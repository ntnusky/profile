class profile::munin::plugins {
  munin::plugin { 'apt':
    ensure => link,
  }
}
