class maestro_nodes::agent(
  $repo,
  $version) {

  include maestro::params

  case $::osfamily {
    'Linux': {
      if ! defined(Package["libxml2-devel"]) {
        package { "libxml2-devel":
          ensure => installed,
        }
      }

      if ! defined(Package["zlib-devel"]) {
        package { "zlib-devel":
          ensure => installed,
        }
     }

     if ! defined(Package["libxslt-devel"]) {
       package { "libxslt-devel":
         ensure => installed,
       }
     }
     if ! defined(Package["rubygems"]) {
       package { "rubygems":
         ensure => installed,
         before => Package["rake"]
       }
     }
    }
    default: {

    }
  }
  
  
  $agent_user = $maestro::params::agent_user
  $agent_group = $maestro::params::agent_group
  $agent_user_home = $maestro::params::agent_user_home
  class { 'maestro::agent':
    repo          => $repo,
    agent_version => $version,
  }

  # Git
  class { git: } ->
  git::resource::config { "agent-gitconfig":
    user     => $agent_user,
    group    => $agent_group,
    root     => $agent_user_home,
    email    => 'info@maestrodev.com',
    realname => 'MaestroDev Demonstration',
  }

  # Subversion
  class { 'svn': }

  # Maven
  class {'maven::maven':
    version => '3.0.4',
  } ->
  maven::settings { $agent_user :
    home                => $agent_user_home,
    user                => $agent_user,
    default_repo_config => $maestro_nodes::repositories::default_repo_config,
    mirrors             => $maestro_nodes::repositories::mirrors,
    servers             => $maestro_nodes::repositories::servers,
    require             => [Class['maestro_nodes::repositories']],
  }

  # Ant
  class { 'ant': }
  class { 'ant::ivy': }
  class { 'ant::tasks::maven': }
  class { 'ant::tasks::sonar': }
  file { "ant.xml":
    path    => "${agent_user_home}/ant.xml",
    owner   => $agent_user,
    group   => $agent_group,
    mode    => 755,
    content => template("maestro_nodes/ant.xml.erb")
  }

  # Rake
  package { 'rake':
    provider => gem,
    ensure => installed,
  }

  # server_key for autoconnect and autoactivate
  file { '.maestro':
    ensure  => directory,
    path    => "${agent_user_home}/.maestro", 
    owner   => $agent_user,
    group   => $agent_group,
    mode    => 700,
  } ->
  file { 'server.key':
    content => 'server_key',
    path    => "${agent_user_home}/.maestro/server.key",
    owner   => $agent_user,
    group   => $agent_group,
    mode    => 600,
  }
 
}
