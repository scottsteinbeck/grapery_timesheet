component extends="coldbox.system.EventHandler" {

	/**
	 * Default Action
	 */
	function index( event, rc, prc ) {
		prc.welcomeMessage = "Welcome to ColdBox!";
		event.setView( "main/index" );
		//prc.data = QueryExecute("select globalID, objectID, crewName, crewNumber, crewLead  from CREW",{},{});
		prc.data = QueryExecute("
			select
			JOBCODES.description,
			POLYFIELD.vine_count,
			POLYFIELD.field_acres1,
			POLYFIELD.Variety_name,
			TIME_ENTRY_FORM_V2.BlockID,
			TIME_ENTRY_FORM_V2.Crew, CREW.CrewName, CREW.CrewLead, CREW.CrewNumber,
			TIME_ENTRY_FORM_V2.FieldCode, TIME_ENTRY_FORM_V2.JobCode, TIME_ENTRY_FORM_V2.Date, TIME_ENTRY_FORM_V2.QC_Average, TIME_ENTRY_FORM_V2.Totalvines, TIME_ENTRY_FORM_V2.QC_Hours, TIME_ENTRY_FORM_V2.TotalCalculatedTime
			from TIME_ENTRY_FORM_V2
			LEFT JOIN CREW on TIME_ENTRY_FORM_V2.Crew = CREW.GDB_ARCHIVE_OID
			Left Join POLYFIELD on TIME_ENTRY_FORM_V2.FieldCode = POLYFIELD.field_name
			Left Join JOBCODES on JOBCODES.jobcode = TIME_ENTRY_FORM_V2.JobCode
			where TIME_ENTRY_FORM_V2.jobcode != 'NULL'
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
