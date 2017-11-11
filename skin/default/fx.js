  // shopping basket expand and collapse effect
  var FX = {
  		 oldHeight: 156,
  		 newHeight: 156,
  		 rowCount: 0,
  		 
  		 createEffect: function() {
  		 	  if (document.getElementById('basketExpandWrapper')) {
  		 	  var myelement = document.getElementById('basketExpandWrapper');
  	 		  myEffect = new fx.Height(myelement , {duration: 500});
  		 	  }
  		 },
  		 
  		 getRows: function() {
  		 
  		 	if (document.getElementById('basketExpandWrapper').getElementsByTagName('tr').length) {
  		 	 return document.getElementById('basketExpandWrapper').getElementsByTagName('tr').length;
  		 	} else {
  		 	return 0;
  		 	}
  		 
  		 },
  		 
  		 Increment: function() {
			FX.Fade();
			
			if 	(FX.rowCount == 0) {
				FX.rowCount=FX.getRows();
			}
			
			// if basket is in "contracted mode" cancel increment
  		     if (FX.newHeight==156) return;
  		     		     	     
  		     // if the number of rows is the same as it was previously then shopper has 
  		     // increase the quantity of an item already in basket, therefore don't increase size
  		     var newRowCount = FX.getRows();
  		     //alert("FX.rowCount: " + FX.rowCount + " newRowCount: " + newRowCount);
  		     if (FX.rowCount==newRowCount) return;  		     
  		     		    
  		     FX.oldHeight = FX.newHeight;
  			 FX.newHeight = FX.oldHeight + 16;
  		 	 myEffect.custom(FX.oldHeight,FX.newHeight);
  		 	 
  		 	 FX.rowCount=newRowCount;
  		 },
  		 
 		 
  		 Big: function() {
			FX.Fade();
			FX.setHeight();	
  		    //alert("new Height: " + FX.newHeight + " No of rows: " + FX.getRows());
  		    myEffect.custom(156,FX.newHeight);  
			//FX.oldHeight = FX.newHeight; 		
   		 },
  		 
  		 Small: function() {
  		  	//alert("FX.rowCount: " + FX.rowCount + " newRowCount: " + FX.getRows());
  		  	FX.Fade();
  		  	myEffect.custom(FX.newHeight,156);	
  		 	FX.newHeight = 156;
  		 	FX.rowCount = FX.getRows();
  		 },
  		 
  		 Fade: function() {
		  Fat.fade_element("basketExpandWrapper", 60, 850, "#177730", "#FFFFFF");	  
  		 },
  		 
  		 setHeight: function() {
  		    //if (!document.getElementById('noOfItems')) return;
  		 	var noOfItems = FX.getRows(); //document.getElementById('noOfItems').firstChild.nodeValue;
  		    FX.newHeight = (noOfItems*18)+6;
  		 }
  		 		
  }