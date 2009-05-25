lappend auto_path ../Wub ../tcllib/modules .

package require Site

namespace eval MyDirectDomain {

    proc maketable { d } {
	return [<table> [Foreach k [dict keys $d] {[<tr> "[<td> $k] [<td> [dict get $d $k]]"]}]]
    }

    proc /default { req } { 
	set content ""
	append content [<h1> Listener] [maketable $::Site::listener]
	append content [<h1> Cache] [maketable $::Site::cache]
	append content [<h1> Httpd] [maketable $::Site::httpd]
	append content [<h1> Nub] [maketable $::Site::nub]
	dict set req -content $content
	dict set req content-type x-text/html-fragment
	dict set req -title "Ini parameters"
	return $req
    }
}

Site start home . nubs ex.nub ini ex.ini
