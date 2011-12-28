#
class ossec::client (
  $ossec_active_response=true,
  $ossec_server_ip
) {
    include ossec::common
	
	# if we are not on the same machine than the server...
	if ($ossec_server_ip != $ipaddress) {
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
	
	  service { "ossec-hids-agent":
        ensure => running,
        enable => true,
        hasstatus => true,
        pattern => "ossec-his-agent",
        require => Package["ossec-hids-agent"],
      }

	  file {"/var/ossec/etc/ossec.conf":
		ensure  => file,
		group   => ossec,
		owner   => root,
		require => Package["ossec-hids-agent"],
        content => template("ossec/ossec_agent.conf.erb"),
        notify => Service["ossec-hids-agent"]
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
        notify  => Service[ossec-hids-agent],
		require => Package["ossec-hids-agent"]
      }
	  ossec::agentKey{ "ossec_agent_${hostname}_client": agent_id=>$uniqueid, agent_name => $hostname, agent_ip_address => $ipaddress}
	  @@ossec::agentKey{ "ossec_agent_${hostname}_server": agent_id=>$uniqueid, agent_name => $hostname, agent_ip_address => $ipaddress}
    }
}


