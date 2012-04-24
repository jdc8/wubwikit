
catch {console show}

if {![catch {package require starkit}]} {
    starkit::startup
} else {
    namespace eval ::starkit {
	variable topdir [file dirname [file normalize [info script]]]
    }
}

set help(count_pages) {Count all pages.}
set sql(count_pages) {
    SELECT COUNT(*) 
    FROM pages
}

set help(count_text_pages) {Count all image pages.}
set sql(count_text_pages) {
    SELECT COUNT(*) 
    FROM pages 
    WHERE type GLOB "text/*" 
    OR type is NULL
}

set help(count_image_pages) {Count all image pages.}
set sql(count_image_pages) {
    SELECT COUNT(*) 
    FROM pages a
    WHERE NOT type GLOB "text/*"
    AND NOT type is NULL
}

set help(count_empty_text_pages) {Count all empty text pages (content size <= 1).}
set sql(count_empty_text_pages) {
    SELECT COUNT(*) 
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) < 2
}

set help(count_non_empty_text_pages) {Count all non empty text pages (content size > 1).}
set sql(count_non_empty_text_pages) {
    SELECT COUNT(*) 
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) > 1
}

set help(count_pages_without_content) {Count without content. This are pages which have a title but haven't got content yet, not even content with size < 1.}
set sql(count_pages_without_content) {
    SELECT COUNT(*)
    FROM pages
    WHERE id NOT IN (SELECT id FROM pages_content)
    AND id NOT IN (SELECT id FROM pages_binary)
}

set help(line_per_page) { Print one line per page with id and page title to standard output. The resulting output can be used as input for the `util html|markup` commands.}

set help(count_non_empty_text_pages_without_references_to_others) {Count non-empty text pages without any references to other pages.}
set sql(count_non_empty_text_pages_without_references_to_others) {
    SELECT COUNT(*)
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) > 1 
    AND a.id NOT IN (SELECT fromid FROM refs)
}

set help(count_non_empty_text_pages_unreferenced_by_others) {Count non-empty text pages not referenced by any other pages.}
set sql(count_non_empty_text_pages_unreferenced_by_others) {
    SELECT COUNT(*)
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) > 1 
    AND a.id NOT IN (SELECT toid FROM refs)
}

set help(count_image_pages_unreferenced_by_others) {Count image pages not referenced by any other pages.}
set sql(count_image_pages_unreferenced_by_others) {
    SELECT COUNT(*)
    FROM pages a, pages_binary b 
    WHERE a.id = b.id 
    AND a.id NOT IN (SELECT toid FROM refs)
}

set help(non_empty_text_pages_without_references_to_others) "Print list of non-empty text pages without any references to other pages.$help(line_per_page)"
set sql(non_empty_text_pages_without_references_to_others) {
    SELECT a.id, a.name 
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) > 1 
    AND a.id NOT IN (SELECT fromid FROM refs)
}

set help(non_empty_text_pages_unreferenced_by_others) "Print list of non-empty text pages not referenced by any other pages.$help(line_per_page)"
set sql(non_empty_text_pages_unreferenced_by_others) {
    SELECT a.id, a.name 
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) > 1 
    AND a.id NOT IN (SELECT toid FROM refs)
}

set help(image_pages_unreferenced_by_others) "Print list of image pages not referenced by any other pages.$help(line_per_page)"
set sql(image_pages_unreferenced_by_others) {
    SELECT a.id, a.name 
    FROM pages a, pages_binary b 
    WHERE a.id = b.id 
    AND a.id NOT IN (SELECT toid FROM refs)
}

set sql(pages_content) {
    SELECT id, content
    FROM pages_content
    WHERE id = :page
}

set help(non_empty_text_pages) "Print list of non-empty text pages (content size > 1).$help(line_per_page)"
set sql(non_empty_text_pages) {
    SELECT a.id, a.name 
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) > 1 
}

set help(binary_ids) "Print list of image text pages.$help(line_per_page)"
set sql(binary_ids) {
    SELECT a.id, a.name, a.type 
    FROM pages a, pages_binary b 
    WHERE a.id = b.id 
}

set help(empty_text_pages) "Print list of empty text pages (content size <= 1).$help(line_per_page)"
set sql(empty_text_pages) {
    SELECT a.id, a.name 
    FROM pages a, pages_content b 
    WHERE a.id = b.id 
    AND length(b.content) <= 1 
}

