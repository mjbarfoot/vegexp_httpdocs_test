<!---
    Set a reasonable timeout for this task execution. This can
    always be overriden in the individual task templates.
--->
<cfsetting requesttimeout="600" />


<!--- Param the task ID. --->
<cfparam name="url.id" type="numeric" default="0" />


<!---
    Since this page can be run either from the database or manually,
    let's wrap the page in an exlcusive lock so as to make sure that
    subsequent executions don't overlap.

    NOTE: We are not going to throw an error if the lock times-out
    since this task will just be run again later.
--->
<cflock
        name="tasks_#url.id#_#hash( getCurrentTemplatePath() )#"
        type="exclusive"
        timeout="1"
        throwontimeout="false">


<!---
    Now that we are exclusive, query for the given task. When
    doing so, we are going to make sure that the task is not
    currently running (that its dateStarted time is NULL).
--->
    <cfquery name="task" datasource="vegexp_mysql">
       SELECT t.id,
	   t.crontaskid,
	   t.server,
	   c.name,
	   c.description,
	   c.template,
	   t.metaData,
	   t.interval,
       t.dateOfLastExecution,
       t.dateOfNextExecution,
       t.dateStarted
        FROM veappdata.tblCronSchedule t, tblCronTask c
        WHERE t.crontaskid = c.crontaskid
        AND t.id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer" />
        AND t.dateOfNextExecution <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
        AND t.dateStarted IS NULL
    </cfquery>

<!---
    Make sure that the task was found. If not, then just exit
    out as there's nothing left to do.
--->
    <cfif !task.recordCount>

<!--- Nothing more to do. --->
        <cfexit />

    </cfif>


<!--- ------------------------------------------------- --->
<!--- ------------------------------------------------- --->


<!---
    If we've made it this far, then we have a task that needs
    to be executed. As such, let's flag it as being started.
--->
    <cfquery name="changeTaskStatus" datasource="vegexp_mysql">
        UPDATE
            veappdata.tblCronSchedule
        SET
            dateStarted = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
        WHERE
        id = <cfqueryparam value="#task.id#" cfsqltype="cf_sql_integer" />
    </cfquery>

<!---
    Record an execution of this cron job
--->
    <cfset dStart = now()/>

    <cfquery name="iCronAction" datasource="vegexp_mysql">
        INSERT INTO
            veappdata.tblCronAction (crontaskid, dateOfExecution)
        VALUES (<cfqueryparam value="#task.crontaskid#" cfsqltype="cf_sql_integer" />,
        <cfqueryparam value="#dStart#" cfsqltype="cf_sql_timestamp" /> )
    </cfquery>

<!--- fetch the id--->
    <cfquery name="action" datasource="vegexp_mysql">
       SELECT
       id
       FROM
       veappdata.tblCronAction
       WHERE
       crontaskid = <cfqueryparam value="#task.crontaskid#" cfsqltype="cf_sql_integer" />
        AND dateOfExecution =  <cfqueryparam value="#dStart#" cfsqltype="cf_sql_timestamp" />
    </cfquery>


<!---
    When we run the task, let's wrap it in a try/catch so that we
    can log any errors that occur.
--->
    <cftry>

<!---
    When we execute the task, we're going to do so as a
    module. This will give the task some level of sandboxing.
    However, we also want the task algorithm to be able to
    modify the task metaData and next execution date. As
    such, let's create a task data object to pass into the
    module during execution.
--->
        <cfset taskData = {
            id = task.id,
            name = task.name,
            description = task.description,
            template = task.template,
            interval = task.interval,
            metaData = task.metaData,
            dateOfLastExecution = task.dateOfLastExecution,
            dateOfNextExecution = task.dateOfNextExecution
        } />

<!---
    Before executing the task, check to see if the meta data
    is valid JSON data. If so, let's implicitly deserialize
    it prior to task execution.
--->
        <cfif isJSON( taskData.metaData )>

<!--- Deserialize meta data. --->
            <cfset taskData.metaData = deserializeJSON( taskData.metaData ) />

        </cfif>

<!---
    Execute the task as a module to give it a little bit of
    a sandbox to play in. We don't want it messing up the
    variables in this page. When doing this, let's pass the
    Task data object in for reference.
