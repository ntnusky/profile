# Add utility-scripts for haproxy administration
class profile::services::postgresql::scripts {
  $postgres_version = lookup('profile::postgres::version', {
    'default_value' => '9.6',
    'value_type'    => String,
  })

  file { "/usr/local/sbin/postgres-joinMaster.sh":
    ensure  => file,
    mode    => '0755',
    owner   => root,
    group   => root,
    content => epp('profile/postgres-joinMaster.epp', {
      'version' => $postgres_version,
    ),
  }
}
