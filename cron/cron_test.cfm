<!---
    This page gets invoked as a Module / custom tag for
    sandboxing. Copy the Task object reference to the variables
    scope for convenience.
--->
<cfset task = attributes.task />


<cfthrow type="cron.error.ack" message="Random error" detail="random error stuff" errorcode="ack01"/>

<!--- Param the task meta-data. Make sure that it is a struct. --->
<cfif !isStruct( task.metaData )>

<!---
       *********  SET THIS AT THE END **********************
    Create the meta data. This data will be persisted in the
    database automatically.
--->
    <cfset task.metaData = {
        name = "ack",
        results = {
            ack =   randRange(1,10000)
        }
    } />


</cfif>