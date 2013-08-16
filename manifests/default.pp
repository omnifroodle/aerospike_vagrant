########################################
# resource defaults
Package {
  ensure => present
}

########################################
# Update apt-get before any packages install
exec {"apt-update":
  command => "/usr/bin/apt-get update"
}
Exec["apt-update"] -> Package <| |>

########################################
# install aerospike
notify {"This installs aerospike":}

exec { "unzip-aerospike":
  command => "/bin/tar xvf /vagrant/citrusleaf-community-server-2.6.10-ubuntu12.04.tgz",
  cwd     => "/var/tmp",
  creates => "/var/tmp/citrusleaf-community-server-2.6.10-ubuntu12.04/",
  logoutput => on_failure,
}

exec { "install-aerospike-tools":
  command => "/usr/bin/dpkg -i /var/tmp/citrusleaf-community-server-2.6.10-ubuntu12.04/citrusleaf-tools-2.6.9.ubuntu12.04.x86_64.deb",
  path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/local/sbin/:/usr/sbin/:/sbin/",
  logoutput => on_failure,
}

exec { "install-aerospike-server":
  command => "/usr/bin/dpkg -i /var/tmp/citrusleaf-community-server-2.6.10-ubuntu12.04/citrusleaf-community-server-2.6.10.ubuntu12.04.x86_64.deb",
  creates => "/etc/init.d/citrusleaf",
  path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/local/sbin/:/usr/sbin/:/sbin/",
  logoutput => on_failure,
}

exec { "start-aerospike":
  command => "/etc/init.d/citrusleaf start",
  logoutput => true
}

Exec['unzip-aerospike'] -> Exec['install-aerospike-tools'] -> Exec['install-aerospike-server'] -> Exec['start-aerospike']


########################################
# install clojure

notify {"This installs openjdk and leiningen for clojure":}


package {"openjdk-7-jre-headless":} ->
package {"maven2":}


exec {"install_leiningen":
  command => "/usr/bin/wget https://raw.github.com/technomancy/leiningen/stable/bin/lein \
  && mv lein /usr/bin/ \
  && chmod a+x /usr/bin/lein",
  cwd => '/var/tmp',
  creates => '/usr/bin/lein',
  logoutput => 'on_failure'
}

Package['openjdk-7-jre-headless'] -> Exec['install_leiningen']

package {'emacs23': }

notify{"installs old version of gnu-crypto required by aerospike driver":}

exec {"install gnu-crypto":
  command => "/usr/bin/mvn install:install-file -DgroupId=org.gnu  -DartifactId=gnu-crypto -Dversion=2.0.1 -Dfile=gnu-crypto.jar -Dpackaging=jar -DgeneratePom=true",
  logoutput => "on_failure",
  cwd => "/vagrant",
  user => 'vagrant'
}
