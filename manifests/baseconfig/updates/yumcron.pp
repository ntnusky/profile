# Install and configure yum-cron
class profile::baseconfig::updates::yumcron {

  $email_host = lookup('profile::baseconfig::smtp_relay', Stdlib::Fqdn)
  $mailto = lookup('profile::admin::maillist')

  class { '::yum_cron':
    apply_updates => true,
    email_host    => $email_host,
    mailto        => $mailto,
    extra_configs => {
      'commands/upgrade_type' => { 'value' => 'security' }
    },
  }
}
