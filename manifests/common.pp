
#
#
class ossec::common {
	if (!defined(File['/opt'])) {
		file { "/opt":
			ensure => directory
		}
	}
	if (!defined(File['/opt/debs'])) {
		file { "/opt/debs":
			ensure => directory
		}
	}
	case "${lsbdistid}" {
		/(Ubuntu|ubuntu|Debian|debian)/ : {
		case "${lsbdistcodename}" {
			lucid: { 
				# install package
#				include apt::ppa::ossec
			}
    		default : { fail("This ossec module has not been tested on your distribution") }
			}
		}
    	default : { fail("This ossec module has not been tested on your distribution") }
	}
}

