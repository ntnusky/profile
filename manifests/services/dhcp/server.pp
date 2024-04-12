# Installs and configures a DHCP server.
class profile::services::dhcp::server {
  # Determine which search-domain(s) to use:
  $searchdomain = lookup('profile::dhcp::searchdomain', {
    'default_value' => undef,
    'value_type'    => Optional[Stdlib::Fqdn],
  })
  $searchdomains = lookup('profile::dns::searchdomains', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::Fqdn],
  })
  if($searchdomain) {
    $searchdomains_real = $searchdomains + [ $searchdomain ]
  } else {
    $searchdomains_real = $searchdomains
  }

  # Determine which NTP-servers to use
  $ntp_servers = lookup('profile::ntp::servers', {
    'value_type' => Array[Variant[Stdlib::Fqdn, Stdlib::IP::Address]],
    'merge'      => 'unique',
  })

  # Determine which interfaces to run the DHCP-server at; either by simply using 
  # the list of interfaces being configured on the server, or by using the 
  # specific hiera-key.
  $interfaces = keys(lookup('profile::baseconfig::network::interfaces', Hash))
  $dhcp_interfaces = lookup('profile::dhcp::server::interfaces', {
    'value_type'    => Array[String],
    'default_value' => $interfaces,
  })

  # Get the OMAPI settings
  $omapi_name = lookup('profile::dhcp::omapi::name', String)
  $omapi_key = lookup('profile::dhcp::omapi::key', String)
  $omapi_port = lookup('profile::dhcp::omapi::port', {
    'value_type'    => Stdlib::Port,
    'default_value' => 7911,
  })

  # Determine the management-IP for the server; either through the now obsolete
  # hiera-keys, or through the sl2-data:
  #  TODO: Remove the old-fashioned lookups. 
  $man_if = lookup('profile::interfaces::management', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })
  if($man_if) {
    $mip = $facts['networking']['interfaces'][$man_if]['ip']
    $management_ip = lookup("profile::baseconfig::network::interfaces.${man_if}.ipv4.address", {
      'value_type'    => Stdlib::IP::Address::V4,
      'default_value' => $mip,
    })
  } else {
    $management_ip = $::sl2['server']['primary_interface']['ipv4']
  }

  # Get the relevant parameters to configure DHCP classes for PXE/UEFI booting.
  $pxe_server = lookup('profile::dhcp::pxe::server', {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $management_ip,
  })
  $pxe_file = lookup('profile::dhcp::pxe::file', {
    'value_type'    => String,
    'default_value' => 'pxelinux.0',
  })
  $uefi_file = lookup('profile::dhcp::uefi::file', {
    'value_type'    => String,
    'default_value' => 'syslinux.efi',
  })

  $nameservers = lookup('profile::dns::resolvers', {
    'value_type' => Array[Stdlib::IP::Address::V4],
    'merge'      => 'unique',
  })

  $pxe_logic = {
    uefi1 => {
      parameters => [
        'match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00007"',
        "next-server ${pxe_server}",
        "filename \"${uefi_file}\""
      ],
    },
    uefi2 => {
      parameters => [
        'match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00008"',
        "next-server ${pxe_server}",
        "filename \"${uefi_file}\""
      ],
    },
    uefi3 => {
      parameters => [
        'match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00009"',
        "next-server ${pxe_server}",
        "filename \"${uefi_file}\""
      ],
    },
    bios => {
      parameters => [
        'match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00000"',
        "next-server ${pxe_server}",
        "filename \"${pxe_file}\""
      ]
    }
  }

  class { '::dhcp':
    dnssearchdomains => $searchdomains_real,
    interfaces       => $dhcp_interfaces,
    nameservers      => $nameservers,
    ntpservers       => $ntp_servers,
    omapi_key        => $omapi_key,
    omapi_name       => $omapi_name,
    omapi_port       => $omapi_port,
    dhcp_classes     => $pxe_logic,
  }
}
