/*******************************************************************************/
//	File:			/js/vegexp.js 										
//	Description: 	Core Javascript Objects/Functions
// 	Author: 		Matt Barfoot - Clearview Webmedia Limited
//  Date:			23/04/2006
//  History: 		02/06/2006 - Added Product Info Tool tips	
/*******************************************************************************/ 

//debugger

/*******************************************************************************/
/* ------------------/ VARS /------------------------------------------------- */
/*******************************************************************************/ 
var myEffect;

/* for Product Info Tool Tips */
var pInfoDiv;
var offsetEl;

  
/*******************************************************************************/
/* ------------------/ INIT FUNCTION /------------------------------------ */
/*******************************************************************************/ 
  function init() {
  		FX.createEffect();
  		Basket.init();
  		
  		// if this page contains a product list add rollover product information and recipe info
  		if (document.getElementById('productList')) {
  			pINFO.addRO();
  		    if (rINFO) rINFO.addRO();
            Favourites.init();
  		}	
  		
  		 		
  		// if this is the regform add blur/focus effects
  		if (document.getElementById('frmRegister')) fBg.init('frmRegister');
  		
  		// if this is the checkout form add blur/focus effects
  		if (document.getElementById('checkoutForm'))  {
  			fReq.init('checkoutForm');
  			fBg.init('checkoutForm');
  		}
  		
  		// if this is the contact form add blur/focus effects
  		if (document.getElementById('frmContact')) fBg.init('frmContact');
  		
 		// if this is the comments form add blur/focus effects
  		if (document.getElementById('frmComment')) fBg.init('frmComment');  		
  		
  		// if this is the recipe section add the expand/contract MOO effects
  		if (document.getElementById('recipeWrap')) RECIP.createEffects();
  		
  		// if this is the Offers section add the expand/contract MOO effects
  		if (document.getElementById('offerWrap')) OFFER.createEffects();
  		
  		//slidedown tool tips effect 
  		if (document.getElementById('sortHelp')) DHTMLG.slidedown_init();
  			
  		
  }
  
/*******************************************************************************/
/* ------------------/ TACONITE /--------------------------------------------- */
/*******************************************************************************/ 
  var TAC = {
		send: function(url, Action, increment) {
				var ajaxRequest = new AjaxRequest(url);
                //ajaxRequest.setEchoDebugInfo();
		        if (Action=="Add") {
                    if (increment) {
                        ajaxRequest.setPostRequest(Basket.afterUpdate);
                    } else {
                        ajaxRequest.setPostRequest();
                    }
		        } else if (Action=="Expand") {
		        	ajaxRequest.setPostRequest(FX.Big);
		        } else if (Action=="Contract") {
		        	ajaxRequest.setPostRequest(FX.Small);
		        } else if (Action=="clientSaveBasket") {
                    ajaxRequest.setPostRequest();
                }
		        ajaxRequest.sendRequest();	
		}
		  	
  }
  
/*******************************************************************************/
/* ------------------/ BASKET FORM /------------------------------------------ */
/*******************************************************************************/ 
  // form functions
  var FRM = {
  		setTotal: function(ProductID) {
			  	var id_of_total = 'tot_' + ProductID;
			  	var id_of_price = 'prc_' + ProductID;
			  	var id_of_qty 	= 'fldQty_' + ProductID;
			  	
			  	// get the existing total to use when updating the grand total
			  	var existing_total = UTIL.getElText(document.getElementById(id_of_total));
			  	existing_total = existing_total.substring(1, existing_total.length);
			  	
			  			  	
			  	// get the price and remove the pound sign
			  	
			  	var price_of_product = UTIL.getElText(document.getElementById(id_of_price)).replace(/[�]/, '');
			  	
			  	price_of_product = price_of_product.substring(1, price_of_product.length);
			  	var new_quantity = document.getElementById(id_of_qty).value;
			  	
			  	//alert("price_of_product: " + price_of_product + " new_quantity:" + new_quantity);
			  	
			  	var new_total_val = (Number(price_of_product) * Number(new_quantity)).toFixed(2);
			  	var new_total = String.fromCharCode(163) + String(new_total_val);
			  				  	
			  	UTIL.setElText(document.getElementById(id_of_total), new_total);
  		
  				//update the grandTotal
  				var grand_total = UTIL.getElText(document.getElementById('myBasketItemsGrandTotalVal')).replace(/[�]/, '');
  				grand_total = grand_total.substring(1, price_of_product.length);
  				  				
  				var new_grand_total = String.fromCharCode(163) + (Number(grand_total) + Number(new_total_val) - Number(existing_total)).toFixed(2);
  				UTIL.setElText(document.getElementById('myBasketItemsGrandTotalVal'), new_grand_total); 
  		}
  	
  	
  }
  

