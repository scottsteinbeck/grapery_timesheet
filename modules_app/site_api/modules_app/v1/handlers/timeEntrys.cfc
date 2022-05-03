component extends="BaseHandler"{
    // HTTP Method Security
	this.allowedMethods = {
		index : "GET",
		create: "POST,PUT",
		update: "POST,PUT,PATCH",
		delete: "DELETE"
	};

	function index( event, rc, prc ) {
	}

	function create( event, rc, prc ) {
		// dump(rc.newRecieptnoVal); abort;
		// abort;
		queryExecute("
			INSERT INTO TIME_ENTRY_FORM_V2(Time_Entry_Form_ROW_INDEX, Date, JobCode, Crew, JobDescription, ContractorID, Contractor, FieldCode, Name, `In`, `Out`, ID, FirstName, LastName, ID1, Name1, In1, Out1, FirstName1, LastName1, ID2, Name2, In2, Out2, FirstName2, LastName2, Totalunits, Totalvines, StartTime, fulllunchstart, fulllunchstop, Stoptime, VerificationType, RECIEPTNO, QC_Name, QC_Hours, Unitcheck, Verification, ROW_INDEX, TotalCalculatedTime, TotalActualTime, ACTUALMINUTES, AdditionalCrewActual, QC_Average, BlockID, crewstartampm, FullStartTime, crewstopampm, Full_Stop_Time, Break1, Break2, Lunch_in, lunchinampm, Lunch_Out, lunchoutampm, vinecountcheck, Actual_Hours, TimeDiff, TimeDiff2nd, TimeDiff3rd, deleteDate) 
			SELECT 0, Date, JobCode, Crew, JobDescription, ContractorID, Contractor, FieldCode, Name, `In`, `Out`, ID, FirstName, LastName, ID1, Name1, In1, Out1, FirstName1, LastName1, ID2, Name2, In2, Out2, FirstName2, LastName2, Totalunits, Totalvines, StartTime, fulllunchstart, fulllunchstop, Stoptime, VerificationType, :recieptnoVal, QC_Name, QC_Hours, Unitcheck, Verification, ROW_INDEX, TotalCalculatedTime, TotalActualTime, ACTUALMINUTES, AdditionalCrewActual, QC_Average, BlockID, crewstartampm, FullStartTime, crewstopampm, Full_Stop_Time, Break1, Break2, Lunch_in, lunchinampm, Lunch_Out, lunchoutampm, vinecountcheck, Actual_Hours, TimeDiff, TimeDiff2nd, TimeDiff3rd, deleteDate
			FROM TIME_ENTRY_FORM_V2
			WHERE Time_Entry_Form_ROW_INDEX = :timeEntryFormRowIndex
		",{
			timeEntryFormRowIndex = { value = deserializeJSON(rc.rowIdx), cfsqltype = "cf_sql_integer"},
			recieptnoVal = { value = rc.newRecieptnoVal, cfsqltype="cf_sql_varchar"}
		});
    }

	function update( event, rc, prc ) {
    }

	function delete( event, rc, prc ) {
		// dump(rc.id); abort;

		queryExecute("
			UPDATE TIME_ENTRY_FORM_V2
			SET deleteDate = :currentDate
			WHERE Time_Entry_Form_ROW_INDEX = :id
		",{
			currentDate = { value = now(), cfsqltype = "cf_sql_date"},
			id = { value = rc.id, cfsqltype = "cf_sql_integer" }
		});

    }
}