<cffunction name="splitByCR" access="private" returntype="array" output="false">
<cfargument name="str" type="string" required="true" hint="the string containing chr(13)">
<cfscript>
var myStringArray = ArrayNew(1);
var myChoppedString = ARGUMENTS.str;
var i=1;

//test for existence
if (find(chr(13), ARGUMENTS.str) neq 0) {

//chop up string and apend to array until no more chr(13)s are found
	do  {
	 	myStringArray[i] = left(myChoppedString, find(chr(13), myChoppedString));
			myChoppedString = mid(myChoppedString, (find(chr(13), myChoppedString)+1), len(myChoppedString));
			i = i + 1;	
	} while (find(chr(13), myChoppedString) neq 0);

// finished chopping, but see if there is some part of the string left over
	if (len(myChoppedString) gte 1) {
		myStringArray[i] = myChoppedString;
	}
	
	return myStringArray;
} 
// no chr(13) found return empty string	
	else {
return myStringArray;	
}
</cfscript>
</cffunction>


<cfscript>
if (isdefined("form.submit")) {
del_notes_array = splitByCR(form.delNotes);
}

delline1="";
delline2="Oppersite British Gas";
delline3="Reading A-Z P12-5C";
delline4="End of A329M In Thames Valley";
delpostcode="Business Park";

delnotes=delline1 & chr(13) &
		delline2 & chr(13) &
		delline3 & chr(13) &
		delline4 & chr(13) &
		delpostcode;

</cfscript>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title><cfif isdefined("shopperBreadcrumbTrail")><cfoutput>#request.pageTitle#</cfoutput><cfelse>Welcome to Vegetarian Express</cfif></title>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
  <cfloop list="#session.shop.skin.css#" index="cssfile"><link rel="stylesheet" type="text/css" href="<cfoutput>#cssfile#</cfoutput>" />
  </cfloop> 
  <cfloop list="#request.css#" index="cssfile"><link rel="stylesheet" type="text/css" href="<cfoutput>#cssfile#</cfoutput>" />
  </cfloop>
  <link rel="icon" href="/favicon.ico" type="image/x-icon" />
  <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
  <script type="text/javascript" src="/js/prototype.lite.js"></script>
  <script type="text/javascript" src="/js/moo.fx.js"></script>
  <script type="text/javascript" src="/js/fat.js"></script>
  <script type="text/javascript" src="/js/taconite-parser.js"></script>
  <script type="text/javascript" src="/js/taconite-client.js"></script>
  <script type="text/javascript" src="/js/vegexp.js"></script>
  <script type="text/javascript" src="<cfoutput>#session.shop.skin.path#</cfoutput>fx.js"></script> 
<cfif isdefined("request.js")><cfloop list="#request.js#" index="jsfile"><script type="text/javascript" src="<cfoutput>#jsfile#</cfoutput>"></script>
  </cfloop></cfif>	
</head>
 <body style="margin:4em;"> 	
<cfoutput>
<p>
<cfscript>
if (isdefined("form.submit")) {
	for (i=1; i lte ArrayLen(del_notes_array); i=i+1) {
	writeOutput("#HTMLEditFormat(del_notes_array[i])#"	 & "<br />");
	}
}
</cfscript>
</p>
<form name="myForm" method="post" action="#cgi.script_name#">
<textarea style="font-size: 0.8em;" name="delnotes" id="delnotes" wrap="HARD" cols="50" rows="5	">#delnotes#</textarea>
<input type="submit" name="submit" value="submit" />
</form>
<a href="#cgi.script_name#">#cgi.SCRIPT_NAME#</a>
</cfoutput>
 </body>
</html>