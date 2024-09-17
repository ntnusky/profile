# Defines anchors to aid in the ordering of zabbix installation steps 
class profile::zabbix::deps {
  anchor { 'shiftleader::database::create' : }
}