--->
        <cfmodule
                template="#task.template#"
                task="#taskData#">


<!---
        record the duration of the task
--->
    <cfset dEnd = now() />
    <cfset durationSeconds = (dEnd - dStart) * 1440 * 60 />
    <cfset dateOfNextExecution = task.dateOfNextExecution + task.interval />



<!---
    If we made it this far, then the task has executed
    completely and without error. Update the record for
    next execution.
--->
        <cfquery name="updateTask" datasource="vegexp_mysql">
            UPDATE
                veappdata.tblCronSchedule
            SET
                <!---
                    Move the date started into the last exectuion for
                    debugging purposes.
                --->
                dateOfLastExecution = dateStarted,

                <!---
                    Flag the task as no longer running so that it can
                    be invoked next time.
                --->
                dateStarted = NULL,

                <!---
                    Check to see if the date of next execution in the
                    Task object is the same as the one originally
                    passed-in. If so, then perform the update
                    automatically. If the Task-based date of next
                    execution is different, assume the task algorithm
                    set it explicitly (and that we should use that one
                    directly).

                    NOTE: We are using dateDiff() rather than EQ
                    so as to account for differently formatted dates
                    and dates that are too similar to warrant a
                    difference.
                --->
            <cfif dateOfNextExecution lte now()>
                dateOfNextExecution = <cfqueryparam value="#(now() + task.interval + task.interval)#" cfsqltype="cf_sql_timestamp" />,


            <cfelseif !dateDiff( "n",dateOfNextExecution, taskData.dateOfNextExecution )>

<!---
    Update the date of next execution by
    incrementing the current time by the given
    internval. Remember, the interval in our
    system is defined as a fractional number of
    days. As such, we can simply use date-math to
    make the addition.
--->
                dateOfNextExecution = <cfqueryparam value="#(task.dateOfNextExecution + task.interval)#" cfsqltype="cf_sql_timestamp" />,

                <cfelse>

<!---
    Use the date provided by the task (which was
    presumed to have been updated by the task
    algorithm).
--->
                dateOfNextExecution = <cfqueryparam value="#taskData.dateOfNextExecution#" cfsqltype="cf_sql_timestamp" />,

            </cfif>

<!---
    Store any meta data that has been put into the
    task object. Since the database can only hold
    string data, we'll convert the value to JSON.
--->
            metaData = <cfqueryparam value="#serializeJSON( taskData.metaData )#" cfsqltype="cf_sql_longvarchar" />

<!--- Clear out any old error-log.
            errorLog = <cfqueryparam value="" cfsqltype="cf_sql_longvarchar" />--->
            WHERE
            id = <cfqueryparam value="#task.id#" cfsqltype="cf_sql_integer" />
        </cfquery>


<!---
    update cronAtion recording any results
--->
        <cfquery name="updateAction" datasource="vegexp_mysql">
               UPDATE
                veappdata.tblCronAction
                SET
                success = 1,
                results = <cfqueryparam value="#serializeJSON( taskData.metaData.results )#" cfsqltype="cf_sql_longvarchar" />,
                duration = <cfqueryparam value="#durationSeconds#" cfsqltype="cf_sql_integer" />
                WHERE  id = <cfqueryparam value="#action.id#" cfsqltype="cf_sql_integer" />
         </cfquery>



<!--- Catch any errors that bubbled up from the task. --->
        <cfcatch>
<!---
    Log error in database. For this demo, we will be
    logging the CFCatch object as JSON to the text field.
--->
            <cfquery name="logError" datasource="vegexp_mysql">
                UPDATE
                     veappdata.tblCronAction
                SET
                    errorLog = <cfqueryparam value="#serializeJSON( cfcatch )#" cfsqltype="cf_sql_longvarchar" />
                WHERE
                id = <cfqueryparam value="#action.id#" cfsqltype="cf_sql_integer" />
            </cfquery>

<!--- --------------------------------- --->
<!--- --------------------------------- --->
<!---
    At this point, you probably want to shoot
    out an email to someone so as to alert them
    that an unexpected TASK error has occurred.
    Or, you might create that as a task in an of
    itself (a task that checks the errorLog
    fields of other tasks).
--->
<!--- --------------------------------- --->
<!--- --------------------------------- --->

        </cfcatch>

    </cftry>


</cflock>