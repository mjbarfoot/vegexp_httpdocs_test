var xwForm = {
	init : function(){
		
		var myforms = document.getElementById("main").getElementsByTagName("form");	
		
		
		//iterate over them and assign them
		for (var i=0; i<myforms.length; i++) {
			// any links that contain reqtype can be automatically forwarded by Taconite.
			if (myforms[i].className.indexOf("xwform")!=-1) {
				eV.addEvent(myforms[i], 'submit', xwForm.submitH, false);
			}
		}
	},
	
	submitH: function(e) {
		var frm = window.event ? window.event.srcElement : e ? e.target : null;
		if (!frm) return;
		
		AJAX_LINKS.stopBubble(e); //stop bubble
		AJAX_CLIENT.ShowLoadingDiv();
		AJAX_CLIENT.post(frm.action, frm.id, AJAX_CLIENT.HideLoadingDiv); 	
	}
}	 