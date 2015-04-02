# == Class: maas
#  Metal as a Service – MAAS – lets you treat physical servers
#  like virtual machines in the cloud. Rather than having to 
#  manage each server individually, MAAS turns your bare metal 
#  into an elastic cloud-like resource.
#  More information can be found here:
#  https://maas.ubuntu.com/docs/
#
#  This Puppet module deploys the MAAS packages and provides puppetized
#  Administration of the MAAS Server/Cluster
#
# Full description of class maas here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# [*version*]
#   Specify a version of MAAS to install
#
# [*ensure*]
#   Valid options are 'present' or 'absent'
#
# [*cloud_archive_release*]
#   Release of the Cloud-archive:tools to use for maas packages
#   Default is currently the OpenStack Juno release
#
# [*profile_name*]
#   The name with which you will later refer to this
#   remote server and credentials within this tool.
#
# [*server_url*]
#   The URL of the remote API, e.g. http://example.com/MAAS/
#   or http://example.com/MAAS/api/1.0/ if you wish to specify the API version.
#
# [*api_version*]
#   Version of the MAAS API to use.   Default is 1.0.
#
#
# [*maas_packages*]
#   Default MAAS Packages to install 
#
# [*maas_superuser*]
#   Default MAAS Root Username
#
# [*maas_superuser_email*]
#   Default MAAS Root User email address
#
# [*maas_superuser_passwd*]
#   Password for the MAAS Root Account
#
# === Examples
#
#  class { 'maas':
#  }
#
# === Authors
#
# Peter J. Pouliot <peter@pouliot.net>
#
# === Copyright
#
# Copyright 2015 Peter J. Pouliot <peter@pouliot.net>, unless otherwise noted.
#
class maas (

  $version               = $maas::params::version,
  $ensure                = $maas::params::ensure,
  $prerequired_packages  = $maas::params::prerequired_packages,
  $cloud_archive_release = $maas::params::cloud_archive_release,
  $profile_name          = $maas::params::profile_name,
  $maas_packages         = $maas::params::maas_packages,
  $superuser_name        = $maas::params::superuser_name,
  $superuser_pass        = $maas::params::superuser_pass,
  $superuser_email       = $maas::params::superuser_email,
  $manage_package        = $maas::params::manage_package,

) inherits maas::params {

  validate_string($version)
  validate_re($::operatingsystem, '(^Ubuntu)$', 'This Module only works on Ubuntu based systems.')
  validate_re($::operatingsystemrelease, '(^12.04|14.04)$', 'This Module only works on Ubuntu releases 12.04 and 14.04.')
  notice("MAAS on node ${::fqdn} is managed by the maas puppet module." )

  if ($cloud_archive_release) {
    validate_string($cloud_archive_release, '^(icehouse|juno|kilo)$', 'This module only supports the IceHouse, Juno and Kilo Releases')
  }

  class{'maas::install':} -> 
  class{'maas::config':}

  contain 'maas::install'
  contain 'maas::config'

  Class['maas'] -> Maas::Superuser <||>
# TODO: Create a define out of import_resources.pp
#  Class['maas'] -> Maas::Import_resources <||>

}
