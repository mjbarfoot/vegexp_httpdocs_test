/*******************************************************************************/
//	File:			/js/qsaudit.js 										
//	Description: 	QS Audit Specific Methods/Objects/Setup
// 	Author: 		Matt Barfoot - Clearview Webmedia Limited
//  Date:			27/06/2007
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
	
	
	if (document.getElementById('tbodydatarows')) {
		// Initialise WORKORDER Details Table Expander
		TBL_EXPANDER.init(); 

		// table column sorting
		TBL_SORT.init();
		
		//Dynamic changing of result set via Taconite
		TBL_NAV.init();
	
		// form buttons, selecting and exporting records
		TBL_FORM.init();
		
		TBL_FORM_ACTION.init();
		
	}
	
	
	
	
	WOEXPORT.init();

	if (document.getElementById('qsa_filter_form')) WOFILTER.init();
	
	// Admin functions
	if (document.getElementById('qsa_admin')) ADMIN.init();
}


/*******************************************************************************/
/* ------------------/ Refresh Init FUNCTION /-------------------------------- */
/*******************************************************************************/ 

refresh_init = function() {
	
	AppVars.reqURL = UTIL.URLgetScriptName(location.href);	 
	if (AppVars.reqURL=="/") AppVars.reqURL="index.cfm";	
	
	
	if (document.getElementById('tbodydatarows')) {
		// Initialise WORKORDER Details Table Expander
		TBL_EXPANDER.init(); 
		
		// table column sorting
		TBL_SORT.init();	
		
		//Dynamic changing of result set via Taconite
		TBL_NAV.init();
		
		// form buttons
		TBL_FORM_ACTION.init();
	}
	
	
	WOEXPORT.init();
	
	// Admin functions
	if (document.getElementById('qsa_admin')) ADMIN.init();
	
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
/* ------------------/ WOEXPORT /----------------------------------------------*/
/*******************************************************************************/
WOEXPORT = {
	init: function() {
	
		if (document.getElementById('qsa_ah_linkOptionExport')) {
			var exportLinkHD = document.getElementById('qsa_ah_linkOptionExport');
			var exportLinkFT = document.getElementById('qsa_af_linkOptionExport');
			eV.addEvent(exportLinkHD, 'click', WOEXPORT.exportWO, false);
			eV.addEvent(exportLinkFT, 'click', WOEXPORT.exportWO, false);		
		}		

		if (document.getElementById('qsa_ah_linkOptionExportConfirm')) {
			var exportConfirmLinkHD = document.getElementById('qsa_ah_linkOptionExportConfirm');
			var exportConfirmLinkFT = document.getElementById('qsa_af_linkOptionExportConfirm');
			eV.addEvent(exportConfirmLinkHD, 'click', WOEXPORT.exportWOConfirm, false);
			eV.addEvent(exportConfirmLinkFT, 'click', WOEXPORT.exportWOConfirm, false);		
		}		
	},
	
	exportWO: function(e) {
		// get target
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return; 
			
		AJAX_LINKS.stopBubble(target);	//stop bubble			
		
		TabAction.changeTab("tabexport_workorders");
	},
	
	exportWOConfirm: function(e) {
				// get target
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return; 
		
		//alert("ack");
			
		AJAX_LINKS.stopBubble(target);	//stop bubble		
		
		//construct the URL and refresh the infoBar
		var moduleid = 'home';
		var tabid = 'export_workorders';
		var action = 'exportWO';
		var myURL = AppVars.reqURL + '?reqtype=tab&moduleid=' + moduleid + '&tabid=' + tabid 
		+ '&action=' + action;
		
		//prompt(myURL, myURL);
		// *** SEND REQUEST TO GET THE DATA
		AJAX_CLIENT.ShowLoadingDiv();
		AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); 
	}
}


 /*******************************************************************************/