set help(pages_without_content) "Print list of pages without content. This are pages which have a title but haven't got content yet, not even content with size < 1.$help(line_per_page)"
set sql(pages_without_content) {
    SELECT id, name
    FROM pages
    WHERE id NOT IN (SELECT id FROM pages_content)
    AND id NOT IN (SELECT id FROM pages_binary)
}

set help(references_to_other_pages) "Print references found in specified pages to other pages.$help(line_per_page)"
set util_args(references_to_other_pages) "?page <page-id>? ?pages <file>?"
set sql(references_to_other_pages) {
    SELECT a.id, b.fromid, a.name
    FROM pages a, refs b
    WHERE a.id = b.toid
    AND b.fromid = :page
    ORDER BY a.id
}

set help(references_from_other_pages) "Print references from other pages to specified pages.$help(line_per_page)"
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
    puts {**Usage of unzippped archive:**

 % tclsh wubwikit<version>/main.tcl <options>

**Requirements:**

   * tclsh based on Tcl/Tk 8.6
   * package [tdbc], part of Tcl/Tk 8.6
   * package tdbc::sqlite3 from http://tdbc.tcl.tk, version >= 1.0b16
   * package [sqlite]3, version >= 3.7.3

**Typical usage:**

***Create a new wiki database:***

 % tclsh wubwikit<version>/main.tcl mkdb mywiki.tkd title "My Wiki"

This will create a new wiki database and use the specified title as wiki title.

***Start a wiki:***

 % tclsh wubwikit<version>/main.tcl wikidb mywiki.tkd

***Start a wiki with a copy of the Tcler's wiki database:***

 % tclsh wubwikit<version>/main.tcl wikidb wikit.tkd

**Command line options**

***Basic options:***
 
+++
help  Show this message
wikidb ''<file>''  Set path to Wiki database. Mandatory!
mkdb ''<file>'' title ''<title>''  Create empty Wiki database.
mklocal ''<path>''  Create default Wiki `local.tcl` to configure your Wiki.
mkconfig ''<path>''  Create default Wiki config file to configure the Wub webserver.
mkfts ''<boolean>'' Add full-text-search table to specified wiki-database.
+++

***Configuration options:***

+++
port ''<port>''  Set port used by [Wub], default is 8080.
cmdport ''<port>''  Set command port used by [Wub], you can [telnet] to this port to interface with the webserver, default is 8082.
logfile ''<file>''  Set name of log file
local ''<file>''  Wiki config file to be used for your wiki. The output of the `mklocal` command is used as default.
config ''<file>''  Wub config file to be used for your wiki. The output of the `mkconfig` command is used as default.
+++

***Utilities:***

+++
util ids  Print one line per page with page-id, indication if ok or empty and page title to standard output. The resulting output can be used as input for the `util html|markup` commands.
util html|markup page ''<page-id>'' ''?opath <path>?'' ''?html_ext <html-extension>?''  Print html or markup for specified page to file `<opath>/<page-id><html-extension>|.txt`.
util html|markup pages ''<file>'' ''?opath <path>?'' ''?html_ext <html-extension>?''  Print html or markup for each page specified with its `<page-id>` in `<file>` to file `<opath>/<page-id><html-extension>|.txt`. Put each page-id as first item on a separate line in `<file>`. The output of other util commands can be used as input for this command.
util stats  Print some statistics about the wiki database.}

foreach k [lsort -dictionary [array names ::sql]] {
    if {$k ni {ids pages_content}} {
	puts -nonewline "util $k"
	if {[info exists ::util_args($k)]} {
	    puts -nonewline " ''$::util_args($k)''"
	}
	puts -nonewline "  "
	if {[info exists ::help($k)]} {
	    puts $::help($k)
	} else {
	    puts ""
	}
    }
}

puts {util sql sqlstmt ''<sql statement>''  Execute the SQL statement and print the results}
puts "+++"

}

proc exec_sql_stmt {db stmt} {
    set qs [$db prepare $stmt]
    set rs [$qs execute]
    while {1} {
	while {[$rs nextdict d]} {
	    puts $d
	}
	if {![$rs nextresults]} {
	    break
	}
    }
    $rs close
    $qs close
}

proc mkfts { fnm } {
    tdbc::sqlite3::connection create db $fnm
    catch {exec_sql_stmt db {DROP TABLE pages_content_fts}} msg
    puts $msg
    catch {exec_sql_stmt db {CREATE VIRTUAL TABLE pages_content_fts USING fts4(id,name,content)}} msg
    puts $msg
    catch {exec_sql_stmt db {INSERT INTO pages_content_fts SELECT a.id, a.name, b.content FROM pages a, pages_content b WHERE a.id = b.id}} msg
    puts $msg
    db close
}

