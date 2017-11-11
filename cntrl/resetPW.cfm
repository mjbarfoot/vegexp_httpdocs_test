<cfquery name="qryUpdateAccount" datasource="#APPLICATION.dsn#">
UPDATE tblUsers
SET accPass = '#HASH("te57er")#'
WHERE AccountID = '#url.AccountID#'
</cfquery>

<cfoutput>Job Done!</cfoutput>