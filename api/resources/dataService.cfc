<!---
  Created by mbarfoot on 11/07/15.
--->
<cfcomponent>
   <cffunction name="updateCustomer" output="false">
       <cfargument name="record" typ="struct" required="true" />

       <cfscript>

           var posSpace="";
           var firstname="";
           var lastname="";


//set firstname and lastname by splitting string at position of space.
           posSpace = Findnocase(" ", record.CONTACTNAME);
           if (posSpace) {
               firstName = mid(record.CONTACTNAME,1,posSpace);
               lastname  = mid(record.CONTACTNAME, (posSpace+1), len(record.CONTACTNAME));
           } else {
               firstname = "";
               lastname  =	record.CONTACTNAME;
           }

       </cfscript>


       <cfquery name="u" datasource="vegexp_mysql" result="qRes">
            UPDATE tblUsers
            SET
            AccountOnHold = #ARGUMENTS.record.AccountOnHold#,
            firstname = '#FIRSTNAME#',
            lastName = '#LASTNAME#',
            company = '#xmlformat(ReplaceNoCase(ARGUMENTS.record.ACCOUNTNAME, "ONHOLD", "", "ALL"))#',
            discountRate = '#ARGUMENTS.record.DISCOUNTRATE#',
            priceband = '#ARGUMENTS.record.PRICEBAND#',
            telnum = '#ARGUMENTS.record.PHONENUMBER#',
            emailAddress = '#ARGUMENTS.record.EMAILADDRESS#',
            contactPref = 'PHONE',
            building = '#ARGUMENTS.record.BUILDING#',
            postcode = '#ARGUMENTS.record.POSTCODE#',
            viewFC = 1,
            line1 = '#ARGUMENTS.record.LINE1#',
            town = '#ARGUMENTS.record.TOWN#',
            county = '#ARGUMENTS.record.COUNTY#',
            delline1 = '#ARGUMENTS.record.DELLINE1#',
            delline2 = '#ARGUMENTS.record.DELLINE2#',
            delline3 = '#ARGUMENTS.record.DELLINE3#',
            delline4 = '#ARGUMENTS.record.DELLINE4#',
            delPostcode = '#ARGUMENTS.record.DELPOSTCODE#',
            delContactName = '#ARGUMENTS.record.DELCONTACTNAME#',
            delName = '#ARGUMENTS.record.DELCONTACTNAME#',
            delTelephoneNumber = '#ARGUMENTS.record.DELTELNUMBER#',
            delFaxNumber = '#ARGUMENTS.record.DELFAXNO#',
            AllowEmailPost = 1,
            AllowPhoneCalls = 1,
            creditAccount = 1,
            creditAccountAuth = 1,
            AuthLevel = 1,
            LastUpdatedDate = <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
            LastUpdatedTime = <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
            LastUpdatedBy = 'CronTask',
            newCustomer = 0
            WHERE AccountID = '#ARGUMENTS.record.ACCOUNT_REF#'
	</cfquery>


   </cffunction>
    <cffunction name="createCustomer" output="true" returntype="any" hint="adds a customer record">
        <cfargument name="record" type="struct" required="true"/>

        <cfscript>

            var posSpace="";
            var firstname="";
            var lastname="";


//set firstname and lastname by splitting string at position of space.
            posSpace = Findnocase(" ", record.CONTACTNAME);
            if (posSpace) {
                firstName = mid(record.CONTACTNAME,1,posSpace);
                lastname  = mid(record.CONTACTNAME, (posSpace+1), len(record.CONTACTNAME));
            } else {
                firstname = "";
                lastname  =	record.CONTACTNAME;
            }

        </cfscript>


        <cfquery name="i" datasource="vegexp_mysql" result="qRes">
            INSERT INTO tblUsers
            (AccountID,
            AccountOnHold,
            firstname,
            lastName,
            company,
            discountRate,
            priceband,
            telnum,
            emailAddress,
            contactPref,
            building,
            postcode,
            viewFC,
            line1,
            town,
            county,
            delline1,
            delline2,
            delline3,
            delline4,
            delPostcode,
            delContactName,
            delName,
            delTelephoneNumber,
            delFaxNumber,
            AllowEmailPost,
            AllowPhoneCalls,
            creditAccount,
            creditAccountAuth,
            AuthLevel,
            CreateDate,
            CreateTime,
            LastUpdatedDate,
            LastUpdatedTime,
            LastUpdatedBy,
            newCustomer)
            VALUES ('#ARGUMENTS.record.ACCOUNT_REF#',
                    #ARGUMENTS.record.ACCOUNTONHOLD#,
                    '#FIRSTNAME#',
                    '#LASTNAME#',
                    '#xmlformat(ReplaceNoCase(ARGUMENTS.record.ACCOUNTNAME, "ONHOLD", "", "ALL"))#',
                    '#ARGUMENTS.record.DISCOUNTRATE#',
                    '#ARGUMENTS.record.PRICEBAND#',
                    '#ARGUMENTS.record.PHONENUMBER#',
                    '#ARGUMENTS.record.EMAILADDRESS#',
                    'PHONE',
                    '#ARGUMENTS.record.BUILDING#',
                    '#ARGUMENTS.record.POSTCODE#',
                    1,
                    '#ARGUMENTS.record.LINE1#',
                    '#ARGUMENTS.record.TOWN#',
                    '#ARGUMENTS.record.COUNTY#',
                    '#ARGUMENTS.record.DELLINE1#',
                    '#ARGUMENTS.record.DELLINE2#',
                    '#ARGUMENTS.record.DELLINE3#',
                    '#ARGUMENTS.record.DELLINE4#',
                    '#ARGUMENTS.record.DELPOSTCODE#',
                    '#ARGUMENTS.record.DELCONTACTNAME#',
                    '#ARGUMENTS.record.DELCONTACTNAME#',
                    '#ARGUMENTS.record.DELTELNUMBER#',
                    '#ARGUMENTS.record.DELFAXNO#',
                    1,
                    1,
                    1,
                    1,
                    1,
                    <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
                    <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
                    <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
                    <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
                    'CronTask',
                    0)

        </cfquery>


    </cffunction>


</cfcomponent>
