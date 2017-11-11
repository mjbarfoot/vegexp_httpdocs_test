<cfcomponent displayname="CVS Functions" output="false" hint="Functions to convert Array's and Queries to and from CSV">
<!--- 
	Licence: CPL 1.0
	Copyright: RedBalloon Pty Ltd
	Author: Mark Lynch (mark@redballoon.com.au)
	Contributors: Lucas Sherwood (lucas@redballoon.com.au)

	A collection of CSV formatting functions to create and read CSV files
	
	CSV Reference - http://www.edoceo.com/utilis/csv-file-format.php  
	 --->

<!--- Convert to CSV --->
<cffunction name="Query2CSV" returntype="string" output="false" hint="Return a CSV string of a query">
<!--- Note: Doing this via a return variables was incredibly slow when working with large data sets. 
	So instead output directly to the output buffer  
	--->
	<cfargument name="myQ" type="query" required="true">
	<cfargument name="columnList" type="string" required="false" default="" hint="An optional list of columns to show.  Also used to specify order of column output">
	<cfargument name="columnFriendlyList" type="string" required="false" default="" hint="An optional list of column names to show.  Must be same length as columnList">
	<cfargument name="ignoreFirstRows" type="numeric" required="false" default="0">
	<!--- <cfargument name="mimetype" type="string" required="false" default="text/plain" hint="Mime type of returned page"> --->
	<cfset var i = "">
	<cfset var j = "">
	<cfset var myCols = ArrayNew(1)>
	<cfset var myColNames = ArrayNew(1)>
<!--- 	<cfcontent reset="true" type="#arguments.mimetype#"> --->
	
	<!--- If no columnList passed then use the query columnList --->
	<cfif arguments.columnList EQ "">
		<cfset arguments.columnList = myQ.columnList>
	</cfif>
	<cfset myCols = listToArray(arguments.columnList)>
	

	<!--- If not passed a columnlist then use the default query one --->
	<cfif ListLen(arguments.columnFriendlyList) GT 0 AND ArrayLen(myCols) NEQ ListLen(arguments.columnFriendlyList)>
		<cfthrow type="core.cfc.csv.query2csv" message="Arguments.columnFriendlyList is specified but is not the same length as the number of columns to be returned">
	</cfif>
	<!--- If no columnFriendlyList then use the default col names --->
	<cfif arguments.columnFriendlyList EQ "">
		<cfset arguments.columnFriendlyList = arguments.columnList>
	</cfif>
	<cfset myColNames = listToArray(arguments.columnFriendlyList)>

	<cfsavecontent variable="csvString"><cfscript>
		if(arguments.ignoreFirstRows eq 0)
		{
			for(j=1;j lte arrayLen(myCols);j=j+1)
			{
				if(j gt 1)	writeOutput(",");
				writeOutput(String2CSV(myColNames[j]));
			}
			// add new line
			writeOutput(Chr(13));
			writeOutput(Chr(10));
		}
		else
		{
			arguments.ignoreFirstRows =arguments.ignoreFirstRows - 1;
		}
		// add rows
		for(i=1+arguments.ignoreFirstRows;i lte myQ.recordCount;i=i+1)
		{
			for(j=1;j lte arrayLen(myCols);j=j+1)
			{
				if(j gt 1)	writeOutput(",");
				writeOutput(String2CSV(myQ[myCols[j]][i]));
			}
			// add new line
			writeOutput(Chr(13));
			writeOutput(Chr(10));

		}
	</cfscript></cfsavecontent>

	<cfreturn csvString>
