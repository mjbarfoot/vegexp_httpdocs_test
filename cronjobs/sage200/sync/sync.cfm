{"name": "populateAuthorisedItems", "target": "tblSyncAuthorisedItems", "sql":"
  SELECT LIST, STOCKCODE, DISCOUNT FROM AUTHORISEDITEM"},
  "dbTable":"VEORDERSYNC.dbo.tblSyncAuthorisedItem",
  "cols": ["stockcode","price","bandname"],
  "insert":"insert into VEORDERSYNC.dbo.tblSyncPrices (stockcode, price, bandname, insync) values (?,?,?,1)"},
{"name": "populateAuthorisedList", "target": "tblSyncAuthorisedList", "sql":"
  SELECT CODE, DESCRIPTION, ALLOWED FROM AUTHORISEDLIST"},
  "dbTable":"VEORDERSYNC.dbo.tblSyncAuthorisedItem",
  "cols": ["stockcode","price","bandname"],
  "insert":"insert into VEORDERSYNC.dbo.tblSyncPrices (stockcode, price, bandname, insync) values (?,?,?,1)"},
{"name": "populateListAssigment", "target": "tblSyncListAssigment", "sql":"
SELECT CustomerAccountNumber AS ACCOUNT_REF, AnalysisCode5, AnalysisCode9
FROM dbo.SLCustomerAccount AS SCA"},
"dbTable":"VEORDERSYNC.dbo.tblSyncAuthorisedItem",
"cols": ["stockcode","price","bandname"],
"insert":"insert into VEORDERSYNC.dbo.tblSyncPrices (stockcode, price, bandname, insync) values (?,?,?,1)"},
{"name": "populateCustomers", "target": "tblSyncCustomers", "sql":"
SELECT	DISTINCT	CA.CUSTOMERACCOUNTNUMBER 		AS ACCOUNT_REF,
            CA.ACCOUNTISONHOLD 				AS ACCOUNTONHOLD,
            CA.CUSTOMERACCOUNTNAME			AS ACCOUNTNAME,
            PB.NAME							AS PRICEBAND,
            CA.INVOICELINEDISCOUNTPERCENT 	AS DISCOUNTRATE,
            CON.CONTACTNAME 				AS CONTACTNAME,
            CV1.CONTACTVALUE 				AS PHONENUMBER,
            CV2.CONTACTVALUE 				AS EMAILADDRESS,
            LOC.ADDRESSLINE1 				AS BUILDING,
            LOC.ADDRESSLINE2 				AS LINE1,
            LOC.ADDRESSLINE3 				AS TOWN,
            LOC.ADDRESSLINE4 				AS COUNTY,
            LOC.POSTCODE					AS POSTCODE,
            DEL.ADDRESSLINE1 				AS DELLINE1,
            DEL.ADDRESSLINE2 				AS DELLINE2,
            DEL.ADDRESSLINE3 				AS DELLINE3,
            DEL.ADDRESSLINE4 				AS DELLINE4,
            DEL.POSTCODE 					AS DELPOSTCODE,
            DEL.CONTACT 					AS DELCONTACTNAME,
            DEL.TELEPHONENO 				AS DELTELNUMBER,
            DEL.FAXNO						AS DELFAXNO
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
      AND	CV1.SYSCONTACTTYPEID = 0 and CV1.IsPreferredValue = 1
      LEFT JOIN SLCUSTOMERCONTACTVALUE CV2
  ON		CON.SLCUSTOMERCONTACTID = CV2.SLCUSTOMERCONTACTID
      AND	CV2.SYSCONTACTTYPEID = 2 and CV2.IsPreferredValue = 1
      LEFT JOIN PRICEBAND PB
  ON		CA.PRICEBANDID = PB.PRICEBANDID"},
{"name": "populateDeliverySchedules", "target": "tblSyncDeliverySchedules", "sql":"
SELECT CUSTOMER, DAY, VAN, DELIVERYDROP, DAYOFWEEK FROM DELIVERYSCHEDULE
"},
"dbTable":"VEORDERSYNC.dbo.tblSyncAuthorisedItem",
"cols": ["stockcode","price","bandname"],
"insert":"insert into VEORDERSYNC.dbo.tblSyncPrices (stockcode, price, bandname, insync) values (?,?,?,1)"},
{"name": "populateProducts", "target": "tblSyncProducts", "sql":"
SELECT     dbo.StockItem.ItemID,
       dbo.StockItem.Code AS stockcode,
       dbo.StockItem.FreeStockQuantity AS StockQuantity,
       dbo.StockItem.Name,
       dbo.StockItem.Description AS Description,
       dbo.ProductGroup.Code as StockCategoryNumber,
           dbo.StockItem.Weight UnitOfWeight,
           dbo.StockItemPrice.Price SalePrice,
           dbo.StockItemPrice.PriceBandID ,
           dbo.StockItem.SpareText1 UnitOfSale,
           dbo.StockItem.StockItemStatusID
FROM         dbo.StockItem INNER JOIN dbo.StockItemPrice ON dbo.StockItem.ItemID = dbo.StockItemPrice.ItemID
       INNER JOIN dbo.ProductGroup on dbo.StockItem.ProductGroupID = dbo.ProductGroup.ProductGroupID
WHERE     (dbo.StockItemPrice.PriceBandID = 1001) AND (dbo.StockItem.StockItemStatusID = 0)
ORDER BY dbo.ProductGroup.Code asc
",
"dbTable":"VEORDERSYNC.dbo.tblSyncProducts",
"cols": ["itemid","row_value"],
"insert":"insert into VEORDERSYNC.dbo.tblSyncProducts (itemid, row_value, insync) values (?,?,?,1)"}
];
