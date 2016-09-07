# == Class:maas::install
#
# class to install an update-to-date version of maas from
# the default package repository or the Cloud-Archive repo
# This installs on Ubunt based distributions only.

class maas::install {
  validate_string($maas::version)
  validate_re($::operatingsystem, '(^Ubuntu)$', 'This Module only works on Ubuntu based systems.')
  validate_re($::operatingsystemrelease, '(^12.04|14.04|16.04)$', 'This Module only works on Ubuntu releases 12.04, 14.04, and 16.04.')
  notice("MAAS installation is occuring on node ${::fqdn}." )


  case $::operatingsystem {
    'Ubuntu':{

      if ($maas::maas_maintainers_release) {
        include apt
        notice("Node ${::fqdn} is using the maas-maintainers ${maas::maas_maintiners_release} package repository for MAAS installation." )
        apt::ppa{"ppa:maas-maintainers/${maas::maas_maintainers_release}":}
        if ($maas::manage_package) {
          Apt::Ppa["ppa:maas-maintainers/${maas::maas_maintainers_release}"] -> Package['maas']
        }
      } else {
        if $maas::version and $maas::ensure != 'absent' {
          $ensure = $maas::version
        } else {
          $ensure = $maas::ensure
        }
      }

      if $maas::version {
        $maaspackage = "${maas::package_name}-${maas::version}"
      } else {
        $maaspackage = $maas::package_name
      }

      if $maas::manage_package {
        package { 'maas':
          ensure => $maas::ensure,
          name   => $maaspackage
        } ->
        package{['maas-dhcp','maas-dns']:
          ensure => $maas::ensure,
        }
        ## A Directory for help with MAAS related command automation
        file {'/etc/maas/.puppet/':
          ensure  => directory,
          require => Package['maas'],
        }
        ## Create MAAS Superuser
        maas::superuser{ $maas::default_superuser:
          password => $maas::default_superuser_password,
          email    => $maas::default_superuser_email,
          require  => Package['maas'],
        }
      }
    }
    default:{
      fail("MAAS does not support installation on your operation system: ${::osfamily} ")
    }
  }
}