</cffunction>
<cffunction name="Array2CSV" returnType="string" output="false" hint="converts a 2d array to a csv format. All of the 2nd dimension arrays must be the same length.">
	<cfargument name="array" type="array" required="true">
	<!--- TODO:  This could probably benefit from using same method as Query2CSV (i.e. using cfsavecontent and output buffer 
	Need to benchmark --->
	<cfscript>
		var i=1;
		var j=1;
		var CSVMatrix ="";
		for(i=1;i LTE ArrayLen(array);i=i+1){
			for(j=1;j LTE ArrayLen(array[1]);j=j+1){
				if(j GT 1){
					CSVMatrix = "#CSVMatrix#,";
				}
				CSVMatrix = CSVMatrix&String2CSV(array[i][j]);
			}
			CSVMatrix=CSVMatrix&Chr(13)&Chr(10);
		}
		return CSVMatrix;
	</cfscript>
</cffunction>
<!--- Convert from CSV --->
<cffunction name="CSV2Array" returnType="array" output="false" hint="Converts a CSV file to a 2d Array">
	<cfargument name="CSVFile" type="string" required="true">
	<cfscript>
		/*Convert CSV file to array using following logic
		Commas Seperate all data
		If a cell contains any special chars it must have double quotes around it.
		CR and/or LF denotes end of a row.		*/
		var row = 1;
		var col = 1;
		var maxCol = 1;
		var InCell = False; //Set to true if currently in quoted cell.
		var CurrentCell = "";
		var aCSVData = ArrayNew(2);
			
		var CR = Chr(13);
		var LF = Chr(10);
		var DblQuote = Chr(34);
		var Comma = Chr(44);
		
		CSVFile = UnixFormat(CSVFile);
		
		for(i=1; i LTE Len(CSVFile); i=i+1){
			//WriteOutput(Mid(CSVFile,i,1));
			CurrentChar = Mid(CSVFile,i,1);
			
			switch(CurrentChar) {
			case '"':
				if(NOT InCell){
					InCell = True;
				} else if(Mid(CSVFile,i+1,1) EQ DblQuote) {//Next char is a double quote
					CurrentCell = CurrentCell & CurrentChar;
					i=i+1;
				} else  // End of cell
					InCell = False;	
				break;
			case ',':
				if(NOT InCell){
					aCSVData[row][col] = CurrentCell;
					Col = Col + 1;
					CurrentCell = "";
				} else
					CurrentCell = CurrentCell & CurrentChar;		
				break;
			case Chr(10): // LF
				if(NOT InCell){
					aCSVData[row][col] = CurrentCell;
					CurrentCell = "";
					row = row + 1;
					if(col GT maxCol)
						maxCol = col;
					col = 1;
				} else	
					CurrentCell = CurrentCell & CurrentChar;
				break;
			default:
				CurrentCell = CurrentCell & CurrentChar;	
			}	// switch
		} // for
		
		/* pad the end of short rows with blanks */
		for(i=1; i LTE ArrayLen(aCSVData); i=i+1) {
			if(ArrayLen(aCSVData[i]) LT maxCol)
				ArraySet(aCSVData[i], ArrayLen(aCSVData[i]) + 1, maxCol, "");
		}
		return aCSVData;
	</cfscript>
</cffunction>
<cffunction name="CSV2Query" returnType="query" output="false" hint="Converts a CSV file to a Query">
	<cfargument name="CSVFile" type="string" required="true">
	<cfscript>
		/*Convert CSV file to array using following logic
		Commas Seperate all data
		If a cell contains any special chars it must have double quotes around it.
		CR and/or LF denotes end of a row.		*/
		var row = 1;
		var col = 1;
		var maxCol = 1;
		var InCell = False; //Set to true if currently in quoted cell.
		var CurrentCell = "";
		
		var qCSVData = ""; //Need to work out cell names before we can create the query
		var colNames = "";
		
		var CR = Chr(13);
		var LF = Chr(10);
		var DblQuote = Chr(34);
		var Comma = Chr(44);
		
		CSVFile = UnixFormat(CSVFile);
		
		for(i=1; i LTE Len(CSVFile); i=i+1){
			//WriteOutput(Mid(CSVFile,i,1));
			CurrentChar = Mid(CSVFile,i,1);
			
			switch(CurrentChar) {
			case '"':
				if(NOT InCell){
					InCell = True;
				} else if(Mid(CSVFile,i+1,1) EQ DblQuote) {//Next char is a double quote
					CurrentCell = CurrentCell & CurrentChar;
					i=i+1;
				} else  // End of cell
					InCell = False;	
				break;
			case ',':
				if(NOT InCell){
					if(row EQ 1){
						//Add the column Name
						colnames = ListAppend(colnames,varSafeFormat(CurrentCell));
					}else{
						//If we need a new row then add it
						if(row-1 GT qCSVData.recordcount){
							queryAddRow(qCSVData); 
						}
						querySetCell(qCSVData,listGetAt(colnames,col),CurrentCell);					
					}
					Col = Col + 1;
					CurrentCell = "";
				} else
					CurrentCell = CurrentCell & CurrentChar;		
				break;
			case Chr(10): // LF
				if(NOT InCell){
					if(row EQ 1){
						//We've got the column Names to create the query
						colnames = ListAppend(colnames,varSafeFormat(CurrentCell));
						qCSVData = queryNew(colnames);
					}else{
						//Add current data in cell
						querySetCell(qCSVData,listGetAt(colnames,col),CurrentCell);					
					}
					CurrentCell = "";
					row = row + 1;
					if(col GT maxCol)
						maxCol = col;
					col = 1;
				} else	
					CurrentCell = CurrentCell & CurrentChar;
				break;
			default:
				CurrentCell = CurrentCell & CurrentChar;	
			}	// switch
		} // for
	</cfscript>
	<cfreturn qCSVData>
</cffunction>


<!--- Internal (private) functions --->
<cffunction name="String2CSV" returntype="string" output="false" access="private">
	<cfargument name="string" type="string" require="true">
	<cfscript>
		var CSVString = "";
		string=trim(REReplaceNoCase(string,"<[^>]*>","","ALL"));
		CSVString = Replace(Trim(string),'"','""',"ALL");
		//if(REFind("[[:print:],]",CSVString)){
			CSVString='"' & CSVString & '"';
		//}
		return CSVString;
	</cfscript>
</cffunction>
<cffunction name="UnixFormat" returntype="string" output="false" access="private" hint="Convert the line endings in Windows or Macintosh text file to Unix format">
	<cfargument name="string" type="string" require="true">
	<cfscript>
		var CR = Chr(13);
		var LF = Chr(10);
		/* Convert Windows line endings */
		string = Replace(string, CR & LF, LF, "ALL");
		/* Convert Macintosh line endings */
		string = Replace(string, CR, LF, "ALL");
		return string;
	</cfscript>
</cffunction>
<cffunction name="WinFormat" returntype="string" output="false" access="private">
	<cfargument name="string" type="string" require="true">
	<cfscript>
		var CR = Chr(13);
		var LF = Chr(10);
		/* Convert string into Unix format to make sure all line endings are the same */
		string = UnixFormat(string);
		/* Convert Unix line endings to Windows format */
		string = Replace(string, LF, CR & LF, "ALL");
		return string;
	</cfscript>
</cffunction>
<cffunction name="varSafeFormat" returntype="string" output="false" access="private" hint="remove special chars that are not valid as variable names">
	<cfargument name="str" type="string" required="true">
	<!--- <cfset ARGUMENTS.str = rereplace(ARGUMENTS.str, "[^A-Za-z0-9.-]", "", "all")>  --->
	<!--- TODO: This could probably be done more efficiently i.e. single regex
  	<cfset arguments.str = ReplaceNoCase(arguments.str,' ','_','all')>
	<cfset arguments.str = ReplaceNoCase(arguments.str,'&','_','all')>
	<cfset arguments.str = ReplaceNoCase(arguments.str,'.','_','all')>
	<cfset arguments.str = ReplaceNoCase(arguments.str,',','_','all')> --->

	<cfreturn rereplace(ARGUMENTS.str, "[^A-Za-z0-9._]", "", "all") />
</cffunction>
</cfcomponent>