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

        if(rc.clAction == "edit"){
            var revertItems = deserializeJSON(rc.clOldData)
            var setItems = "";
    
            for(col in getQueryColNames()){
                if(revertItems.keyExists(col)){
                    setItems = col & '=' & revertItems[col];
                }
            }
    
            queryExecute("
                UPDATE TIME_ENTRY_FORM_V2
                SET " & setItems & "
                WHERE Time_Entry_Form_ROW_INDEX = :timeEntryFormIndex
            ",{
                timeEntryFormIndex = { value = rc.id, cfsqltype = "cf_sql_integer" }
            });
        }
        else if(rc.clAction == "copy"){
            queryExecute("
                UPDATE TIME_ENTRY_FORM_V2
                SET deleteDate = :currentDate
                WHERE Time_Entry_Form_ROW_INDEX = :timeEntryFormIndex
            ",{
                timeEntryFormIndex = { value = rc.id, cfsqltype = "cf_sql_integer" },
                currentDate = { value = now(), cfsqltype = "cf_sql_date" }
            });
        }
        else if(rc.clAction == "delete"){
            queryExecute("
                UPDATE TIME_ENTRY_FORM_V2
                SET deleteDate = NULL
                WHERE Time_Entry_Form_ROW_INDEX = :timeEntryFormIndex
            ",{
                timeEntryFormIndex = { value = rc.id, cfsqltype = "cf_sql_integer" }
            });
        }

        queryExecute("
            UPDATE change_log
            SET restoreDate = :currentDate
            WHERE clID = :changeLogID
        ",{
            changeLogID = { value = rc.clID, cfsqltype = "cf_sql_integer" },
            currentDate = { value = now(), cfsqltype = "cf_sql_date" }
        });
    }

	function delete( event, rc, prc ) {
    }
}