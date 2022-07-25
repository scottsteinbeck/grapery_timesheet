component extends="coldbox.system.RestHandler" {
    function getQueryColNames(specifyTable){
		var colItems = [
            "BlockID", "Crew",
			"FieldCode", "JobCode",
			"QC_Average", "Totalvines", "QC_Hours",
			"TotalCalculatedTime",
			"Totalunits",
			"ROW_INDEX",
			"RECIEPTNO",
			"costOverride",
			"Date",
			"Total_Hours",
			"TimeDiff", "TimeDiff2nd", "TimeDiff3rd"
        ]
		if(specifyTable){
			for(i=1; i <= len(colItems); i++){
				colItems[i] = "Time_Entry_Form_v4." & colItems[i];
			}
		}

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