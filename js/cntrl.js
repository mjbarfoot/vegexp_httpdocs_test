/*******************************************************************************/
//	File:			/js/cntrl.js 										
//	Description: 	Control Panel Javascript Objects/Functions
// 	Author: 		Matt Barfoot - Clearview Webmedia Limited
//  Date:			11/09/2006
//  History: 		
/*******************************************************************************/ 

// initiate objects

function init() {

		var stretchers = document.getElementsByClassName('stretcher'); //div that stretches
		var toggles = document.getElementsByClassName('display'); //h3s where I click on

		//accordion effect
		var myAccordion = Acc.make(toggles, stretchers); 
		
		//new fx.Accordion(
		//	toggles, stretchers, {opacity: true, duration: 300}
		//);

		if (!Acc.checkHash(toggles, stretchers, myAccordion)) myAccordion.showThisHideOpen(stretchers[0]);
		
		//Element.cleanWhitespace('content');


}


 /*******************************************************************************/
/* ------------------/ Accordion Object /------------------------------------- */
/*******************************************************************************/ 

Acc = {
	make: function(toggles, stretchers) {
	
	return new fx.Accordion(toggles, stretchers, {opacity: true, duration: 300}); 
	
	},
	
	//hash function
	checkHash: 	function(toggles, stretchers, myAccordion){
			var found = false;
			toggles.each(function(h3, i){
				if (window.location.href.indexOf(h3.title) > 0) {
					myAccordion.showThisHideOpen(stretchers[i]);
					found = true;
				}
			});
			return found;
		}
}


 /*******************************************************************************/
/* ------------------/ EVENT Object /------------------------------------------- */
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