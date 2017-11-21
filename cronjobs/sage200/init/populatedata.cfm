<!--- Specification for populatedata.cfm
1. populate the ve-orders-sync tables with data
  1.1 tblSyncPrices
  1.2 tblSyncAuthorisedItem
  1.3 tblSyncAuthorisedList
  1.4 tblSyncListAssigment
  1.5 tblSyncCustomers
  1.6 tblSyncDeliverySchedules
  1.8 tblSyncProducts
The sync tables hold a hash value against the primary key which is used for comparison.
--->
<cfscript>
  //vars
util = createObject("component", "sage200sync.com.util");
include "..\vars.cfm";
step = 0;
VARIABLES.messages = [];
styleTag="<style>span,p {color: black; /*color:  ##00ff00;*/ font-family: 'Lucida Console'; font-size: 11px;};</style>";
styleTagOuputFlag=false;
VARIABLES.progressHTML = "<div><span id='msg'></span><span id='pct'></span></div>";
VARIABLES.progressHTMLOutputFlag = false;
VARIABLES.sqlScripts = getSQLScripts();
VARIABLES.bindObj = [];
VARIABLES.insertCnt = 0;
VARIABLES.insertDuration = 0;
VARIABLES.badRecords = [];

try {
      for (key in VARIABLES.sqlScripts) {
        sql = key.sql;
        qryResult = "";
        myQuery = queryExecute(sql, {}, {datasource = VARIABLES.sage200sync.sage200_dsn, result="qryResult"});
        arrayAppend(VARIABLES.messages,"Query: " & key.name & " recordcount: " & qryResult.recordcount & " Execution Time: " & qryResult.executiontime & " ms");


        outputAndFlush();

        //truncate table
        queryExecute(key.truncSQL, [], {datasource = VARIABLES.sage200sync.syncdb_dsn});
        arrayAppend(VARIABLES.messages, "Truncating table: " & key.dbTable);
        outputAndFlush();

        arrayAppend(VARIABLES.messages,"Inserting " & qryResult.recordcount & " records into " & key.dbTable);
        outputAndFlush();

        VARIABLES.insertDuration = 0;
        VARIABLES.insertCnt = 0;
        insertStart = getTickCount();
        for (row in myQuery) {
            //build bind VARIABLES
            VARIABLES.bindObj = [];
            for (col in key.cols) {
              arrayAppend(VARIABLES.bindObj, evaluate("row." & col));
            }

            try {
                //identify inserts that use row_value as these must use varbinary cfsqltype
                if (find(":row_value", key.insert)> 0) {
                  VARIABLES.bindObj = {"#key.cols[1]#" : {value: evaluate("row." & key.cols[1]), cfsqltype: "varchar"}, row_value={value=row.row_value, cfsqltype="varbinary"}};
                }

                queryExecute(key.insert, VARIABLES.bindObj, {datasource = VARIABLES.sage200sync.syncdb_dsn} )


                if (insertCnt !=0 and insertCnt mod 1000 == 0) {
                    updateProgress("Progress: Inserted " &   VARIABLES.insertCnt & " records", VARIABLES.insertCnt, qryResult.recordcount);
                }
                VARIABLES.insertCnt++;
            }
            catch (database ex) {
              if (find("PRIMARY KEY constraint",ex.detail) > 0){
                  badRecord = {"error-message": ex.message, "full-error": serializeJSON(ex), "bind-variables": VARIABLES.bindObj, "table": key.dbtable};
                  arrayAppend(VARIABLES.badRecords, badRecord);

              } else {
                throw(ex);
              }
            }
        }
        insertEnd = getTickCount();
        VARIABLES.insertDuration = (insertEnd - insertStart) / 1000;

        arrayAppend(VARIABLES.messages,"Finished. All records successfully added to " & key.dbTable & ". Duration: " & VARIABLES.insertDuration & " (s)");
        outputAndFlush();
      }

      arrayAppend(VARIABLES.messages,"Finished population of data");
      outputAndFlush();

} catch (any ex) {
    throw(ex);
}

writeOutput("<h2>Bad Records</h2>");
for (rec in VARIABLES.badRecords) {
  writeOutput("<p>" & rec.toString() & "</p>");
}


function updateProgress(msg, rec, recCnt) {
  if (!VARIABLES.progressHTMLOutputFlag) {
    writeOutput(VARIABLES.progressHTML);
    cfflush();
  }

  writeOutput('<script>document.getElementById("msg").innerHTML="' & msg & ' ";document.getElementById("pct").innerHTML="' & decimalFormat((rec/recCnt)*100) & ' %";</script>');
  cfflush();

};


