# = Class name: java7
#
# Puppet module for managing Oracle JDK 7.
# This will install java7 on your debian and ubuntu boxes using update
# alternatives script to setup the path properly.
#
# = Parameters
# version:: the java7 version; 1.7.0_07 by default
class java7($version = '1.7.0_07') {
  $tarball = $::architecture ? {
    'amd64' => "jdk-${version}-linux-x64.tar.gz",
    default => "jdk-${version}-linux-i586.tar.gz",
  }

  package { 'java-common':
    ensure => latest,
  }

  file { 'java-tarball':
    ensure => file,
    path   => "/tmp/${tarball}",
    source => "puppet:///modules/java7/${tarball}",
  }

  exec { 'extract-java-tarball':
    command => "/bin/tar -xvzf ${tarball}",
    cwd     => '/tmp',
    user    => 'root',
    creates => "/tmp/jdk${version}",
    require => File['java-tarball'],
  }

  file { '/usr/lib/jvm':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    require => Exec['extract-java-tarball'],
  }

  exec { 'move-java-directory':
    command => "/bin/cp -r jdk${version} /usr/lib/jvm/jdk${version}",
    creates => "/usr/lib/jvm/jdk${version}",
    cwd     => '/tmp',
    user    => 'root',
    require => File['/usr/lib/jvm'],
    notify  => Exec['alternatives-installer']
  }

  file { '/usr/lib/jvm/java-7-oracle':
    ensure  => link,
    target  => "/usr/lib/jvm/jdk${version}",
    require => Exec['move-java-directory']
  }

  file {'/tmp/alternatives-installer.sh':
    ensure  => 'file',
    source  => 'puppet:///modules/java7/alternatives.sh',
    mode    => '0755',
    require => File['/usr/lib/jvm/java-7-oracle'],
  }

  exec { 'alternatives-installer':
    command     => 'alternatives-installer.sh',
    path        => ['/tmp', '/bin', '/sbin'],
    refreshonly => true,
    require     => File['/tmp/alternatives-installer.sh'],
  }
}
