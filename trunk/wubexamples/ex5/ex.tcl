lappend auto_path ../Wub .

package require TclOO
package require Site

oo::class create MyOODomain {
    constructor {args} {
    }
    method /test_html_tags { req } { 
	set content ""
	append content [<h1> "Some test with HTML tags"]
	append content [<p> "This is [<b> bold] and this is [<i> italic], this is both [<b> [<i> {bold and italic}]], this is a [<a> href /directoo/test link]"] \n
	dict set req -content $content
	dict set req content-type x-text/html-fragment
	dict set req -title "MyOODomain: HTML tag command tests"
	return $req	
    }
    method /test_redir { req } {
	return [Http Redir $req /directoo/test_html_tags]
    } 
    method /test_redirect { req } {
	return [Http Redirect $req /directoo/test_html_tags]
    } 
    method /test_found { req } {
	return [Http Found $req /directoo/test_html_tags]
    } 
    method /test_notfound { req } {
	return [Http NotFound $req]
    } 
    method /test_forbidden { req } {
	return [Http Forbidden $req]
    } 
    method /test_referer {req args} {
	dict set req -content [<p> "Referer = [Http Referer $req]"]
	dict set req content-type x-text/html-fragment
	dict set req -title "MyOODomain: test referer"
	return $req	
    }
    method /test_redirect_to_referer { req } {
	return [Http RedirectReferer $req]
    } 
    method /test_relocated { req } {
	return [Http Relocated $req /directoo/test_html_tags]
    } 
    method /test_see_other { req } {
	return [Http SeeOther $req /directoo/test_html_tags]
    } 
    method /test_moved { req } {
	return [Http Moved $req /directoo/test_html_tags]
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

set oodomain [MyOODomain new]

package require conversions
set Html::XHTML 1
set ::conversions::htmlhead {<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">}

namespace eval ::conversions {
    proc .x-unarmoured-text/html-fragment.x-text/html-fragment { rsp } { 
	set rspcontent [dict get $rsp -content]
	if {[string match "<!DOCTYPE*" $rspcontent]} {
	    # the content is already fully HTML
	    set content $rspcontent
	} else {
	    set content [armour $rspcontent]
	}	
	return [Http Ok $rsp $content x-text/html-fragment]	
    }
}

Site start home . nubs ex.nub ini ex.ini
