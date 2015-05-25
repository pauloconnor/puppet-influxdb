# == Class: influxdb::install
# DO NO CALL DIRECTLY
class influxdb::install {
  package { 'influxdb':
    ensure => $influxdb::ensure,
  }
  if !$influxdb::install_from_repository {
    # package source and provider
    if $influxdb::install_dev {
      $package_source = "http://get.influxdb.org/influxdb_0.9.0-rc31_amd64.deb"
    } else {
      $package_source = "http://s3.amazonaws.com/influxdb/influxdb"
    }
    case $::osfamily {
      'Debian': {
        $package_provider = 'dpkg'
        $package_source = $::architecture ? {
          /64/    => "${package_source}_${influxdb::version}_amd64.deb",
          default => "${package_source}_${influxdb::version}_i386.deb",
        }
      }
      'RedHat', 'Amazon': {
        $package_provider = 'rpm'
        $package_source = $::architecture ? {
          /64/    => "${package_source}-${influxdb::version}-1.x86_64.rpm",
          default => "${package_source}-${influxdb::version}-1.i686.rpm",
        }
      }
      default: {
        fail('Only supports Debian or RedHat $::osfamily')
      }
    }

    # get the package
    staging::file { 'influxdb-package':
      source   => $package_source,
    }

    # install the package
    Package['influxdb']{
      provider => $package_provider,
      source   => '/opt/staging/influxdb/influxdb-package',
      require  => Staging::File['influxdb-package'],
    }
  }
}
