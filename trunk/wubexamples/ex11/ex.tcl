lappend auto_path ../Wub ../tcllib/modules .

package require TclOO
package require Site

namespace eval MyDirectDomain {

    proc /test_set_cookie { req answer } {
	puts "cookie answer: $answer"
    	if {[dict exists $req -cookies]} {
	    set cdict [dict get $req -cookies]
	} else {
	    set cdict [dict create]
	}
	set cdict [Cookies add $cdict -path / -name my_cookie -value $answer -expires "next week"]
	dict set req -cookies $cdict
	return [Http Redirect $req /directns/test_cookie]
    }
    proc /test_cookie { req } {
	set answer ""
    	if {[dict exists $req -cookies]} {
	    set cdict [dict get $req -cookies]
	    puts "cdict=$cdict"
	    set cl [Cookies match $cdict -name my_cookie]
	    puts "cl=$cl"
	    if {[llength $cl] == 1} {
		set answer [dict get [Cookies fetch $cdict -name my_cookie] -value]
		puts "answer=$answer"
	    }
	}
	set C [<h1> "Cookies:"]
	append C [<form> test method post action /directns/test_set_cookie {
	    What is your favorite color? [<text> answer title Answer $answer]
	}]
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: cookies"
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