proc mkdb { fnm title } { 

    if {[file exists $fnm]} {
	error "Database '$fnm' already exists"
    }

    tdbc::sqlite3::connection create db $fnm
    db allrows {PRAGMA foreign_keys = ON}
    db allrows { 
	CREATE TABLE pages (id INT NOT NULL,
			    name TEXT NOT NULL,
			    date INT NOT NULL,
			    who TEXT NOT NULL,
                            type TEXT,
			    PRIMARY KEY (id))
    }
    db allrows { 
	CREATE TABLE pages_content (id INT NOT NULL,
				    content TEXT NOT NULL,
				    PRIMARY KEY (id),
				    FOREIGN KEY (id) REFERENCES pages(id))
    }
    db allrows {
	CREATE TABLE changes (id INT NOT NULL,
			      cid INT NOT NULL,
			      date INT NOT NULL,
			      who TEXT NOT NULL,
			      delta TEXT NOT NULL,
			      PRIMARY KEY (id, cid),
			      FOREIGN KEY (id) REFERENCES pages(id))
    }
    db allrows {
	CREATE TABLE pages_binary (id INT NOT NULL,
				   content BLOB NOT NULL,
				   PRIMARY KEY (id),
				   FOREIGN KEY (id) REFERENCES pages(id))
    }
    db allrows {
	CREATE TABLE diffs (id INT NOT NULL,
			    cid INT NOT NULL,
			    did INT NOT NULL,
			    fromline INT NOT NULL,
			    toline INT NOT NULL,	
			    old TEXT NOT NULL,
			    PRIMARY KEY (id, cid, did),
			    FOREIGN KEY (id, cid) REFERENCES changes(id, cid))
    }
    db allrows {
	CREATE TABLE changes_binary (id INT NOT NULL,
				     cid INT NOT NULL,
				     date INT NOT NULL,
				     who TEXT NOT NULL,
				     type TEXT,
				     content BLOB NOT NULL,
				     PRIMARY KEY (id, cid),
				     FOREIGN KEY (id) REFERENCES pages(id))
    }
    db allrows {
	CREATE TABLE refs (fromid INT NOT NULL,
			   toid INT NOT NULL,
			   PRIMARY KEY (fromid, toid),
			   FOREIGN KEY (fromid) references pages(id),
			   FOREIGN KEY (toid) references pages(id))
    }
    db allrows {CREATE INDEX refs_toid_index ON refs (toid)}
    db allrows {CREATE INDEX idx_pages_date ON pages(date)}
    set date [clock seconds]
    set who "init"
    
    set ids   [list 0                        1                     2           3            4]
    set names [list $title                   "ADMIN:Welcome"       "ADMIN:TOC" "ADMIN:MOTD" "Help"]
    set pages [list "Your Wiki starts here!" "Welcome page (html)" ""          ""           "Add help for your wiki here"]
    foreach id $ids name $names page $pages {
	db allrows {INSERT INTO pages (id, name, date, who) VALUES (:id, :name, :date, :who)}
	db allrows {INSERT INTO pages_content (id, content) VALUES (:id, :page)}
    }
    db close
}

proc mklocal {fnm} {
    if {[file exists $fnm]} {
	error "Config file '$fnm' already exists"
    }
    file copy $::kit_dir/deflocal.tcl $fnm
}

