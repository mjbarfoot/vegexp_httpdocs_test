<cfquery name="chk"  datasource="#APPLICATION.dsn#" result="chkResult">
select 'tblAuthCustomerList' as entity, 'account_ref' as attribute, account_ref as attributevalue, count(1) as count
from  veappdata.tblAuthCustomerList
group by account_ref
having count(1) > 1
union all
select 'tblAuthManagedItem' as entity, 'stockcode' as attribute, stockcode as attributevalue, count(1) as count
from  veappdata.tblAuthManagedItem
group by list, stockcode
having count(1) > 1
union all
select 'tblAuthManagedList' as entity, 'code' as attribute, code as attributevalue, count(1) as count
from  veappdata.tblAuthManagedList
group by code, listtype
having count(1) > 1
union all
select 'tblCategory' as entity, 'Category' as attribute, Category as attributevalue, count(1) as count
from  veappdata.tblCategory
group by DepartmentID, CategoryID, Category
having count(1) > 1
union all
select 'tblDelPostcode' as entity, 'Postcode' as attribute, Postcode as attributevalue, count(1) as count
from  veappdata.tblDelPostcode
group by Postcode
having count(1) > 1
union all
select 'tblDelProfile' as entity, 'DelProfileName' as attribute, DelProfileName as attributevalue, count(1) as count
from  veappdata.tblDelProfile
group by DelProfileName
having count(1) > 1
union all
select 'tblDelSlot' as entity, 'DelSlotID' as attribute, DelSlotID as attributevalue, count(1) as count
from  veappdata.tblDelSlot
group by DelSlotID
having count(1) > 1
union all
select 'tblDeliverySchedule' as entity, 'AccountID' as attribute, AccountID as attributevalue, count(1) as count
from  veappdata.tblDeliverySchedule
group by AccountID, Day
having count(1) > 1
union all
select 'tblFavourite' as entity, 'StockCode' as attribute, StockCode as attributevalue, count(1) as count
from  veappdata.tblFavourite
group by AccountID, StockCode
having count(1) > 1
union all
select 'tblPrices' as entity, 'StockCode' as attribute, StockCode as attributevalue, count(1) as count
from  veappdata.tblPrices
group by stockcode, bandname
having count(1) > 1
union all
select 'tblProducts' as entity, 'StockCode' as attribute, StockCode as attributevalue, count(1) as count
from  veappdata.tblProducts
group by stockcode
having count(1) > 1
union all
select 'tblUsers' as entity, 'AccountID' as attribute, AccountID as attributevalue, count(1) as count
from  veappdata.tblUsers
group by AccountID
having count(1) > 1
</cfquery>

<cfsavecontent variable="content">
    <cfdump var="#chk#" />
</cfsavecontent>


<cfif chk.recordcount neq 0>

    <Cfset mailAttributes = {
        server = "email-smtp.eu-west-1.amazonaws.com",
        username = "AKIAIRWEPDJDQXQY56EA",
        password = "AvijQKLVEq9veHNNi9ANm3VNzbF8dlDUYVWWXohtwQQU",
        port="587",
        useTLS="true",
        from="crontask@orders.vegetarianexpress.co.uk",
        to="matt.barfoot@clearview-webmedia.co.uk",
        subject="Orders Website Data Integrity Alert",
        type = "html"
    }
            />

    <cfmail attributeCollection="#mailAttributes#"><cfoutput>#content#</cfoutput></cfmail>


</cfif>

<cfoutput>#content#</cfoutput>