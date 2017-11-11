/******************************** Table Javascript Library ************************************/
/* Object descriptions:
   1) tBL: initalises other methods and adds events
   2) aJ: handles Sarissa calls to table.cfc 
   3) tTip: (bubble tooltip courtesy of Alessandro Fulciniti) 
   	  Script uses title elemement in the anchor tag for it's bubble.
   4) fHandler (form handler): Cancels form submissions instead using redirects and 
   	 query string to perform desired action. Use for the table column filter at present. 
   	 It could be extended for other features
   5) tFilt: Shows and hides (cancels) the column filter
   6) tRow: Adds table row rollovers
   7) util: utility functions i.e. retScriptname returns the script name without the query string 

*/

/*******************************************************************************/
/* ------------------/ XWIDGET: TABLE Library /-------------------------*/
/*******************************************************************************/ 
var xw = {
	init : function(){
		if (document.getElementsByTagName('table')) {
		xw.xwTable.init();
		}
	}, 
	
	xwTable: {
	 	init: function() {
		xw.xwTable.tRow.init(); // add row highlighting
		xw.xwTable.tFilt.init(); // add the ability to filter on data rows
		xw.xwTable.tForm.init();
		//DEBUG ONLY alert(xw.eV.evList); // display the list of objects which have had listeners added.
		//tTip.enableTooltips('tblNav');
		
		},	
		
		
		UI : {
		
			setLoading: function() {
			// displays (set) or clears (clear) a loading message;
				var xwTableEl = xw.xwTable.UI.getTableEl();
				
				//create table cover
				var tableCover = document.createElement('div');				
				tableCover.setAttribute("id", "xwTableCover");
				tableCover.setAttribute("style", "position: relative; background-color: #f2f2f2; z-index: 99999; filter:alpha(opacity=50);-moz-opacity:.50;opacity:.50;");
				
				//create span element
				var span = document.createElement('span');
				span.setAttribute("style", "position: absolute; right: 3em; top: 5em; color: #393939; font-size: 1.8em; width: 450px; z-index: 999999");
				span.setAttribute("id", "tblLoadingTxt");
				//create text node
				var loadingTxt = document.createTextNode("Loading ..."); 
				
				// add the text to the span, add the tablecover to the form element and make the table a child of the tablecover
				span.appendChild(loadingTxt);			
				
				// insert the table cover infront of the form element which wraps our table in the DOM tree
				document.getElementById('content').insertBefore(tableCover, xwTableEl.parentNode);
				//tableCover.appendChild(span);
				document.getElementById('content').insertBefore(span, tableCover); // put our loading text in place
				//now put our form and table inside the div, using appendChild to move the element
				tableCover.appendChild(xwTableEl.parentNode); 
				//alert(tableCover.childNodes[0].id);
				//xwTableEl.parentNode.appendChild(span);
				//xwTableEl.parentNode.appendChild(tableCover);
				//tableCover.appendChild(xwTableEl); //appendChild can be used to move an element 
				
			},
			
			clearLoading: function() {
				xw.xwTable.UI.opacity("xwTableCover", 50, 0, 400);
				setTimeout("xw.xwTable.UI.clearTidyUp()",400);				
				document.getElementById('tblLoadingTxt').parentNode.removeChild(document.getElementById("tblLoadingTxt"));
					
			},
			
			clearTidyUp: function() {
				var xwTableEl = xw.xwTable.UI.getTableEl();
				var tableCover = document.getElementById('xwTableCover');
				document.getElementById('content').insertBefore(xwTableEl.parentNode, tableCover);
				document.getElementById('content').removeChild(tableCover);
			},
			
			
			// v1.3 courtesy http://www.brainerror.net/scripts_js_blendtrans.php
			opacity: function(id, opacStart, opacEnd, millisec) {
			    //speed for each frame
			    var speed = Math.round(millisec / 100);
			    var timer = 0;
			
			    //determine the direction for the blending, if start and end are the same nothing happens
			    if(opacStart > opacEnd) {
			        for(i = opacStart; i >= opacEnd; i--) {
			            setTimeout("xw.xwTable.UI.changeOpac(" + i + ",'" + id + "')",(timer * speed));
			            timer++;
			        }
			        return true;
			    } else if(opacStart < opacEnd) {
			        for(i = opacStart; i <= opacEnd; i++)
			            {
			            setTimeout("xw.xwTable.UI.changeOpac(" + i + ",'" + id + "')",(timer * speed));
			            timer++;
			        }
			        return true;
			    }
			},
			
			
			// v1.3 courtesy http://www.brainerror.net/scripts_js_blendtrans.php
			//change the opacity for different browsers
			changeOpac:  function(opacity, id) {
			    var object = document.getElementById(id).style;
			    object.opacity = (opacity / 100);
			    object.MozOpacity = (opacity / 100);
			    object.KhtmlOpacity = (opacity / 100);
			    object.filter = "alpha(opacity=" + opacity + ")";
			}, 	
			
			getTableEl: function() {
			
			
			//1 Locate the Table
			var xwTableEl = "";
			if (document.getElementById("thead_cols")) {
			  // ascend DOM looking for form element
			  var formEl = "";
			  var thisEl = document.getElementById("thead_cols");
			 //walk up from child to parent
			 	while (thisEl.parentNode) {
			 		if (thisEl.parentNode.nodeName.toLowerCase() == "table") {
			 			xwTableEl = thisEl.parentNode;
			 			break;	//job done! stop the looop!
			 		}
			 		thisEl = thisEl.parentNode;
		 		}				
			 return xwTableEl;	
			} else {
			 return null;	
			}
			}	
		},
		
		
		// ******************************** Table Filter ********************************** //
		tFilt: {
			init: function() {
				//alert("add the click events to showFilter and hideFilter");
				if (document.getElementById('showFilter')) {
				var showLink = document.getElementById('showFilter');
				xw.eV.removeEvent(showLink, 'click', ALINK.forward, false);
				xw.eV.addEvent(showLink, 'click', xw.xwTable.tFilt.addFilter, false);
				}
				
				if (document.getElementById('hideFilter')) {
				var hideLink = document.getElementById('hideFilter');
				xw.eV.removeEvent(hideLink, 'click', ALINK.forward, false);
				xw.eV.addEvent(hideLink, 'click', xw.xwTable.tFilt.removeFilter, false);
				}
			},
			
						
			addFilter: function(e) {
				if (document.getElementById('tblFilter')) {
				return;
				}
				
						
				// * -----------  Select the first data row in the table --------------- * //
				// get the tbody element
				var tbodyEL = document.getElementById('tbodydatarows');
						
				// get the first row
				var FirstTableRow = tbodyEL.getElementsByTagName('tr')[0];
		
				// * -----------  Build the elements to append --------------- * //
				
				//Build a new table row
				var newrow = document.createElement('tr');
				newrow.setAttribute("id", "tblFilter");
				newrow.setAttribute("name", "tblFilter");
					
						
				// * -----------  Build table cell elements  ----------------------- --------------- * //
				//how many columns are in our table?
				var theadEL = document.getElementById('thead_cols');
				
				var tbl_columns = theadEL.getElementsByTagName('th');
				var tbl_column_count = tbl_columns.length;
				
					
				//iterate through the columns to determine if they are any header table columns or custom columns
				for (var i = 0; i < tbl_column_count; i++) {
					
					// find data row columns: they have an ID attribute, navigation header columns don't
					if (tbl_columns[i].id) {
				
					//create a table cell element 
					var newcell = document.createElement('td');
					//set the class for left most and righter most cells
					if (i ==1) {
						newcell.setAttribute("class", "lhscol");
					} else if (i == (tbl_column_count -1) ) {
						newcell.setAttribute("class", "rhscol");
					}
					
								
						// use pattern match to check this is not a custom column, the word "custom" is part of ID attribute 
						if (tbl_columns[i].id.search(/custom/) == -1) {
							
							// get the name of the column to use as input elements id attribute
							var table_col_name = "";
							table_col_name = tbl_columns[i].id.replace(/col[0-9]_/, "");
														
							//espace and unescape hint from http://jennifermadden.com/javascript/stringEscape.html
							
							//remove unwanted characters in column name
							table_col_name = escape(table_col_name);
							var replaceWith="";
							
							// remove all occurences (g) of:
							//  (%0A) : linefeed, (%0D): carriage return, (%09): tab and (%20): space
												
							if(table_col_name.indexOf("%0A") > -1){
								table_col_name=table_col_name.replace(/%0A/g,replaceWith)
							}
							
							if(table_col_name.indexOf("%0D") > -1){
									table_col_name=table_col_name.replace(/%0D/g,replaceWith)
							}
										
							if(table_col_name.indexOf("%09") > -1){
								table_col_name=table_col_name.replace(/%09/g,replaceWith)
							}
											
							if(table_col_name.indexOf("%20") > -1){
								table_col_name=table_col_name.replace(/%20/g,replaceWith)
							}
							
							//alert(table_col_name);
							table_col_name = unescape(table_col_name);
							
							// * -----------  Build form input elements  ----------------------- --------------- * //
							var inputEl_name = "frmFilter_"+table_col_name;					
							
							//create an input element 	
							var inputEl = document.createElement('input');
							inputEl.setAttribute("id", inputEl_name);
							inputEl.setAttribute("name", inputEl_name);
							inputEl.setAttribute("class", "frmFilterFld");
							inputEl.setAttribute("type", "text");
							
							//Check if width attribute is set for the thead column
							if (document.getElementById("col" + i)) {
							   var inputEl_colwidth = document.getElementById("col" + i).style.width;
							   //replace the "px"
							   inputEl_colwidth = inputEl_colwidth.replace("px","");
							   if (inputEl_colwidth >= 300) inputEl_colwidth = 250;
							   var inputEl_styleWidth = "width: " + (inputEl_colwidth - 22) + "px";
							   //alert(inputEl_styleWidth);
							   inputEl.setAttribute("style", inputEl_styleWidth);
							}					
							
							// add the input element to the table cell					
							newcell.appendChild(inputEl);				
							}
		
						//add the cell element to the table row 
						newrow.appendChild(newcell);
					}			
				}	
				
				//insert new row before first row
				tbodyEL.insertBefore(newrow, FirstTableRow);
				
			  // add the keypress listeners to handle "enter" key press
			  xw.xwTable.tForm.inputListeners();
				
			  // stop the event propogating and causing the form submit event to fire
			  if (e && e.stopPropagation && e.preventDefault) {
		        e.stopPropagation();
		        e.preventDefault();
		      }
		      
		      if (window.event) {
		        window.event.cancelBubble = true;
		        window.event.returnValue = false;
		      }
					
			},
			
			removeFilter: function(e) {
				if (document.getElementById('tblFilter')) {
				 
					 // get the filter element
				 	 var filterEl = document.getElementById('tblFilter');
				 	
				 	//remove it from the parent node
				 	 filterEl.parentNode.removeChild(filterEl);
				}
		 
			 	xw.xwTable.tForm.saveFilter(null, null);
			
				  // stop the event propogating and causing the form submit event to fire
				  if (e && e.stopPropagation && e.preventDefault) {
			        e.stopPropagation();
			        e.preventDefault();
			      }
			      
			      if (window.event) {
			        window.event.cancelBubble = true;
			        window.event.returnValue = false;
			      }
			}
		},
		
		// ******************************** Form submit handler ********************************** //
		tForm : {
				init: function() {
					
					/* locate thead_cols and ascend the dom to find the form. This is much safer than any other method 
					as multiple tables can be used or forms without causing a problem with this method */
					if (document.getElementById("thead_cols")) {
						 // ascend DOM looking for form element
						 var formEl = "";
						 var thisEl = document.getElementById("thead_cols");
							 //walk up from child to parent
						 while (thisEl.parentNode) {
						 	if (thisEl.parentNode.nodeName.toLowerCase() == "form") {
						 		xw.eV.addEvent(thisEl.parentNode, 'submit', xw.xwTable.tForm.submitHandler, false);	
						 		break;	//job done! stop the looop!
						 	}
						 	thisEl = thisEl.parentNode;
						 }				
					}	
																									
					
					if (document.getElementById('tblFilter')) {
						xw.xwTable.tForm.inputListeners();
					}
					//frm.onsubmit = fHandler.submitHandler; // Safari
				},
				
				
				// add the input listeners. called from addFilter() when dynamically add input elements
				inputListeners: function() {	
					if (document.getElementsByTagName('input')) {
						var inputElms = document.getElementsByTagName('input');
						 //alert("setting input listeners");
						 for (var x = 0; x < inputElms.length; x++) {
							xw.eV.addEvent(inputElms[x], 'keypress', xw.xwTable.tForm.keycodeHandler, false);		
						}
					}
				},
				
				
				saveFilter: function(filterCol, fieldValue) {
				/* Saves the filter by adding filter parameters to our URL
				1) Get the FORM ACTION URL
				2) Remove Filter Attributes if contained in the URL
				3) Send our XHTTP GET request to refresh the table
				*/		
				
				var requestURL = document.getElementById("products").action;
				requestURL = xw.UTIL.removeURLAttrib(requestURL, "&tblfilter=");
				requestURL = xw.UTIL.removeURLAttrib(requestURL, "&q=");
				requestURL = xw.UTIL.addURLAttrib(requestURL, "tblfilter", filterCol);
				requestURL = xw.UTIL.addURLAttrib(requestURL, "q", fieldValue);
				//	alert(requestURL);
				
				//xw.xwTable.UI.setLoading();
				xw.DATA.get(requestURL);				
				},
				
				// listeners for key press and sets the filter
				keycodeHandler: function(e) {
				  	  var k = window.event ? window.event.srcElement : e ? e.target : null;
		         	  	  	         	  	  
		         	  	  if (!k) return;
				
					  if (e && e.which) {
					  	var code = e.which;
					  } else if (e && e.keyCode) {
					  	var code = e.keyCode
					  }	else if (window.event && window.event.keyCode) {
					  	var code = window.event.keyCode;
					  } else {
					  return;
					  }
				
					 // if enter is pressed
					 if (code == 13) {
					 	var dbColName = "";
					 	var fieldValue = "";
					 	dbColName = k.id.replace(/frmFilter_/, "");
					 	fieldValue = document.getElementById(k.id).value;
					 	//save the filter
					 	xw.xwTable.tForm.saveFilter(dbColName, fieldValue);
					 }	
				},
				
				
				submitHandler: function(e) {
		  			  var frm = window.event ? window.event.srcElement : e ? e.target : null;
		         	  if (!frm) return;
				 				
					  // stop the event propogating and causing the form submit event to fire
					  if (e && e.stopPropagation && e.preventDefault) {
				        e.stopPropagation();
				        e.preventDefault();
				      }
				      
				      if (window.event) {
				        window.event.cancelBubble = true;
				        window.event.returnValue = false;
				      }
				xw.xwTable.tForm.saveFilter();
				}
		},
		

		// ******************************** Roll rollover ********************************** //
		 tRow:  {
			init: function() {
				
				
				// add row mouseover and mouseout functions
				var rows = document.getElementsByTagName('tr');
				for (var i = 0; i < rows.length; i++) {
					xw.eV.addEvent(rows[i], 'mouseover', xw.xwTable.tRow.hilite, false);
					xw.eV.addEvent(rows[i], 'mouseout',  xw.xwTable.tRow.hiliteoff, false);
				}
			},
			
			// row mouseover
			hilite: function(e) {
				var target = window.event ? window.event.srcElement : e ? e.target : null;
		    		if (!target) return;
			
				//is the target a row or cell?
					if (target.id == "") {
						var parent = target.parentNode;
						parent.className += ' hilite';		
						} else {
						 target.className += ' hilite';
					}
				},
			
			// row mouseout
			hiliteoff: function(e) {
		
				var target = window.event ? window.event.srcElement : e ? e.target : null;
		    		if (!target) return;
		
				//is the target a row or cell?
				if (target.id == "") {
					var parent = target.parentNode;
					parent.className = parent.className.replace('hilite', '');
					} else {
					target.className = target.className.replace('hilite', '');
					}
				}
		} //END xw.xwTable.tRow
		
	}, // END xw.xwTable	

	 /*******************************************************************************/
	/* ------------------/ DATA (remoteData rD) FUNCTIONS /-------------------------*/
	/*******************************************************************************/ 
	DATA : {
		// creates new Taconite Ajax Request Object and requests product info from the cfc
	 		get: function(url, postReq) {
					var ajaxRequest = new AjaxRequest(url);
	                		ajaxRequest.setEchoDebugInfo();
			        	ajaxRequest.setPreRequest(xw.xwTable.UI.setLoading);
			        	ajaxRequest.setPostRequest(xw.xwTable.UI.clearLoading);
			        	ajaxRequest.sendRequest();	
			}	
	},
	
	
	 /*******************************************************************************/
	/* ------------------/ UTILITY FUNCTIONS /------------------------------------- */
	/*******************************************************************************/ 
	UTIL : {
		addURLAttrib: function(URL, attrib, val) {
		// adds the attribute to the URL	
		return URL + "&" + attrib + "=" + val;	
			
		},
				
		/* removes certain URI attributes from the URI and returns it clean. 
		   Used primarily by the row filter so when a filter is set more than once 
		   only one set of URI attributes persist */
		removeURLAttrib: function(URL, attrib) {
			// find the first character of the attribute in our URL
			var attribStart=URL.indexOf(attrib);
			if (attribStart!=-1) { // if we found it
				// find the end
				var attribEnd = URL.indexOf("&",attribStart); 
				return URL.replace(URL.substring(attribStart, (attribEnd+1)), "");
			} else {
				return URL; //if the attribute is not there, return URL 'as is'
			}
		},
		
		
		 //function to retrieve the value from key/value pair in the url scope
		URLgetValueFromKey: function(URL, key) {
		  	 	
		  	 	var N_StartOfKey 	= URL.indexOf(key); //find the start of the key
		  	 	var N_EndOfKey 		= URL.length; //by default end of key is end of URL
		  	 	
		  	 	// if not found, exit function
		  	 	if (N_StartOfKey == -1) return;
		  	 	  	 	
		  	 	// now truncate the first part of the URL leaving everything after the Key we are looking for
		  	 	var myVal 	= URL.substring((N_StartOfKey+key.length+1),URL.length);
		  	 	
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
		  	 
		}, // end xw.UTIL
	
	
		 /*******************************************************************************/
		/* ------------------/ EVENT Setup /------------------------------------------- */
		/*******************************************************************************/ 
		eV : {
		/**
		  * Crossbrowser event handling functions.
		  *
		  * A set of functions to easily attach and detach event handlers to HTML elements.
		  * These functions work around the shortcomings of the traditional method ( element.onevent = function; )
		  * where only 1 handler could be attached for a certain event on the object, and mimic the DOM level 2
		  * event methods addEventListener and removeEventListener for browsers that do not support these
		  * methods (e.g. Internet Explorer) without resorting to propriety methods such as attachEvent and detachEvent
		  * that have a whole set of their own shortcomings.
		  * Created as an entry for the 'contest' at quirksmode.org: http://www.quirksmode.org/blog/archives/2005/09/addevent_recodi.html
		  *
		  * @author Tino Zijdel ( crisp@xs4all.nl )
		  * @version 1.2
		  * @date 2005-10-21
		  */
		
		
		/**
		  * addEvent
		  *
		  * Generic function to attach event listeners to HTML elements.
		  * This function does NOT use attachEvent but creates an own stack of function references
		  * in the DOM space of the element. This prevents closures and therefor possible memory leaks.
		  * Also because of the way the function references are stored they will get executed in the
		  * same order as they where attached - matching the behavior of addEventListener.
		  *
		  * @param obj The object to which the event should be attached.
		  * @param evType The eventtype, eg. 'click', 'mousemove' etcetera.
		  * @param fn The function to be executed when the event fires.
		  * @param useCapture (optional) Whether to use event capturing, or event bubbling (default).
		  */
		addEvent: function(obj, evType, fn, useCapture)
		{
			//-- Default to event bubbling
			if (!useCapture) useCapture = false;
		
			//-- DOM level 2 method
			if (obj.addEventListener)
			{
				obj.addEventListener(evType, fn, useCapture);
			}
			else
			{
				//-- event capturing not supported
				if (useCapture)
				{
					alert('This browser does not support event capturing!');
				}
				else
				{
					var evTypeRef = '__' + evType;
		
					//-- create function stack in the DOM space of the element; seperate stacks for each event type
					if (obj[evTypeRef])
					{
						//-- check if handler is not already attached, don't attach the same function twice to match behavior of addEventListener
						if (xw.eV.array_search(fn, obj[evTypeRef]) > -1) return;
					}
					else
					{
						//-- create the stack if it doesn't exist yet
						obj[evTypeRef] = [];
		
						//-- if there is an inline event defined store it in the stack
						if (obj['on'+evType]) obj[evTypeRef][0] = obj['on'+evType];
		
						//-- attach helper function using the DOM level 0 method
						obj['on'+evType] = xw.eV.IEEventHandler;
					}
		
					//-- add reference to the function to the stack
					obj[evTypeRef][obj[evTypeRef].length] = fn;
				}
			}
		},
		
		/**
		  * removeEvent
		  *
		  * Generic function to remove previously attached event listeners.
		  *
		  * @param obj The object to which the event listener was attached.
		  * @param evType The eventtype, eg. 'click', 'mousemove' etcetera.
		  * @param fn The listener function.
		  * @param useCapture (optional) Whether event capturing, or event bubbling (default) was used.
		  */
		removeEvent: function(obj, evType, fn, useCapture)
		{
			//-- Default to event bubbling
			if (!useCapture) useCapture = false;
		
			//-- DOM level 2 method
			if (obj.removeEventListener)
			{
				obj.removeEventListener(evType, fn, useCapture);
			}
			else
			{
				var evTypeRef = '__' + evType;
		
				//-- Check if there is a stack of function references for this event type on the object
				if (obj[evTypeRef])
				{
					//-- check if function is present in the stack
					var i = xw.eV.array_search(fn, obj[evTypeRef]);
					if (i > -1)
					{
						try
						{
							delete obj[evTypeRef][i];
						}
						catch(e)
						{
							obj[evTypeRef][i] = null;
						}
					}
				}
			}
		},
		
		/**
		  * IEEventHandler
		  * 
		  * IE helper function to execute the attached handlers for events.
		  * Because of the way this helperfunction is attached to the object (using the DOM level 0 method)
		  * the 'this' keyword will correctely point to the element that the handler was defined on.
		  *
		  * @param e (optional) Event object, defaults to window.event object when not passed as argument (IE).
		  */
		IEEventHandler: function(e)
		{
			e = e || window.event;
			var evTypeRef = '__' + e.type, retValue = true;
		
			//-- iterate through the stack and execute each function in the scope of the object by using function.call
			for (var i = 0, j = this[evTypeRef].length; i < j; i++)
			{
				if (this[evTypeRef][i])
				{
					if (Function.call)
					{
						retValue = this[evTypeRef][i].call(this, e) && retValue;
					}
					else
					{
						//-- IE 5.0 doesn't support call or apply, so use this
						this.__fn = this[evTypeRef][i];
						retValue = this.__fn(e) && retValue;
					}
				}
			}
		
			if (this.__fn) try { delete this.__fn; } catch(e) { this.__fn = null; }
		
			return retValue;
		},
		
		/**
		  * array_search
		  * 
		  * Searches the array for a given value and returns the (highest) corresponding key if successful, -1 if not found.
		  *
		  * @param val The value to search for.
		  * @param arr The array to search in.
		  */
		array_search: function(val, arr)
		{
			var i = arr.length;
		
			while (i--)
				if (arr[i] && arr[i] === val) break;
		
			return i;
		}
  
  	} // end of eV
} // xw