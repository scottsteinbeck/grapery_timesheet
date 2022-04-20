component extends="BaseHandler"{
    // HTTP Method Security
	this.allowedMethods = {
		index : "GET",
		downloadTemplate : "GET",
		create: "POST,PUT",
		update: "POST,PUT,PATCH",
		delete: "DELETE"
	};

	function index( event, rc, prc ) {
	}

	function create( event, rc, prc ) {
    }

	function update( event, rc, prc ) {
    }

	function delete( event, rc, prc ) {
		dump(url); abort;

		queryExecute("
			UPDATE TIME_ENTRY_FORM_V2
			SET deleteDate = :currentDate
			WHERE Time_Entry_Form_ROW_INDEX = :id
		",{
			currentDate = { value = new(), cfsqltype = "cf_sql_date"},
			id = { value = url.id, cfsqltype = "cf_sql_integer" }
		});

    }
}