/* ------------------/ TABLE SORT /---------------------------------*/
/*******************************************************************************/
TBL_SORT = {
	init: function() {
		//check we have the thead col table element in the DOM
		if (!document.getElementById('thead_cols')) return; 
		
		//grab all links in the header of the table
		var sortLinks = document.getElementById('thead_cols').getElementsByTagName('a');
		
		 for (var i=0; i<sortLinks.length; i++) {
			// if they have tblSort= in the href assign the sortByCol event 
			if (sortLinks[i].href.search('&tblsort=')!=-1) {
				eV.addEvent(sortLinks[i], 'click', TBL_SORT.sortByCol, false);
			} 
		 } 
	
	},
	
	sortByCol: function(e) {
		 // get target
		 var target = window.event ? window.event.srcElement : e ? e.target : null;
	     if (!target) return; 
		 
		 if (target.nodeName!="a") target=UTIL.ascendDOM(target, "a");
		
		AJAX_LINKS.stopBubble(e);
		
		//build the request URL
		var reqtype="widget";
		var action="xwtableColumnSort";
		var nodeID="qsa_wo_queue";
		var nodeAction="replace-children";
		var widgetid = document.getElementById('xwtableid').value;
		var widgettype = "xwtable";
		var sortcol = UTIL.URLgetValueFromKey(target.href, "tblsort");
						
		var myURL = AppVars.reqURL + "?reqtype=" + reqtype
		+ "&action=" + action + "&nodeID=" + nodeID + "&nodeAction=" + nodeAction
		+ "&widgetid=" + widgetid + "&widgettype=" + widgettype
		+ "&sortcol=" + sortcol;

		// *** SEND REQUEST TO GET THE DATA
		AJAX_CLIENT.ShowLoadingDiv();
		AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest

	}

}

/*******************************************************************************/
/* ------------------/ VIEW JOURNALS  /----------------------------------------*/
/*******************************************************************************/ 
JOURNALS = {
		init: function() {
				if (document.getElementById('btnviewjournals')) {
					eV.addEvent(document.getElementById('btnviewjournals'), 'click', JOURNALS.view, false);
				}
		},
		
		
		// called by Taconite after populating with Journal data
		navinit: function() {
				if (document.getElementById('JOURNAL_content')) {
					var navLinks = document.getElementById('JOURNAL_content').getElementsByTagName('a');
				
					 for (var i=0; i<navLinks.length; i++) {
						// iterate through checkboxes, are they checked?
						if (navLinks[i].id.search('JOURNAL_nav_')!=-1) {
							eV.addEvent(navLinks[i], 'click', JOURNALS.refreshData, false);
						} 
					}
				}
		},
		
		
		refreshData: function(e) {
			// get target
		 	var target = window.event ? window.event.srcElement : e ? e.target : null;
	     	if (!target) return; 
			
			AJAX_LINKS.stopBubble(e);	//stop bubble
					
			// if using an img for navigation
			if (target.nodeName!="a") target = UTIL.ascendDOM(target, 'a');
			
			
			//get the nav action
			var recAction = target.id.replace('JOURNAL_nav_', '');
			var recNumber = document.getElementById('recNumber').value;
			
			//build the request URL
			var reqtype="custom";
			var widgetid = "journal";
			var methodid = "get";
			var ElmID = "JOURNALdata";
			var paramVal = document.getElementById('woDetail_wonum').value;
				
					
			// Construct the GET URL
		 	var myURL = AppVars.reqURL + "?reqtype=" + reqtype
			+ "&widgetid=" + widgetid +  "&methodid=" + methodid
			+ "&ElmID=" + ElmID + "&paramVal=" + paramVal 
			+ "&recNumber=" + recNumber + "&recAction=" + recAction;

			// *** SEND REQUEST TO GET THE DATA
			AJAX_CLIENT.get(myURL, JOURNALS.setCloseEv); //no postrequest	
		},
			
		
		view: function(e) {
			// get target
		 	var target = window.event ? window.event.srcElement : e ? e.target : null;
	     	if (!target) return; 
			
			AJAX_LINKS.stopBubble(e);	//stop bubble
			
			JOURNALS.openDIV();
			
			//build the request URL
			var reqtype="custom";
			var widgetid = "journal";
			var methodid = "get";
			var ElmID = "JOURNALdata";
			var paramVal = document.getElementById('woDetail_wonum').value;
		
			// Construct the GET URL
		 	var myURL = AppVars.reqURL + "?reqtype=" + reqtype
			+ "&widgetid=" + widgetid +  "&methodid=" + methodid
			+ "&ElmID=" + ElmID + "&paramVal=" + paramVal;

			// *** SEND REQUEST TO GET THE DATA
			AJAX_CLIENT.get(myURL, JOURNALS.setCloseEv); //no postrequest	
		},

		openDIV: function() {
			var myDIV = document.createElement('div');
			myDIV.setAttribute('id', 'JOURNALdata');
 			document.getElementById('main').appendChild(myDIV);
		},
		
		closeDIV: function(e) {
			// get target
		 	var target = window.event ? window.event.srcElement : e ? e.target : null;
	     	if (!target) return; 
			
			AJAX_LINKS.stopBubble(e);	//stop bubble
			
			if (document.getElementById('JOURNALdata')) {
				var el = document.getElementById('JOURNALdata');
				document.getElementById('JOURNALdata').parentNode.removeChild(el);
			}
		
		},
		
		setCloseEv: function() {
			if (document.getElementById('close_JOURNALdata')) {
				eV.addEvent(document.getElementById('close_JOURNALdata'), 'click', JOURNALS.closeDIV, false);
			}
		}

}

 /*******************************************************************************/
