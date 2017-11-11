<cfcomponent output="false">

	<cffunction name="read" output="false" access="public" returntype="cfc.data.tblCronScheduleBean">
		<cfargument name="id" required="true">
		<cfset var qRead="">
		<cfset var obj="">

		<cfquery name="qRead" datasource="veappdata">
			select 	CronJobID, CronJobName, CronJobDesc, CronJobFile, CronStatus, Frequency, 
					FreqUnit, LastRun, NextRun
			from tblCronSchedule
			where CronJobID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.id#" />
		</cfquery>

		<cfscript>
			obj = createObject("component", "cfc.data.tblCronScheduleBean").init();
			obj.setCronJobID(qRead.CronJobID);
			obj.setCronJobName(qRead.CronJobName);
			obj.setCronJobDesc(qRead.CronJobDesc);
			obj.setCronJobFile(qRead.CronJobFile);
			obj.setCronStatus(qRead.CronStatus);
			obj.setFrequency(qRead.Frequency);
			obj.setFreqUnit(qRead.FreqUnit);
			obj.setLastRun(qRead.LastRun);
			obj.setNextRun(qRead.NextRun);
			return obj;
		</cfscript>
	</cffunction>



	<cffunction name="create" output="false" access="public">
		<cfargument name="bean" required="true" type="cfc.data.tblCronScheduleBean">
		<cfset var qCreate="">

		<cfset var qGetId="">

		<cfset var local1=arguments.bean.getCronJobName()>
		<cfset var local2=arguments.bean.getCronJobDesc()>
		<cfset var local3=arguments.bean.getCronJobFile()>
		<cfset var local4=arguments.bean.getCronStatus()>
		<cfset var local5=arguments.bean.getFrequency()>
		<cfset var local6=arguments.bean.getFreqUnit()>
		<cfset var local7=arguments.bean.getLastRun()>
		<cfset var local8=arguments.bean.getNextRun()>

		<cftransaction isolation="read_committed">
			<cfquery name="qCreate" datasource="veappdata">
				insert into tblCronSchedule(CronJobName, CronJobDesc, CronJobFile, CronStatus, Frequency, FreqUnit, LastRun, NextRun)
				values (
					<cfqueryparam value="#local1#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#local2#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#local3#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#local4#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#local5#" cfsqltype="CF_SQL_INTEGER" null="#iif((local5 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local6#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#local7#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((local7 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local8#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((local8 eq ""), de("yes"), de("no"))#" />
				)
			</cfquery>

			<!--- If your server has a better way to get the ID that is more reliable, use that instead --->
			<cfquery name="qGetID" datasource="veappdata">
				select CronJobID
				from tblCronSchedule
				where CronJobName = <cfqueryparam value="#local1#" cfsqltype="CF_SQL_VARCHAR" />
				  and CronJobDesc = <cfqueryparam value="#local2#" cfsqltype="CF_SQL_VARCHAR" />
				  and CronJobFile = <cfqueryparam value="#local3#" cfsqltype="CF_SQL_VARCHAR" />
				  and CronStatus = <cfqueryparam value="#local4#" cfsqltype="CF_SQL_VARCHAR" />
				  and Frequency = <cfqueryparam value="#local5#" cfsqltype="CF_SQL_INTEGER" null="#iif((local5 eq ""), de("yes"), de("no"))#" />
				  and FreqUnit = <cfqueryparam value="#local6#" cfsqltype="CF_SQL_VARCHAR" />
				  and LastRun = <cfqueryparam value="#local7#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((local7 eq ""), de("yes"), de("no"))#" />
				  and NextRun = <cfqueryparam value="#local8#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((local8 eq ""), de("yes"), de("no"))#" />
				order by CronJobID desc
			</cfquery>
		</cftransaction>

		<cfscript>
			arguments.bean.setCronJobID(qGetID.CronJobID);
		</cfscript>
		<cfreturn arguments.bean />
	</cffunction>



	<cffunction name="update" output="false" access="public">
		<cfargument name="bean" required="true" type="cfc.data.tblCronScheduleBean">
		<cfset var qUpdate="">

		<cfquery name="qUpdate" datasource="veappdata" result="status">
			update tblCronSchedule
			set CronJobName = <cfqueryparam value="#arguments.bean.getCronJobName()#" cfsqltype="CF_SQL_VARCHAR" />,
				CronJobDesc = <cfqueryparam value="#arguments.bean.getCronJobDesc()#" cfsqltype="CF_SQL_VARCHAR" />,
				CronJobFile = <cfqueryparam value="#arguments.bean.getCronJobFile()#" cfsqltype="CF_SQL_VARCHAR" />,
				CronStatus = <cfqueryparam value="#arguments.bean.getCronStatus()#" cfsqltype="CF_SQL_VARCHAR" />,
				Frequency = <cfqueryparam value="#arguments.bean.getFrequency()#" cfsqltype="CF_SQL_INTEGER" null="#iif((arguments.bean.getFrequency() eq ""), de("yes"), de("no"))#" />,
				FreqUnit = <cfqueryparam value="#arguments.bean.getFreqUnit()#" cfsqltype="CF_SQL_VARCHAR" />,
				LastRun = <cfqueryparam value="#arguments.bean.getLastRun()#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((arguments.bean.getLastRun() eq ""), de("yes"), de("no"))#" />,
				NextRun = <cfqueryparam value="#arguments.bean.getNextRun()#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((arguments.bean.getNextRun() eq ""), de("yes"), de("no"))#" />
			where CronJobID = <cfqueryparam value="#arguments.bean.getCronJobID()#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfreturn arguments.bean />
	</cffunction>



	<cffunction name="delete" output="false" access="public" returntype="void">
		<cfargument name="bean" required="true" type="cfc.data.tblCronScheduleBean">
		<cfset var qDelete="">

		<cfquery name="qDelete" datasource="veappdata" result="status">
			delete
			from tblCronSchedule
			where CronJobID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bean.getCronJobID()#" />
		</cfquery>

	</cffunction>


</cfcomponent>