
catch {console show}

package require starkit
starkit::startup

proc help { } {
    puts {

Usage: tclkit wubwikit<version>.kit <options>

Basic options:
 
  help                                  

    Show this message

  port <port>                           

    Set port used by [Wub]

  wikidb <path>                         

    Set path to wiki database. Mandatory!

  wub <boolean>                         

    Run as [Wub] based web-server if true, run as [Tk] application if false (default).

Options to set Table Of Contents (TOC):

  toc file:<path>                       

    Use the contents of the specified file as table of contents in [Wub]
    mode. Copy contents of the specified file to page 8 of the specified wiki
    database to use it as table of contents in [Tk] mode.

  toc wub                               

    Copy table of contents as found in the starkit to page 8 of the specified
    wiki database to use it as table of contents in [Tk] mode.

Options in Wub mode:

  cmdport <port>                        

    Set command port used by [Wub], you can `telnet` to this port to interface
    with the webserver.

  image <file>                          

    Specify name of image to be added to the wiki

  logfile <file>                        

    Set name of log file

  title <text>                          

    Set title to be used on welcome page when the welcome page is base on welcome.html

  welcome <file>                        

    Specify html file to be used as welcome page

  welcomeone <boolean>

    When set to true, page 1 from the database will be used as welcome
    page. When set to false, the file 'welcome.html' will be used as welcome
    page.

Options in Tk mode:

  font_buttonsize <size>                

    Set the size of the font used to display text in buttons. Default is `9` on
    windows and `11` on other platforms.

  font_default <size>                   

    Set the size of the font used to display text. Default is `9` on windows and
    `12` on other platforms.

  font_family <font-family-name>        

    Set the name of the font-family to be used for non fixed-width test. Default
    is `arial`.

  font_fixedfamily <font-family-name>  

    Set the name of the font-familt to be used for fixed-width test. Default is
    `courier`.

  font_thin <size>                      

    Set size of thin font. Default is `4`. This font is used to create
    horizontal lines.

  font_title <size>                     

    Set size of title font. Default is `16`. The title font is also made bold.

  font_title <size3>                    

    Set size of sub-title font. Default is `14`. The sub-title font is also made
    bold and italic.

  font_title <size4>                    

    Set size of sub-sub-title font. Default is `14`. The sub-sub-title font is
    also made italic.
}
}

proc mkdb { fnm } { 

    if {[file exists $fnm.tkd]} {
	error "Database '$fnm.tkd' already exists"
    }

    if {[file exists $fnm.toc]} {
	error "Table of contents '$fnm.toc' already exists"
    }

    set db [mk::file open db $fnm.tkd]

    mk::view layout $db.pages {
	name
	page
	date:I
	who
	{changes {
	    date:I
	    who
	    delta:I
	    {diffs {
		from:I to:I old
	    }}
	}}
    }
    
    mk::view layout $db.refs {from:I to:I}

    # Page 0
    mk::row append $db.pages \
	name "Page 0" \
	page "Not used." \
	date [clock seconds] \
	who init

    # Page 1
    mk::row append $db.pages \
	name "Your wiki start page" \
	page "Your wiki starts here!" \
	date [clock seconds] \
	who init

    # Page 2
    mk::row append $db.pages \
	name "Search" \
	page "Generated." \
	date [clock seconds] \
	who init

    # Page 3
    mk::row append $db.pages \
	name "Help" \
	page "Your wiki help and formatting rules go here." \
	date [clock seconds] \
	who init

    # Page 4
    mk::row append $db.pages \
	name "Recent Changes" \
	page "Generated." \
	date [clock seconds] \
	who init

    # Other reserved pages
    foreach p {5 6 7 8 9} {
	mk::row append $db.pages \
	    name "Page $p" \
	    page "Not used." \
	    date [clock seconds] \
	    who init
    }

    mk::file commit $db

    mk::file close $db

    set f [open $fnm.toc w]
    close $f

    puts "Start wubwikit with these options:\n\n    wub <boolean> wikidb $fnm.tkd toc file:$fnm.toc welcomeone 1\n"
}


set iargv $argv
set argv {}

set kit_dir [file dirname [file normalize [info script]]]

set wub 0
set wubdir [file join $kit_dir lib wub]
set globalroot 0
set home [pwd]
set port 8080
set cmdport 8082
if {[info exists ::env(TEMP)]} {
    set logfile [file join $::env(TEMP) wikit.log]
} elseif {[info exists ::env(TMP)]} {
    set logfile [file join $::env(TMP) wikit.log]
} else {
    set logfile /tmp/wikit.log
}
set welcome_file ""
set welcomeone 0
set image_files {}
set ttitle "Welcome to the Tclers Wiki starkit!"

