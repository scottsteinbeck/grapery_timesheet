component extends="coldbox.system.RestHandler" {
    function getQueryColNames(){
        return [
            "BlockID", "Crew",
			"FieldCode", "TIME_ENTRY_FORM_V2.JobCode", "Date",
			"QC_Average", "Totalvines", "QC_Hours",
			"TotalCalculatedTime",
			"Time_Entry_Form_ROW_INDEX",
			"RECIEPTNO",
			"TimeDiff", "TimeDiff2nd", "TimeDiff3rd",
            "pSeason", "pLeader", "pAssistant", "pQC", "pFieldWorker"
        ]
    }
}