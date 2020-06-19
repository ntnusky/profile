# Install and configure yum-cron
class profile::baseconfig::updates::yumcron {

  $email_host = lookup('profile::baseconfig::smtp_relay', Stdlib::Fqdn)
  $mailto = lookup('profile::admin::maillist')

  class { '::yum_cron':
    apply_updates => true,
    update_cmd    => 'security',
    email_host    => $email_host,
    mailto        => $mailto,
  }
}
