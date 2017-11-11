<cfset useragent = "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)">
<cfoutput>#mid(useragent, (FindNoCase('MSIE',useragent)+5), 2)#</cfoutput>