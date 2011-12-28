class ossec::lightclient {
	include concat::setup
    @@concat::fragment { "ossec.conf_50_${hostname}" :
                target => '/var/ossec/etc/ossec.conf',
                content => template("ossec/50_ossec.conf.erb"),
                order => 50,
                notify => Service["ossec-hids-server"]
    }

	include rsyslog::client
}
