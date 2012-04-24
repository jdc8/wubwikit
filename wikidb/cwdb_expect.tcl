# arguments: host release script

source cwdb.conf

set timeout -1

spawn ssh $wiki_user@wiki.tcl.tk

expect {
    -ex "\$" {
    } -re . {
	exp_continue
    }
    default {
	puts "Could not connect to wiki.tcl.tk"
	exit 2
    }
}

exp_send "cp /usr/local/wikit/data/wikit.tkd wikit.tkd\r"

expect {
    -ex "\$" {
    } -re . {
	exp_continue
    }
    default {
	puts "Could not copy the db"
	exit 3
    }    
}

exp_send "gzip -f wikit.tkd\r"

expect {
    -ex "\$" {
    } -re . {
	exp_continue
    }
    default {
	puts "Could not gzip the db"
	exit 3
    }    
}

exp_send "exit\r"

exit 0


