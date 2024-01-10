# This class installs and configures both the shiftleader API and frontend.
class profile::services::shiftleader {
  include ::profile::services::shiftleader::haproxy::backend
  include ::shiftleader::web 

  class { '::shiftleader::api':
    puppetapi_cert => false,
    puppetapi_key  => false,
  }
}