/*******************************************************************************/
/* ------------------/ UTILITY FUNCTIONS /------------------------------------ */
/*******************************************************************************/ 
 
  var UTIL = {
  	
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
	  
	  setElText: function(el, val) {
	  if (el.textContent) el.textContent = val;
	  if (el.innerText) el.innerText = val;
	  	
	  } 
	  
  	
  }

/*******************************************************************************/
/* ------------------/ Favourites /------------------------------------- */
/*******************************************************************************/

var Favourites = {
    init: function() {
        if (!document.getElementById('productList')) return;

        var Links = document.getElementById('productList').getElementsByTagName('a');

        //iterate through them and add the listener event clickNav
        for (var i = 0; i < Links.length; i++) {

            //if the link has a class of "veProduct"
            if (Links[i].className && (' ' + Links[i].className + ' ').indexOf('iconFav') != -1) {
                eV.addEvent(Links[i], 'click', Favourites.Add, false);
                Links[i].onclick = function() { return false; }; // Safari
            } //end if
        }
    },

    Add: function(e) {
        var target = window.event ? window.event.srcElement : e ? e.target : null;
        if (!target) return;

        if (target.nodeName=="IMG")
            target= target.parentNode;


        //double check ProductID is in URL and get the value for the key ProductID
        if (target.href.search(/StockID/) != -1) {
            var myProductID = Favourites.URLgetValueFromKey(target.href, "StockID");

            var url = "/cfc/shopper/favouriteRemote.cfc?method=addRemote&ProductID=" + myProductID;

            //send ProductID via Taconite client and refresh the shopping basket view
            TAC.send(url, "Add");

            // cancel the href action of the link and stop propogation/event bubbling
            if (window.event) {
                window.event.cancelBubble = true;
                window.event.returnValue = false;
                return;
            }

            if (e) {
                e.stopPropagation();
                e.preventDefault();
            }

        } else {
            return; //not found, exit out of function
        }

    },

    /*//stops a previously added favourite being added again
    disarm: function(productID) {
        var favLink = document.getElementById('fav-productid-'+productID).getElementsByTagName('a');
        function.onclick = function() { return false; };
    },*/

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
/* ------------------/ SHOPPING BASKET  /------------------------------------- */
/*******************************************************************************/

  // add event handlers to "add" links
  var Basket = {
  	  
  	  // initialise anything we need to do with adding products to the shopping basket
  	  init: function() {
  	  		Basket.SetupLinks();
  	  		//Basket.SetupExpandContractLinks();
  	 }, // end of function		
	
	 afterUpdate: function() {
         FX.Increment();
         var url = "/cfc/shopper/basketContents.cfc?method=clientSaveBasket";

         //Refresh view and expand basket
         TAC.send(url, "clientSaveBasket");
     },
	 SetupLinks: function() {
	 	   //grab the add to basket links and add event listeners
			if (!document.getElementById('productList')) return;
			
			var Links = document.getElementById('productList').getElementsByTagName('a');
  	  
  	  		//iterate through them and add the listener event clickNav
			for (var i = 0; i < Links.length; i++) {
	     		
	     		//if the link has a class of "veProduct"
	     		if (Links[i].className && (' ' + Links[i].className + ' ').indexOf(' addtobasket ') != -1) {  		    
					eV.addEvent(Links[i], 'click', Basket.Add, false);
	     		 	Links[i].onclick = function() { return false; }; // Safari			
	  	   		} //end if
	    	} //end for		
	 }, //end function
	 
	/* SetupExpandContractLinks: function() {
	 	if (document.getElementById('tblBasketExpandLink')) {
	 	alert("setup expand link");
	 		var ExpandLink = document.getElementById('tblBasketExpandLink');
	 		eV.addEvent(ExpandLink, 'click', Basket.ExpandBasket, false);
	 	}
	 
	 	if (document.getElementById('tblBasketContractLink')) {
	 		var ContractLink = document.getElementById('tblBasketContractLink');
	 		eV.addEvent(ContractLink, 'click', Basket.ContractBasket, false);
	 	} 	
	 },*/
	 
	 Expand: function() {
			/* var target = window.event ? window.event.srcElement : e ? e.target : null;
    	  	 if (!target) return;
    	  	 
    	  	 alert("Expand Clicked"); */
    	  	 
    	  	 var url = "/cfc/shopper/basketContents.cfc?method=getRemote&Action=Expand";
    	  	 
    	  	 //Refresh view and expand basket
			 TAC.send(url, "Expand");
			 //FX.Big();
    	  	 //FX.Fade();
    	  	 /*if (window.event) {
			      window.event.cancelBubble = true;
			      window.event.returnValue = false;
			      return;
			  }
			  
			  if (e) {
			  	  e.stopPropagation();
			      e.preventDefault();
			  }*/		
	 },
	 
	 Contract: function() {
	 		/*var target = window.event ? window.event.srcElement : e ? e.target : null;
    	  	if (!target) return;*/
    	  	
    	  	var url = "/cfc/shopper/basketContents.cfc?method=getRemote&Action=Contract";
    	  	
    	  	//Refresh view and contract basket
			TAC.send(url, "Contract");
    	  	//FX.Small();
    	  	//FX.Fade();
    	  /*	 if (window.event) {
			      window.event.cancelBubble = true;
			      window.event.returnValue = false;
			      return;
			  }
			  
			  if (e) {
			  	  e.stopPropagation();
			      e.preventDefault();
			  }		
		*/
	 },
	 
	 // this function is called when the a shopper clicks "Add"
	 Add: function(e) {
		  var target = window.event ? window.event.srcElement : e ? e.target : null;
    	  if (!target) return;
	  	  
		  	
	  	  //double check ProductID is in URL and get the value for the key ProductID
	  	  if (target.href.search(/ProductID/) != -1) {
			  var myProductID = Basket.URLgetValueFromKey(target.href, "ProductID");
    	      
    	      
    	      //check for quantity
    	      var myProductQty = 1;
    	      var myProductQtyFldVal="";
    	      if (document.getElementById("BsQty" + myProductID) && document.getElementById("BsQty" + myProductID).value != null) {
    	      	myProductQtyFldVal = document.getElementById("BsQty" + myProductID).value;
    	      	
    	      	//is it a number between 1 and 999  regex: ^\d{1,3}$;
    	      	if (myProductQtyFldVal.search(/^\d{1,3}$/) == -1) {
    	      	 	alert("Please enter a quanity between 1 and 999, thanks");
    	      		return;
    	      	}	// a valid quanity value has been given
    	      		else {
    	      		myProductQty = myProductQtyFldVal;
    	      	} //end regex check
    	      } //end quantity check
    	      
    	      
    	   	      
    	      var url = "/cfc/shopper/basketContents.cfc?method=addRemote&ProductID=" + myProductID + "&qty=" + myProductQty;
    	      
    	      //send ProductID via Taconite client and refresh the shopping basket view
			  TAC.send(url, "Add",1);
			  //FX.Increment();
			  //FX.Fade();	 			  
		  	  // cancel the href action of the link and stop propogation/event bubbling
		  	  if (window.event) {
			      window.event.cancelBubble = true;
			      window.event.returnValue = false;
			      return;
			  }
			  
			  if (e) {
			  	  e.stopPropagation();
			      e.preventDefault();
			  }
		  
		  } else {
		  return; //not found, exit out of function	
	  	  }
  	 },//end of function
  	 
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
/* ------------------/ PRODUCT INFO ------------------------------------------ */
/*******************************************************************************/ 
 
 
 var pINFO = {
 	//disable links and add rollover
 	addRO: function() {
 		
 			//grab the prodinfo links and add listeners
			var Links = document.getElementById('productList').getElementsByTagName('a');
  	  
  	  		//iterate through them and add the listener: "getInfo"
			for (var i = 0; i < Links.length; i++) {
	     		
	     		//if the link has a class of "prodinfo" add the listeners
	     		if (Links[i].className && (' ' + Links[i].className + ' ').indexOf(' prodinfo ') != -1) {  		    
					eV.addEvent(Links[i], 'mouseover', pINFO.getInfo, false);
					eV.addEvent(Links[i], 'mouseout',  pINFO.clearData, false);
					eV.addEvent(Links[i], 'click', 	   pINFO.stopBubble, false);
	     		 	Links[i].onclick = function() { return false; }; // Safari			
	  	   		} //end if
	    	} //end for		
 		
 	},
 	 	
 	// creates new Taconite Ajax Request Object and requests product info from the cfc
 	getData: function(url, postReq) {
				var ajaxRequest = new AjaxRequest(url);
                //ajaxRequest.setEchoDebugInfo();
		        ajaxRequest.setPostRequest(pINFO.removeLoadingText);
		        ajaxRequest.sendRequest();	
	},
	
 	// if set to true allows mouseover to get more information for a product
 	allowMouseOver: function(isAllowed) {
 	
 		if (isAllowed) {
 			pINFO.isAllowed=true;
 		} else {
 			pINFO.isAllowed=false;	
		} 
 	
 	},
 		
 	isAllowed: true,
 	
 		
 	// gets product info for selected item
 	getInfo: function(e) {
 			 
 			 //if (!pINFO.isAllowed) return;
 			 
 			 //disable repetition within 1/5 second
 			 //pINFO.allowMouseOver(false);
 			 					 
 			 pINFO.clearData();	 			 //clear any existing div	 
 			 target = eV.find_target(e); // get the target element
 			 pINFO.stopBubble(e);	//stop the event bubbling up the DOM tree!
 			 		 
 			 pInfoDiv = pINFO.createDIV();  //create the DIV element
 			 // offset Element is parent (table cell)
 			 //alert(document.getElementById(target.id).parentNode.nodeName);
 			 offsetEl = document.getElementById(target.id);
			 offsetEl.appendChild(pInfoDiv); //add the pINFODiv to our page
 			 pINFO.setOffsets();      //set it's style and positions
			 
			 //prepare AJAX/Taconite request
			 var myProductID = Basket.URLgetValueFromKey(target.href, "ProductID");	   	      
    	     var url = "/cfc/departments/view.cfc?method=prodInfoRemote&ProductID=" + myProductID + "&TargetID=pInfoDivContent";
			 pINFO.setLoadingText(); //set loading text
			 pINFO.getData(url, 'pINFO.removeLoadingText'); //send request
 						
 	},
 	
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
	},
	
	
 	//sets offsets based upon the source object or parent of source object
 	setOffsets: function() {
 		var end = offsetEl.offsetWidth;
 		var top = pINFO.calcOffsetTop(offsetEl);
 		//pInfoDiv.style.border="1px solid black";
 		pInfoDiv.style.left = end - 570 + "px";
 		//pInfoDiv.style.top = top + "px";
 		pInfoDiv.style.top = "-75px";	
 	},
 	
 	calcOffsetTop: function(field) {
 		return pINFO.calcOffset(field, "offsetTop");
 	},
 	
 	
 	calcOffset: function(field, attr) {
 		var offset = 0;
 		while(field) {
 			offset += field[attr];
 			field = field.offsetParent;
 		
 		}
 		return offset;
 	},
 	
 	//clears data
 	clearData: function() {
		//set back to true after 1/5 second has passed
  		pINFO.removeDIV();
 		pINFO.removeLoadingText();
		//setTimeout("pINFO.allowMouseOver(true)", 100);
 	},
 
	
	// sets text within pinfo div to "loading...";
 	setLoadingText: function() {
 			var span = document.createElement('span');
				span.setAttribute('id', 'pInfoDiv-loading');
			
			var txtNode = document.createTextNode("Loading data..."); 	
 			span.appendChild(txtNode);
 			document.getElementById('productList').appendChild(span);
 			
 	},
	
	//removes "loading..." text
	removeLoadingText: function() {
		 if (document.getElementById('pInfoDiv-loading')) {
			var el = document.getElementById('pInfoDiv-loading');
			document.getElementById('pInfoDiv-loading').parentNode.removeChild(el);
		}
	},
	
	// returns a DIV element
 	createDIV: function() {
 			//create outer div
 			var div = document.createElement('div');
				div.setAttribute('id', 'pInfoDiv');			
 			
 			var divContent = document.createElement('div'); 			
 			divContent.setAttribute('id', 'pInfoDivContent');
 			
 			div.appendChild(divContent);
 			
 			/*create header
 			var hd = document.createElement('div');
				hd.setAttribute('id', 'pInfoDiv-hd');	
			
			//create body	
			var body = document.createElement('div');
				body.setAttribute('id', 'pInfoDiv-body');	
			
			//create footer	
			var foot = document.createElement('div');
				foot.setAttribute('id', 'pInfoDiv-foot');
							
 			//createer inner div 			
 			var innerDiv = document.createElement('div');
 				innerDiv.setAttribute('id', 'pInfoInnerWrap');
 				
 			// build the div and child divs			
 			div.appendChild(hd);
 			div.appendChild(body);
 			div.appendChild(foot);
 			body.appendChild(innerDiv);
 			*/
 					
 			return div;
 	},
 	
 	// removes a DIV element
 	removeDIV: function() {
 		  if (document.getElementById('pInfoDiv')) {
 		  	var el = document.getElementById('pInfoDiv');
		  	document.getElementById('pInfoDiv').parentNode.removeChild(el);
		  }
 	}	 
 }
 
 /*******************************************************************************/
/* ------------------/ RECIPE INFO ------------------------------------------ */
/*******************************************************************************/ 
 
 var rINFO = {
 
 		//disable links and add rollover
 	addRO: function() {
 		
 			//grab the prodinfo links and add listeners
			var Links = document.getElementById('productList').getElementsByTagName('a');
  	  
  	  		//iterate through them and add the listener: "getInfo"
			for (var i = 0; i < Links.length; i++) {
	     		
	     		//if the link has a class of "prodinfo" add the listeners
	     		if (Links[i].className && (' ' + Links[i].className + ' ').indexOf(' recipeinfo ') != -1) {  		    
					eV.addEvent(Links[i], 'mouseover', rINFO.getInfo, false);
					eV.addEvent(Links[i], 'mouseout',  pINFO.clearData, false);	
	  	   		} //end if
	    	} //end for		
 		
 	},
 	
 	
 	// gets product info for selected item
 	getInfo: function(e) {
 			 					 
 			 pINFO.clearData();	 			 //clear any existing div	 
 			 target = eV.find_target(e); // get the target element
 			 pINFO.stopBubble(e);	//stop the event bubbling up the DOM tree!
 			 
 			 pInfoDiv = pINFO.createDIV();  //create the DIV element
 			 // offset Element is parent (table cell)
 			 offsetEl = document.getElementById(target.id);
			 offsetEl.appendChild(pInfoDiv); //add the pINFODiv to our page
 			 
 			 var showPosition = rINFO.setOffsets();      //set it's style and positions
			 
			 //prepare AJAX/Taconite request
			 var myProductID = Basket.URLgetValueFromKey(target.href, "ProductID");	   	      
    	     var url = "/cfc/departments/view.cfc?method=recipeInfoRemote&ProductID=" + myProductID + "&TargetID=pInfoDivContent&showPosition=" + showPosition;
			 pINFO.setLoadingText(); //set loading text
			 pINFO.getData(url, 'pINFO.removeLoadingText'); //send request
 						
 	},
 	
 	 	//sets offsets based upon the source object or parent of source object
 	setOffsets: function() {
 		var end = offsetEl.offsetWidth;
 		var top = pINFO.calcOffsetTop(offsetEl);
 		
 		//find tr parent element id 
 		// all tr elements have row(number) as ID (generated by XWTABLE) 
 		//i.e. row1 through to row1000
 		// depending on how many rows are generated on page
 		var pid = rINFO.ascendDOM(offsetEl, "tr", "id");
 		pid = pid.replace("row", "");
 		
 		// change position of recipe info depending on which row the mouseover event occurs
 		// if at top of top table i.e. row number less than or equal to 6
 		if (pid <= 6) {
 			pInfoDiv.style.left = end - 550 + "px";
 			pInfoDiv.style.top = "-95px";
 			return "mid";
 		} 
 		// if at bottom of table
 			else {
 			pInfoDiv.style.left = end - 550 + "px";
 			pInfoDiv.style.top = "-240px";
 			return "high";
 		}	
 	},
 	
 	//ascends DOM from the source element (el) looking for a (tagN) type element
 	//and returns a specified attribute (attr)
 	ascendDOM: function(el, tagN, attr) {
 		//while  (el.nodeName.toLowerCase() != tagN && 
 		    //    el.nodeName.toLowerCase() != 'html')
 	    el = el.parentNode.parentNode;
 	    
 	   return (el.nodeName.toLowerCase() == 'html') ? null: el[attr];
 	
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




/************************************************************************************************************
(C) www.dhtmlgoodies.com, September 2005
This is a script from www.dhtmlgoodies.com. You will find this and a lot of other scripts at our website.	
Terms of use:
See http://www.dhtmlgoodies.com/index.html?page=termsOfUse
Thank you!
www.dhtmlgoodies.com
Alf Magne Kalleland
************************************************************************************************************/		

var DHTMLG = {
	slideDownInitHeight: new Array(),	
	slidedown_direction: new Array(),
	slidedownActive: false,
	slidedownContentBox: "",
	slidedownContent: "",
	contentHeight: false,
	slidedownSpeed: 5, 	// Higher value = faster script
	slidedownTimer: 6, // Lower value = faster script
	slidedown_init: function() {
		var mySlideDownLink = document.getElementById('sortHelp');
		var close_mySlideDownLink = document.getElementById('closeHelp');
		eV.addEvent(mySlideDownLink, 'click', DHTMLG.slidedown_showHide, false);
		eV.addEvent(close_mySlideDownLink, 'click', DHTMLG.slidedown_showHide, false);
	},
	slidedown_showHide: function(e) {
		target = eV.find_target(e); // get the target element
		boxId = 'sortHelpWrapper';
		
		if(!DHTMLG.slidedown_direction[boxId])DHTMLG.slidedown_direction[boxId] = 1;
		if(!DHTMLG.slideDownInitHeight[boxId])DHTMLG.slideDownInitHeight[boxId] = 0;
		
		if(DHTMLG.slideDownInitHeight[boxId]==0)DHTMLG.slidedown_direction[boxId]=DHTMLG.slidedownSpeed; else DHTMLG.slidedown_direction[boxId] = DHTMLG.slidedownSpeed*-1;
		
		DHTMLG.slidedownContentBox = document.getElementById(boxId);
		var subDivs = DHTMLG.slidedownContentBox.getElementsByTagName('DIV');
		for(var no=0;no<subDivs.length;no++){
			if(subDivs[no].className=='helpHintcontent') DHTMLG.slidedownContent = subDivs[no];	
		}

		DHTMLG.contentHeight = DHTMLG.slidedownContent.offsetHeight;
	
		DHTMLG.slidedownContentBox.style.visibility='visible';
		DHTMLG.slidedownActive = true;
		DHTMLG.slidedown_showHide_start(DHTMLG.slidedownContentBox,DHTMLG.slidedownContent);	
		
	}, 
	 slidedown_showHide_start: function(slidedownContentBox,slidedownContent)
	{

		if(!DHTMLG.slidedownActive)return;
		DHTMLG.slideDownInitHeight[slidedownContentBox.id] = DHTMLG.slideDownInitHeight[slidedownContentBox.id]/1 + DHTMLG.slidedown_direction[slidedownContentBox.id];
		if(DHTMLG.slideDownInitHeight[slidedownContentBox.id] <= 0){
			DHTMLG.slidedownActive = false;	
			slidedownContentBox.style.visibility='hidden';
			DHTMLG.slideDownInitHeight[slidedownContentBox.id] = 0;
		}
		if(DHTMLG.slideDownInitHeight[slidedownContentBox.id]>DHTMLG.contentHeight){
			DHTMLG.slidedownActive = false;	
		}
		slidedownContentBox.style.height = DHTMLG.slideDownInitHeight[slidedownContentBox.id] + 'px';
		slidedownContent.style.top = DHTMLG.slideDownInitHeight[slidedownContentBox.id] - DHTMLG.contentHeight + 'px';

		setTimeout('DHTMLG.slidedown_showHide_start(document.getElementById("' + slidedownContentBox.id + '"),document.getElementById("' + slidedownContent.id + '"))',DHTMLG.slidedownTimer);	// Choose a lower value than 10 to make the script move faster
	},
	setSlideDownSpeed: function(newSpeed)
	{
		DHTMLG.slidedownSpeed = newSpeed;
	}
}

	
	
	
	