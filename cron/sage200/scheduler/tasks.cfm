<!---
    Query for all the tasks that look like they should be
    executing - that is, tasks whose "next" execution date has
    passed AND who are not currently executing.
--->
<cfquery name="tasks" datasource="veappdata">
    SELECT
        t.id
    FROM
        veappdata.tblCronSchedule t
    WHERE
        t.server = 'SAGE' and
        t.dateOfNextExecution <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
    AND
    t.dateStarted IS NULL
    ORDER BY
    t.id ASC
</cfquery>

<!---
    Now that we have the tasks, we are going to examine each one
    using a separate HTTP call. This way, we don't use a CFThread and
    don't have to worry about nested thread errors. In order to do
    this, let's get the base HTTP URL.
--->
<cfset baseUrl = (
    "http://" &
    cgi.server_name & ":" & cgi.server_port &
        getDirectoryFromPath( cgi.script_name )
    ) />

<!--- Loop over each task to invoke. --->
<cfloop query="tasks">
    <cfoutput>Calling #baseUrl#run.cfm?url=#tasks.id#</cfoutput>
<!---
    When running the task, we don't want to wait for the task
    to return - this way, we can try to have all the tasks
    running in parallel (as best as possible).
--->
    <cfhttp
            method="get"
            url="#baseUrl#run.cfm"
            timeout="1"
            throwonerror="false">

<!--- Pass the task ID through to the RUN page. --->
        <cfhttpparam
                type="url"
                name="id"
                value="#tasks.id#"
                />

    </cfhttp>

</cfloop>