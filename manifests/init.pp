# Class: odaijbossslave
#
# This module manages odaijbossslave
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class odaijbossslave (
  $package_url             = "http://",
  $bind_address            = $::ipaddress,
  $deploy_dir              = "/opt/jboss",
  $mode                    = "domain",
  $bind_address_management = $::ipaddress,
  $bind_address_unsecure   = $::ipaddress,
  # $domain_role             = 'master',
  $admin_user              = $::hostname,
  $admin_user_password     = hiera('jbossadminslavepwd', ""),
  $master_ip               = '',) {
  #   $appjboss      = hiera('appjboss', undef)
  package { 'unzip': ensure => present, }

  package { 'bind-utils': ensure => present, }

  notify { "${master_ip}": }

  class { 'opendai_java':
    distribution => 'jdk',
    version      => '6u25',
    repos        => $package_url,
  }

  #  Odaijbossslave::SetMaster <<| tag == $appjboss["tag"] |>>

  #  notify{"${master_ip}":
  #    require => Odaijbossslave::SetMaster['setMasterIP']
  #  }

  class { 'jbossas':
    package_url             => "http://$package_url/",
    bind_address            => $bind_address,
    deploy_dir              => $deploy_dir,
    mode                    => $mode,
    role                    => 'slave',
    bind_address_management => $bind_address_management,
    bind_address_unsecure   => $bind_address_unsecure,
    domain_master_address   => $master_ip,
    #    domain_role             => 'master',
    admin_user              => $admin_user,
    admin_user_password     => $admin_user_password,
    require                 => [Class['opendai_java'], Package['unzip'], Package['bind-utils']],
    before                  => Anchor['odaijbossslave:master_installed'],
  }

  anchor { 'odaijbossslave:master_installed': }

  @@jbossas::add_user { $admin_user:
    password => $admin_user_password,
    tag      => 'app_slave_user'
  }
}
