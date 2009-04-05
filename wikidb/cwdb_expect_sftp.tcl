# arguments: host release script

source cwdb.conf

set timeout -1

spawn sftp $sourceforge_user@frs.sourceforge.net

expect {
    -ex "$sourceforge_user@frs.sourceforge.net's password: " {
    } -re . {
	exp_continue
    }
    default {
	puts "Could not connect to $sourceforge_user@frs.sourceforge.net"
	exit 2
    }
}

exp_send "$sourceforge_password\r"

expect {
    -ex "sftp> " {
    } -re . {
	exp_continue
    }
    default {
	puts "Could not connect to $sourceforge_user@frs.sourceforge.net"
	exit 3
    }    
}

exp_send "cd uploads\r"

expect {
    -ex "sftp> " {
    } -re . {
	exp_continue
    }
    default {
	puts "Could not cd tp uploads"
	exit 4
    }    
}

exp_send "put [lindex $argv 0]\r"

expect {
    -ex "sftp> " {
    } -re . {
	exp_continue
    }
    default {
	puts "Could not upload [lindex $argv 0]"
	exit 4
    }    
}

exp_send "exit\r"

exit 0


