lappend auto_path ../Wub ../tcllib/modules .

package require TclOO
package require Site
package require jQ

namespace eval MyDirectDomain {

    variable suspended_requests {}

    proc /test_suspend { req } {
	append C [<h1> "Suspended Ajax request..."]
	append C "<button type='button' onclick='load_contents();'>Make request</button>"
	append C [<div> id contents {}]
	set req [jQ jquery $req]
	set req [jQ ready $req "load_contents();"]
	dict set req -content $C
	dict set req -script [list /scripts/ajax.js {}]
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: suspended"
	return $req	
    }
    proc /test_ajax_callback { req } { 
	puts "Callback, suspend ..."
	variable suspended_requests
	lappend suspended_requests $req [info coroutine]
	return {-suspend -1}
    }
    proc /test_return_result { req } {
	puts "Return result"
	set C [<h1> "Resumed at [clock format [clock seconds]]"]
	dict set req -content $C
	dict set req content-type text/html
	return $req
    }
    proc /test_resume { req } {
	puts "Resume suspended requests"
	variable suspended_requests
	append C [<h1> "Resuming Ajax requests..."]
	foreach {r cr} $suspended_requests {
	    append C [<p> $r]
	    after 1 [list catch [list $cr [list RESUME [/test_return_result $r]]]]
	}
	set suspended_requests {}
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: resuming..."
	return $req		
    }
    proc /test_suspended { req } {
	variable suspended_requests
	append C [<h1> "Suspended Ajax requests:"]
	foreach {r cr} $suspended_requests {
	    append C [<p> $r]
	}
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: suspended requests"
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
set Html::XHTML 1
set ::conversions::htmlhead {<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">}

Site start home . nubs ex.nub ini ex.ini
