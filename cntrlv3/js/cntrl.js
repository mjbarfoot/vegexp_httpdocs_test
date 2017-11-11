/*******************************************************************************/
//	File:			/js/cntrl.js 										
//	Description: 	Control Panel Methods/Objects/Setup
// 	Author: 		Matt Barfoot - Clearview Webmedia Limited
//  Date:			08/10/2007
//  History: 			
/*******************************************************************************/ 


/*******************************************************************************/
/* ------------------/ VARS /------------------------------------------------- */
/*******************************************************************************/ 
AppVars =  {
	reqURL: ''
}

var debugMode=false;
/*******************************************************************************/
/* ------------------/ INIT FUNCTION /------------------------------------ */
/*******************************************************************************/ 
init = function() {
		AppVars.reqURL = UTIL.URLgetScriptName(location.href);	 
		if (AppVars.reqURL=="/") AppVars.reqURL="index.cfm";	
		
		if (document.getElementById('content')) AJAX_LINKS.init();
		
		if (document.getElementsByTagName('form')) xwForm.init(); 
}

/*******************************************************************************/
/* ------------------/ AJAX / TACONITE LINKS /-------------------------------- */
/*******************************************************************************/
AJAX_LINKS = {
	init: function() {
		// *** ASSIGN LINK HANDLERS
		//find all the active links inside "content" div and 
		//assign them a taconite onclick listener to forward clicks
		var myContentLinks = document.getElementById("main").getElementsByTagName("a");	
		
		
		//iterate over them and assign them
		for (var i=0; i<myContentLinks.length; i++) {
			// any links that contain reqtype can be automatically forwarded by Taconite.
			if (myContentLinks[i].href.indexOf("reqtype=")!=-1) {
				eV.addEvent(myContentLinks[i], 'click', AJAX_LINKS.forward, false);
			}
		}
		// *** END		
		
	}, 
	
	
	forward: function(e) {
	 	  // get target
		 var target = window.event ? window.event.srcElement : e ? e.target : null;
	     if (!target) return; 	 
	    
	    //check it's a anchor element
	     if (target.tagName!='A') target = UTIL.ascendDOM(target, 'a');
		
		//append the query string to the base application url	
	     var myURL = AppVars.reqURL + '?' + UTIL.URLgetQueryString(target.href);

		 AJAX_CLIENT.ShowLoadingDiv();
		 AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); 	
		 AJAX_LINKS.stopBubble(e);	//stop bubble
			
	},
	
	stopBubble: function(e) {
				  if (window.event) {
				      window.event.cancelBubble = true;
				      window.event.returnValue = false;
				      return;
				  }
				  
				  if (e && e.stopPropagation && e.preventDefault) {
				  	  e.stopPropagation();
				      e.preventDefault();
				  }
	}	
}


/*******************************************************************************/
/* ------------------/ AJAX_CLIENT FUNCTIONS /-------------------------*/
/*******************************************************************************/ 
AJAX_CLIENT = {
	// creates new Taconite Ajax Request Object and requests product info from the cfc
 		get: function(url, postFn) {
				if(debugMode) document.getElementById('DebugAjaxGetInfo').value=url;
				
				var ajaxRequest = new AjaxRequest(url);             	
		        	if (postFn) ajaxRequest.setPostRequest(postFn);
		        	ajaxRequest.sendRequest();		        		
		},
		
		
		post: function(url, frmId, postFn) {
			
			if(debugMode) document.getElementById('DebugAjaxGetInfo').value=url;
				
			var ajaxRequest = new AjaxRequest(url);    
			ajaxRequest.setPostRequest(AJAX_CLIENT.HideLoadingDiv);	    
			ajaxRequest.setUsePOST();
			ajaxRequest.addFormElements(frmId);
			if(debugMode) ajaxRequest.setEchoDebugInfo();
		    ajaxRequest.sendRequest();	
		
		},
		
		
		ShowLoadingDiv: function() {
			var span = document.createElement('span');
			span.setAttribute('id', 'content-loading');
			
			var txtNode = document.createTextNode("Loading data..."); 	
 			span.appendChild(txtNode);
 			document.getElementById('main').appendChild(span);
		},
		
		HideLoadingDiv: function() {
			if (document.getElementById('content-loading')) {
				var el = document.getElementById('content-loading');
				document.getElementById('content-loading').parentNode.removeChild(el);
			}
			
			//refreshes the debug DIV if in debug mode
		    if(debugMode) {	        		
				var myScriptName = "index.cfm";
		    	var debugURL = myScriptName + "?reqtype=" + "debug"
		    	var debugRequest = new AjaxRequest(debugURL);  
		    	debugRequest.sendRequest();
		    }
		}	
}


 /*******************************************************************************/
/* ------------------/ Tab Action /------------------------------------------- */
/*******************************************************************************/
																					
