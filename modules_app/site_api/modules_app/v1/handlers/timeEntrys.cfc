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
		// dump(deserializeJSON(rc.rowIdx)); abort;

		queryExecute("
			INSERT INTO TIME_ENTRY_FORM_V2
			SELECT *
			FROM TIME_ENTRY_FORM_V2
			WHERE Time_Entry_Form_ROW_INDEX = :timeEntryFormRowIndex
		",{
			timeEntryFormRowIndex = { value = deserializeJSON(rc.rowIdx), cfsqltype = "cf_sql_integer"}
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