/* ------------------/ FORM ACTION HANDLERS /---------------------------------*/
/*******************************************************************************/ 
TBL_FORM_ACTION = {
	init: function() {
		//Add Select Checkbox Events: Send Ajax event to woSelectList to add selected wonum
		 var woCheckBoxes = document.getElementById('tbodydatarows').getElementsByTagName('input');
	    
	    for (var i=0; i<woCheckBoxes.length; i++) {
			// iterate through checkboxes, are they checked?
			if (woCheckBoxes[i].type && woCheckBoxes[i].type=="checkbox" && woCheckBoxes[i].id.search('fldSelect')!=-1) { 
				eV.addEvent(woCheckBoxes[i], 'click', TBL_FORM_ACTION.woSelect, false);	
			}
		}
		
		//Add Selected Buttons
		if (document.getElementById('qsa_ah_linkOptionAddSelected')) {
			var addHeaderSelectedButtonEl = document.getElementById('qsa_ah_linkOptionAddSelected');
			var addFooterSelectedButtonEl = document.getElementById('qsa_af_linkOptionAddSelected');
			//Add events
			eV.addEvent(addHeaderSelectedButtonEl, 'click', TBL_FORM_ACTION.addSelected, false);	
			eV.addEvent(addFooterSelectedButtonEl, 'click', TBL_FORM_ACTION.addSelected, false);
		}
		
		//Add RemoveWO Action (Delete Icon)
		var RemoveWoLinks = document.getElementById('tbodydatarows').getElementsByTagName('a');
	    for (var i=0; i<RemoveWoLinks.length; i++) {
			// iterate through checkboxes, are they checked?
			if (RemoveWoLinks[i].id.search('removeWO_')!=-1) {
				eV.addEvent(RemoveWoLinks[i], 'click', TBL_FORM_ACTION.removeSelected, false);
			} 
		} 
		
		//Post Validated Buttons
		if (document.getElementById('qsa_ah_linkOptionPostValidated')) {
			var addHPostValidatedButtonEl = document.getElementById('qsa_ah_linkOptionPostValidated');
			var addFPostValidatedButtonEl = document.getElementById('qsa_af_linkOptionPostValidated');
			
			eV.addEvent(addHPostValidatedButtonEl, 'click', TBL_FORM_ACTION.postValidated, false);	
			eV.addEvent(addFPostValidatedButtonEl, 'click', TBL_FORM_ACTION.postValidated, false);
		}		
		
		//Confirm Validate
		if (document.getElementById('qsa_af_linkOptionValidateConfirm')) {
			var addFValidateConfirmedButtonEl = document.getElementById('qsa_af_linkOptionValidateConfirm');
			
			eV.addEvent(addFValidateConfirmedButtonEl, 'click', TBL_FORM_ACTION.validateConfirmed, false);	
		}
			
	},
	
	postValidated: function(e) {
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return;
	
	
        //construct the URL and refresh the infoBar
		var moduleid = 'home';
		var tabid = 'validate_workorders';
		//var tabid = 'audit_queue';
		//var action = 'post_validated';
		var myURL = AppVars.reqURL + '?reqtype=tab&moduleid=' + moduleid 
		+ '&tabid=' + tabid + '&validate_refesh=true';	
		
		AJAX_CLIENT.ShowLoadingDiv();
		AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest
		AJAX_LINKS.stopBubble(target);
	
	},
	
	validateConfirmed: function(e) {
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return;
	
        //construct the URL and refresh the infoBar
		var moduleid = 'home';
		var tabid = 'audit_queue';
		var action = 'post_validated';
		var myURL = AppVars.reqURL + '?reqtype=tab&moduleid=' + moduleid 
		+ '&tabid=' + tabid + '&action=' + action;	
		
		AJAX_CLIENT.ShowLoadingDiv();
		AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest
		AJAX_LINKS.stopBubble(target);
	
	},
	
	
	
	woSelect: function(e) {
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return; 
	    
	     //construct the URL and refresh the infoBar
		var moduleid = 'home';
		var tabid = 'audit_queue';
		var wonum = target.id.replace('fldSelect_', '');	
		var action = '';
		   
	    if (target.type && target.type=="checkbox") {
	    	if (target.checked==true) {
	  			action = 'AQSelectAdd';
	   		} else {
	   			action = 'AQSelectRemove';
	   		} 	
	    }
	    
	    var myURL = AppVars.reqURL + '?reqtype=void&moduleid=' + moduleid + '&tabid=' + tabid 
		+ '&action=' + action + '&wonum=' + wonum;
	    
	    AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest
	},
	
	addSelected: function(e) {
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return; 
	    
	    var WONUM_list = "";
	    var woCheckBoxes = document.getElementById('tbodydatarows').getElementsByTagName('input');
	    
	    for (var i=0; i<woCheckBoxes.length; i++) {
			// iterate through checkboxes, are they checked?
			if (woCheckBoxes[i].type && woCheckBoxes[i].type=="checkbox" && woCheckBoxes[i].id.search('fldSelect')!=-1) {
				// found a checked one, add it to the list
				if (woCheckBoxes[i].checked==true) {
					if (WONUM_list=="") {
					// if the first iteration
						WONUM_list =  woCheckBoxes[i].id.replace('fldSelect_', '');	
					} else {
					// if not first iteration, add to comma delimited list
						WONUM_list = WONUM_list + "," + woCheckBoxes[i].id.replace('fldSelect_', '');			
					}	
				}// end if checked==true
			} // end checkbox type validaition	
		} // end checkbox iterator
	    
	    
	    //construct the URL and refresh the infoBar
		var moduleid = 'home';
		var tabid = 'selected_workorders';
		var action = 'addSelected';
		var myURL = AppVars.reqURL + '?reqtype=tab&moduleid=' + moduleid + '&tabid=' + tabid 
		+ '&action=' + action + '&wonum_list=' + WONUM_list;
			
		AJAX_CLIENT.ShowLoadingDiv();
		AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest
		AJAX_LINKS.stopBubble(target);
	},
	
	removeSelected: function(e) {
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return; 
	
		
		var WONUM=UTIL.ascendDOM(target, 'a').id.replace('removeWO_','');

		 //construct the URL and refresh the infoBar
		var moduleid = 'home';
		var tabid = 'selected_workorders';
		var action = 'removeSelected';
		var nodeID="qsa_wo_queue";
		var nodeAction="replace-children";
		var widgetid = document.getElementById('xwtableid').value;
		var widgettype = "xwtable";		
		var myURL = AppVars.reqURL +  "?reqtype=widget" 
		+ "&action=" + action + "&nodeID=" + nodeID + "&nodeAction=" + nodeAction
		+ "&widgetid=" + widgetid + "&widgettype=" + widgettype
		+ "&wonum=" + WONUM;
		
			
		AJAX_CLIENT.ShowLoadingDiv();
		AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest
		AJAX_LINKS.stopBubble(target);
	}
}

 /*******************************************************************************/