TabAction = {
		
		changeTab: function(elmID) {
			var moduleid =UTIL.URLgetValueFromKey(location.href, "moduleid"); 
						
			//construct the URL and refresh the infoBar
			if (!moduleid) moduleid = 'home';
			var myURL = AppVars.reqURL + '?reqtype=tab&moduleid=' + moduleid + '&tabid=' + elmID.replace("tab", "");
			
			AJAX_CLIENT.ShowLoadingDiv();
			AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest
			
			//set the tab focus
			//TabAction.setActiveTab(elmID);			
			
		},
		
		
		setActiveTab: function(tabID) {			
			// make the selected tab the focus tab
			var Tabs = document.getElementById("tabs").getElementsByTagName("a");
			for (var i=0; i<Tabs.length; i++) {
				if (Tabs[i].id == tabID) {
					Tabs[i].className=Tabs[i].className.replace(new RegExp("tabunselected\\b"), "tabselected");
				} else {
					Tabs[i].className=Tabs[i].className.replace(new RegExp("tabselected\\b"), "tabunselected");
				}					
		
			}
			
	
	
		},	
				
				
		
		// unselect a tab. By default is set a tab to selected, when another tab is clicked is it not unset.
		unSelectRow: function() {
		 	var myTabs = document.getElementById("tabs").getElementsByTagName("a");
			for (var i=0; i<myTabs.length; i++) {
				if (i == 0) {
						myTabs[i].className = myTabs[i].className.replace("tabselected", "");
				}			
			}			
		}	
				
}


/*******************************************************************************/
/* ------------------/ UTILITY FUNCTIONS /------------------------------------ */
/*******************************************************************************/ 
 
  var UTIL = {
 	// climb up the tree to the supplied tag.
 	ascendDOM: function(target, El) {
 	while (target.nodeName.toLowerCase() != El &&  
    	 target.nodeName.toLowerCase() != 'html')
   		target = target.parentNode;
 
 	return (target.nodeName.toLowerCase() == 'html') ? null : target;
	}, 
 	
 	
 	//gets the text content from a DOM element	
	getElText: function(el)	{
			if (el.textContent) return el.textContent;
			if (el.innerText) return el.innerText;
			var x = el.childNodes;
			var txt = '';
			for (var i=0, len=x.length; i<len; ++i){
			if (3 == x[i].nodeType) {
			txt += x[i].data;
			} else if (1 == x[i].nodeType){
			txt += getElText(x[i]);
			}
			}
			return txt.replace(/\s+/g,' ');
	  },
	  
	  
	  //set the text content of a DOM element
	  setElText: function(el, val) {
	  if (el.textContent) el.textContent = val;
	  if (el.innerText) el.innerText = val;
	  	
	  },
	  
	 //function to retrieve the value from key/value pair in the url scope
  	 URLgetValueFromKey: function(url, key) {
  	 	
  	 	var N_StartOfKey 	= url.indexOf(key); //find the start of the key
  	 	var N_EndOfKey 		= url.length; //by default end of key is end of URL
  	 	
  	 	// if not found, exit function
  	 	if (N_StartOfKey == -1) return;
  	 	  	 	
  	 	// now truncate the first part of the URL leaving everything after the Key we are looking for
  	 	var myVal 	= url.substring((N_StartOfKey+key.length+1),url.length);
  	 	
  	 	//see if this is last name/value pair by checking for ampersand
  	 	if (myVal.indexOf("&") != -1) {
  	 	   myVal = myVal.substring(0,myVal.indexOf("&"));		
  	 	}
  	 	 	 	
  	 	return myVal;	
  	 },
  	 
  	  URLgetQueryString: function(URL) {
  	 	var myVal = URL.replace("http://", "");
  	 	var querystring_start = myVal.indexOf("?") + 1;
  	 	var querystring_end = myVal.length;
  	 	return myVal.substring(querystring_start,querystring_end);
  	 
  	  },
  	  
  	  URLgetScriptName: function(URL) {
  	 	
  	 	// to get the script name strip off host, port and any query string attributes
  	 	var myVal = URL.replace("http://", "");
  	 	var script_start = myVal.indexOf("/") + 1;
  	 	
  	 	// by default the end point is the end of the URL
  	 	var script_end = myVal.length;
  	 	
  	 	// if there is a query string, set the script_end just before it starts
  	 	if (myVal.indexOf("?") != -1) script_end = myVal.indexOf("?");
  	 	
  	 	// get the substring, but prepend with a forward slash  	 	 	
  	 	myVal 	= "/" + myVal.substring(script_start,script_end);
  	 	
  	 	return myVal;	
  	 } 
  }

/*******************************************************************************/
/* ------------------/ EVENT Setup /------------------------------------------- */
/*******************************************************************************/ 

  
  eV = {
	addEvent: function(elm, evType, fn, useCapture) {
    if (elm.addEventListener) {
      elm.addEventListener(evType, fn, useCapture);
      return true;
    } else if (elm.attachEvent) {
      var r = elm.attachEvent('on' + evType, fn);
      return r;
    } else {
      elm['on' + evType] = fn;
    }
  },
 
     removeEvent: function(obj, evType, fn, useCapture){
	  if (obj.removeEventListener){
	    obj.removeEventListener(evType, fn, useCapture);
	    return true;
	  } else if (obj.detachEvent){
	    var r = obj.detachEvent("on"+evType, fn);
	    return r;
	  } else {
	    alert("Handler could not be removed");
	  }
	},	
	
   
    find_target: function(e)	{
	/* Begin the DOM events part, which you */
	/* can ignore for now if it's confusing */
	var target; 
		
	if (window.event && window.event.srcElement) 
		target = window.event.srcElement;
	else if (e && e.target)
	    target = e.target;
	
	if (!target)
	    return null;
		
	while (target != document.body &&
	     target.nodeName.toLowerCase() != 'a')
	     target = target.parentNode;
		
	if (target.nodeName.toLowerCase() != 'a')
	    return null;
		
	return target;
	}
  
}

 /*******************************************************************************/
/* ------------------/ After document run init method /------------------------ */
/*******************************************************************************/ 
eV.addEvent(window, 'load', init, false);	