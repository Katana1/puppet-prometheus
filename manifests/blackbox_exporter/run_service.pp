# == Class prometheus::blackbox_exporter::service
#
# This class is meant to be called from prometheus::blackbox_exporter
# It ensure the blackbox_exporter service is running
#
class prometheus::blackbox_exporter::run_service {

  $init_selector = $prometheus::blackbox_exporter::init_style ? {
    'launchd' => 'io.blackbox_exporter.daemon',
    default   => 'blackbox_exporter',
  }

  if $prometheus::blackbox_exporter::manage_service == true {
    service { 'blackbox_exporter':
      ensure => $prometheus::blackbox_exporter::service_ensure,
      name   => $init_selector,
      enable => $prometheus::blackbox_exporter::service_enable,
    }
  }
}