/* ------------------/ FORM OPTION HANDLERS /---------------------------------*/
/*******************************************************************************/ 
TBL_FORM = {
	init: function() {
		// Select All Button
		if (document.getElementById('linkOptionSelectAll')) {
			var selectAllButtonEl = document.getElementById('linkOptionSelectAll');
			eV.addEvent(selectAllButtonEl, 'click', TBL_FORM.selectAll, false);
		}
		
		//Select None Button
		if (document.getElementById('linkOptionSelectNone')) {
			var selectNoneButtonEl = document.getElementById('linkOptionSelectNone');
			eV.addEvent(selectNoneButtonEl, 'click', TBL_FORM.selectNone, false);
		}
		
		//Change number of rows Per Page
		if (document.getElementById('fldFormatOptionRowPerPage')) {
			var changeRowsPerPage = document.getElementById('fldFormatOptionRowPerPage');
			eV.addEvent(changeRowsPerPage, 'blur', TBL_FORM.changeRowsPerPage, false);
		
			// Add Submit Handler to form
			var frmOptionsEl = document.getElementById('qsa_frm_format_options');	
			eV.addEvent(frmOptionsEl, 'submit', TBL_FORM.submitHandler, false);
			
		}	
	},
	
	selectAll: function(e) {
		 var target = window.event ? window.event.srcElement : e ? e.target : null;
	     if (!target) return; 
	
		 var woCheckBoxes = document.getElementById('tbodydatarows').getElementsByTagName('input');
		
		for (var i=0; i<woCheckBoxes.length; i++) {
			// any links that contain reqtype can be automatically forwarded by Taconite.
			if (woCheckBoxes[i].type && woCheckBoxes[i].type=="checkbox" && woCheckBoxes[i].id.search('fldSelect')!=-1) {
				woCheckBoxes[i].setAttribute('checked', true);
			}	
		}
		
		
		//construct the URL and refresh the infoBar
		var moduleid = 'home';
		var tabid = 'audit_queue';
		var action = 'AQSelectAll';  
	    var myURL = AppVars.reqURL + '?reqtype=void&moduleid=' + moduleid + '&tabid=' + tabid 
		+ '&action=' + action;
	    
	    AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest
		
					
	
	},
	
	selectNone: function(e) {
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return;

		var woCheckBoxes = document.getElementById('tbodydatarows').getElementsByTagName('input');
		
		for (var i=0; i<woCheckBoxes.length; i++) {
			// any links that contain reqtype can be automatically forwarded by Taconite.
			if (woCheckBoxes[i].type && woCheckBoxes[i].type=="checkbox" && woCheckBoxes[i].id.search('fldSelect')!=-1) {
				woCheckBoxes[i].setAttribute('checked', false);
				woCheckBoxes[i].removeAttribute('checked');
			}	
		}
		
			//construct the URL and refresh the infoBar
		var moduleid = 'home';
		var tabid = 'audit_queue';
		var action = 'AQSelectNone';  
	    var myURL = AppVars.reqURL + '?reqtype=void&moduleid=' + moduleid + '&tabid=' + tabid 
		+ '&action=' + action;
	    
	    AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest	
	},
	
	changeRowsPerPage: function(e) {
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return;
		
		var currentRowsPerPage = document.getElementById('fldFormatOptionRowPerPageCurrent').value;
		var newRowsPerPage = document.getElementById('fldFormatOptionRowPerPage').value;
		
		// if user entered the field and then changed nothing, do nothing!
		if (currentRowsPerPage==newRowsPerPage) return;
	
		
		TBL_FORM.changeRowsPerPageAction();
		
	},
	
	changeRowsPerPageAction: function() {
		
		//build the request URL
		var reqtype="widget";
		var action="setRowsPerPage";
		var nodeID="qsa_wo_queue";
		var nodeAction="replace-children";
		var widgetid = document.getElementById('xwtableid').value;
		var widgettype = "xwtable";
		var myScriptName = UTIL.URLgetScriptName(location.href);	 
		var newRowsPerPage = document.getElementById('fldFormatOptionRowPerPage').value;
		if (myScriptName=="/") myScriptName = "index.cfm";	
		
		var myURL = myScriptName + "?reqtype=" + reqtype
		+ "&action=" + action + "&nodeID=" + nodeID + "&nodeAction=" + nodeAction
		+ "&widgetid=" + widgetid + "&widgettype=" + widgettype
		+ "&rowsPerPage=" + newRowsPerPage;
		
		
		//prompt(myURL, myURL);
		// *** SEND REQUEST TO GET THE DATA
		AJAX_CLIENT.ShowLoadingDiv();
		AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest
		
		document.getElementById('fldFormatOptionRowPerPageCurrent').value = document.getElementById('fldFormatOptionRowPerPage').value;
		
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
		
		TBL_FORM.changeRowsPerPageAction();
	}

}



 /*******************************************************************************/
