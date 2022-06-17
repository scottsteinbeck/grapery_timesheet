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

		selectItems = arrayMerge(getQueryColNames(true), [
            "pSeason", "pLeader", "pAssistant", "pQC", "pFieldWorker",
			
			"vine_count",
			"Variety_name",
			"description",
			"contractor_name",

			"field_acres1",

			"HOUR(TotalCalculatedTime) AS employeeHours",

			"(vine_count / field_acres1) AS vines_per_acre",

			"(ifNull(TimeDiff,0) * pLeader) + (ifNull(TimeDiff2nd,0) * pAssistant) + (ifNull(TimeDiff3rd,0) * pAssistant) + (ifNull(QC_Hours,0) * pQC) AS total",

			"ROUND((Totalvines / (vine_count / field_acres1)), 2) AS vineacres",

			// employeeHours / vineacres = employeeAcresPerHr
			"HOUR(TotalCalculatedTime) / (Totalvines / (vine_count / field_acres1)) AS employeeAcresPerHr",

			// total / vineacres = acresPerHour
			"ROUND(((ifNull(TimeDiff, 0) * pLeader) + (ifNull(TimeDiff2nd, 0) * pAssistant) + (ifNull(TimeDiff3rd,0) * pAssistant) + (ifNull(QC_Hours,0) * pQC)) / (Totalvines / (vine_count / field_acres1)),2) AS acresPerHour",
		
			"CREW.CrewName"
		]);

		if(rc.keyExists("pq_sort")) {
			var usendingOrDesending = (deserializeJSON(rc.pq_sort)[1].dir == "up") ? "desc" : "asc";
			var sortBy = deserializeJSON(rc.pq_sort)[1].dataIndx;
			if(sortBy == "crew_info") sortBy = "Crew";
			if(sortBy == "jobcode_info") sortBy = "description";
		}
		else {
			var usendingOrDesending = "desc";
			var sortBy = "Date";
		}

		var timeEntryForm = qb.newQuery().from('TIME_ENTRY_FORM_V2')
			.selectRaw(selectItems.toList(', '))
			.leftJoin('JOBCODES', function(j){
				j.on('TIME_ENTRY_FORM_V2.JobCode', '=', 'JOBCODES.jobcode');
				j.where('JOBCODES.GDB_TO_DATE', '=', {value:'9999-12-31 23:59:59.000', cfsqltype = "CF_SQL_VARCHAR"});
			})
			.leftJoin('CREW', function(j){
				j.on('TIME_ENTRY_FORM_V2.Crew', '=', 'CREW.CrewNumber');
				j.where('CREW.GDB_TO_DATE', '=', {value:'9999-12-31 23:59:59.000', cfsqltype = "CF_SQL_VARCHAR"});
			})
			.leftJoin('POLYFIELD', function(j){
				j.on('TIME_ENTRY_FORM_V2.FieldCode' , '=', 'POLYFIELD.field_name');
				j.where('POLYFIELD.GDB_TO_DATE', '=', {value:'9999-12-31 23:59:59.000', cfsqltype = "CF_SQL_VARCHAR"});
			})
			.leftJoin('CONTRACTOR', function(j) {
				j.on('CONTRACTOR.GlobalID', '=', 'CREW.ContractorID');
				// j.where('CONTRACTOR.GDB_TO_DATE', '=', {value:'9999-12-31 23:59:59.000', cfsqltype = "CF_SQL_TIMESTAMP"});
			})
			.leftJoin('payrates', (j) => {
				j.on('payrates.pSeason', j.raw('YEAR(Date)'));
			})
			.orderBy(sortBy, usendingOrDesending)
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

				q.having(rc.filterCol, filterTp, rc.filterData);
			})
			.whereNull('deleteDate')
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
				FROM TIME_ENTRY_FORM_V2
				WHERE RECIEPTNO like :copyReciept AND deleteDate IS NULL
			",{
				copyReciept = { value = rc.copyReciept & "_%", cfsqltype="cf_sql_string" }
			});
			
			var newRecieptName = rc.copyReciept & "_" & numberOfCopys.copys[1] + 1;
			
			// dump(newRecieptName); abort;

			queryExecute("
				INSERT INTO TIME_ENTRY_FORM_V2(Time_Entry_Form_ROW_INDEX, Date, JobCode, Crew, JobDescription, ContractorID, Contractor, FieldCode, Name, `In`, `Out`, ID, FirstName, LastName, ID1, Name1, In1, Out1, FirstName1, LastName1, ID2, Name2, In2, Out2, FirstName2, LastName2, Totalunits, Totalvines, StartTime, fulllunchstart, fulllunchstop, Stoptime, VerificationType, RECIEPTNO, QC_Name, QC_Hours, Unitcheck, Verification, ROW_INDEX, TotalCalculatedTime, TotalActualTime, ACTUALMINUTES, AdditionalCrewActual, QC_Average, BlockID, crewstartampm, FullStartTime, crewstopampm, Full_Stop_Time, Break1, Break2, Lunch_in, lunchinampm, Lunch_Out, lunchoutampm, vinecountcheck, Actual_Hours, TimeDiff, TimeDiff2nd, TimeDiff3rd, deleteDate) 
				SELECT null, Date, JobCode, Crew, JobDescription, ContractorID, Contractor, FieldCode, Name, `In`, `Out`, ID, FirstName, LastName, ID1, Name1, In1, Out1, FirstName1, LastName1, ID2, Name2, In2, Out2, FirstName2, LastName2, Totalunits, Totalvines, StartTime, fulllunchstart, fulllunchstop, Stoptime, VerificationType, :recieptnoVal, QC_Name, QC_Hours, Unitcheck, Verification, ROW_INDEX, TotalCalculatedTime, TotalActualTime, ACTUALMINUTES, AdditionalCrewActual, QC_Average, BlockID, crewstartampm, FullStartTime, crewstopampm, Full_Stop_Time, Break1, Break2, Lunch_in, lunchinampm, Lunch_Out, lunchoutampm, vinecountcheck, Actual_Hours, TimeDiff, TimeDiff2nd, TimeDiff3rd, deleteDate
				FROM TIME_ENTRY_FORM_V2
				WHERE Time_Entry_Form_ROW_INDEX = :timeEntryFormRowIndex
			",{
				timeEntryFormRowIndex = { value = deserializeJSON(rc.rowIdx), cfsqltype = "cf_sql_integer"},
				recieptnoVal = { value = newRecieptName, cfsqltype="cf_sql_varchar"}
			}, { result="rowIdx" });
	
			queryExecute("
				INSERT INTO change_log(clTEFID, clAction, clReciept, clUserID, clDate)
				VALUES (:tefID, 'copy', :reciept, :userID, :currentDate)
			",{
				reciept = { value = newRecieptName, cfsqltype = "cf_sql_varchar" },
				tefID = { value = rowIdx.generated_key, cfsqltype = "cf_sql_integer" },
				userID = { value = auth().getUserId(), cfsqltype="cf_sql_integer"},
				currentDate = { value = now(), cfsqltype="cf_sql_date"}
			});

			return newRecieptName;
		}
		// Code for adding ---------------------------------------
		else {

			// dump(rc); abort;

			var colNamesToQry = [];
			var newRowData = deserializeJSON(rc.newRowData);
			var newRowsToQry = {};

			var index = 0;
			for(data in newRowData){
				if(getQueryColNames(false).find(data) && !isNull(newRowData[data]) && newRowData[data] != "" && newRowData[data] != "0"){
					index++;
					newRowsToQry[data] = { value = newRowData[data] };
					colNamesToQry[index] = data;
				}
			}

			if(arrayLen(colNamesToQry) > 0){
				queryExecute("
					INSERT INTO TIME_ENTRY_FORM_V2 (" & arrayToList(colNamesToQry, ',') & ")
					VALUES (" & ':' & arrayToList(colNamesToQry, ', :') & ")
				",newRowsToQry , { result="newRecord" });
			}

			extraRowData = queryExecute("
				SELECT CONTRACTOR.contractor_name, POLYFIELD.field_acres1, vine_count
				FROM TIME_ENTRY_FORM_V2
				LEFT JOIN CREW ON TIME_ENTRY_FORM_V2.Crew = CREW.CrewNumber
				LEFT JOIN CONTRACTOR ON CONTRACTOR.GlobalID = CREW.ContractorID
				LEFT JOIN POLYFIELD ON TIME_ENTRY_FORM_V2.FieldCode = POLYFIELD.field_name
				WHERE TIME_ENTRY_FORM_V2.Time_Entry_Form_ROW_INDEX = :tefID 
					AND CREW.GDB_TO_DATE = '9999-12-31 23:59:59.000' 
					AND CONTRACTOR.GDB_TO_DATE = '9999-12-31 23:59:59.0000000'
				LIMIT 1
			",{
				tefID = { value = newRecord.generated_key, cfsqltype="cf_sql_integer" }
			},{ returnType = "array"});

			// dump(contractorName); abort;

			return {generatedKey: newRecord.generated_key,extraRowData: extraRowData[1]};
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
		var updateDataQry = {tefRowIndex: { value = newRowDataObj.Time_Entry_Form_ROW_INDEX, cfsqltype = "cf_sql_varchar" }};

		var index = 0;
		for(col in getQueryColNames(false)){
			if(newRowDataObj.keyExists(col)){
				index++;
				updateQry[index] = col & " = :" & col;
				updateDataQry[col] = { value = newRowDataObj[col]};
			}
		}
		queryExecute("
			UPDATE TIME_ENTRY_FORM_V2
			SET " & arrayToList(updateQry, ',') & "
			WHERE Time_Entry_Form_ROW_INDEX = :tefRowIndex
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
			UPDATE TIME_ENTRY_FORM_V2
			SET deleteDate = :currentDate
			WHERE Time_Entry_Form_ROW_INDEX = :id
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