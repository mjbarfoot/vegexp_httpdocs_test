/*******************************************************************************/
//	File:			/js/OFFER.js 										
//	Description: 	OFFERe Javascript Objects/Functions/Effects
// 	Author: 		Matt Barfoot - Clearview Webmedia Limited
//  Date:			07/06/2006
//  History: 		
/*******************************************************************************/ 
var RECIP = {
  		 
  		 MooCat: new Array(),
  		  		 
  		 createEffects: function() {
  	
  		  var dynamicDIVs = document.getElementById('recipeDesc').getElementsByTagName('div');
  		  var divCounter = 0; 		  
  		  for (var i = 0; i < dynamicDIVs.length; i++) {
  		  	if (dynamicDIVs[i].className && (' ' + dynamicDIVs[i].className + ' ').indexOf(' recipeCat ') != -1) {  		     		
  		  		RECIP.MooCat[divCounter] = eval('new fx.Height(dynamicDIVs[' + i + '], {duration: 500})');
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
			 	if ((newH == "18" && actualHeight < 200) || (oldH == "18" && actualHeight > 200)) return;
			 	
			 	
			 	//set the new height ( MOO Fx object stored in RECIP.MooCat array)			 				
   				eval("RECIP.MooCat[" + elID.replace('rCat', '') + "]").custom(oldH,newH);	
   				
   				//if new height is bigger than old height we are maximising
   				//so display hide element
   				/* ******************* DISABLED DUE TO IE7 DEFECT****************
   				Moved Show/Hide buttons side by side at top instead
   				Reason: Show/hiding them dynamically does not work using display 
   				property, fine in FF and IE6
   				
   				if (oldH > newH) {
   					document.getElementById(elID + "-hide").style.display="none";
   					document.getElementById(elID + "-hide").style.visibility="hidden";
   					document.getElementById(elID + "-hide").style.zIndex=-50;
   					document.getElementById(elID + "-show").style.display="inline";
   					document.getElementById(elID + "-show").style.visibility="visible";
   					document.getElementById(elID + "-show").style.zIndex=50;
   				} 
   				//vice versa
   				else { 
   					document.getElementById(elID + "-show").style.display="none";
   					document.getElementById(elID + "-show").style.visibility="hidden";
   					document.getElementById(elID + "-show").style.zIndex=-50;
   					document.getElementById(elID + "-hide").style.display="inline";
   					document.getElementById(elID + "-hide").style.visibility="visible";
   					document.getElementById(elID + "-hide").style.zIndex=50;
   				}				
  				
  				****************/
  		},
  
 		 
 		 
 		 show:  function(elID, newH) {
				
				if (!newH) var newH = 150;
			 				
   				eval("RECIP.MooCat[" + elID.replace('rCat', '') + "]").custom(18,newH);	
   				document.getElementById(elID + "-hide").style.display="inline";
   				document.getElementById(elID + "-show").style.display="none";
   								
  		},
  
  		hide: function(elID, newH) {
   				
   				if (!newH) {
				var newH = 18;
				}
   				
   				eval("RECIP.MooCat[" + elID.replace('rCat', '') + "]").custom(150,newH);	
				document.getElementById(elID + "-hide").style.display="none";
   				document.getElementById(elID + "-show").style.display="inline";
  		} 		 		
}

