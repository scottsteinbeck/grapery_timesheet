component extends="coldbox.system.EventHandler" {

	
	function changeLog(event, rc, prc){
		prc.changeLogData = queryExecute("
			SELECT *
			FROM change_log
			WHERE clDate > :showToDate
		",
		{
			showToDate = { value = dateAdd('m', -1, now()), cfsqltype = "cf_sql_date"}
		},
		{ returnType = 'array'});
	}

	/**
	 * Default Action
	*/
	function index( event, rc, prc ) {
		prc.welcomeMessage = "Welcome to ColdBox!";
		event.setView( "main/index" );
	
		prc.timeEntryForm = queryExecute("
			SELECT 
			TIME_ENTRY_FORM_V2.BlockID,
			TIME_ENTRY_FORM_V2.Crew,
			TIME_ENTRY_FORM_V2.FieldCode, TIME_ENTRY_FORM_V2.JobCode, TIME_ENTRY_FORM_V2.Date,
			TIME_ENTRY_FORM_V2.QC_Average, TIME_ENTRY_FORM_V2.Totalvines, TIME_ENTRY_FORM_V2.QC_Hours,
			TIME_ENTRY_FORM_V2.TotalCalculatedTime,
			Time_Entry_Form_ROW_INDEX,
			TIME_ENTRY_FORM_V2.RECIEPTNO,
			TIME_ENTRY_FORM_V2.TimeDiff, TIME_ENTRY_FORM_V2.TimeDiff2nd, TIME_ENTRY_FORM_V2.TimeDiff3rd
			FROM TIME_ENTRY_FORM_V2
			WHERE TIME_ENTRY_FORM_V2.jobcode != 'NULL' AND TIME_ENTRY_FORM_V2.deleteDate IS NULL
			ORDER BY TIME_ENTRY_FORM_V2.Date, TIME_ENTRY_FORM_V2.RECIEPTNO
			LIMIT 100
		",{},{ returnType = 'array'});

		prc.jobcodes = queryExecute("
			SELECT JOBCODES.description, JOBCODES.jobcode
			FROM JOBCODES
			WHERE JOBCODES.GDB_TO_DATE = '9999-12-31 23:59:59.000'
		",{},{ returnType = 'array'});

		prc.polyfield = queryExecute("
			SELECT
			POLYFIELD.vine_count,
			POLYFIELD.field_acres1,
			POLYFIELD.Variety_name,
			POLYFIELD.field_name
			FROM POLYFIELD
			WHERE POLYFIELD.GDB_TO_DATE = '9999-12-31 23:59:59.000'
		",{},{ returnType = 'array'});

		prc.crew = queryExecute("
			SELECT
			CREW.CrewName,
			CREW.CrewLead,
			CREW.CrewNumber
			FROM CREW
			WHERE CREW.GDB_TO_DATE = '9999-12-31 23:59:59.000'
		",{},{ returnType = 'array'});
	}



	/************************************** IMPLICIT ACTIONS *********************************************/

	function onAppInit( event, rc, prc ) {
	}

	function onRequestStart( event, rc, prc ) {
	}

	function onRequestEnd( event, rc, prc ) {
	}

	function onSessionStart( event, rc, prc ) {
	}

	function onSessionEnd( event, rc, prc ) {
		var sessionScope     = event.getValue( "sessionReference" );
		var applicationScope = event.getValue( "applicationReference" );
	}

	function onException( event, rc, prc ) {
		event.setHTTPHeader( statusCode = 500 );
		// Grab Exception From private request collection, placed by ColdBox Exception Handling
		var exception = prc.exception;
		// Place exception handler below:
	}

}
