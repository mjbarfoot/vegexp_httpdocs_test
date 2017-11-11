		  eV : {
			addEvent: function(elm, evType, fn, useCapture) {
		    	if (elm) {
			    if (elm.addEventListener) {
			      elm.addEventListener(evType, fn, useCapture);
			      return true;
			    } else if (elm.attachEvent) {
			      var r = elm.attachEvent('on' + evType, fn);
			      return r;
			    } else {
			      elm['on' + evType] = fn;
			    }
		   	}
		  	},
		  	
		  	removeEvent: function(elm, evType, fn) {
		  	if (elm) {
		  	  if (elm.	
		  	
		  		
		  	 }	
		  	},
		  	
		
		 evList: "",
		 
		 addToList: function(elm, evType, fn) {
		if (evType != "mouseover" && evType != "mouseout") {
		 xw.eV.evList = xw.eV.evList +  '\n' + '"' + elm + '-' + evType + '"';	
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
		  
		}	// END xw.eV 