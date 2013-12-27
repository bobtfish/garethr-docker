# == Define: docker:run
#
# A define which manages an upstart managed docker container
#
define docker::run(
  $image,
  $command,
  $memory_limit = '0',
  $ports = [],
  $volumes = [],
  $links = [],
  $use_name = false,
  $running = true,
  $volumes_from = false,
  $username = false,
  $hostname = false,
  $env = [],
  $dns = [],
  $restart_service = true,
) {

  validate_re($image, '^[\S]*$')
  validate_re($title, '^[\S]*$')
  validate_re($memory_limit, '^[\d]*$')
  validate_string($command)
  if $username {
    validate_string($username)
  }
  if $hostname {
    validate_string($hostname)
  }
  validate_bool($running)

  $ports_array = any2array($ports)
  $volumes_array = any2array($volumes)
  $env_array = any2array($env)
  $dns_array = any2array($dns)
  $links_array = any2array($links)

  file { "/etc/init/docker-${title}.conf":
    ensure  => present,
    content => template('docker/etc/init/docker-run.conf.erb')
  }

  service { "docker-${title}":
    ensure     => $running,
    enable     => true,
    status     => "docker ps | grep ${image}",
    hasrestart => true,
    provider   => 'base',
    restart    => "/sbin/stop docker-${title} && /sbin/start docker-${title}", # Upstart won't re-read the config file in all cases unless you stop and start
    start      => "/sbin/start docker-${title}",
    stop       => "/sbin/stop docker-${title}";
  }

  if str2bool($restart_service) {
    File["/etc/init/docker-${title}.conf"] ~> Service["docker-${title}"]
  }
  else {
    File["/etc/init/docker-${title}.conf"] -> Service["docker-${title}"]
  }
}

