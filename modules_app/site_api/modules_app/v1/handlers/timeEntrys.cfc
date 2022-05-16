component extends="BaseHandler"{
    // HTTP Method Security
	this.allowedMethods = {
		index : "GET",
		create: "POST,PUT",
		update: "POST,PUT,PATCH",
		delete: "DELETE"
	};

	property name = "qb" inject = 'QueryBuilder@qb';

	function index( event, rc, prc ) {
		// if(rc.keyExists("pq_filter")) {dump(rc.pq_filter); abort;}

		selectItems = arrayMerge(getQueryColNames(), [
			"(vine_count / field_acres1) AS vines_per_acre",

			"((HOUR(TotalCalculatedTime) * 14.25 + QC_Hours * 20.75) * 1.32) AS total",

			"(Totalvines / (vine_count / field_acres1)) AS vineacres",

			// employeeHours / vineacres = employeeAcresPerHr
			"HOUR(TotalCalculatedTime) / (Totalvines / (vine_count / field_acres1)) AS employeeAcresPerHr",

			// total / vineacres = acresPerHour
			"((HOUR(TotalCalculatedTime) * 14.25 + QC_Hours * 20.75) * 1.32) / (Totalvines / (vine_count / field_acres1)) AS acresPerHour"
		]);

		if(rc.keyExists("pq_sort")) {
			var usendingOrDesending = (deserializeJSON(rc.pq_sort)[1].dir == "up") ? "desc" : "asc";
			var sortBuy = deserializeJSON(rc.pq_sort)[1].dataIndx;
		}
		else {
			var usendingOrDesending = "desc";
			var sortBuy = "Date";
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
			.leftJoin('payrates', (j) => {
				j.on('payrates.pSeason', j.raw('YEAR(Date)'));
			})
			.orderBy(sortBuy, usendingOrDesending)
			.when(rc.keyExists("pq_filter"), function(q){
				var deserializedFilter = deserializeJSON(rc.pq_filter);
				for(col in deserializedFilter.data) {
					q.having(col.dataIndx, "like", col.value & "%");
				}
			})
			.whereNull('deleteDate')
			// .toSQL();
			.paginate(pq_curpage, rc.pq_rpp);

		return {"totalRecords": timeEntryForm.pagination.totalRecords, "curPage": timeEntryForm.pagination.page, "data": timeEntryForm.results };
	}

	function create( event, rc, prc ) {
		// dump(rc); abort;

		if(rc.keyExists("copyReciept")) {
			
			numberOfCopys = queryExecute("
				SELECT COUNT(*) AS copys
				FROM TIME_ENTRY_FORM_V2
				WHERE RECIEPTNO like :copyReciept
			",{
				copyReciept = { value = rc.copyReciept & "_%", cfsqltype="cf_sql_string"}
			});

			// dump(numberOfCopys); abort;

			newRecieptName = rc.copyReciept & "_" & numberOfCopys.copys[1] + 1;

			queryExecute("
				INSERT INTO TIME_ENTRY_FORM_V2(Time_Entry_Form_ROW_INDEX, Date, JobCode, Crew, JobDescription, ContractorID, Contractor, FieldCode, Name, `In`, `Out`, ID, FirstName, LastName, ID1, Name1, In1, Out1, FirstName1, LastName1, ID2, Name2, In2, Out2, FirstName2, LastName2, Totalunits, Totalvines, StartTime, fulllunchstart, fulllunchstop, Stoptime, VerificationType, RECIEPTNO, QC_Name, QC_Hours, Unitcheck, Verification, ROW_INDEX, TotalCalculatedTime, TotalActualTime, ACTUALMINUTES, AdditionalCrewActual, QC_Average, BlockID, crewstartampm, FullStartTime, crewstopampm, Full_Stop_Time, Break1, Break2, Lunch_in, lunchinampm, Lunch_Out, lunchoutampm, vinecountcheck, Actual_Hours, TimeDiff, TimeDiff2nd, TimeDiff3rd, deleteDate) 
				SELECT null, Date, JobCode, Crew, JobDescription, ContractorID, Contractor, FieldCode, Name, `In`, `Out`, ID, FirstName, LastName, ID1, Name1, In1, Out1, FirstName1, LastName1, ID2, Name2, In2, Out2, FirstName2, LastName2, Totalunits, Totalvines, StartTime, fulllunchstart, fulllunchstop, Stoptime, VerificationType, :recieptnoVal, QC_Name, QC_Hours, Unitcheck, Verification, ROW_INDEX, TotalCalculatedTime, TotalActualTime, ACTUALMINUTES, AdditionalCrewActual, QC_Average, BlockID, crewstartampm, FullStartTime, crewstopampm, Full_Stop_Time, Break1, Break2, Lunch_in, lunchinampm, Lunch_Out, lunchoutampm, vinecountcheck, Actual_Hours, TimeDiff, TimeDiff2nd, TimeDiff3rd, deleteDate
				FROM TIME_ENTRY_FORM_V2
				WHERE Time_Entry_Form_ROW_INDEX = :timeEntryFormRowIndex
			",{
				timeEntryFormRowIndex = { value = deserializeJSON(rc.rowIdx), cfsqltype = "cf_sql_integer"},
				recieptnoVal = { value = newRecieptName, cfsqltype="cf_sql_varchar"}
			});
	
			queryExecute("
				INSERT INTO change_log(clTEFID, clAction, clReciept, clUserID, clDate)
				VALUES (:tefID, 'copy', :reciept, :userID, :currentDate)
			",{
				reciept = { value = newRecieptName, cfsqltype = "cf_sql_varchar" },
				tefID = { value = deserializeJSON(rc.rowIdx), cfsqltype = "cf_sql_integer" },
				userID = { value = 1, cfsqltype="cf_sql_integer"},
				currentDate = { value = now(), cfsqltype="cf_sql_date"}
			});

			return newRecieptName;
		}
    }

	function update( event, rc, prc ) {

		rowData = deserializeJSON(rc.rowData);
		// dump(rc.newRowData); dump(rc.oldRowData); abort;

		var newRowDataObj = deserializeJSON(rc.newRowData);

		if(!isNull(rc.newRowData) && rc.newRowData != "{}" && rc.newRowData != rc.oldRowData
			&& !(newRowDataObj.keyExists("crew_info") && !newRowDataObj.keyExists("Crew"))) {

			queryExecute("
				UPDATE TIME_ENTRY_FORM_V2
				SET Crew = :crew, FieldCode = :fieldCode, JobCode = :jobCode
				WHERE Time_Entry_Form_ROW_INDEX = :rowIndex
			",{
				rowIndex = { value = rowData.Time_Entry_Form_ROW_INDEX, cfsqltype = "cf_sql_varchar" },
				crew = { value = rowData.Crew, cfsqltype="cf_sql_varchar" },
				fieldCode = { value = rowData.FieldCode, cfsqltype="cf_sql_varchar" },
				jobCode = { value = rowData.JobCode, cfsqltype="cf_sql_varchar" }
			});
	
			queryExecute("
				INSERT INTO change_log(clTEFID, clNewRowData, clOldRowData, clAction, clReciept, clUserID, clDate)
				VALUES (:tefID, :newRowData, :oldRowData, 'edit', :reciept, :userID, :currentDate)
			",{
				reciept = { value = rowData.RECIEPTNO, cfsqltype = "cf_sql_varchar" },
				newRowData = { value = rc.newRowData, cfsqltype = "cf_sql_varchar" },
				oldRowData = { value = rc.oldRowData, cfsqltype = "cf_sql_varchar" },
				tefID = { value = deserializeJSON(rc.id), cfsqltype = "cf_sql_integer" },
				userID = { value = 1, cfsqltype="cf_sql_integer"},
				currentDate = { value = now(), cfsqltype="cf_sql_date"}
			});
		}
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
			userID = { value = 1, cfsqltype="cf_sql_integer"},
			currentDate = { value = now(), cfsqltype="cf_sql_date"},
		});

    }
}