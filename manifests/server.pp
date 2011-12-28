class ossec::server (
  $mailserver_ip,
  $ossec_emailfrom = "ossec@${domain}",
  $ossec_emailto,
  $ossec_active_response = true,
  $ossec_global_host_information_level = 8,
  $ossec_global_stat_level=8,
  $ossec_email_alert_level=7,
  $ossec_ignorepaths = []
) {
	include ossec::common
	
	# install package
	case $architecture {
		"amd64","x86_64": {
			file { "/opt/debs/ossec-hids-server_2.6.0-ubuntu5_amd64.deb":
				owner   => root,
		        group   => root,
		        mode    => 644,
		        ensure  => present,
		        source => "puppet:///modules/ossec/ossec-hids-server_2.6.0-ubuntu5_amd64.deb",
		        require => File["/opt/debs"]
			}
			package { "ossec-hids-server":
		        provider => dpkg,
		        ensure => installed,
		        source => "/opt/debs/ossec-hids-server_2.6.0-ubuntu5_amd64.deb",
		        require => File["/opt/debs/ossec-hids-server_2.6.0-ubuntu5_amd64.deb"]
		    }
		}
		"i386": {
			file { "/opt/debs/ossec-hids-server_2.6.0-ubuntu5_i386.deb":
				owner   => root,
		        group   => root,
		        mode    => 644,
		        ensure  => present,
		        source => "puppet:///modules/ossec/ossec-hids-server_2.6.0-ubuntu5_i386.deb",
		        require => File["/opt/debs"]
			}
			package { "ossec-hids-server":
		        provider => dpkg,
		        ensure => installed,
		        source => "/opt/debs/ossec-hids-server_2.6.0-ubuntu5_i386.deb",
		        require => File["/opt/debs/ossec-hids-server_2.6.0-ubuntu5_i386.deb"]
		    }
		}
		default: { fail("architecture not supported") }
	}
	
	include rsyslog::server
# 	package{ "ossec-hids-server":
#		ensure => present,
#		require => Apt::Repo["ossec"]
#	}
	
	service { "ossec-hids-server":
        ensure => running,
        enable => true,
        hasstatus => true,
        pattern => "ossec-his-server",
        require => Package["ossec-hids-server"],
    }

	# configure ossec
	include concat::setup
	concat { '/var/ossec/etc/ossec.conf':
		owner => root,
		group => ossec,
		mode => 0440,
		require => Package["ossec-hids-server"],
        notify => Service["ossec-hids-server"]
	}
	concat::fragment { "ossec.conf_10" :
                target => '/var/ossec/etc/ossec.conf',
                content => template("ossec/10_ossec.conf.erb"),
                order => 10,
                notify => Service["ossec-hids-server"]
    }
	
#	Concat::Fragment <<| tag == 'ossec' |>>

	concat::fragment { "ossec.conf_90" :
                target => '/var/ossec/etc/ossec.conf',
                content => template("ossec/90_ossec.conf.erb"),
                order => 90,
                notify => Service["ossec-hids-server"]
    }
	
	# get log from rsyslog for apache
	file {"/etc/rsyslog.d/30-ossec.conf":
		ensure  => file,
		group   => root,
		owner   => root,
		source  => "puppet:///modules/ossec/30-ossec.conf",
		notify  => Service['rsyslog'],
		require => Package['rsyslog'],
	}
	
	include concat::setup
	concat { "/var/ossec/etc/client.keys":
		owner   => "root",
		group   => "ossec",
		mode    => "640",
		notify  => Service[ossec-hids-server]
	}
	Ossec::AgentKey<<| |>>
	
	concat::fragment { "var_ossec_etc_client.keys_end" :
		target  => "/var/ossec/etc/client.keys",
		order   => 99,
		content => "\n",
        notify => Service["ossec-hids-server"]
    }

  # bugfix for ossec 2.6.0 (resolve in the ossec git repo)
	file {'/var/ossec/bin/ossec-logtest':
		target => '/var/ossec/ossec-logtest',
		ensure => link,
	}
    
}
