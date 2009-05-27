function load_contents() 
{
    $("#contents").load("/directns/test_ajax_callback", "test");
}

function ajaxpage(url, postData, containerid){
    var page_request = false
    if (window.XMLHttpRequest) // if Mozilla, Safari etc
        page_request = new XMLHttpRequest()
    else if (window.ActiveXObject){ // if IE
	try {
	    page_request = new ActiveXObject("Msxml2.XMLHTTP")
	} 	
	catch (e){
	    try{
		page_request = new ActiveXObject("Microsoft.XMLHTTP")
	    }
	    catch (e){}
	}
    }
    else
        return false

    page_request.onreadystatechange=function(){
	loadpage(page_request, containerid)
    }
    if (postData.length) {
	page_request.open('POST', url, true);
	page_request.setRequestHeader('Content-type', "application/xml");
	page_request.setRequestHeader('Content-length', postData.length);
	page_request.send(postData);
    }
    else {
	page_request.open('GET', url, true);
	page_request.send(null);
    }
}

function loadpage(page_request, containerid){
    if (page_request.readyState == 4/* && (page_request.status==200 || window.location.href.indexOf("http")==-1)*/) {
	if (page_request.responseText != "") {
	    document.getElementById(containerid).innerHTML = page_request.responseText;
	}
    }
}

function load_contents2() 
{
    ajaxpage("/directns/test_ajax_callback2", "test", "contents");
}
