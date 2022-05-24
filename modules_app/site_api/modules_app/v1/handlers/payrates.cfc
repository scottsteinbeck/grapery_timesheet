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
    }

	function update( event, rc, prc ) {
        // dump(rc); abort;
		var updatedVals = deserializeJSON(rc.updatedVal);

		queryExecute("
			UPDATE payrates
			SET pLeader = :leader, pAssistant = :assistant, pQC = :QC, pFieldWorker = :fieldWorker
			WHERE pSeason = :year
		",{
			year = { value = updatedVals.pSeason, cfsqltype = "cf_sql_numeric" },
			leader = { value = updatedVals.pLeader, cfsqltype = "cf_sql_numeric" },
			assistant = { value = updatedVals.pAssistant, cfsqltype = "cf_sql_numeric" },
			QC = { value = updatedVals.pQC, cfsqltype = "cf_sql_numeric" },
			fieldWorker = { value = updatedVals.pFieldWorker, cfsqltype = "cf_sql_numeric" }
		});
    }

	function delete( event, rc, prc ) {
    }
}