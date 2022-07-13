component extends="coldbox.system.RestHandler" {
    function getQueryColNames(specifyTable){
		var colItems = [
            "BlockID", "Crew",
			"FieldCode", "JobCode",
			"QC_Average", "Totalvines", "QC_Hours",
			"TotalCalculatedTime",
			"ROW_INDEX",
			"RECIEPTNO",
			"TimeDiff", "TimeDiff2nd", "TimeDiff3rd"
        ]
		if(specifyTable){
			for(i=1; i <= len(colItems); i++){
				colItems[i] = "TIME_ENTRY_FORM_V3." & colItems[i];
			}
		}

        colItems.append("FORMAT (TIME_ENTRY_FORM_V3.Date, 'yyyy-MM-dd') AS Date");
        return colItems;
    }

	function getPolyfieldColNames(){
		return [
			"Variety_name",
			"field_acres1",
			"vine_count"
		]
	}
}