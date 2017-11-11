/*******************************************************************************/
//	File:			/js/offer.js based upon /js/recipes.js										
//	Description: 	Recipe Javascript Objects/Functions/Effects
// 	Author: 		Matt Barfoot - Clearview Webmedia Limited
//  Date:			12/06/2006
//  History: 		
/*******************************************************************************/ 
var OFFER = {
  		 
  		 MooCat: new Array(),
  		  		 
  		 createEffects: function() {
  	
  		  var dynamicDIVs = document.getElementById('offerDesc').getElementsByTagName('div');
  		  var divCounter = 0; 		  
  		  for (var i = 0; i < dynamicDIVs.length; i++) {
  		  	if (dynamicDIVs[i].className && (' ' + dynamicDIVs[i].className + ' ').indexOf(' offerCat ') != -1) {  		     		
  		  		OFFER.MooCat[divCounter] = eval('new fx.Height(dynamicDIVs[' + i + '], {duration: 500})');
  		  		divCounter = divCounter + 1;
  		  	}
  		  } 		 
  		 
  		 },
 
 		minMax:  function(elID, oldH, newH) {
				//defaults
				if (!oldH) var oldH = 18;
				if (!newH) var newH = 250;
			 	
			    // if we clicking "Show", but the element is already displayed in full do nothing
			    // and vice versa. 			 	
			 	var actualHeight = document.getElementById(elID).offsetHeight;
			 	if ((newH == "75" && actualHeight < 250) || (oldH == "75" && actualHeight > 250)) return;
			 	
			 	
			 	//set the new height ( MOO Fx object stored in OFFER.MooCat array)			 				
   				eval("OFFER.MooCat[" + elID.replace('oCat', '') + "]").custom(oldH,newH);	
   				
   				//if new height is bigger than old height we are maximising
   				//so display hide element
   				
   				/* ******************* DISABLED DUE TO IE7 DEFECT****************
   				Moved Show/Hide buttons side by side at top instead
   				Reason: Show/hiding them dynamically does not work using display 
   				property, fine in FF and IE6
   				  				
   				 
   				if (oldH > newH) {
   					document.getElementById(elID + "-hide").style.display="none";
   					document.getElementById(elID + "-show").style.display="inline";
   				} 
   				//vice versa
   				else { 
   					document.getElementById(elID + "-show").style.display="none";
   					document.getElementById(elID + "-hide").style.display="inline";
   				}
   				*****************************************************************/				
  		} 		
}
