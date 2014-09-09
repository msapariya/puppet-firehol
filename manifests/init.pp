class firehol {
   $firehol_dir = "/etc/firehol"
   $firehol_services = "$firehol_dir/services"
   $firehol_simple_services = "$firehol_dir/simple_services"
   $firehol_interfaces = "$firehol_dir/interfaces"

   # this will fail unless you have a firehol package available
   package { "firehol":
      ensure => present,

      notify => Service["firehol"],
   }

   service { "firehol":
      enable => true,
      ensure => running,
   }

   file { "$firehol_dir":
      ensure => directory,
      owner => root,
      group => root,
      mode => 0755,

      purge => true,
      recurse => true,
      force => true,
   }

   file { "$firehol_services":
      ensure => directory,
      owner => root,
      group => root,
      mode => 0755,

      purge => true,
      recurse => true,
      force => true,
   }

   file { "$firehol_simple_services":
      ensure => directory,
      owner => root,
      group => root,
      mode => 0755,

      purge => true,
      recurse => true,
      force => true,
   }

   file { "$firehol_interfaces":
      ensure => directory,
      owner => root,
      group => root,
      mode => 0755,

      purge => true,
      recurse => true,
      force => true,
   }

   file { "$firehol_dir/firehol.conf":
      content => template('firehol/firehol.conf.erb'),

      owner => root,
      group => root,
      mode => 644,

      notify => Service["firehol"],
   }
}

define firehol::interface ($interface_alias, $policy="accept", $sources=[], $not_sources=[]) {
   include firehol

   $interface_name = $name
   $interface_dir = "$firehol::firehol_interfaces/$interface_name"
   $interface_conf = "$firehol::firehol_interfaces/$interface_name.conf"

   file { "$interface_dir":
      ensure => directory,
      owner => root,
      group => root,
      mode => 0755,

      purge => true,
      recurse => true,
      force => true,

      require => [
         File["$firehol::firehol_dir"],
      ],

      notify => Service["firehol"],
   }

   file { "$interface_conf":
      content => template("firehol/interface.conf.erb"),
      owner => root,
      group => root,
      mode => 0755,

      require => [
         File["$interface_dir"],
      ],

      notify => Service["firehol"],
   }
}

define firehol::server ($service_name, $interface_name, $policy="accept", $sources=[]) {
   include firehol

   file { "$firehol::firehol_interfaces/$interface_name/server_$service_name.conf":
      content => template("firehol/server.conf.erb"),
      owner => root,
      group => root,
      mode => 0755,

      require => [
         File["$firehol::firehol_interfaces/$interface_name"],
      ],

      notify => Service["firehol"],
   }
}

define firehol::client ($service_name, $interface_name, $policy="accept", $sources=[]) {
   include firehol

   file { "$firehol::firehol_interfaces/$interface_name/client_$service_name.conf":
      content => template("firehol/client.conf.erb"),
      owner => root,
      group => root,
      mode => 0755,

      require => [
         File["$firehol::firehol_interfaces/$interface_name"],
      ],

      notify => Service["firehol"],
   }
}

define firehol::service ($server_ports, $client_ports="default") {
   include firehol

   $service_name = $name

   file { "$firehol::firehol_simple_services/$service_name.conf":
      content => template("firehol/service.conf.erb"),
      owner => root,
      group => root,
      mode => 0755,

      require => [
         File["$firehol::firehol_simple_services"],
      ],

      notify => Service["firehol"],
   }
}
