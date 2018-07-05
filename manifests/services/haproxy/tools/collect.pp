# Adds an entry to the haproxy tools configfile.
define profile::services::haproxy::tools::collect (
){
  require ::profile::services::haproxy::tools

  Concat::Fragment <<| tag == "haproxy-${name}" |>>
}
