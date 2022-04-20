component extends="coldbox.system.EventHandler" {

	/**
	 * Default Action
	 */
	function index( event, rc, prc ) {
		prc.welcomeMessage = "Welcome to ColdBox!";
		event.setView( "main/index" );
		//prc.data = QueryExecute("select globalID, objectID, crewName, crewNumber, crewLead  from CREW",{},{});
		prc.data = QueryExecute("
			SELECT
			JOBCODES.description,
			POLYFIELD.vine_count,
			POLYFIELD.field_acres1,
			POLYFIELD.Variety_name,
			TIME_ENTRY_FORM_V2.BlockID,
			TIME_ENTRY_FORM_V2.Crew, CREW.CrewName, CREW.CrewLead, CREW.CrewNumber,
			TIME_ENTRY_FORM_V2.FieldCode, TIME_ENTRY_FORM_V2.JobCode, TIME_ENTRY_FORM_V2.Date, TIME_ENTRY_FORM_V2.QC_Average, TIME_ENTRY_FORM_V2.Totalvines, TIME_ENTRY_FORM_V2.QC_Hours, TIME_ENTRY_FORM_V2.TotalCalculatedTime,
			Time_Entry_Form_ROW_INDEX
			FROM TIME_ENTRY_FORM_V2
			LEFT JOIN CREW ON TIME_ENTRY_FORM_V2.Crew = CREW.GDB_ARCHIVE_OID AND CREW.GDB_TO_DATE = '9999-12-31 23:59:59.000'
			LEFT JOIN POLYFIELD ON TIME_ENTRY_FORM_V2.FieldCode = POLYFIELD.field_name AND POLYFIELD.GDB_TO_DATE = '9999-12-31 23:59:59.000'
			LEFT JOIN JOBCODES ON JOBCODES.jobcode = TIME_ENTRY_FORM_V2.JobCode AND JOBCODES.GDB_TO_DATE = '9999-12-31 23:59:59.000'
			WHERE TIME_ENTRY_FORM_V2.jobcode != 'NULL' AND TIME_ENTRY_FORM_V2.deleteDate IS NULL
			GROUP BY JOBCODES.description,
			POLYFIELD.vine_count,
			POLYFIELD.field_acres1,
			POLYFIELD.Variety_name,
			TIME_ENTRY_FORM_V2.BlockID,
			TIME_ENTRY_FORM_V2.Crew, CREW.CrewName, CREW.CrewLead, CREW.CrewNumber,
			TIME_ENTRY_FORM_V2.FieldCode, TIME_ENTRY_FORM_V2.JobCode, TIME_ENTRY_FORM_V2.Date, TIME_ENTRY_FORM_V2.QC_Average, TIME_ENTRY_FORM_V2.Totalvines, TIME_ENTRY_FORM_V2.QC_Hours, TIME_ENTRY_FORM_V2.TotalCalculatedTime
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
