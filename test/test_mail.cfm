<!---<cfset mailAttributes = {
server="185.34.81.148",
username="WebsiteSales",
password="Am@Z0Nord3RsV3gexpr3Ss",
from="websales@vegexp.co.uk",
to="matt.barfoot@clearview-webmedia.co.uk",
subject="Vegetarian Express Sales Order Test"
}
/>--->

<Cfset mailAttributes = {
    server = "email-smtp.eu-west-1.amazonaws.com",
    username = "AKIAIRWEPDJDQXQY56EA",
    password = "AvijQKLVEq9veHNNi9ANm3VNzbF8dlDUYVWWXohtwQQU",
    port="587",
    useTLS="true",
    from="crontask@orders.vegetarianexpress.co.uk",
    to="matt.barfoot@clearview-webmedia.co.uk",
    subject="Vegetarian Express Website Mail Test"   
}
/>




<cfmail attributeCollection="#mailAttributes#">Hello this is a test mesage.</cfmail>



<!---<cfscript>
// config
sMailServer = "185.34.81.148";
sPort = "4471";
sAuthType = "NTLM";    
sUsername = "WebsiteSales";
sPassword = "Am@Z0Nord3RsV3gexpr3Ss";
sSubject = "Using the JavaMail API!";
sAddyTo = "matt.barfoot@clearview-webmedia.co.uk";
sAddyFrom = "websales@vegexp.co.uk";


// set javamail properties
oProps = createObject("java", "java.util.Properties").init();
oProps.put("javax.mail.smtp.host", sMailServer);
oProps.put("mail.smtp.auth", "true");
oProps.put("mail.debug", "true");   

// *** CHANGED ***
oProps.put("mail.smtp.auth.ntlm.domain","VEGEXPRESS"); 
        
oAuth = createObject("java","javax.mail.Authenticator").init();

oPasswordAuthentication = createObject("java","javax.mail.PasswordAuthentication").init(sUsername,sPassword);

oAuth2 = oAuth.getPasswordAuthentication(oPasswordAuthentication); 
        
// create the session for the smtp server
oMailSession = createObject("java", "javax.mail.Session").getInstance(oProps,oAuth2);

    
// create a new MIME message
oMimeMessage = createObject("java", "javax.mail.internet.MimeMessage").init(oMailSession);

// create the to and from e-mail addresses
oAddressFrom = createObject("java", "javax.mail.internet.InternetAddress").init(sAddyFrom);
oAddressTo = createObject("Java", "javax.mail.internet.InternetAddress").init(sAddyTo);

// build message
// set who the message is from
oMimeMessage.setFrom(oAddressFrom);
// add a recipient
oMimeMessage.addRecipient(oRecipientType.TO, oAddressTo);
// set the subject of the message
oMimeMessage.setSubject(sSubject);
// set text
oMimeMessage.setText("Hello, this is sample for to check send email using JavaMailAPI ");    
    

// create a transport to actually send the message via SMTP
oTransport = oMailSession.getTransport("smtp");
// connect to the SMTP server using the parameters supplied; use
// send the message to all recipients
oTransport.sendMessage(oMimeMessage);
// close the transport
oTransport.close();    
    
    
</cfscript> --->  
    
<!---

<cfmail to="matt.barfoot@clearview-webmedia.co.uk" from="websales@vegexp.co.uk"  subject="this is a test message" type="html" server="185.34.81.148" port="4471" username="WebsiteSales" password="Am@Z0Nord3RsV3gexpr3Ss">
Hello this is a test mesage. 
</cfmail>
--->

<!---<cfmail to="matt.barfoot@clearview-webmedia.co.uk" from="websales@vegexp.co.uk"  subject="this is a test message" type="html">
Hello this is a test mesage. 
</cfmail>--->
<cfoutput>done</cfoutput>