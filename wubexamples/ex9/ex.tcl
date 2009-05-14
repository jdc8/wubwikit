lappend auto_path ../Wub ../tcllib/modules .

package require TclOO
package require Site

namespace eval MyDirectDomain {
    proc /test { req } {
	dict set req -content "Test for MyDirectDomain"
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test with query"
	return $req	
    }
    proc /default { req } { 
	set content "Default function for MyDirectDomain"
	set ml {}
	foreach m [info command ::MyDirectDomain::/test*] {
	    lappend ml $m /directns[string range $m 18 end]
	}
	append content [Html menulist $ml]
	dict set req -content $content
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: default"
	return $req
    }
}

oo::class create MyOODomain {
    constructor {args} {
    }
    method /test {req args} {
	dict set req -content "Test for MyOODomain"
	dict set req content-type x-text/html-fragment
	dict set req -title "MyOODomain: test"
	return $req	
    }
    method /default { req } { 
	set content [<p> "Default function for MyOODomain"]
	set ml {}
	foreach m [info object methods [self] -private -all] {
	    if {[string match /* $m]} {
		lappend ml $m /directoo$m
	    }	    
	}
	append content [Html menulist $ml]
	dict set req -content $content
	dict set req content-type x-text/html-fragment
	dict set req -title "MyOODomain: default"
	return $req
    }
}

set ::oodomain [MyOODomain new]

package require conversions
set Html::XHTML 1
set ::conversions::htmlhead {<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">}

Site start home . nubs ex.nub ini ex.ini
