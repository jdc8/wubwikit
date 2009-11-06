
catch {console show}

if {![catch {package require starkit}]} {
    starkit::startup
} else {
    namespace eval ::starkit {
	variable topdir [file dirname [file normalize [info script]]]
    }
}

set help(count_pages) {
    Count all pages.
}
set sql(count_pages) {
    SELECT COUNT(*) 
    FROM pages
}

set help(count_empty_pages) {
    Count all empty pages (content size <= 1).
}
set sql(count_empty_pages) {
    SELECT COUNT(*) 
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) < 2
}

set help(non_empty_pages_without_references_to_others) {
    Print list of non-empty pages without any references to other pages.

    Print one line per page with id and page title to standard output. The
    resulting output can be used as input for the [util html|markup] commands
}
set sql(non_empty_pages_without_references_to_others) {
    SELECT a.id, a.name 
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) > 1 
    AND a.id NOT IN (SELECT fromid FROM refs)
}

set help(non_empty_pages_unreferenced_by_others) {
    Print list of non-empty pages not referenced by any other pages.

    Print one line per page with id and page title to standard output. The
    resulting output can be used as input for the [util html|markup] commands
}
set sql(non_empty_pages_unreferenced_by_others) {
    SELECT a.id, a.name 
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) > 1 
    AND a.id NOT IN (SELECT toid FROM refs)
}

set sql(pages_content) {
    SELECT id, content
    FROM pages_content
    WHERE id = :page
}

set help(non_empty_pages) {
    Print list of non-empty pages (content size > 1).

    Print one line per page with id and page title to standard output. The
    resulting output can be used as input for the [util html|markup] commands
}
set sql(non_empty_pages) {
    SELECT a.id, a.name 
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) > 1 
}


set help(empty_pages) {
    Print list of empty pages (content size <= 1).

    Print one line per page with id and page title to standard output. The
    resulting output can be used as input for the [util html|markup] commands
}
set sql(empty_pages) {
    SELECT a.id, a.name 
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) <= 1 
}

set help(references_to_other_pages) {
    Print references found in specified pages to other pages.

    Print one line per page with to-id, from-id and page title to standard output. The
    resulting output can be used as input for the [util html|markup] commands
}
set util_args(references_to_other_pages) "?page <page-id>? ?pages <file>?"
set sql(references_to_other_pages) {
    SELECT a.id, b.fromid, a.name
    FROM pages a, refs b
    WHERE a.id = b.toid
    AND b.fromid = :page
    ORDER BY a.id
}

set help(references_from_other_pages) {
    Print references from other pages to specified pages.

    Print one line per page with from-id, to-id and page title to standard output. The
    resulting output can be used as input for the [util html|markup] commands
}
set util_args(references_from_other_pages) "?page <page-id>? ?pages <file>?"
set sql(references_from_other_pages) {
    SELECT a.id, b.toid, a.name
    FROM pages a, refs b
    WHERE a.id = b.fromid
    AND b.toid = :page
    ORDER BY a.id
}

set sql(ids) {
    SELECT a.id, a.date, b.content, a.name 
    FROM pages a, pages_content b 
    WHERE a.id = b.id
}

