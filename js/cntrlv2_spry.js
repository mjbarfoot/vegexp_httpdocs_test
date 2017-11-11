/*******************************************************************************/
/* ------------------/ SPRY SETUP /------------------------------------ */
/*******************************************************************************/ 


	/* var myObserver = new Object;
	
	myObserver.onPostLoad = function(dataSet, data)
	{
		//alert(Tabs.getData()[0]["name"]);
		//get the name of the first tab
		tabSelectedName = Tabs.getData()[0]["name"]; 
		 var InfoBar = 
	};

	Tabs.addObserver(myObserver);
	*/





/*******************************************************************************/
/* ------------------/ INIT FUNCTION /------------------------------------ */
/*******************************************************************************/ 
init = function() {
     // add the drop down menu
	if (window.attachEvent) window.attachEvent("onload", sfHover);
	
	//eV.addEvent(aEls[i], 'mouseover', dropmenu.stopBubble, false);	
	//sfHover();

}





sfHover = function() {
	
	// get the list elements
	var sfEls = document.getElementById("dropnav").getElementsByTagName("li");
	for (var i=0; i<sfEls.length; i++) {
		sfEls[i].onmouseover=function() {
			this.className+=" sfhover";
		}
		sfEls[i].onmouseout=function() {
			this.className=this.className.replace(new RegExp(" sfhover\\b"), "");
		}
	}				
}
	
dropmenu = {
	// cancel the href action of the link and stop propogation/event bubbling
		stopBubble: function(e) {
				  if (window.event) {
				      window.event.cancelBubble = true;
				      window.event.returnValue = false;
				      return;
				  }
				  
				  if (e) {
				  	  e.stopPropagation();
				      e.preventDefault();
				  }
		}		

}		
	
 /*******************************************************************************/
/* ------------------/ Tab Action /------------------------------------------- */
/*******************************************************************************/
																					
TabAction = {
		
		changeTab: function(ds_RowID) {
			var InfoBarUrl = "/cfc/cntrl/renderView.cfc?method=getInfoBar&moduleid="
			var moduleid =UTIL.URLgetValueFromKey(location.href, "moduleid"); 
			var tabid="";
			
			// selects the clicked on tab
			Tabs.setCurrentRow('{ds_RowID}');
			
			tabid = Tabs.getData()[ds_RowID]["name"]; 
			
			// if the tab is changed to one other than the default, unselect the default tab
			if (ds_RowID != 0) {
				TabAction.unSelectRow();
			}
			
			// set the url to call the renderview.cfc with the correct tab name			
			
			//alert(InfoBarUrl + moduleid + "&tabid=" + tabid);
			InfoBar.setURL(InfoBarUrl + moduleid + "&tabid=" + tabid); 
			InfoBar.loadData();	// refresh the data			
	
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
/* ------------------/ UTILITY FUNCTIONS /------------------------------------- */
/*******************************************************************************/ 
UTIL = {
	  	 //function to retrieve the value from key/value pair in the url scope
  	 URLgetValueFromKey: function(url, key) {
  	 	
  	 	var N_StartOfKey 	= url.indexOf(key); //find the start of the key
  	 	
  	 	// the value is the part of the string between
  	 	// the start of the key + length of key + 1 (for = ) and the end of the string
  	 	// ** NOTE: only works if the ProductID is last key/value pair in string 
  	 	var myVal 	= url.substring((N_StartOfKey+key.length+1),url.length);
  	 	
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
