<cfoutput>
<div class="text-center card shadow-sm bg-light border border-5 border-white">
	<div class="card-body">
			<div class="col-lg-12 mx-auto">

			<!--- <cfdump var=#datarow#> --->
			<!--- <table class="table table-striped table-sm table-bordered">
				<thead>
					<tr>
						<th>Contractor Name</th>
						<th>Crew Code</th>
						<th>Crew</th>
						<th>Field Vines per Acre</th>
						<th>Field</th>
						<th>Total Acres</th>
						<th>Variety Name</th>
						<th>Field Total Vines</th>
						<th>Operation</th>
						<th>Operation Name</th>
						<th>Crew Date</th>
						<th>Cost / Acre Actual</th>
						<th>Man Hr / Acre Actual</th>
						<th>Quality Score</th>
						<th>Total Vines</th>
						<th>Acres</th>
						<th>Leader Hours</th>
						<th>Assistant Hours</th>
						<th>Inspector Hours</th>
						<th>Employee Hours</th>
						<th>Total Cost</th>
					</tr>
				</thead>
				<tbody>


					<cfoutput query="datarow">
						<cfset vines_per_acre = 0>
						<cfif isNumeric(datarow.vine_count) && isNumeric(datarow.field_acres1)>
							<cfset vines_per_acre = numberFormat(datarow.vine_count/datarow.field_acres1)>
						</cfif>
						<cfset QC_Hours = 0>
						<cfset employeeHours = 0>
						<cfset LeaderHours = 0>
						<cfset AssistantHours = 0>
						<cfif isNumeric(datarow.QC_Hours)>
							<cfset QC_Hours = datarow.QC_Hours>
						</cfif>
						<cfif isDate(datarow.TotalCalculatedTime)>
							<cfset employeeHours = timeformat(datarow.TotalCalculatedTime,"H")>
						<cfelseif isNumeric(datarow.TotalCalculatedTime)>
							<cfset employeeHours = datarow.TotalCalculatedTime>
						</cfif>
						<cfset total = (
							(employeeHours*14.25)
							+(LeaderHours*18.6)
							+(AssistantHours*16.8)
							+(QC_Hours*20.75)
						)*1.32>

						<cfset vineacres = 0>
						<cfif vines_per_acre && isNumeric(datarow.Totalvines)>
							<cfset vineacres = datarow.Totalvines/vines_per_acre>
						</cfif>

						<cfset employeeAcresPerHr = 0>
						<cfif vineacres gt 0 && isNumeric(employeeHours)>
							<cfset employeeAcresPerHr = employeeHours/vineacres>
						</cfif>

						<cfset acresPerHour = 0>
						<cfif vineacres gt 0>
							<cfset acresPerHour = total/vineacres>
						</cfif>
						<tr>
							<td><!--Contractor Name--></td>
							<td>#datarow.crew#</td>
							<td>#datarow.CrewName#</td>
							<td>#numberFormat(vines_per_acre)#</td>
							<td>#fieldcode#</td>
							<td>#datarow.field_acres1#</td>
							<td>#datarow.Variety_name#</td>
							<td>#datarow.vine_count#</td>
							<td>#datarow.JobCode#</td>
							<td>#datarow.description#</td>
							<td nowrap>#datarow.Date#</td>
							<td>#DollarFormat(acresPerHour)#</td>
							<td>#decimalformat(employeeAcresPerHr)#</td>
							<td>#datarow.QC_AVERAGE#</td>
							<td>#datarow.Totalvines#</td>
							<td>#decimalformat(vineacres)#</td>
							<td>#numberFormat(LeaderHours)#</td>
							<td>#numberFormat(AssistantHours)#</td>
							<td>#numberFormat(QC_Hours)#</td>
							<td>#numberFormat(employeeHours)#</td>
							<td>#DollarFormat(total)#</td>
						</tr>
					</cfoutput>
				</tbody>
			</table> --->
			<cfloop array="#prc.data#" index="datarow">
				<cfset datarow.vines_per_acre = 0>
				<cfif isNumeric(datarow.vine_count) && isNumeric(datarow.field_acres1)>
					<cfset datarow.vines_per_acre = numberFormat(datarow.vine_count/datarow.field_acres1)>
				</cfif>
				<cfset datarow.QC_Hours = 0>
				<cfset datarow.employeeHours = 0>
				<cfset datarow.LeaderHours = 0>
				<cfset datarow.AssistantHours = 0>
				<cfif isNumeric(datarow.QC_Hours)>
					<cfset datarow.QC_Hours = datarow.QC_Hours>
				</cfif>
				<cfif isDate(datarow.TotalCalculatedTime)>
					<cfset employeeHours = timeformat(datarow.TotalCalculatedTime,"H")>
				<cfelseif isNumeric(datarow.TotalCalculatedTime)>
					<cfset employeeHours = datarow.TotalCalculatedTime>
				</cfif>
				<cfset datarow.total = (
					(datarow.employeeHours*14.25)
					+(datarow.LeaderHours*18.6)
					+(datarow.AssistantHours*16.8)
					+(datarow.QC_Hours*20.75)
				)*1.32>

				<cfset datarow.vineacres = 0>
				<cfif datarow.vines_per_acre && isNumeric(datarow.Totalvines)>
					<cfset datarow.vineacres = datarow.Totalvines/datarow.vines_per_acre>
				</cfif>

				<cfset datarow.employeeAcresPerHr = 0>
				<cfif datarow.vineacres gt 0 && isNumeric(employeeHours)>
					<cfset datarow.employeeAcresPerHr = datarow.employeeHours/datarow.vineacres>
				</cfif>

				<cfset datarow.acresPerHour = 0>
				<cfif datarow.vineacres gt 0>
					<cfset datarow.acresPerHour = datarow.total/datarow.vineacres>
				</cfif>
			</cfloop>


			<div id="app">
					<vue-table-dynamic :params="params">
						<template v-slot:column-0="{ props }">

						<div class="button-wrapper">
								<a class="btn  btn-sm btn-outline-primary"><i class="bi bi-files"></i></a>
								<a class="btn  btn-sm btn-outline-secondary"><i class="bi bi-pencil-square"></i></a>
								<a class="btn  btn-sm btn-outline-danger"><i class="bi bi-trash3"></i></a>
						</div>
						</template>
					</vue-table-dynamic>
			</div>
		</div>
	</div>
</div>
<style>
	.button-wrapper {
		flex: 0 0 150px;
		justify-content: space-evenly;
	}
</style>
<script>
	var tabledata = #SerializeJSON(prc.data)#;
</script>
</cfoutput>
<script src="resources/js/timesheet.js"></script>