proc help { } {
    puts {

Usage of unzippped archive:

    % tclsh wubwikit<version>.vfs/main.tcl <options>

Requirements:

    - tclsh based on Tcl/Tk 8.6
    - package tdbc, part of Tcl/Tk 8.6
    - package tdbc::sqlite3, include in archive
    - package sqlite3 version 3.6.19

Typical usage:

- Create a new wiki database:

    % tclsh wubwikit<version>.vfs/main.tcl mkdb mywiki title "My Wiki"

  This will create 2 files:

      mywiki.tkd      A new wiki database
      mywiki.toc      A new wiki table of contents

- Start a wiki:

    % tclsh wubwikit<version>.vfs/main.tcl wikidb mywiki.tkd toc file:mywiki.toc welcomezero 1

- Start a wiki with a copy of the Tcler's wiki database:

    % tclsh wubwikit<version>.vfs/main.tcl wikidb wikit.tkd

Basic options:
 
  help                                  

    Show this message

  wikidb <path>                         

    Set path to Wiki database. Mandatory!

  mkdb <path> 

    Create empty Wiki database and TOC file.

Options to set Table Of Contents (TOC):

  toc file:<path>                       

    Use the contents of the specified file as table of contents.

Options for Wub:

  port <port>                           

    Set port used by [Wub]

  cmdport <port>                        

    Set command port used by [Wub], you can `telnet` to this port to interface
    with the webserver.

  logfile <file>                        

    Set name of log file

Options to customise your Wiki:

  edit_template file:<path>
  edit_template <text>

    Set text to be used when editing a page for the first time.    

  image <file>                          

    Specify name of image to be added to the wiki. Special image names used in
    the wiki:

        favicon.ico      The favicon
        plume.png        The plume shown top-right, with background color #CCC

  title <text>                          

    Set title to be used on welcome page when the welcome page is base on welcome.html

  url <text>

    Set url of the website (specify without leading http://)

  welcome <file>                        

    Specify html file to be used as welcome page

  welcomezero <boolean>

    When set to true, page 0 from the database will be used as welcome
    page. When set to false, the file 'welcome.html' will be used as welcome
    page.

  readonly <message>

    Run the wiki in read-only mode

  hidereadonly <boolean>

    Run the wiki in read-only mode

  inline_html <boolean>

    Allow use of Inline-html using the <<inlinehtml>> markup

  include_pages <boolean>

    Allow inclusion of other pages using the <<include: >> markup.

  markup_language <wikit|stx>

Utilities:

  util ids

    Print one line per page with page-id, indication if ok or empty and page
    title to standard output. The resulting output can be used as input for the
    [util html|markup] commands

  util html|markup page <page-id> ?opath <path>?

    Print html|markup for specified page to file <opath>/<page-id>.html|txt

  util html|markup pages <file> ?opath <path>?

    Print html|markup for each page specified with its <page-id> in <file> to
    file <opath>/<page-id>.html|txt. Put each page-id as first item on a
    separate line in <file>. The output of other util commands can be used as
    input for this command.
}

foreach k [lsort -dictionary [array names ::sql]] {
    if {$k ni {ids pages_content}} {
	puts -nonewline "  util $k"
	if {[info exists ::util_args($k)]} {
	    puts -nonewline " $::util_args($k)"
	}
	puts ""
	if {[info exists ::help($k)]} {
	    puts $::help($k)
	} else {
	    puts ""
	}
    }
}

}

proc mkdb_exec {sql} {
    set stmt [db prepare $sql]
    set rs [uplevel $stmt execute]
    $rs close
    $stmt close
}

proc mkdb { fnm title } { 

    if {[file exists $fnm.tkd]} {
	error "Database '$fnm.tkd' already exists"
    }

    if {[file exists $fnm.toc]} {
	error "Table of contents '$fnm.toc' already exists"
    }

    tdbc::sqlite3::connection create db $fnm.tkd
    mkdb_exec {PRAGMA foreign_keys = ON}
    mkdb_exec { 
	CREATE TABLE pages (id INT NOT NULL,
			    name TEXT NOT NULL,
			    date INT NOT NULL,
			    who TEXT NOT NULL,
			    PRIMARY KEY (id))
    }
    mkdb_exec { 
	CREATE TABLE pages_content (id INT NOT NULL,
				    content TEXT NOT NULL,
				    PRIMARY KEY (id),
				    FOREIGN KEY (id) REFERENCES pages(id))
    }
    mkdb_exec {
	CREATE TABLE changes (id INT NOT NULL,
			      cid INT NOT NULL,
			      date INT NOT NULL,
			      who TEXT NOT NULL,
			      delta TEXT NOT NULL,
			      PRIMARY KEY (id, cid),
			      FOREIGN KEY (id) REFERENCES pages(id))
    }
    mkdb_exec {
	CREATE TABLE diffs (id INT NOT NULL,
			    cid INT NOT NULL,
			    did INT NOT NULL,
			    fromline INT NOT NULL,
			    toline INT NOT NULL,	
			    old TEXT NOT NULL,
			    PRIMARY KEY (id, cid, did),
			    FOREIGN KEY (id, cid) REFERENCES changes(id, cid))
    }
    mkdb_exec {
	CREATE TABLE refs (fromid INT NOT NULL,
			   toid INT NOT NULL,
			   PRIMARY KEY (fromid, toid),
			   FOREIGN KEY (fromid) references pages(id),
			   FOREIGN KEY (toid) references pages(id))
    }
    mkdb_exec {CREATE INDEX refs_toid_index ON refs (toid)}
    set date [clock seconds]
    set who "init"

    set ids   [list 0                        1           2             3                                             4]
    set names [list $title                  "Page 1"    "Search"      "Help"                                        "Recent Changes"]
    set pages [list "Your Wiki starts here!" "Not used." "Generated." "Your wiki help and formatting rules go here." "Generated."]
    foreach id $ids name $names page $pages {
	mkdb_exec {INSERT INTO pages (id, name, date, who) VALUES (:id, :name, :date, :who)}
	mkdb_exec {INSERT INTO pages_content (id, content) VALUES (:id, :page)}
    }
    foreach id {5 6 7 8 9} {
	set name "Page $id"
	set page "Not used."
	mkdb_exec {INSERT INTO pages (id, name, date, who) VALUES (:id, :name, :date, :who)}
	mkdb_exec {INSERT INTO pages_content (id, content) VALUES (:id, :page)}
    }

    db close

    set f [open $fnm.toc w]
    close $f
    
    puts "Start wubwikit with these options:\n\n    wikidb $fnm.tkd toc file:$fnm.toc welcomezero 1\n"
}

# from "Invoking browsers" in the wiki
proc launchBrowser url {
    global tcl_platform
    
    # It *is* generally a mistake to switch on $tcl_platform(os), particularly
    # in comparison to $tcl_platform(platform).  For now, let's just regard it
    # as a stylistic variation subject to debate.
    switch $tcl_platform(os) {
	Darwin {
	    set command [list open $url]
	}
	HP-UX -
	Linux  -
	SunOS {
	    foreach executable {firefox mozilla netscape iexplorer opera lynx
		w3m links epiphany galeon konqueror mosaic amaya
		browsex elinks} {
		set executable [auto_execok $executable]
		if [string length $executable] {
		    # Do you want to mess with -remote?  How about other browsers?
		    set command [list $executable $url &]
		    break
		}
	    }
	}
	{Windows 95} -
	{Windows NT} {
	    # auto_execok need system vars in uppercase...
	    foreach key [array names ::env] {
		set ::env([string toupper $key]) $::env($key)
	    } 
	    auto_reset
	    set command "[auto_execok start] {} [list $url]"
	}
    }
    if [info exists command] {
	# Replace {*}$command by eval "$command" if you want < tcl 8.5 compatibility ([RA])
        # Added the '&' to launch the browser as background process. [Duoas]
	if [catch {exec {*}$command &} err] {
	    tk_messageBox -icon error -message "error '$err' with '$command'"
	}
    } else {
	tk_messageBox -icon error -message \
	    "Please tell CL that ($tcl_platform(os), $tcl_platform(platform)) is not yet ready for browsing."
    }
}

proc makeGui {port} {
    if {[catch "package require Tk"]} {
        return
    }
    namespace import ::ttk::*
    wm protocol . WM_DELETE_WINDOW { ::exit }
    wm title . "Wiki Server"
    set l [label .lblMsg -text "Wiki server listening on port $port"]
    grid $l -row 0 -column 0 -columnspan 3 -padx 5 -pady 5
    set b [button .btnStop -text "Stop Server" -command "exit"]
    grid  $b -row 1 -column 0 -padx 5 -pady 5
    set b [button .btnOpen -text "Open in browser" -command "launchBrowser http://localhost:$port"]
    grid $b -row 1 -column 1 -padx 5 -pady 5
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
set welcomezero 0
set image_files {}
set title "Welcome to the Tclers Wiki starkit!"
set mkdb 0
set dbfilename ""
set url ""
set util ""
set page ""
set pages ""
set opath ""
set inline_html 0
set include_pages 0
set readonly ""
set hidereadonly 0
set markup_language "wikit"

foreach {key val} $iargv {
    switch -exact -- $key {
	wub -
	port -
	cmdport -
	util -
	page -
	pages - 
	opath -
	readonly -
	hidereadonly -
	inline_html -
	include_pages -
	markup_language -
	title -
	welcomezero {
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
	edit_template { 
	    if { [string match "file:*" $val] } {
		set fnm [string range $val 5 end]
		set f [open $fnm r]
		set val [read $f]
		close $f
	    }
	    set ::starkit_edit_template $val
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
	image {
	    lappend image_files [file normalize $val]
	}
	help {
	    help
	    exit
	}
	mkdb {
	    set mkdb 1
	    set dbfilename $val
	}
	default {
	    lappend argv $key $val
	}
    }
}

if {$mkdb} {
    mkdb $dbfilename $title
    exit
}

if {![info exists twikidb]} {
    error "No wiki database specified, use 'wikidb <file>' option to specify a wiki data base."
}

lappend auto_path [file join $kit_dir lib] [file join $kit_dir lib wikitcl] [file join $kit_dir lib wub]

package require tdbc
package require tdbc::sqlite3

proc get_pages { } {
    global page pages util_dir
    set pl {}
    if {[string length $pages]} {
	set f [open [file join $util_dir $pages] r]
	foreach l [split [read $f] \n] {
	    set l [string trim $l]
	    if {[string length $l]} {
		lappend pl [lindex $l 0]
	    }
	}
    }
    if {[string length $page]} {
	lappend pl {*}$page
    }
    return $pl
}

proc get_pages_html { } {
    global pages port opath page util_dir
    if {[catch {socket localhost $port} msg]} {
	puts "Waiting for server ..."
	after 100 get_pages_html
	return
    }
    package require http
    foreach page [get_pages] {
	set fnm [file join $util_dir $opath $page.html]
	puts [list $page $fnm]
	set tkn [http::geturl http://localhost:$port/$page]
	set o [open $fnm w]
	puts $o [http::data $tkn]
	close $o
	http::cleanup $tkn
    }
    exit
}

proc get_pages_markup { } {
    global sql pages opath page util_dir
    foreach page [get_pages] {
	set fnm [file join $util_dir $opath $page.txt]
	puts [list $page $fnm]
	set o [open $fnm w]
	set stmt [db prepare $sql(pages_content)]
	$stmt foreach -as dicts d {
	    puts -nonewline $o [dict get $d content]
	}
	$stmt close
	close $o
    }
}

proc get_ids { } {
    global sql util
    set stmt [db prepare $sql($util)]
    $stmt foreach -as dicts d {
	puts [list \
		  [dict get $d id] \
		  [expr {([dict get $d date] > 0 && [string length [dict get $d content]] > 1) ? "ok" : "empty"}] \
		  [dict get $d name]
	     ]
    }
    $stmt close
}

proc get_sql_pages { } {
    global sql util
    foreach page [get_pages] {
	set stmt [db prepare $sql($util)]
	$stmt foreach -as lists d {
	    puts $d
	}
    }
    $stmt close
}

proc get_sql { } {
    global sql util
    set stmt [db prepare $sql($util)]
    $stmt foreach -as lists d {
	puts $d
    }
    $stmt close
}

if {[info exists uTOC]} {
    set fnm [file join $kit_dir lib/wikitcl/wubwikit/docroot TOC]
    set f [open $fnm w]
    puts $f $uTOC
    close $f
}

if {[string length $util]} {
    set util_dir [pwd]
    if {$util eq "html"} {
	set wub 1
	get_pages_html
    } else {
	tdbc::sqlite3::connection create db $twikidb
	switch -exact -- $util {
	    ids { get_ids }
	    markup { get_pages_markup }
	    references_to_other_pages -
	    references_from_other_pages { get_sql_pages }
	    default { get_sql }
	}
	db close
	exit
    }
}

makeGui $port    

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

set f [open local.tcl w]
puts $f "set ::WikitWub::inline_html $inline_html"
puts $f "set ::WikitWub::include_pages $include_pages"
puts $f "set ::WikitWub::readonly \{$readonly\}"
puts $f "set ::WikitWub::markup_language $markup_language"
close $f

set ::starkit_wikittitle $title
set ::starkit_welcomezero $welcomezero
set ::starkit_hidereadonly $hidereadonly
if {[string length $url]} {
    set ::starkit_url $url
}

set ::starkit_wikitdbpath $twikidb

if {[string length $welcome_file]} {
    file copy -force $welcome_file [file join $kit_dir lib wikitcl wubwikit docroot html]
}

foreach f $image_files {
    file copy -force $f [file join $kit_dir lib wikitcl wubwikit docroot images]
}

source WikitWub.tcl