/* ------------------/ WORKORDER FILTER /---------------------------------------*/
/*******************************************************************************/ 
WOFILTER = {
	init: function()  {
			
			// Add Submit Handler to form
			var woFilterFormEl = document.getElementById('qsa_filter_form');	
			eV.addEvent(woFilterFormEl, 'submit', WOFILTER.submitHandler, false);
			
			// Add Clear Filter Handler
			var fldFrmClearEl = document.getElementById('fldFrmClear');	
			eV.addEvent(fldFrmClearEl, 'click', WOFILTER.clearFilter, false);
						
			
	},
	
	clearFilter: function(e) {
		// get target
		 var target = window.event ? window.event.srcElement : e ? e.target : null;
	     if (!target) return; 
				 				
		//initialise vars
			var reqtype="widget";
			var action="clearWOFilter";
			var nodeID="qsa_wo_queue";
			var nodeAction="replace-children";
			var widgetid = document.getElementById('xwtableid').value;
			var fldSupplier = "";
			var fldWorkType = "";
			var widgettype = "xwtable";
			var fldFinCompStart = "";
			var fldFinCompEnd = "";
			var fldAuditStatus = "";
			var myScriptName = UTIL.URLgetScriptName(location.href);	 
			if (myScriptName=="/") myScriptName = "index.cfm";	
			
			//clear the form values
			document.getElementById('fldSupplier').value = "";
			document.getElementById('fldWorkType').value = "";
			document.getElementById('fldFinCompStart').value = "";
			document.getElementById('fldFinCompEnd').value = "";
			document.getElementById('fldAuditStatus').value = "";
			
			//build the request URL
			var myURL = myScriptName + "?reqtype=" + reqtype
			+ "&action=" + action + "&nodeID=" + nodeID + "&nodeAction=" + nodeAction
			+ "&widgetid=" + widgetid + "&widgettype=" + widgettype
			+ "&fldSupplier=" + fldSupplier + "&fldWorkType=" + fldWorkType
			+ "&fldFinCompStart=" + fldFinCompStart + "&fldFinCompEnd=" + fldFinCompEnd 
			+ "&fldAuditStatus=" + fldAuditStatus;
			
			// *** SEND REQUEST TO GET THE DATA
			AJAX_CLIENT.ShowLoadingDiv();
			AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest
			//AJAX_LINKS.stopBubble(target);	//stop bubble		
		
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
		
		//alert("submitHandler fired");
		WOFILTER.saveFilter();
	},
	
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
					 	alert("Enter Hit!");
					 	WOFILTER.saveFilter();
					 }	
	},
	
	saveFilter: function() {
			//initialise vars
			var reqtype="widget";
			var action="saveWOFilter";
			var nodeID="qsa_wo_queue";
			var nodeAction="replace-children";
			var widgetid = document.getElementById('xwtableid').value;
			var widgettype = "xwtable";
			var fldSupplier = document.getElementById('fldSupplier').value;
			var fldWorkType = document.getElementById('fldWorkType').value;
			var fldFinCompStart = document.getElementById('fldFinCompStart').value;
			var fldFinCompEnd = document.getElementById('fldFinCompEnd').value;
			var fldAuditStatus = document.getElementById('fldAuditStatus').value;
			var myScriptName = UTIL.URLgetScriptName(location.href);	 
			if (myScriptName=="/") myScriptName = "index.cfm";	
			
			//build the request URL
			var myURL = myScriptName + "?reqtype=" + reqtype
			+ "&action=" + action + "&nodeID=" + nodeID + "&nodeAction=" + nodeAction
			+ "&widgetid=" + widgetid + "&widgettype=" + widgettype
			+ "&fldSupplier=" + fldSupplier + "&fldWorkType=" + fldWorkType
			+ "&fldFinCompStart=" + fldFinCompStart + "&fldFinCompEnd=" + fldFinCompEnd
			+ "&fldAuditStatus=" + fldAuditStatus;
			
			// *** SEND REQUEST TO GET THE DATA
			//prompt(myURL, myURL);
			AJAX_CLIENT.ShowLoadingDiv();
			AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest
	}
}



 /*******************************************************************************/