foreach {key val} $iargv {
    switch -exact -- $key {
	wub -
	port -
	cmdport {
	    set $key $val 
	}
	toc { 
	    if { [string match "file:*" $val] } {
		set fnm [string range $val 5 end]
	    } elseif {$val eq "wub"} {
		set fnm [file join $kit_dir lib/wikitcl/wubwikit/docroot TOC]
	    }
	    set f [open $fnm r]
	    set uTOC [read $f]
	    close $f
	}
	wikidb {
	    set val [file normalize $val]
	    lappend argv $key $val
	    set twikidb $val
	}
        logfile {
	    set val [file normalize $val]
	    lappend argv $key $val
	    set logfile $val
	}
	welcome {
	    set welcome_file [file normalize $val]
	}
	welcomeone {
	    set welcomeone $val
	}
	image {
	    lappend image_files [file normalize $val]
	}
	title {
	    set ttitle $val
	}
	help {
	    help
	    exit
	}
	mkdb {
	    mkdb $val
	    exit
	}
	default {
	    lappend argv $key $val
	}
    }
}

if {![info exists twikidb]} {
    error "No wiki database specified, use 'wikidb <file>' option to specify a wiki data base."
}

lappend auto_path [file join $kit_dir lib] [file join $kit_dir lib wikitcl] [file join $kit_dir lib wub]

if {[info exists uTOC]} {
    if { $wub } { 
	set fnm [file join $kit_dir lib/wikitcl/wubwikit/docroot TOC]
	set f [open $fnm w]
	puts $f $uTOC
	close $f
    } else {
	puts "Adding TOC to $twikidb"
	mk::file open tdb $twikidb
	mk::set tdb.pages!8 name "Wiki TOC" page $uTOC
	mk::file commit tdb
	mk::file close tdb
    }
}

namespace eval Wikit {
    proc getFontInfo { } {
	global font_info
	lappend rl family      $font_info(family)
	lappend rl fixedfamily $font_info(fixedfamily)
	lappend rl title       $font_info(title)
	lappend rl title3      $font_info(title3)
	lappend rl title4      $font_info(title4)
	lappend rl thin        $font_info(thin)
	lappend rl default     $font_info(default)
	lappend rl buttonsize  $font_info(buttonsize)
	return $rl
    }
}

if { $wub } {

    # Args to pass to wub/nub/wikitcl
    # port, cmdport, wikidb

    cd [file join $kit_dir lib wikitcl wubwikit]

    set f [open wikit.ini w]
    puts $f {# Generated ini file, port, cmdport based on command line args
[cache]
high=100
low=90
maxsize=204800
weight_age=0.02
weight_hits=-2.0

[httpd]
}
    puts $f "logfile=$logfile"
    puts $f {max_conn=20
no_really=30
retry_wait=20
timeout=60000
server_port=80
over=200
max=20

[listener]
}
    puts $f "-port=$port"
    puts $f {[scgi]
-port=0
-scgi_send=::scgi Send

[wub]
}
    puts $f "cmdport=$cmdport"
    puts $f {globaldocroot=1
docroot=./docroot
stx_scripting=0
host=localhost

[https]
-port=8081
-tls=

[nub]
nubs=wikit.nub
nubdir=.

[wikitwub]
base=
}
    close $f

    set ::starkit_wikittitle $ttitle
    set ::starkit_welcomeone $welcomeone

    if {[info exists twikidb]} {
        set ::starkit_wikitdbpath $twikidb
    } else {
        set ::starkit_wikitdbpath [file join $kit_dir lib wikitcl wubwikit doc.sample wikit.tkd]
    }

    if {[string length $welcome_file]} {
        file copy -force $welcome_file [file join $kit_dir lib wikitcl wubwikit docroot html]
    }

    foreach f $image_files {
        file copy -force $f [file join $kit_dir lib wikitcl wubwikit docroot images]
    }
    
    source WikitWub.tcl

} else {

    set font_info(family) arial
    set font_info(fixedfamily) courier
    set font_info(title) 16
    set font_info(title3) 14
    set font_info(title4) 14
    set font_info(thin) 4
    if {[string match Windows* $::tcl_platform(os)]} {
	set font_info(default) 9
	set font_info(buttonsize) 9
    } else {
	set font_info(default) 12
	set font_info(buttonsize) 11
    }

    foreach {key val} $argv {
	if { [string match "font_*" $key] } {
	    set font_info([string range $key 5 end]) $val
	} else {
	    set $key $val
	}
    }

    package require struct
    cd [file join $kit_dir lib wikitcl wikit]
    source gui.tcl
    Wikit::WikiDatabase $wikidb
    Wikit::LocalInterface 
    exit
}
