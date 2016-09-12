# Class prometheus::blackbox_exporter::config
# Configuration class for prometheus blackbox exporter
class prometheus::blackbox_exporter::config(
  $purge = true,
) {

  if $prometheus::blackbox_exporter::init_style {

    case $prometheus::blackbox_exporter::init_style {
      'upstart' : {
        file { '/etc/init/blackbox_exporter.conf':
          mode    => '0444',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/blackbox_exporter.upstart.erb'),
        }
        file { '/etc/init.d/blackbox_exporter':
          ensure => link,
          target => '/lib/init/upstart-job',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
        }
      }
      'systemd' : {
        file { '/lib/systemd/system/blackbox_exporter.service':
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/blackbox_exporter.systemd.erb'),
        }~>
        exec { 'blackbox_exporter-systemd-reload':
          command     => 'systemctl daemon-reload',
          path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
          refreshonly => true,
        }
      }
      'sysv' : {
        file { '/etc/init.d/blackbox_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/blackbox_exporter.sysv.erb')
        }
      }
      'debian' : {
        file { '/etc/init.d/blackbox_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/blackbox_exporter.debian.erb')
        }
      }
      'sles' : {
        file { '/etc/init.d/blackbox_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/blackbox_exporter.sles.erb')
        }
      }
      'launchd' : {
        file { '/Library/LaunchDaemons/io.blackbox_exporter.daemon.plist':
          mode    => '0644',
          owner   => 'root',
          group   => 'wheel',
          content => template('prometheus/blackbox_exporter.launchd.erb')
        }
      }
      default : {
        fail("I don't know how to create an init script for style ${prometheus::blackbox_exporter::init_style}")
      }
    }
  }

  file { 'blackbox.yaml':
    ensure  => present,
    path    => "${prometheus::config_dir}/blackbox.yaml",
    owner   => $prometheus::blackbox_exporter::user,
    group   => $prometheus::blackbox_exporter::group,
    mode    => $prometheus::blackbox_exporter::config_mode,
    content => template('prometheus/blackbox_exporter.yaml.erb'),
    require => File[$prometheus::config_dir],
  }

}
