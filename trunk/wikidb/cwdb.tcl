source cwdb.conf

set do_ssh 1
set do_scp 1
set do_check 1
set do_zip 1
set do_checksum 1

if {[llength $argv]} {
    set do_ssh 0
    set do_scp 0
    set do_check 0
    set do_zip 0
    set do_checksum 0
    foreach a $argv {
	if {$a eq "help"} {
	    puts "cwdb.tcl <steps>"
	    puts "  Valid steps:"
	    puts "    ssh     : copy db on wiki.tcl.tk and gzip it"
	    puts "    scp     : copy the copy on wiki.tcl.tk to local host and gunzip it"
	    puts "    check   : check the packed local copy"
	    puts "    zip     : zip the packed local copy"
	    puts "    checksum: calculate checksum for zip of the packed local copy"
	    exit 1
	}
	set do_$a 1
    }
}

set dbnm [format "wikit-%s.tkd" [clock format [clock seconds] -format "%Y%m%d"]]

if {$do_ssh} {
    puts "Copy wikit.tkd on wiki.tcl.tk and gzip it"
    exec expect cwdb_expect.tcl
}

if {$do_scp} { 
    puts "Copy wikit.tkd.gz to local host"
    exec scp $wiki_user@wiki.tcl.tk:wikit.tkd.gz wikit.tkd.gz
    puts "Gunzip wikit.tkd.gz on local host"
    exec gunzip -f wikit.tkd.gz
}

file copy -force wikit.tkd $dbnm

if {$do_zip} {
    puts "Zip $dbnm on local host"
    exec zip $dbnm.zip $dbnm
}

if {$do_checksum} {
    exec md5sum $dbnm.zip > $dbnm.zip.mk5sum
    set f [open $dbnm.zip.mk5sum r]
    puts [read $f]
    close $f
}

exit