/* ------------------/ TABLE NAVIGATION /----------------------*/
/*******************************************************************************/ 
TBL_NAV = {
	init: function() {
		// *** ASSIGN LINK HANDLERS
		var myContentLinks = document.getElementById("qsa_wo_queue").getElementsByTagName("a");	
		//iterate over them and assign them
		for (var i=0; i<myContentLinks.length; i++) {
			// any links that contain reqtype can be automatically forwarded by Taconite.
			if (myContentLinks[i].href.indexOf("tblchangepg=")!=-1) {
				eV.addEvent(myContentLinks[i], 'click', TBL_NAV.changePageE, false);
			}	
		}
	},

	changePageE: function(e) {
		 var target = window.event ? window.event.srcElement : e ? e.target : null;
	     if (!target) return; 
		 
 		 AJAX_LINKS.stopBubble(e);	//stop bubble
		 TBL_NAV.changePage(target);
	},
	
	changePage: function(target) {
		 // check if the sciptname is not index.cfm -- should always be in this app
		 var myScriptName = UTIL.URLgetScriptName(location.href);	 
		 if (myScriptName=="/") myScriptName = "index.cfm";
		 		
			
		/**************************************************************
		Send Widget Request to refresh Table content
		**************************************************************/
		var reqtype="widget";
		var nodeID="qsa_wo_queue";
		var nodeAction="replace-children";
		var widgettype="xwtable"; 
		var widgetID = UTIL.URLgetValueFromKey(target.href, "widgetID");
		
		var myURL = myScriptName + "?reqtype=" + reqtype + "&nodeID=" + nodeID + "&nodeAction=" + nodeAction 
		+ "&widgettype="  + widgettype + "&widgetID=" + widgetID
		+ "&tblchangepg=" + UTIL.URLgetValueFromKey(target.href, "tblchangepg") 
		+ "&pageid=" +  UTIL.URLgetValueFromKey(target.href, "pageid");
		
		// *** SEND REQUEST TO GET THE DATA
		AJAX_CLIENT.ShowLoadingDiv();
		AJAX_CLIENT.get(myURL, AJAX_CLIENT.HideLoadingDiv); //no postrequest
	}
}

 /*******************************************************************************/
/* ------------------/ WORKORDER DETAILS TABLE EXPANDER /----------------------*/
/*******************************************************************************/ 

