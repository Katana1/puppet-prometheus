# Class prometheus::blackbox_exporter::install
# Install prometheus blackbox_exporter via different methods with parameters from init
# Currently only the install from url is implemented, when Prometheus will deliver packages for some Linux distros I will
# implement the package install method as well
# The package method needs specific yum or apt repo settings which are not made yet by the module
class prometheus::blackbox_exporter::install
{

  case $::prometheus::blackbox_exporter::install_method {
    'url': {
      include staging
      $staging_file = "blackbox_exporter-${prometheus::blackbox_exporter::version}.${prometheus::blackbox_exporter::download_extension}"
      $binary = "${::staging::path}/blackbox_exporter-${::prometheus::blackbox_exporter::version}.${::prometheus::blackbox_exporter::os}-${::prometheus::blackbox_exporter::arch}/blackbox_exporter"
      staging::file { $staging_file:
        source => $prometheus::blackbox_exporter::real_download_url,
      } ->
      staging::extract { $staging_file:
        target  => $::staging::path,
        creates => $binary,
      } ->
      file {
        $binary:
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555';
        "${::prometheus::blackbox_exporter::bin_dir}/blackbox_exporter":
          ensure => link,
          * => $::prometheus::blackbox_exporter::notify_service,
          target => $binary,
      }
    }
    'package': {
      package { $::prometheus::blackbox_exporter::package_name:
        ensure => $::prometheus::blackbox_exporter::package_ensure,
      }
      if $::prometheus::blackbox_exporter::manage_user {
        User[$::prometheus::blackbox_exporter::user] -> Package[$::prometheus::blackbox_exporter::package_name]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${::prometheus::install_method} is invalid")
    }
  }
  if $::prometheus::blackbox_exporter::manage_user {
    ensure_resource('user', [ $::prometheus::blackbox_exporter::user ], {
      ensure => 'present',
      system => true,
      groups => $::prometheus::blackbox_exporter::extra_groups,
    })

    if $::prometheus::blackbox_exporter::manage_group {
      Group[$::prometheus::blackbox_exporter::group] -> User[$::prometheus::blackbox_exporter::user]
    }
  }
  if $::prometheus::blackbox_exporter::manage_group {
    ensure_resource('group', [ $::prometheus::blackbox_exporter::group ], {
      ensure => 'present',
      system => true,
    })
  }
}
