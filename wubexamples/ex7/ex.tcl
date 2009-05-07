lappend auto_path ../Wub ../tcllib/modules .

package require TclOO
package require Site
package require jQ

namespace eval MyDirectDomain {
    proc /test { req } {
	set C [<p> [<input> type text id myTimeEntry size 10 {}]]
	set req [jQ jquery $req]
	set req [jQ timeentry $req #myTimeEntry]
	append C [<p> {<button type='button' onclick="$('#myTimeEntry').timeEntry();">Time</button>}]
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test post method"
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

package require conversions
#set Html::XHTML 1
#set ::conversions::htmlhead {<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">}

Site start home . nubs ex.nub ini ex.ini
