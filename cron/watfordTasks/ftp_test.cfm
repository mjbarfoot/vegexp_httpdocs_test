<cfftp action = "open" username = "vegexp" connection = "veWebServer" password = "V1e1G0e2X7p6" server = "ftp.vegetarianexpress.co.uk" stopOnError = "Yes" timeout="3600" />
<cfftp connection = "veWebServer" action = "CHANGEDIR"   stopOnError = "Yes"  directory = "/httpdocs/xml_inbound/" />
<cfftp connection = "veWebServer" action = "putFile" timeout="60" name = "uploadFile" transferMode = "ascii" localFile = "C:\ColdFusion8\wwwroot\favOut.xml" remoteFile = "favourites.xml" failIfExists="No" />
<cfftp action = "close" connection = "veWebServer" stopOnError = "Yes">