#
class ossec::client (
  $ossec_active_response=true,
  $ossec_server_ip
) {
  include ossec::common

  case $lsbdistid {
    /(Ubuntu|ubuntu|Debian|debian)/ : {
      case $architecture {
        "amd64","x86_64": {
	  file { "/opt/debs/ossec-hids-agent_2.6.0-ubuntu1_amd64.deb":
	    owner   => root,
            group   => root,
            mode    => 644,
            ensure  => present,
            source => "puppet:///modules/ossec/ossec-hids-agent_2.6.0-ubuntu1_amd64.deb",
            require => File["/opt/debs"]
	  }
	  package { "ossec-hids-agent":
            provider => dpkg,
            ensure => installed,
            source => "/opt/debs/ossec-hids-agent_2.6.0-ubuntu1_amd64.deb",
            require => File["/opt/debs/ossec-hids-agent_2.6.0-ubuntu1_amd64.deb"]
	  }
        }
        "i386": {
	  file { "/opt/debs/ossec-hids-agent_2.6.0-ubuntu1_i386.deb":
	    owner   => root,
            group   => root,
            mode    => 644,
            ensure  => present,
            source => "puppet:///modules/ossec/ossec-hids-agent_2.6.0-ubuntu1_i386.deb",
            require => File["/opt/debs"]
	  }
	  package { "ossec-hids-agent":
            provider => dpkg,
            ensure => installed,
            source => "/opt/debs/ossec-hids-agent_2.6.0-ubuntu1_i386.deb",
            require => File["/opt/debs/ossec-hids-agent_2.6.0-ubuntu1_i386.deb"]
	  }
        }
        default: { fail("architecture not supported") }
      }
    }
    /(CentOS|RedHat)/ : {
      file { "/opt/rpm/ossec-hids-2.6.0-5.${ossec::common::redhatversion}.${architecture}.rpm":
        owner   => root,
        group   => root,
        mode    => 644,
        ensure  => present,
        source => "puppet:///modules/ossec/ossec-hids-2.6.0-5.${ossec::common::redhatversion}.${architecture}.rpm",
        require => [File["/opt/rpm"],Package['inotify-tools']]
      }
      package { "ossec-hids":
        provider => rpm,
        ensure => installed,
        source => "/opt/rpm/ossec-hids-2.6.0-5.${ossec::common::redhatversion}.${architecture}.rpm",
        require => File["/opt/rpm/ossec-hids-2.6.0-5.${ossec::common::redhatversion}.${architecture}.rpm"]
      }
      file { "/opt/rpm/ossec-hids-client-2.6.0-5.${ossec::common::redhatversion}.${architecture}.rpm":
        owner   => root,
        group   => root,
        mode    => 644,
        ensure  => present,
        source => "puppet:///modules/ossec/ossec-hids-client-2.6.0-5.${ossec::common::redhatversion}.${architecture}.rpm",
        require => File["/opt/rpm"]
      }
      package { $ossec::common::hidsagentpackage:
        provider => rpm,
        ensure => installed,
        source => "/opt/rpm/ossec-hids-client-2.6.0-5.${ossec::common::redhatversion}.${architecture}.rpm",
        require => [File["/opt/rpm/ossec-hids-client-2.6.0-5.${ossec::common::redhatversion}.${architecture}.rpm"],Package['ossec-hids']]
      }
    }
    default: { fail("OS family not supported") }
  }

  service { $ossec::common::hidsagentservice:
    ensure => running,
    enable => true,
    hasstatus => true,
    pattern => $ossec::common::hidsagentservice,
    require => Package[$ossec::common::hidsagentpackage],
  }

  include concat::setup
  concat { '/var/ossec/etc/ossec.conf':
    owner => root,
    group => ossec,
    mode => 0440,
    require => Package[$ossec::common::hidsagentpackage],
    notify => Service[$ossec::common::hidsagentservice]
  }

  concat::fragment { "ossec.conf_10" :
    target => '/var/ossec/etc/ossec.conf',
    content => template("ossec/10_ossec_agent.conf.erb"),
    order => 10,
    notify => Service[$ossec::common::hidsagentservice]
  }
  concat::fragment { "ossec.conf_99" :
    target => '/var/ossec/etc/ossec.conf',
    content => template("ossec/99_ossec_agent.conf.erb"),
    order => 99,
    notify => Service[$ossec::common::hidsagentservice]
  }

  # get log from rsyslog for apache
#	file {"/etc/rsyslog.d/30-ossec_agent.conf":
#		ensure  => file,
#		group   => root,
#		owner   => root,
#		source  => "puppet:///modules/ossec/30-ossec_agent.conf",
#		notify  => Service['rsyslog'],
#		require => Package['rsyslog'],
#	}

  include concat::setup
  concat { "/var/ossec/etc/client.keys":
    owner   => "root",
    group   => "ossec",
    mode    => "640",
    notify  => Service[$ossec::common::hidsagentservice],
    require => Package[$ossec::common::hidsagentpackage]
  }
  ossec::agentKey{ "ossec_agent_${hostname}_client": agent_id=>$uniqueid, agent_name => $hostname, agent_ip_address => $ipaddress}
  @@ossec::agentKey{ "ossec_agent_${hostname}_server": agent_id=>$uniqueid, agent_name => $hostname, agent_ip_address => $ipaddress}
}


