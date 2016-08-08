class prometheus::consoles {
  # Not thrilling me to do it this way, since we also need to poke the config into prometheus.yaml
  include staging

  file {
    "${::staging::path}/prometheus-${prometheus::version}.${prometheus::os}-${prometheus::arch}/consoles":
      owner => 'root',
      group => 0, # 0 instead of root because OS X uses "wheel".
      mode  => '0555';
    "${::prometheus::config_dir}/consoles":
      ensure => link,
      require => Class['prometheus'],
      target => "${::staging::path}/prometheus-${prometheus::version}.${prometheus::os}-${prometheus::arch}/consoles";
  } ->
  file {
    "${::staging::path}/prometheus-${prometheus::version}.${prometheus::os}-${prometheus::arch}/console_libraries":
      owner => 'root',
      group => 0, # 0 instead of root because OS X uses "wheel".
      mode  => '0555';
    "${::prometheus::config_dir}/console_libraries":
      ensure => link,
      target => "${::staging::path}/prometheus-${prometheus::version}.${prometheus::os}-${prometheus::arch}/console_libraries";
  }

  # Cludge together extra arguments for launching prometheus server
  $::prometheus::extra_options = "${::prometheus::extra_options} -web.console.templates=/etc/prometheus/consoles -web.console.libraries=/etc/prometheus/console_libraries"

}
