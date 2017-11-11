<cfprocessingdirective  suppressWhiteSpace = "Yes">

<cfscript>
//create log files
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: import Favourites Started *****");

//setup Stop Watch Vars
tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;

//server specific log configuration
switch (cgi.SERVER_NAME) {
case "localhost": case "clearview": case "vegexp.clearview.local":
					VARIABLES.inbound_path = "D:\_LOCAL_DATA\vegexp_httpdocs\xml_inbound\";
					VARIABLES.favourites_filename = "favourites.xml";
				  VARIABLES.params_filename = "datelog.log";
				  ;
				  break;
default: 	      VARIABLES.inbound_path = "/var/www/vhosts/vegetarianexpress.co.uk/httpdocs/xml_inbound/";
				  VARIABLES.favourites_filename = "favourites.xml";
				  VARIABLES.params_filename = "datelog.log";
				  ;				  	
				
}

</cfscript>

<!--- RETRIEVE THE FILE --->
<cffile action="read" charset="utf-8" file="#VARIABLES.inbound_path##VARIABLES.favourites_filename#" variable="favourites_wddx" />
<cfscript>
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: import Favourites - File Read Complete *****");
</cfscript>

<!--- RETRIEVE THE PARAM FILE  --->
<cffile action="read" charset="utf-8" file="#VARIABLES.inbound_path##VARIABLES.params_filename#" variable="date_params" />
<cfscript>
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: import Favourites - reading data params *****");
</cfscript>

<!--- extract the params --->
<cfscript>
start_of_days= "-";
end_of_date = "}";
//strip of any extra whitespace
date_params = trim(date_params);
endofline = find(end_of_date, date_params)+1;
//writeOutput(date_params & "<br />" & endofline);
favourites_enddate = left(date_params, endofline-1);
favourites_days_included = trim(mid(date_params, endofline, (len(date_params)-endofline+1)));
writeOutput("favourites_days_included: " & favourites_days_included & "<br />" & "favourites_enddate: " &  favourites_enddate);
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: import Favourites -  Last Date of Favourites: #dateformat(favourites_enddate, 'dd/mm/yyyy')#  Number of days included in import: #favourites_days_included# *****");
</cfscript>


<!--- COVERT TO QUERY --->
<cfwddx    action="wddx2cfml"    input="#favourites_wddx#"  output="qFavourites">
<cfscript>
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: import Favourites - Converted XML to Query object *****");
</cfscript>

<!--- DELETE FROM FAVOURITES ANY OLD DATA --->
<cfquery name="tFavourites" datasource="#APPLICATION.dsn#">
delete from tblFavourite
where LastOrderDate <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DATEADD('m',-6,now())#" />
</cfquery>
<cfscript>
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: import Favourites - Deleted any data older than 6 months *****");
</cfscript>

<!--- DELETE FROM FAVOURITES ANY DATA INCLUDED IN OUR NEW DATA SET --->
<cfquery name="tFavourites" datasource="#APPLICATION.dsn#">
delete from tblFavourite
where LastOrderDate >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DATEADD('d',favourites_days_included,favourites_enddate)#" />
</cfquery>
<cfscript>
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: import Favourites - Deleted any data older than 6 months *****");
</cfscript>


<!--- INSERT NEW FAVOURITES --->
<cfloop query="qFavourites">
<cfquery name="chkFav" datasource="#APPLICATION.dsn#">	
select 1 from tblFavourite where AccountID = '#ACCOUNT_REF#' and stockcode = '#Stock_Code#'
</cfquery>
	
<cfif chkFav.recordcount eq 1>
	<cfquery name="uFavourites" datasource="#APPLICATION.dsn#">
	UPDATE tblFavourite
	SET LastOrderQuantity = '#LastOrderQuantity#',
	LastOrderDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#LastOrderDate#" />,
	OrderCount = #Order_Count#,
	QtyToDate = #QtyToDate#,
	FavLastModifiedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
	WHERE AccountID = '#ACCOUNT_REF#'
	AND StockCode = '#STOCK_CODE#'
	</cfquery>
<cfelse>	
	<cfquery name="iFavourites" datasource="#APPLICATION.dsn#">
	INSERT INTO tblFavourite
	(AccountID, Stockcode, LastOrderQuantity, LastOrderDate, OrderCount, QtyToDate, FavLastModifiedDate)
	values (
	'#ACCOUNT_REF#',
	'#STOCK_CODE#',
	'#LastOrderQuantity#',
	<cfqueryparam cfsqltype="cf_sql_timestamp" value="#LastOrderDate#" />,
	#Order_Count#,
	#QtyToDate#,
	<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
	)
	</cfquery>
</cfif>
</cfloop>
<cfscript>
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: import Favourites - Favourites data inserted *****");
</cfscript>

<cfscript>
// stop the clock
tickEnd=getTickCount();
tickInterval=(tickEnd-tickBegin)/1000;
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: import Favourites complete - Execution time: #tickInterval# s *****");
</cfscript>
</cfprocessingdirective>