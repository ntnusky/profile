class profile::norpf {
  sysctl::value { 'net.ipv4.conf.all.rp_filter':
    value => "0",
  }
  sysctl::value { 'net.ipv4.conf.default.rp_filter':
    value => "0",
  }
}
