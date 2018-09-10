# Sensu checks for LVM
class profile::sensu::checks::lvm {
  sensu::check { 'lvm-vg-usage':
    command     => 'sudo check-vg-usage.rb -I ":::lvm.vg:::" -w ":::lvm.warn|85:::" -c ":::lvm.crit|95:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'lvm-checks' ],
  }
}
