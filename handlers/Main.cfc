component extends="coldbox.system.EventHandler" {

	property name="JSONDiff" inject="JSONDiff";

	function payrates(event, rc, prc) {
		prc.payrateData = queryExecute("
			SELECT *
			FROM payrates
			ORDER BY pSeason DESC
		",{},{returnType = 'array'});

		if(prc.payrateData[1].pSeason < year(now())){
			var newYear = prc.payrateData[1].pSeason + 1;
			queryExecute("
				INSERT INTO payrates (pSeason)
				VALUES (:newYear)
			",{
				newYear = { value = newYear, cfsqltype = "cf_sql_numeric" }
			});
			
			arrayPrepend(prc.payrateData, {"pSeason": newYear});
		}
	}

	function changeLog(event, rc, prc){
		prc.changeLogData = queryExecute("
			SELECT *
			FROM change_log
			-- LEFT JOIN Time_Entry_Form_v4 ON clTEFID = ROW_INDEX AND clReciept = RECIEPTNO AND clAction = 'add'
			WHERE clDate > :showToDate
		",
		{
			showToDate = { value = dateAdd('d', -30, now()), cfsqltype = "cf_sql_date"}
		},
		{ returnType = 'array'});
	}

	/**
	 * Default Action
	*/
	function index( event, rc, prc ) {
		// prc.welcomeMessage = "Welcome to ColdBox!";
		event.setView( "main/index" );

		prc.jobcodes = queryExecute("
			SELECT JOBCODES.description, JOBCODES.jobcode
			FROM ArcGIS.gidata.JOBCODES
			WHERE JOBCODES.GDB_TO_DATE = '9999-12-31 23:59:59.000'
		",{},{ returnType = 'array'});

		prc.polyfield = queryExecute("
			SELECT
			POLYFIELD.vine_count,
			POLYFIELD.field_acres1,
			POLYFIELD.Variety_name,
			POLYFIELD.field_name
			FROM ArcGIS.gidata.POLYFIELD
			WHERE POLYFIELD.GDB_TO_DATE = '9999-12-31 23:59:59.000'
		",{},{ returnType = 'array'});

		prc.crew = queryExecute("
			SELECT
			PTCREW.CrewName,
			PTCREW.CrewLead,
			PTCREW.CrewNumber,
			CONTRACTOR.contractor_name
			FROM ArcGIS.gidata.PTCREW
			LEFT JOIN ArcGIS.gidata.CONTRACTOR ON CONTRACTOR.GlobalID = PTCREW.ContractorID AND CONTRACTOR.GDB_TO_DATE = '9999-12-31 23:59:59.000'
			WHERE PTCREW.GDB_TO_DATE = '9999-12-31 23:59:59.000'
			ORDER BY CrewLead
		",{},{ returnType = 'array'});

		prc.duplicateRecords = queryExecute("
			SELECT Crew, FieldCode, JobCode, RECIEPTNO, Date, COUNT(*) AS numberOfDuplicates
			FROM Time_Entry_Form_v4
			WHERE deleteDate IS NULL
			GROUP BY Crew, FieldCode, JobCode, RECIEPTNO, Date
			HAVING COUNT(*) > 2
		",{ },{ returnType: "array" });

		prc.payrates = queryExecute("
			SELECT *
			FROM payrates
		",{},{ returnType: "struct", columnKey: "pSeason"});
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