proc mkconfig {fnm run} {
    if {!$run && [file exists $fnm]} {
	error "Config file '$fnm' already exists"
    }
    global logfile port cmdport host
    set f [open wikit.config.templ r]
    set templ [read $f]
    close $f
    set f [open $fnm w]
    puts $f "
Cache \{
    high 100
    low 90
    maxsize 204800
    weight_age 0.02
    weight_hits -2.0
\}

Httpd \{
    logfile $logfile
    max_conn 100
    retry_wait 20
    timeout 60000
    server_port 80
    over 200
    max 20
    customize ./custom.tcl
\}

Listener \{
    -port $port
\}

Scgi \{
    -port 0
    -scgi_send ::scgi Send
\}

Wub \{
    cmdport $cmdport
    globaldocroot 1
    docroot ./docroot
    stx_scripting 0
    host $host
    logfile $logfile.wub
\}

Https \{
    -port 8081
\}

Shell \{
    load 1
    port $cmdport ;# Console listening socket
\}

Human \{
    load 0
    path /_/
    cookie human
\}
"
    puts $f $templ
    close $f
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

set globalroot 0
set home [pwd]
set port 8080
set cmdport 8082
if {[info exists env(TMP)]} {
    set tmpdir $env(TMP)
} elseif {[info exists env(TEMP)]} {
    set tmpdir $env(TEMP)
} else {
    set tmpdir [file dirname $kit_dir]
}

set logfile [file join $tmpdir wikit.log]
set mkdb 0
set mklocal 0
set mkconfig 0
set mkfts 0
set dbfilename ""
set util ""
set page ""
set pages ""
set opath ""
set local ""
set config ""
set html_ext ".html"
set host "localhost"
set sqlstmt ""

foreach {key val} $iargv {
    switch -exact -- $key {
	wub -
	port -
	cmdport -
	util -
	page -
	pages - 
	title -
	opath -
	sqlstmt -
	html_ext {
	    set $key $val 
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
	local {
	    set $key [file normalize $val]
	}
	config {
	    set $key [file normalize $val]
	}
	help {
	    help
	    exit
	}
	mkdb {
	    set mkdb 1
	    set dbfilename $val
	}
	mklocal {
	    set mklocal 1
	    set localfilename [file normalize $val]
	}
	mkconfig {
	    set mkconfig 1
	    set configfilename [file normalize $val]
	}
	mkfts {
	    set mkfts $val
	}
	default {
	    lappend argv $key $val
	}
    }
}

lappend auto_path [file join $kit_dir lib] [file join $kit_dir lib wikitcl] [file join $kit_dir lib wub]

package require tdbc
package require sqlite3 3.7.5
package require tdbc::sqlite3

if {$mkdb} {
    mkdb $dbfilename $title
    if {$mkfts} {
	mkfts $dbfilename
    }
    exit
}

if {$mklocal} {
    mklocal $localfilename
    exit
}

if {$mkconfig} {
    cd [file join $kit_dir lib wikitcl wubwikit]
    mkconfig $configfilename 0
    exit
}

if {$mkfts} {
    mkfts $twikidb
    exit
}

if {![info exists twikidb]} {
    error "No wiki database specified, use 'wikidb <file>' option to specify a wiki data base."
}

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

proc write_page {o d} {
    puts -nonewline $o [dict get $d -content]
    close $o
    incr ::written
}

proc get_pages_html { } {
    global pages port opath page util_dir html_ext sql written 
    set written 0
    set started 0
    if {[catch {socket localhost $port} msg]} {
	puts "Waiting for server ..."
	after 100 get_pages_html
	return
    }
    package require HTTP
    set bin {}
    db foreach -as dicts d $sql(binary_ids) {
	set t [dict get $d type]
	if {[string length $t] && ![string match "text/*" $t]} {
	    lappend bin [dict get $d id]
	}
    }
    foreach page [get_pages] {
	set fnm [file join $util_dir $opath $page$html_ext]
	puts [list $page $fnm]
	set o [open $fnm w]
	fconfigure $o -encoding binary -translation binary
	set obj [HTTP new http://localhost:$port/ [list write_page $o]]
	incr started
	$obj get $page
	if {$page in $bin} {
	    set fnm [file join $util_dir $opath image_$page]
	    puts [list $page $fnm]
	    set o [open $fnm w]
	    fconfigure $o -encoding binary -translation binary
	    db foreach -as dicts d {SELECT content FROM pages_binary WHERE id = :page} {
		puts $o [dict get $d content]
	    }
	    close $o
	}
    }
    while {$written != $started} {
	puts "$started/$written"
	update
    }
    exit
}

proc get_pages_markup { } {
    global sql pages opath page util_dir
    set stmt [db prepare $sql(pages_content)]
    foreach page [get_pages] {
	set fnm [file join $util_dir $opath $page.txt]
	puts [list $page $fnm]
	set o [open $fnm w]
	$stmt foreach -as dicts d {
	    puts -nonewline $o [dict get $d content]
	}
	close $o
    }
    $stmt close
}

proc get_ids { } {
    global sql util
    db foreach -as dicts d $sql($util) {
	puts [list \
		  [dict get $d id] \
		  [expr {$util eq "ids" ? (([dict get $d date] > 0 && [string length [dict get $d content]] > 1) ? "ok" : "empty") : [dict get $d type]}] \
		  [dict get $d name]
	     ]
    }
}

proc get_sql_pages { } {
    global sql util
    set stmt [db prepare $sql($util)]
    foreach page [get_pages] {
	$stmt foreach -as lists d {
	    puts $d
	}
    }
    $stmt close
}

proc get_sql { txt } {
    global sql util
    db foreach -as lists l $sql($util) {
 	puts "$txt[string map {\n \\n} $l]"
    }
}

proc residual_changes_per_day { } {
    package require Tk
    package require Plotchart

    canvas .c  -background white -width 800 -height 600
    pack .c -fill both
    
    set s [::Plotchart::createXYPlot .c {900000000.0 1210000000.0 100000000.0} {0.0 80.0 10.0}]
    
    $s dataconfig series1 -colour "red" -type symbol -symbol cross
    $s xtext "Time"
    $s ytext "Edit count"
    $s title "Residual changes per day"
    
    db foreach -as dicts d {SELECT date FROM pages} {
	set date [dict get $d date]
	incr rd([expr $date-($date%86400)]) 1
    }
    
    foreach k [array names rd] {
	$s plot series1 $k $rd($k)
    }

    db close
    vwait forever
}

proc last_change_for_page_graph { } {
    package require Tk
    package require Plotchart

    canvas .c  -background white -width 800 -height 600
    pack .c -fill both
    
    set s [::Plotchart::createXYPlot .c {0.0 22000.0 2000.0} {900000000.0 1210000000.0 100000000.0}]

    $s dataconfig series1 -colour "red" -type symbol -symbol cross
    $s ytext "Time"
    $s xtext "Page number"
    $s title "Page/last-edit graph"

    db foreach -as dicts d {SELECT id, date FROM pages} {
	$s plot series1 [dict get $d id] [dict get $d date]
    }

    db close
    vwait forever
}

proc most_edited { sdate } {
    set edl {}
    db foreach -as dicts d {SELECT id, name FROM pages WHERE date > :sdate} {
	set id [dict get $d id]
	set ed 1
	db foreach -as dicts c {SELECT COUNT(*) FROM changes WHERE id = :id AND date > :sdate} {
	    incr ed [dict get $c COUNT(*)]
	}
	lappend edl [list $id $ed [dict get $d name]]
    }
    
    set edl [lsort -decreasing -index 1 -integer $edl]
    
    set cnt 0
    
    puts "%|'''Number of page'''|'''Number of edits'''|'''Page name'''|%"
    
    foreach edsl $edl {
	lassign $edsl page count name
	puts "&|[format %5d $page]|[format %5d $count]|\[$name\]|&"
	incr cnt
	if { $cnt > 20 } { 
	    break
	}
    }
}

if {[string length $util]} {
    set util_dir [pwd]
    tdbc::sqlite3::connection create db $twikidb
    if {$util eq "html"} {
	get_pages_html
    } else {
	switch -exact -- $util {
	    sql { exec_sql_stmt db $sqlstmt }
	    ids { get_ids }
	    binary_ids { get_ids }
	    markup { get_pages_markup }
	    references_to_other_pages -
	    references_from_other_pages { get_sql_pages }
	    last_change_for_page_graph { last_change_for_page_graph }
	    residual_changes_per_day { residual_changes_per_day }
	    most_edited_ever { most_edited -1}
	    most_edited_last_month { most_edited [expr {[clock seconds]-30*24*60*60}] }
	    stats {
		foreach util {
		    count_pages
		    count_text_pages
		    count_image_pages
		    count_non_empty_text_pages
		    count_empty_text_pages
		    count_pages_without_content
		    count_non_empty_text_pages_without_references_to_others
		    count_non_empty_text_pages_unreferenced_by_others
		    count_image_pages_unreferenced_by_others
		} {
		    get_sql "$util: "
		}
	    }
	    default { get_sql "" }
	}
	db close
	exit
    }
}

makeGui $port    

# Args to pass to wub/nub/wikitcl
# port, cmdport, wikidb

cd [file join $kit_dir lib wikitcl wubwikit]

if {[string length $config]} {
    set ::starkit::config_file $config
} else {
    set ::starkit::config_file [file join $tmpdir wikit.config]
    mkconfig $::starkit::config_file 1
}

if {[string length $local]} {
    set ::starkit::local_file $local
}

set ::starkit_wikitdbpath $twikidb

source WikitWub.tcl
