class maestro_nodes::puppetenterprise($repo = $maestro::repository::maestrodev, $stomp_port = 61630) {

  $srcdir = '/usr/local/src'

  wget::authfetch { 'fetch-pe':
    user        => $repo['username'],
    password    => $repo['password'],
    source      => "${repo['url']}/com/puppetlabs/pe/puppet-enterprise-el-6-x86_64/2.7.1/puppet-enterprise-el-6-x86_64-2.7.1.tar.gz",
    destination => "${srcdir}/puppet-enterprise-el-6-x86_64-2.7.1.tar.gz",
  } ->
  exec { 'unpack-pe':
    command => 'tar -xvf puppet-enterprise-el-6-x86_64-2.7.1.tar.gz',
    cwd => $srcdir,
    creates => '/usr/local/src/puppet-enterprise-2.7.1-el-6-x86_64',
  } ->
  file { '/usr/local/src/puppet-enterprise-2.7.1-el-6-x86_64/puppet-enterprise-installer-answers.txt':
    source => 'puppet:///modules/maestro_nodes/puppet-enterprise-installer-answers.txt',
  } ->
  exec { 'install-pe':
    command => '/usr/local/src/puppet-enterprise-2.7.1-el-6-x86_64/puppet-enterprise-installer -a puppet-enterprise-installer-answers.txt',
    cwd => '/usr/local/src/puppet-enterprise-2.7.1-el-6-x86_64',
    timeout => 0,
    creates => '/opt/puppet',
  } ->
  file { '/etc/puppetlabs/facter/facts.d/puppet_enterprise_installer.txt':
    content => template("maestro_nodes/puppet_enterprise_installer.txt.erb"),
  } ->
  exec { '/pe-puppet-agent':
    command => '/usr/local/bin/puppet agent --test',
    path => '/usr/local/bin',
  }

}