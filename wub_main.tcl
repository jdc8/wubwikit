
catch {console show}

if {![catch {package require starkit}]} {
    starkit::startup
} else {
    namespace eval ::starkit {
	variable topdir [file dirname [file normalize [info script]]]
    }
}

proc help { } {
    puts "
Usage:

    wub.kit ?docroot <path>? ?local <path>? ?config <path>?
    wub.kit help
    wub.kit mkconfig <path>

Options:

    config  : set config file, default is file as obtained by mkconfig command
    docroot : set docroot, default is the docroot directory in the Wub source tree
    help    : print this help message
    local   : set local tcl script to be executed when starting the server, by default no such script is executed
    mkconfig: dump default config file to specified path
"
}

set kit_dir [file dirname [file normalize [info script]]]

set docroot [file join $kit_dir lib wub docroot]
set config [file join $kit_dir wub.config]
set local ""

foreach {key val} $argv {
    switch -exact -- $key {
	config -
	docroot -
	local {
	    set $key [file normalize $val]
	}
	help {
	    help
	    exit
	}
	mkconfig {
	    if {[file exists $val]} {
		error "Config file '$val' already exists"
	    }
	    set fi [open [file join $kit_dir wub.config] r]
	    set fo [open $val w]
	    puts $fo [read $fi]
	    close $fi
	    close $fo
	    exit
	}
    }
}

lappend auto_path [file join $kit_dir lib] [file join $kit_dir lib wikitcl] [file join $kit_dir lib wub]

package require Site

# Initialize Site
set wubdocroot $docroot
Site init home [file normalize [file dirname [info script]]] config $config local $local

# Start Site Server(s)
Site start 
