define ossec::addlog(
  $logtype='syslog',
  $logfile
) {
  concat::fragment { "ossec.conf_20" :
    target => '/var/ossec/etc/ossec.conf',
    content => template("ossec/20_ossecLogfile.conf.erb"),
    order => 10,
    notify => Service[$ossec::common::hidsserverservice]
  }

}