function outputAndFlush() {
    if (NOT styleTagOuputFlag) {
      writeOutput(styleTag);
      styleTagOuputFlag=true;
    }

    for (msg in messages) {
      writeOutput("<p>" & msg & "</p>");
    }

    cfflush();

    //reset messages
    VARIABLES.messages = [];
};

function getSQLScripts() {
  var sqlarray = [
      /*{"name": "populatePrices", "target": "tblSyncPrices", "sql":"
      SELECT S.CODE as STOCKCODE, PR.PRICE, B.NAME AS BANDNAME
    	FROM STOCKITEM S, PRODUCTGROUP P, STOCKITEMPRICE PR, PRICEBAND B
    	WHERE S.PRODUCTGROUPID = P.PRODUCTGROUPID
      AND S.ITEMID = PR.ITEMID
      AND B.PRICEBANDID = PR.PRICEBANDID","truncSQL":"truncate table VEORDERSYNC.dbo.tblSyncPrices", "dbTable":"VEORDERSYNC.dbo.tblSyncPrices",
      "cols": ["stockcode","price","bandname"], "insert":"insert into VEORDERSYNC.dbo.tblSyncPrices (stockcode, price, bandname, insync) values (?,?,?,1)"},*/
      {"name": "populateAuthorisedItems", "target": "tblSyncAuthorisedItem", "sql":"
        SELECT DISTINCT LIST as listcode, STOCKCODE, DISCOUNT FROM AUTHORISEDITEM",
        "truncSQL":"truncate table VEORDERSYNC.dbo.tblSyncAuthorisedItem",
        "dbTable":"VEORDERSYNC.dbo.tblSyncAuthorisedItem",
        "cols": ["listcode","stockcode","discount"],
        "insert":"insert into VEORDERSYNC.dbo.tblSyncAuthorisedItem (listcode, stockcode, discount, insync) values (?,?,?,1)"},
      {"name": "populateAuthorisedList", "target": "tblSyncAuthorisedList", "sql":"
        SELECT DISTINCT CODE as listcode, DESCRIPTION, ALLOWED FROM AUTHORISEDLIST",
        "truncSQL":"truncate table VEORDERSYNC.dbo.tblSyncAuthorisedList",
        "dbTable":"VEORDERSYNC.dbo.tblSyncAuthorisedList",
        "cols": ["listcode","description","allowed"],
        "insert":"insert into VEORDERSYNC.dbo.tblSyncAuthorisedList (listcode, description, allowed, insync) values (?,?,?,1)"},
      {"name": "populateListAssigment", "target": "tblSyncListAssignment", "sql":"
      SELECT CustomerAccountNumber AS account_ref, HASHBYTES('MD5', isNull(AnalysisCode5,'') + isNull(AnalysisCode9,'')) as row_value
      FROM dbo.SLCustomerAccount AS SCA",
      "truncSQL":"truncate table VEORDERSYNC.dbo.tblSyncListAssignment",
      "dbTable":"VEORDERSYNC.dbo.tblSyncListAssignment",
      "cols": ["account_ref","row_value"],
      "insert":"insert into VEORDERSYNC.dbo.tblSyncListAssignment (account_ref, row_value, insync) values (:account_ref,:row_value,1)"},
      {"name": "populateCustomers", "target": "tblSyncCustomers", "sql":"
        SELECT	DISTINCT	CA.CUSTOMERACCOUNTNUMBER 		AS ACCOUNT_REF,
            					HASHBYTES('MD5',
      							isNull(CA.CUSTOMERACCOUNTNAME,'')
      							+isNull(CON.CONTACTNAME,'')
      							+isNull(cast(PB.NAME as varchar),'')
      							+isNull(cast(CA.INVOICELINEDISCOUNTPERCENT as varchar),'')
      							+isNull(CV1.CONTACTVALUE,'')
      							+isNull(CV2.CONTACTVALUE,'')
      							+isNull(LOC.ADDRESSLINE3,'')
            						+isNull(LOC.ADDRESSLINE4,'')
            						+isNull(LOC.POSTCODE,'')
      							+isNull(DEL.POSTCODE,'')
            						+isNull(DEL.CONTACT,'')
            						+isNull(DEL.TELEPHONENO,'')) as row_value
        FROM	SLCUSTOMERACCOUNT CA
      			LEFT  JOIN CUSTDELIVERYADDRESS DEL
      	ON		CA.SLCUSTOMERACCOUNTID = DEL.CUSTOMERID AND DEL.DESCRIPTION = '1'
      			LEFT JOIN SLCUSTOMERCONTACT CON
      	ON		CA.SLCUSTOMERACCOUNTID = CON.SLCUSTOMERACCOUNTID
      			INNER JOIN SLCUSTOMERCONTACTROLE R
      	ON		CON.SLCUSTOMERCONTACTID = R.SLCUSTOMERCONTACTID
      			AND R.SYSTRADERCONTACTROLEID = 1
      			AND R.ISPREFERREDCONTACTFORROLE = 1
      			LEFT JOIN SLCUSTOMERLOCATION LOC
      	ON		CA.SLCUSTOMERACCOUNTID = LOC.SLCUSTOMERACCOUNTID
      			LEFT JOIN SLCUSTOMERCONTACTVALUE CV1
      	ON		CON.SLCUSTOMERCONTACTID = CV1.SLCUSTOMERCONTACTID
      			AND	CV1.SYSCONTACTTYPEID = 0 AND CV1.IsPreferredValue = 1
      			LEFT JOIN SLCUSTOMERCONTACTVALUE CV2
      	ON		CON.SLCUSTOMERCONTACTID = CV2.SLCUSTOMERCONTACTID
      			AND	CV2.SYSCONTACTTYPEID = 2 AND CV2.IsPreferredValue = 1
      			LEFT JOIN PRICEBAND PB
      	ON		CA.PRICEBANDID = PB.PRICEBANDID",
      "truncSQL":"truncate table VEORDERSYNC.dbo.tblSyncCustomers",
      "dbTable":"VEORDERSYNC.dbo.tblSyncCustomers",
      "cols": ["account_ref","row_value"],
      "insert":"insert into VEORDERSYNC.dbo.tblSyncCustomers (account_ref, row_value, insync) values (:account_ref,:row_value,1)"},
      {"name": "populateDeliverySchedules", "target": "tblSyncDeliverySchedule", "sql":"
      SELECT DISTINCT CUSTOMER, DAY, VAN, DELIVERYDROP, DAYOFWEEK FROM DELIVERYSCHEDULE WHERE CUSTOMER NOT LIKE '0WEB%'
      ",
      "truncSQL":"truncate table VEORDERSYNC.dbo.tblSyncDeliverySchedule",
      "dbTable":"VEORDERSYNC.dbo.tblSyncDeliverySchedule",
      "cols": ["customer","day","van","deliverydrop","dayofweek"],
      "insert":"insert into VEORDERSYNC.dbo.tblSyncDeliverySchedule (customer, day, van, deliverydrop, dayofweek, insync) values (?,?,?,?,?,1)"},
      {"name": "populateProducts", "target": "tblSyncProducts", "sql":"
      SELECT dbo.StockItem.ItemID,
  		   HASHBYTES('MD5',cast(dbo.StockItem.Code as varchar)
  		   +isNull(cast(dbo.ProductGroup.Code as varchar),'')
  		   +isNull(cast(dbo.StockItem.FreeStockQuantity as varchar),'')
  		   +isNull(dbo.StockItem.Name+dbo.StockItem.Description,'')
  		   +isNull(cast(dbo.StockItemPrice.Price as varchar),'')
  		   +isNull(cast(dbo.StockItemPrice.PriceBandID as varchar),''))
  		   as row_value
         FROM dbo.StockItem INNER JOIN dbo.StockItemPrice ON dbo.StockItem.ItemID = dbo.StockItemPrice.ItemID
  			 INNER JOIN dbo.ProductGroup on dbo.StockItem.ProductGroupID = dbo.ProductGroup.ProductGroupID
         WHERE (dbo.StockItemPrice.PriceBandID = 1001) AND (dbo.StockItem.StockItemStatusID = 0)
      ",
      "truncSQL":"truncate table VEORDERSYNC.dbo.tblSyncProducts",
      "dbTable":"VEORDERSYNC.dbo.tblSyncProducts",
      "cols": ["itemid","row_value"],
      "insert":"insert into VEORDERSYNC.dbo.tblSyncProducts (itemid, row_value, insync) values (:itemid,:row_value,1)"},
      {"name": "populateCategories", "target": "tblSyncCategory", "sql":"SELECT CODE, DESCRIPTION FROM dbo.PRODUCTGROUP",
      "truncSQL":"truncate table VEORDERSYNC.dbo.tblSyncCategory",
      "dbTable":"VEORDERSYNC.dbo.tblSyncCategory",
      "cols": ["code","description"],
      "insert":"insert into VEORDERSYNC.dbo.tblSyncCategory (code, description, insync) values (?,?,1)"}
      ];

  return sqlarray;
};
</cfscript>
