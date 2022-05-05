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
        dump(rc); abort;

        var setVals = deserializeJSON(rc.clOldData)

        queryExecute("
            UPDATE TIME_ENTRY_FORM_V2
            SET " & setVals & "
            WHERE Time_Entry_Form_ROW_INDEX = :timeEntryFormIndex
        ",{
            timeEntryFormIndex = { value = rc.id, cfsqltype = "cf_sql_integer"}
        });
    }

	function delete( event, rc, prc ) {
    }
}