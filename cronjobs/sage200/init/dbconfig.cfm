<!--- Specification for dbconfig.cfm
1. create ve-orders-sync db
2. create sync tables - each table as primary key, hash value and insync flag
  2.1 tblSyncPrices
  2.2 tblSyncAuthorisedItems
  2.3 tblSyncAuthorisedList
  2.4 tblSyncListAssigment
  2.5 tblSyncCustomers
  2.6 tblSyncDeliverySchedules
  2.7 tblSyncPrices
  2.8 tblSyncProducts
The sync tables hold a hash value against the primary key which is used for comparison.
--->
<cfscript>
//vars
util = createObject("component", "sage200sync.com.util");
include "..\vars.cfm";
step = 0;
VARIABLES.messages = [];
tables = getTables();
styleTag="<style>p {color:  ##00ff00; font-family: 'Lucida Console'; font-size: 11px;};</style>";
styleTagOuputFlag=false;

// start script
try {


    // create db
    if (checkIfSyncDbExists()) {
      arrayAppend(messages, "VEORDERSYNC exists. Dropping and recreating");
      arrayAppend(messages, "Dropping DB");
      outputAndFlush();
      dropSyncDb();
      arrayAppend(messages, "Database dropped");
      outputAndFlush();
    }

    arrayAppend(messages, "Creating VEORDERSYNC database");
    createSyncDb();
    outputAndFlush();

    arrayAppend(messages, "Finished  creating VEORDERSYNC database");
    outputAndFlush();

    //create tables
    createTables(tables);
    outputAndFlush();

} catch (any ex) {
    throw(ex);
}


//endScript();


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


function endScript () {
    writeOutput(util.htmlOut(messages));
};

function createSyncDb() {
  sql = "CREATE DATABASE VEORDERSYNC";
  myQuery = queryExecute(sql, {}, {datasource = VARIABLES.sage200sync.syncdb_dsn});
}


function dropSyncDb() {
  sql = "ALTER DATABASE VEORDERSYNC SET AUTO_CLOSE OFF ";
  myQuery = queryExecute(sql, {}, {datasource = VARIABLES.sage200sync.syncdb_dsn});
  sql = "ALTER DATABASE VEORDERSYNC SET SINGLE_USER WITH ROLLBACK IMMEDIATE";
  myQuery = queryExecute(sql, {}, {datasource = VARIABLES.sage200sync.syncdb_dsn});
  sql = "DROP DATABASE VEORDERSYNC";
  myQuery = queryExecute(sql, {}, {datasource = VARIABLES.sage200sync.syncdb_dsn});
}

function checkIfSyncDbExists() {
  sql = "SELECT name FROM master.dbo.sysdatabases WHERE name = 'VEORDERSYNC'";
  myQuery = queryExecute(sql, {}, {datasource = VARIABLES.sage200sync.syncdb_dsn});
  return IIF(myQuery.recordcount eq 1, true, false)
};

function createTables(tables) {
    sql = "";
    for (table in tables) {
        sql = "create table VEORDERSYNC.dbo." & table.name & " ( ";
          if (table.hash) {
              // pk
              sql &= table.cols[1].name & " " & table.cols[1].type & ",";
              sql &= " row_value varbinary(8000),";
          } else {
              // create definition for all the columns
              for (col in table.cols) {
                sql &= " [" & col.name & "] " & col.type & " NOT NULL,";
              }
          }

          // create row_value (hash column and insync)
          sql &= " insync bit NOT NULL DEFAULT 0 ";

          //primary column constraint
          sql &= chr(13) & "CONSTRAINT PK_" & FormatBaseN(randRange(1000000, 2000000),16) & " PRIMARY KEY NONCLUSTERED (";
          keyIdx = 1;
          for (key in table.pk) {
              sql &= "[" & key & "]";

            if (keyIdx lt arraylen(table.pk)) {
              sql &= ",";
            }
            keyIdx++;
          }

          sql &= "))";
          arrayAppend(messages,sql);
          myQuery = queryExecute("DROP TABLE IF EXISTS VEORDERSYNC.dbo." & table.name, {}, {datasource = VARIABLES.sage200sync.syncdb_dsn});
          myQuery = queryExecute(sql, {}, {datasource = VARIABLES.sage200sync.syncdb_dsn});
    }

}

function getTables() {
  var tables = [
    {"name": "tblSyncCategory", "cols": [
                {"name":"code", type: "varchar(20)"},
                {"name":"description",type: "varchar(50)"}
                ],
                "hash": false,
                "pk": ["code"]
    },
    {"name": "tblSyncAuthorisedItem","cols":
                [
                {"name":"listcode",  type: "varchar(25)"},
                {"name":"stockcode", type: "varchar(50)"},
                {"name":"discount", type: "decimal(2,2)"}
                ],
                "hash": false,
                "pk": ["listcode","stockcode"]
    },
    {"name": "tblSyncAuthorisedList","cols":
               [
                {"name":"listcode", type: "varchar(25)"},
                {"name":"description", type: "varchar(50)"},
                {"name":"allowed", type: "bit"}
                ],
                "hash": false,
                "pk": ["listcode"]
    },
    {"name": "tblSyncListAssignment","cols":[
                {"name":"account_ref", type: "varchar(25)"},
                {"name":"managed_list", type: "varchar(25)"},
                {"name": "analysiscode5", type: "varchar(25)"},
                {"name": "analysiscode9", type: "varchar(25)"}
                ],
                "hash": true,
                "pk": ["account_ref"]
    },
    {"name": "tblSyncCustomers","cols": [
                {"name": "account_ref",type: "varchar(50)"},
                {"name": "discountrate",type: "decimal(4,2)"},
                {"name": "contactname",type: "varchar(255)"},
                {"name":  "emailaddress",type: "varchar(255)"},
                {"name": "postcode",type: "varchar(255)"},
                {"name": "delpostcode", type: "varchar(255)"}
                ],
                "hash": true,
                "pk": ["account_ref"]
    },
    {"name": "tblSyncDeliverySchedule","cols": [
                    {"name": "customer", type: "varchar(25)"},
                    {"name": "day", type: "varchar(10)"},
                    {"name": "van", type: "int"},
                    {"name": "deliverydrop", type:"varchar(50)"},
                    {"name": "dayofweek", type:"int"}
                  ],
                  "hash": false,
                  "pk":["customer","day"]},
    {"name": "tblSyncPrices", cols: [
              {"name":"stockcode", type:"varchar(25)"},
              {"name":"price", type:"decimal(5,2)"},
              {"name":"bandname", type:"varchar(250)"},
            ],
            "hash": false, "pk": ["stockcode","bandname"]},
    {"name": "tblSyncProducts", cols: [
            {"name": "itemid", type: "int"},
            {"name": "stockcode", type: "varchar(255)"},
            {"name": "freestockquantity",type: "int"},
            {"name": "description",type: "255"},
            {"name": "name",type: "255"},
            ] ,
            "hash": true,
            "pk":["itemid"]
          }
  ];

  return tables;
}



</cfscript>
