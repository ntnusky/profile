class profile::munin::node {
  munin::plugin { 'apt':
    ensure => link,
  }
}
