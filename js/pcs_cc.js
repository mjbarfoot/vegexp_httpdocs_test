function pcaFastAddressBegin(postcode, building, language, style, account_code, license_code, machine_id, options)
   {
      var scriptTag 		= document.getElementById("pcaScriptTag");
      var headTag 		 	= document.getElementsByTagName("head").item(0);
      var strUrl		 	= "";
      
      var postcode			= document.getElementById("billPostcode").value;
      var building			= document.getElementById("billBuilding").value;
     
	  var language 			= "english";
 	  var style 			= "simple"; 
  	  var account_code 		= "CLEAR11124";	  	
	  var license_code 		= "RZ27-GT55-GF19-UR83";
	  var machine_id 		= "";
	  var options 			= "";	  

      //Build the url
      strUrl = "http://services.postcodeanywhere.co.uk/inline.aspx?";
      strUrl += "&action=fetch";
      strUrl += "&postcode=" + escape(postcode);
      strUrl += "&building=" + escape(building);
      strUrl += "&language=" + escape(language);
      strUrl += "&style=" + escape(style);
      strUrl += "&account_code=" + escape(account_code);
      strUrl += "&license_code=" + escape(license_code);
      strUrl += "&machine_id=" + escape(machine_id);
      strUrl += "&options=" + escape(options);
      strUrl += "&callback=pcaFastAddressEnd";

      //alert(strUrl);
      
      //Make the request
      if (scriptTag) 
         {
            headTag.removeChild(scriptTag);
         }
      scriptTag = document.createElement("script");
      scriptTag.src = strUrl
      scriptTag.type = "text/javascript";
      scriptTag.id = "pcaScript";
      headTag.appendChild(scriptTag);
   	 
   }

function pcaFastAddressEnd()
   {
      //Test for an error
      if (pcaIsError)
         {
            //Show the error message
            alert(pcaErrorMessage);
         }
      else
         {
            //Check if there were any items found
            if (pcaRecordCount==0)
               {
                  alert("Sorry, no matching items found");
               }
            else
               {
                 // document.getElementById("billBuilding").value=pca_organisation_name[0];
                  document.getElementById("billLine1").value=pca_line1[0];
                  document.getElementById("billLine2").value=pca_line2[0];
                  document.getElementById("billLine3").value=pca_line3[0];
                  document.getElementById("billTown").value=pca_post_town[0];
                  document.getElementById("billCounty").value=pca_county[0];
                  document.getElementById("billPostcode").value=pca_postcode[0];
               }
         }
   }