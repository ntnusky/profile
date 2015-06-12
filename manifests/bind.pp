class profile::bind {

  include dns::server

  # Forwarders
  dns::server::options { '/etc/bind/named.conf.options':
    allow_query       => [ '10.10.10.0/24' ],
    forwarders        => [ '128.39.243.10', '128.39.243.11' ]
  }

  # Forward Zone
  dns::zone { 'skyhigh':
    soa         => 'manager.skyhigh',
    soa_email   => 'hostmaster.skyhigh',
    nameservers => ['manager']
  }

  # Reverse Zone
  dns::zone { '10.10.10.IN-ADDR.ARPA':
    soa         => 'manager.skyhigh',
    soa_email   => 'hostmaster.skyhigh',
    nameservers => ['manager']
  }

  # A Records:
  dns::record::a {
    'compute01':    zone => 'skyhigh', data => ['10.10.10.1'],   ptr  => true; 
    'compute02':    zone => 'skyhigh', data => ['10.10.10.2'],   ptr  => true; 
    'compute03':    zone => 'skyhigh', data => ['10.10.10.3'],   ptr  => true; 
    'compute04':    zone => 'skyhigh', data => ['10.10.10.4'],   ptr  => true; 
    'compute05':    zone => 'skyhigh', data => ['10.10.10.5'],   ptr  => true; 
    'compute06':    zone => 'skyhigh', data => ['10.10.10.6'],   ptr  => true; 
    'compute07':    zone => 'skyhigh', data => ['10.10.10.7'],   ptr  => true; 
    'compute08':    zone => 'skyhigh', data => ['10.10.10.8'],   ptr  => true; 
    'compute09':    zone => 'skyhigh', data => ['10.10.10.9'],   ptr  => true; 
    'compute10':    zone => 'skyhigh', data => ['10.10.10.10'],  ptr  => true; 
    'compute11':    zone => 'skyhigh', data => ['10.10.10.11'],  ptr  => true; 
    'compute12':    zone => 'skyhigh', data => ['10.10.10.12'],  ptr  => true; 
    'chiles':       zone => 'skyhigh', data => ['10.10.10.51'],  ptr  => true; 
    'steinbrenner': zone => 'skyhigh', data => ['10.10.10.52'],  ptr  => true; 
    'lippman':      zone => 'skyhigh', data => ['10.10.10.53'],  ptr  => true; 
    'storage01':    zone => 'skyhigh', data => ['10.10.10.101'], ptr  => true; 
    'storage02':    zone => 'skyhigh', data => ['10.10.10.102'], ptr  => true; 
    'storage03':    zone => 'skyhigh', data => ['10.10.10.103'], ptr  => true; 
    'storage04':    zone => 'skyhigh', data => ['10.10.10.104'], ptr  => true; 
    'storage05':    zone => 'skyhigh', data => ['10.10.10.105'], ptr  => true; 
    'storage06':    zone => 'skyhigh', data => ['10.10.10.106'], ptr  => true; 
    'storage07':    zone => 'skyhigh', data => ['10.10.10.107'], ptr  => true; 
    'storage08':    zone => 'skyhigh', data => ['10.10.10.108'], ptr  => true; 
    'tmpspace01':   zone => 'skyhigh', data => ['10.10.10.150'], ptr  => true; 
    'manager':      zone => 'skyhigh', data => ['10.10.10.200'], ptr  => true; 
    'monitor':      zone => 'skyhigh', data => ['10.10.10.201'], ptr  => true; 
  }

  dns::record::mx {
    'mx,0':
      zone       => 'skyhigh',
      preference => 0,
      data       => 'manager.skyhigh';
  }


}
