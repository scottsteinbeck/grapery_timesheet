import Vue from 'vue'
import VueTableDynamic from 'vue-table-dynamic'
function numberFormat(val){
	return Math.round(val * 100)/100
}
var data = [];
var headerConfig = [
	{title:'Actions', col:'', sort: false, filter:[], width:150},
	{title:'Crew', col:'crew_info', sort: true, filter:[], width:250},
	{title:'Field Vines per Acre', col:'vines_per_acre', sort: false, filter:[], width:150},
	{title:'Field', col:'FieldCode', sort: true, filter:[], width:150},
	{title:'Total Acres', col:'field_acres1', sort: true, filter:[], width:150},
	{title:'Variety Name', col:'Variety_name', sort: true, filter:[], width:150},
	{title:'Field Total Vines', col:'vine_count', sort: true, filter:[], width:150},
	{title:'Operation Name', col:'description', sort: true, filter:[], width:150},
	{title:'Crew Date', col:'Date', sort: true, filter:[], width:150},
	{title:'Cost / Acre Actual', col:'acresperhour', sort: true, filter:[], width:150},
	{title:'Man Hr / Acre Actual', col:'employeeacresperhr', sort: true, filter:[], width:150},
	{title:'Quality Score', col:'qc_average', sort: true, filter:[], width:150},
	{title:'Total Vines', col:'Totalvines', sort: true, filter:[], width:150},
	{title:'Acres', col:'vineacres', sort: true, filter:[], width:150},
	{title:'Leader Hours', col:'leaderhours', sort: true, filter:[], width:150},
	{title:'Assistant Hours', col:'assistanthours', sort: true, filter:[], width:150},
	{title:'Inspector Hours', col:'QC_Hours', sort: true, filter:[], width:150},
	{title:'Employee Hours', col:'employeehours', sort: true, filter:[], width:150},
	{title:'Total Cost', col:'total', sort: true, filter:[], width:150}
];
data.push(headerConfig.reduce((acc,x)=> {acc.push(x.title); return acc},[]));
var colWidthConfig = headerConfig.reduce((acc,x,i)=> {
	acc.push({column: i, width: x.width});
	return acc;
},[]);
var sortConfig = headerConfig.reduce((acc,x,i)=> {
	if(x.sort) acc.push(i);
	return acc;
},[]);

tabledata.forEach((x)=>{
	x.vines_per_acre = 0;
	if( !isNaN(x.vine_count) && !isNaN(parseFloat(x.field_acres1))){
		x.vines_per_acre = numberFormat(x.vine_count/parseFloat(x.field_acres1));
	}
	x.employeeHours = 0;
	x.LeaderHours = 0;
	x.AssistantHours = 0;
	if( !isNaN(parseFloat(x.QC_Hours))){
		x.QC_Hours = parseFloat(x.QC_Hours);
	} else {
		x.QC_Hours = 0;
	}
	if( new Date(x.TotalCalculatedTime) != 'Invalid Date'){
		x.employeeHours = new Date(x.TotalCalculatedTime).getHours();
	} else if( !isNaN(x.TotalCalculatedTime)){
		x.employeeHours = parseFloat(x.TotalCalculatedTime);
	}
	x.total = numberFormat((
		(x.employeeHours*14.25)
		+(x.LeaderHours*18.6)
		+(x.AssistantHours*16.8)
		+(x.QC_Hours*20.75)
	)*1.32);

	x.vineacres = 0;
	if( x.vines_per_acre && !isNaN(parseFloat(x.Totalvines))){
		x.vineacres = numberFormat(parseFloat(x.Totalvines)/x.vines_per_acre);
	}

	x.employeeAcresPerHr = 0;
	if( x.vineacres > 0 && !isNaN(parseFloat(x.employeeHours))){
		x.employeeAcresPerHr = x.employeeHours/x.vineacres;
	}

	x.acresPerHour = 0;
	if( x.vineacres > 0){
		x.acresPerHour = x.total/x.vineacres;
	}
	x.crew_info = x.Crew + ' ' + x.CrewName;
	var temprow = [];
	headerConfig.forEach((hr)=> {
		temprow.push(x[hr.col] || '');
	})
	data.push(temprow);
})

new Vue({
  el: '#app',
  created() {

  },
  data() {
    return {
      params: {
        data: data,
		header: 'row',
        border: true,
        enableSearch: true,
        stripe: true,
        columnWidth: colWidthConfig,
        rowHeight: 35,
        fixed: 0,
        pagination: true,
		sort:sortConfig,
        pageSize: 15
	   }
    }
  },
  components: { VueTableDynamic }
})
