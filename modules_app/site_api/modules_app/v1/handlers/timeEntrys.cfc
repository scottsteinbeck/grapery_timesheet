component extends="BaseHandler"{
    // HTTP Method Security
	this.allowedMethods = {
		index : "GET",
		create: "POST,PUT",
		update: "POST,PUT,PATCH",
		delete: "DELETE"
	};

	property name = "qb" inject = 'QueryBuilder@qb';
	property name = "JSONDiff" inject = "JSONDiff";

	function index( event, rc, prc ) {
		// if(rc.filterData != '') {
		// 	dump(rc.filterCol);
		// 	dump(rc.filterData);
		// 	abort;
		// }

		var employee_hrs ="coalesce(TRY_CAST(Total_Hours as numeric),0)";
		var leader_hrs ="coalesce(TRY_CAST(TimeDiff as numeric) / 60,0)";
		var assistant_hrs ="COALESCE(((TRY_CAST(TimeDiff2nd as numeric) + TRY_CAST(TimeDiff3rd as numeric))/60),0)";
		var inspector_hours ="COALESCE(TRY_CAST(QC_Hours as numeric),0)";
		var total_hours = "#employee_hrs# + #leader_hrs# + #assistant_hrs# + #inspector_hours#";
		var field_acres  ="COALESCE(TRY_CAST(field_acres1 as numeric),1)";
		selectItems = [
            "BlockID", "Crew", "FieldCode", "Time_Entry_Form_v4.JobCode", "QC_Average", "Totalvines", 
			
			"coalesce(TRY_CAST(Total_Hours as numeric),0) as Total_Hours", 
			"coalesce(TRY_CAST(QC_Hours as numeric),0) as QC_Hours", 
			"coalesce(TRY_CAST(TimeDiff as numeric),0) as TimeDiff", 
			"coalesce(TRY_CAST(TimeDiff2nd as numeric),0) as TimeDiff2nd", 
			"coalesce(TRY_CAST(TimeDiff3rd as numeric),0) as TimeDiff3rd",
			"#employee_hrs# as employee_hrs",
			"#leader_hrs# as leader_hrs",
			"#assistant_hrs# as assistant_hrs",
			"#inspector_hours# as inspector_hours",

			"costOverride",
			"Totalunits",
			"TotalCalculatedTime",
			"ROW_INDEX",
			"RECIEPTNO",
			"FORMAT (Time_Entry_Form_v4.Date, 'yyyy-MM-dd') AS Date",
            "pSeason", 
			"pLeader", 
			"pAssistant", 
			"pQC", 
			"pFieldWorker",
			
			"vine_count",
			"Variety_name",
			"description",
			"contractor_name",

			"field_acres1",

			"round((TRY_CAST (vine_count AS FLOAT)/#field_acres#),2) AS vines_per_acre",
			
			"( #leader_hrs# * pLeader ) + ( #assistant_hrs# * pAssistant)  + ( #inspector_hours# * pQC)  + ( #employee_hrs# * pFieldWorker) + (CASE WHEN Time_Entry_Form_v4.jobcode = 4940 THEN (TRY_CAST (Totalunits AS FLOAT) * 0.6832 ) ELSE 0 END)  AS total",
			"ROUND((Totalvines/(TRY_CAST (vine_count AS FLOAT)/#field_acres#)),2) AS vineacres",

			// employeeHours / vineacres = employeeAcresPerHr
			"CASE WHEN Totalvines> 0 THEN ROUND((#total_hours#)/(Totalvines/(TRY_CAST (vine_count AS FLOAT)/#field_acres#)),2) ELSE 0 END AS employeeAcresPerHr",
			
			// total / vineacres = acresPerHour
			"CASE WHEN Totalvines> 0 THEN ROUND((( #leader_hrs# * pLeader ) + ( #assistant_hrs# * pAssistant) + ( #inspector_hours# * pQC) + ( #employee_hrs# * pFieldWorker) )/(Totalvines/(TRY_CAST (vine_count AS FLOAT)/#field_acres#)),2) ELSE 0 END AS acresPerHour",

			"PTCREW.CrewName"
		];

		if(rc.keyExists("pq_sort")) {
			var usendingOrDesending = (deserializeJSON(rc.pq_sort)[1].dir == "up") ? "desc" : "asc";
			var sortBy = deserializeJSON(rc.pq_sort)[1].dataIndx;
			if(sortBy == "crew_info") sortBy = "Crew";
			if(sortBy == "jobcode_info") sortBy = "description";
		}
		else {
			var usendingOrDesending = "desc";
			var sortBy = "Time_Entry_Form_v4.Date";
		}

		var timeEntryForm = qb.newQuery().from('Time_Entry_Form_v4')
			.selectRaw(selectItems.toList(', '))
			.leftJoin('ArcGIS.gidata.JOBCODES', function(j){
				j.on('Time_Entry_Form_v4.JobCode', '=', 'ArcGIS.gidata.JOBCODES.jobcode');
				j.where('ArcGIS.gidata.JOBCODES.GDB_TO_DATE', '=', {value:'9999-12-31 23:59:59.000', cfsqltype = "CF_SQL_TIMESTAMP"});
			})
			.leftJoin('ArcGIS.gidata.PTCREW', function(j){
				j.on('Time_Entry_Form_v4.Crew', '=', 'ArcGIS.gidata.PTCREW.CrewNumber');
				j.where('ArcGIS.gidata.PTCREW.GDB_TO_DATE', '=', {value:'9999-12-31 23:59:59.000', cfsqltype = "CF_SQL_TIMESTAMP"});
			})
			.leftJoin('ArcGIS.gidata.POLYFIELD', function(j){
				j.on('Time_Entry_Form_v4.FieldCode' , '=', 'ArcGIS.gidata.POLYFIELD.field_name');
				j.where('ArcGIS.gidata.POLYFIELD.GDB_TO_DATE', '=', {value:'9999-12-31 23:59:59.000', cfsqltype = "CF_SQL_TIMESTAMP"});
			})
			.leftJoin('ArcGIS.gidata.CONTRACTOR', function(j) {
				j.on('ArcGIS.gidata.CONTRACTOR.GlobalID', '=', 'ArcGIS.gidata.PTCREW.ContractorID');
				j.where('CONTRACTOR.GDB_TO_DATE', '=', {value:'9999-12-31 23:59:59.000', cfsqltype = "CF_SQL_TIMESTAMP"});
			})
			.leftJoin('payrates', (j) => {
				j.on('payrates.pSeason', j.raw('YEAR(Date)'));
			})
			.orderByRaw("#sortBy# #usendingOrDesending#")
			.when(rc.filterData != '', function(q){
				var filterTp;
				filterTp = rc.filterType;
				if(rc.filterType == "Contains") {
					filterTp = "like";
					rc.filterData = "%" & rc.filterData & "%"
				}

				if(rc.filterCol == "crew_info") {
					rc.filterCol = "CREW.CrewName";
				}

				q.where(rc.filterCol, filterTp, rc.filterData);
			})
			.whereNull('deleteDate')
			.andWhereIn('Time_Entry_Form_v4.JobCode',['4940','4941'])
			.andWhere('VerificationType','=',{value:'1', cfsqltype = "CF_SQL_INTEGER"})
			// .toSQL();
			.paginate(pq_curpage, rc.pq_rpp);

			// if(rc.filterData != '') {
				// dump(timeEntryForm); abort;
			// }

		return {"totalRecords": timeEntryForm.pagination.totalRecords, "curPage": timeEntryForm.pagination.page, "data": timeEntryForm.results };
	}

	function create( event, rc, prc ) {

		// Code for copying ---------------------------------------
		if(rc.keyExists("copyReciept")) {
			
			numberOfCopys = queryExecute("
				SELECT COUNT(*) AS copys
				FROM Time_Entry_Form_v4
				WHERE RECIEPTNO like :copyReciept AND deleteDate IS NULL
			",{
				copyReciept = { value = rc.copyReciept & "_%", cfsqltype="cf_sql_string" }
			});
			
			var newRecieptName = rc.copyReciept & "_" & numberOfCopys.copys[1] + 1;
			
			// dump(newRecieptName); abort;

			queryExecute("
				INSERT INTO Time_Entry_Form_v4([DATE], [JobCode], [Crew], [JobDescription], [ContractorID], [Contractor], [FieldCode], [ID1], [Name1], [In1], [Out1], [FirstName1], [LastName1], [TimeDiff2nd], [Totalunits], [Totalvines], [StartTime], [fulllunchstart], [fulllunchstop], [Stoptime], [VerificationType], [RECIEPTNO], [QC_Name], [QC_Hours], [Unitcheck], [Verification], [Total_Hours], [break1startampm], [Break1Stop], [break1stopampm], [break2startampm], [Break2Stop], [break2stopampm], [ID], [NAME], [IN], [OUT], [FirstName], [LastName], [TimeDiff], [ID2], [Name2], [In2], [Out2], [LastName2], [FirstName2], [TimeDiff3rd], [Scan_Date], [TotalCalculatedTime], [TotalActualTime], [ACTUALMINUTES], [AdditionalCrewActual], [QC_Average], [deleteDate], [BlockID]) 
				SELECT [DATE], [JobCode], [Crew], [JobDescription], [ContractorID], [Contractor], [FieldCode], [ID1], [Name1], [In1], [Out1], [FirstName1], [LastName1], [TimeDiff2nd], [Totalunits], [Totalvines], [StartTime], [fulllunchstart], [fulllunchstop], [Stoptime], [VerificationType], :recieptnoVal, [QC_Name], [QC_Hours], [Unitcheck], [Verification], [Total_Hours], [break1startampm], [Break1Stop], [break1stopampm], [break2startampm], [Break2Stop], [break2stopampm], [ID], [NAME], [IN], [OUT], [FirstName], [LastName], [TimeDiff], [ID2], [Name2], [In2], [Out2], [LastName2], [FirstName2], [TimeDiff3rd], [Scan_Date], [TotalCalculatedTime], [TotalActualTime], [ACTUALMINUTES], [AdditionalCrewActual], [QC_Average], [deleteDate], [BlockID]
				FROM Time_Entry_Form_v4
				WHERE ROW_INDEX = :timeEntryFormRowIndex
			",{
				timeEntryFormRowIndex = { value = deserializeJSON(rc.rowIdx), cfsqltype = "cf_sql_integer"},
				recieptnoVal = { value = newRecieptName, cfsqltype="cf_sql_varchar"}
			}, { result="rowIdx" });
	
			queryExecute("
				INSERT INTO change_log(clTEFID, clAction, clReciept, clUserID, clDate)
				VALUES (:tefID, 'copy', :reciept, :userID, :currentDate)
			",{
				reciept = { value = newRecieptName, cfsqltype = "cf_sql_varchar" },
				tefID = { value = rowIdx.generatedKey, cfsqltype = "cf_sql_integer" },
				userID = { value = auth().getUserId(), cfsqltype="cf_sql_integer"},
				currentDate = { value = now(), cfsqltype="cf_sql_date"}
			});

			return newRecieptName;
		}
		// Code for adding ---------------------------------------
		else {

			
			var colNamesToQry = ['VerificationType'];
			var newRowData = deserializeJSON(rc.newRowData);
			var newRowsToQry = {};
			newRowsToQry['VerificationType'] = { value = 1 };
			
			var index = 1;
			for(data in newRowData){
				if(getQueryColNames(false).find(data) && !isNull(newRowData[data]) && newRowData[data] != "" && newRowData[data] != "0"){
					index++;
					newRowsToQry[data] = { value = newRowData[data] };
					colNamesToQry[index] = data;
				}
			}
			
			if(arrayLen(colNamesToQry) > 0){
				queryExecute("
					INSERT INTO Time_Entry_Form_v4 (" & arrayToList(colNamesToQry, ',') & ")
					VALUES (" & ':' & arrayToList(colNamesToQry, ', :') & ")
				",newRowsToQry , { result="newRecord" });
			}

			extraRowData = queryExecute("
				SELECT TOP 1 CONTRACTOR.contractor_name, POLYFIELD.field_acres1, vine_count
				FROM Time_Entry_Form_v4
				LEFT JOIN ArcGIS.gidata.PTCREW ON Time_Entry_Form_v4.Crew = ArcGIS.gidata.PTCREW.CrewNumber
				LEFT JOIN ArcGIS.gidata.CONTRACTOR ON ArcGIS.gidata.CONTRACTOR.GlobalID = ArcGIS.gidata.PTCREW.ContractorID
				LEFT JOIN ArcGIS.gidata.POLYFIELD ON Time_Entry_Form_v4.FieldCode = ArcGIS.gidata.POLYFIELD.field_name
				WHERE Time_Entry_Form_v4.ROW_INDEX = :tefID 
					AND ArcGIS.gidata.PTCREW.GDB_TO_DATE = '9999-12-31 23:59:59.000' 
					AND ArcGIS.gidata.CONTRACTOR.GDB_TO_DATE = '9999-12-31 23:59:59.0000000'
			",{
				tefID = { value = newRecord.generatedKey, cfsqltype="cf_sql_integer" }
			},{ returnType = "array"});

			// dump(contractorName); abort;

			return {"generatedKey": newRecord.generatedKey,"extraRowData": extraRowData[1] ?: {}};
		}
    }

	function getQryInfo(colNams, newRowData, whereItem){
		var updateQry = [];
		var updateDataQry = {whereItem: whereItem};

		var index = 0;
		for(col in colNams){
			if(newRowData.keyExists(col)){
				index++;
				updateQry[index] = col & " = :" & col;
				updateDataQry[col] = { value = newRowData[col]};
			}
		}

		return {string: arrayToList(updateQry, ','), data: updateDataQry}
	}

	function update( event, rc, prc ) {
		// dump(rc); abort;

		var newRowDataObj = deserializeJSON(rc.newRowData);
		var oldRowDataObj = deserializeJSON(rc.oldRowData);
		var updatedRowDataObj = JSONDiff.diff(oldRowDataObj, newRowDataObj, ['pq_rowcls']);

		var updateQry = [];
		var updateDataQry = {tefRowIndex: { value = newRowDataObj.ROW_INDEX, cfsqltype = "cf_sql_varchar" }};

		var index = 0;
		for(col in getQueryColNames(false)){
			if(newRowDataObj.keyExists(col) && col != 'ROW_INDEX'){
				index++;
					updateQry[index] = col & " = :" & col;
					updateDataQry[col] = { value = newRowDataObj[col]};
			}
		}
		queryExecute("
			UPDATE Time_Entry_Form_v4
			SET " & arrayToList(updateQry, ',') & "
			WHERE ROW_INDEX = :tefRowIndex
		", updateDataQry);

		queryExecute("
			INSERT INTO change_log(clTEFID, clChanges, clOldRowData, clAction, clReciept, clUserID, clDate)
			VALUES (:tefID, :changes, :oldRowData, 'edit', :reciept, :userID, :currentDate)
		",{
			reciept = { value = newRowDataObj.RECIEPTNO, cfsqltype = "cf_sql_varchar" },
			changes = { value = serializeJSON(updatedRowDataObj), cfsqltype = "cf_sql_varchar" },
			oldRowData = { value = rc.oldRowData, cfsqltype = "cf_sql_varchar" },
			tefID = { value = deserializeJSON(rc.id), cfsqltype = "cf_sql_integer" },
			userID = { value = auth().getUserId(), cfsqltype="cf_sql_integer"},
			currentDate = { value = now(), cfsqltype="cf_sql_date"}
		});
    }

	function delete( event, rc, prc ) {
		// abort;

		queryExecute("
			UPDATE Time_Entry_Form_v4
			SET deleteDate = :currentDate
			WHERE ROW_INDEX = :id
		",{
			currentDate = { value = now(), cfsqltype = "cf_sql_date"},
			id = { value = rc.id, cfsqltype = "cf_sql_integer" }
		});

		queryExecute("
			INSERT INTO change_log(clTEFID, clAction, clReciept, clUserID, clDate)
			VALUES (:tefID, 'delete', :reciept, :userID, :currentDate)
		",{
			reciept = { value = rc.reciept, cfsqltype = "cf_sql_varchar" },
			tefID = { value = deserializeJSON(rc.id), cfsqltype = "cf_sql_integer" },
			userID = { value = auth().getUserId(), cfsqltype="cf_sql_integer"},
			currentDate = { value = now(), cfsqltype="cf_sql_date"},
		});

    }
}