TBL_EXPANDER = {
	init: function() {
		// *** ASSIGN LINK HANDLERS
		var myContentLinks = document.getElementById("qsa_wo_queue").getElementsByTagName("a");	
		//iterate over them and assign them
		for (var i=0; i<myContentLinks.length; i++) {
			// any links that contain reqtype can be automatically forwarded by Taconite.
			if (myContentLinks[i].href.indexOf("reqtype=custom")!=-1 && 
				UTIL.URLgetValueFromKey(myContentLinks[i].href, "methodid") && 
				(UTIL.URLgetValueFromKey(myContentLinks[i].href, "methodid")=="getWODetails"
				|| UTIL.URLgetValueFromKey(myContentLinks[i].href, "methodid")=="getWOHistoryDetails")) {
				eV.addEvent(myContentLinks[i], 'click', TBL_EXPANDER.expandRow, false);
			}	
		}
	},
	
	myExpandedRowAnchorID: '',
	myExpandedRowAnchorTableID: '',
	
	expandRow: function(e) {
	 	  // get target
		 var target = window.event ? window.event.srcElement : e ? e.target : null;
	     if (!target) return; 

 		 var xwtableid = document.getElementById('xwtableid').id;
		 
		 if (target.nodeName!="a") target=TBL_EXPANDER.ascendDOM(target, "a");
		 var myURL = UTIL.URLgetQueryString(target.href);
		   
		
		 // Walk up the DOM and get the TR element
		 var myTableRow = TBL_EXPANDER.ascendDOM(target, "tr");
		 
		 // Append the DOM ElementID to the GET Request URI so Taconite knows which element to insert after
		 myURL =  AppVars.reqURL + '?' + myURL + '&ElmID='+myTableRow.id;

		 // *** SEND REQUEST TO GET THE DATA
		  AJAX_CLIENT.get(myURL, ''); //no postrequest		
		 AJAX_LINKS.stopBubble(e);	//stop bubble
		
		 //change the arrow so it points downwards			
		 var WONUM = UTIL.URLgetValueFromKey(target.href, 'paramVal');
		 TBL_EXPANDER.swap_arrow('DOWN', WONUM, myTableRow.id);
		 		 
		 //make the row highlight so it looks "selected"
		 TBL_EXPANDER.highlightRow(myTableRow);
		  
		 
		  // *** COLLAPSE ANY EXISTING EXPANDED ROWS
		 if (TBL_EXPANDER.myExpandedRowAnchorID &&  TBL_EXPANDER.myExpandedRowAnchorID!='' 
		 	&& TBL_EXPANDER.myExpandedRowAnchorTableID != xwtableid) {
		 	TBL_EXPANDER.contractRowByID(TBL_EXPANDER.myExpandedRowAnchorID);
		 }
		 
		 // set the mouse focus to the select box of the opened workorder
		 if (document.getElementById('fldSelect_' + WONUM)) {
		 document.getElementById('fldSelect_' + WONUM).focus();
		 }
		 
		 //store the expanded ID for the row
		 TBL_EXPANDER.myExpandedRowAnchorID = target.id;
		 TBL_EXPANDER.myExpandedRowAnchorTableID = xwtableid;
	},
	
	

	contractRow: function(e) {
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return; 
		 
		TBL_EXPANDER.contractRowByID(target.id);
		AJAX_LINKS.stopBubble(e);	
	},
	
	
	contractRowByID: function(targetID) {
		var xwtableid = document.getElementById('xwtableid').id;
		
		if (document.getElementById(targetID) && xwtableid==TBL_EXPANDER.myExpandedRowAnchorTableID) {
			var target = document.getElementById(targetID);
		} else {
			return;
		}
		
			
		if (target.nodeName!="a") target=TBL_EXPANDER.ascendDOM(target, "a");
	   
		var myTableRow = TBL_EXPANDER.ascendDOM(target, "tr");
		
		//delete the row
		var tbodyEl = TBL_EXPANDER.ascendDOM(target, "tbody");
		if (document.getElementById(myTableRow.id + '_data')) {
			var myWODETAIL_row = document.getElementById(myTableRow.id + '_data');
			var deleted_row = tbodyEl.removeChild(myWODETAIL_row);
		} else {
			/*alert("Oops! Couldn't collapse row. Please report this bug to the system administrator!" + 
			 "\n\n" + "myTableRow.id: " + myTableRow.id);*/
		}
		
		//change the arrow so it points downwards			
		TBL_EXPANDER.swap_arrow('RIGHT', UTIL.URLgetValueFromKey(target.href, 'paramVal'), myTableRow.id);
		
		//make the row highlight so it looks "selected"
		TBL_EXPANDER.deselectRow(myTableRow);
		
		//Remove any stored ROW IDs 
		TBL_EXPANDER.myExpandedRowAnchorID = '';
	},
	
	swap_arrow: function(arrow_direction, Wonum, RowID) {

		if (arrow_direction=="RIGHT" && document.getElementById('img_' + Wonum)) {
				//swap image and change onclick events
				document.getElementById('img_' + Wonum).src = document.getElementById('img_' + Wonum).src.replace('arrow-down-9.gif', 'arrow-right-9.gif'); 
				eV.removeEvent(document.getElementById('img_' + Wonum).parentNode, 'click', TBL_EXPANDER.contractRow, false);
				eV.addEvent(document.getElementById('img_' + Wonum).parentNode, 'click', TBL_EXPANDER.expandRow, false);
		
		} else if (arrow_direction=="DOWN" && document.getElementById('img_' + Wonum)) {
				//swap image and change onclick events
				document.getElementById('img_' + Wonum).src = document.getElementById('img_' + Wonum).src.replace('arrow-right-9.gif', 'arrow-down-9.gif');
				eV.removeEvent(document.getElementById('img_' + Wonum).parentNode, 'click', TBL_EXPANDER.expandRow, false);
				eV.addEvent(document.getElementById('img_' + Wonum).parentNode, 'click', TBL_EXPANDER.contractRow, false);
				} else {
		 return;
		}
		
	},
		
	highlightRow: function(myTableRow) {
	   if (myTableRow.nodeName=='TR' && myTableRow.className) {
	    //myTableRow.setAttribute('class', myTableRow.className + ' highlight');
	   	myTableRow.className = myTableRow.className + ' highlight';
	   } else if (myTableRow.nodeName=='TR' && !myTableRow.className)  {
	   	  	myTableRow.className='highlight';
	   } else {
	   	return;
	   }
	},
	
	deselectRow: function(myTableRow) {
	   if (myTableRow.nodeName=='TR' && myTableRow.className) {
	 	myTableRow.className = myTableRow.className.replace('highlight', '');
	   } else {
	   	return;
	   }
	},
	
	
	// climb up the tree to the supplied tag.
 	ascendDOM: function(target, El) {
 	while (target.nodeName.toLowerCase() != El &&  
    	 target.nodeName.toLowerCase() != 'html')
   		target = target.parentNode;
 
 	return (target.nodeName.toLowerCase() == 'html') ? null : target;
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
		
		ShowLoadingDiv: function() {
			var span = document.createElement('span');
			span.setAttribute('id', 'WODETAIL-loading');
			
			var txtNode = document.createTextNode("Loading data..."); 	
 			span.appendChild(txtNode);
 			document.getElementById('main').appendChild(span);
		},
		
		HideLoadingDiv: function() {
			if (document.getElementById('WODETAIL-loading')) {
				var el = document.getElementById('WODETAIL-loading');
				document.getElementById('WODETAIL-loading').parentNode.removeChild(el);
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
/* ------------------/ AJAX / TACONITE LINKS /-------------------------------- */
/*******************************************************************************/
AJAX_LINKS = {
	init: function() {
		// *** ASSIGN LINK HANDLERS
		//find all the active links inside "content" div and 
		//assign them a taconite onclick listener to forward clicks
		var myContentLinks = document.getElementById("qsa_content").getElementsByTagName("a");	
		
		//iterate over them and assign them
		for (var i=0; i<myContentLinks.length; i++) {
			// any links that contain reqtype can be automatically forwarded by Taconite.
			if (myContentLinks[i].href.indexOf("reqtype=widget")!=-1) {
			eV.addEvent(myContentLinks[i], 'click', AJAX_LINKS.forward, false);
			}
		}
		// *** END		
		
	}, 
	
	
	forward: function(e) {
	 	  // get target
		 var target = window.event ? window.event.srcElement : e ? e.target : null;
	    	 if (!target) return; 
		 
		  var reqtype = "tab"; //set default request type
		  
		 //check if the request is from a widget
		 if (target.href.indexOf("widgetid")!=-1) { 	 
		  reqtype = "widget";
		}
		 
		 // construct a URL based upon our predetermined Base Request URL and the query string of the clicked link
		 if (reqtype=="tab") {
		    var myURL = AppVars.reqURL + '?reqtype=' + reqtype + '&' + UTIL.URLgetQueryString(target.href);
		 } else if (reqtype=="widget") {
		    var myURL = AppVars.reqURL + '?' + UTIL.URLgetQueryString(target.href);	
		 } 
		  
		 alert(myURL);
		 //AJAX_CLIENT.get(myURL, ''); //no postrequest		
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