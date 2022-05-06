<!--- <cfdump var="#prc.data#"> --->
<div id="app">
    
    <ul class="nav nav-tabs">
        <li class="nav-item">
            <a class="nav-link active" href="#">Data</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="/main/changeLog">Change log</a>
        </li>
    </ul>

    <div style="height: calc(100vh - 115px);">
        <pq-grid ref="grid" :options="options"></pq-grid>
    </div>
</div>
    
<script>
    <!--- <cfoutput>queryData = #serializeJSON(prc.data)#</cfoutput> --->

    <cfoutput>timeEntryForm = #serializeJSON(prc.timeEntryForm)#</cfoutput>
    <cfoutput>jobcodes = #serializeJSON(prc.jobcodes)#</cfoutput>
    <cfoutput>polyfield = #serializeJSON(prc.polyfield)#</cfoutput>
    <cfoutput>crew = #serializeJSON(prc.crew)#</cfoutput>
    // console.log(timeEntryForm);

    var jobcodesByJobcode = jobcodes.reduce(function(acc,x){
        acc[x.jobcode] = String(x.description);
        return acc;
    },{});

    var polyfieldByFieldName = polyfield.reduce(function(acc,x){
        acc[x.field_name] = {
            displayName: String(x.vine_count) + ", " + String(x.field_acres1) + ", " + String(x.Variety_name),
            vine_count: x.vine_count,
            field_acres1: x.field_acres1
        };
        return acc;
    },{});

    var crewByOid = crew.reduce(function(acc,x){
        if(String(x.CrewName) != "")
            acc[x.CrewNumber] = String(x.CrewName) + " (" + String(x.CrewLead) + ")";
        else acc[x.CrewNumber] = "Unnamed (" + String(x.CrewLead) + ")";
        return acc;
    },{});
    // console.table(polyfieldByFieldName);

    function numberFormat(val){
        return Math.round(val * 100)/100
    }

    var calculateRow = function(rowData) {

        rowData.jobcode_info = jobcodesByJobcode[rowData.JobCode];

        rowData.polyfield = polyfieldByFieldName[rowData.FieldCode]?.displayName;
        rowData.vine_count = polyfieldByFieldName[rowData.FieldCode]?.vine_count;
        rowData.field_acres1 = polyfieldByFieldName[rowData.FieldCode]?.field_acres1;

        rowData.crew_info = crewByOid[rowData.Crew];

        if(rowData.Date != ""){
            var date = new Date(rowData.Date);
            rowData.Date = ((date.getMonth() > 8) ? (date.getMonth() + 1) : ('0' + (date.getMonth() + 1))) + '/' + ((date.getDate() > 9) ? date.getDate() : ('0' + date.getDate())) + '/' + date.getFullYear();
        }

        rowData.vines_per_acre = 0;
        if( !isNaN(rowData.vine_count) && !isNaN(parseFloat(rowData.field_acres1))){
            rowData.vines_per_acre = numberFormat(rowData.vine_count / parseFloat(rowData.field_acres1));
        }
        rowData.employeeHours = 0;
        rowData.LeaderHours = 0;
        rowData.AssistantHours = 0;
        if( !isNaN(parseFloat(rowData.QC_Hours))){
            rowData.QC_Hours = parseFloat(rowData.QC_Hours);
        } else {
            rowData.QC_Hours = 0;
        }
        if( new Date(rowData.TotalCalculatedTime) != 'Invalid Date'){
            rowData.employeeHours = new Date(rowData.TotalCalculatedTime).getHours();
        } else if( !isNaN(rowData.TotalCalculatedTime)){
            rowData.employeeHours = parseFloat(rowData.TotalCalculatedTime);
        }
        rowData.total = numberFormat((
            (rowData.employeeHours*14.25)
            +(rowData.LeaderHours*18.6)
            +(rowData.AssistantHours*16.8)
            +(rowData.QC_Hours*20.75)
        )*1.32);

        rowData.vineacres = 0;
        if( rowData.vines_per_acre && !isNaN(parseFloat(rowData.Totalvines))){
            rowData.vineacres = numberFormat(parseFloat(rowData.Totalvines)/rowData.vines_per_acre);
        }

        rowData.employeeAcresPerHr = 0;
        if( rowData.vineacres > 0 && !isNaN(parseFloat(rowData.employeeHours))){
            rowData.employeeAcresPerHr = numberFormat(rowData.employeeHours/rowData.vineacres);
        }

        rowData.acresPerHour = 0;
        if( rowData.vineacres > 0){
            rowData.acresPerHour = numberFormat(rowData.total/rowData.vineacres);
        }
        
        return rowData;
    }

    timeEntryForm.map(function(x){
        return calculateRow(x);
    });

    Vue.component('pq-grid', {
        props: ['options'],
        mounted: function() {
            this.grid = pq.grid(this.$el, this.options);
        },
        methods: {
            export: function() {
                var blob = this.grid.exportData({
                    format: 'xlsx',
                    render: true
                });
                if (typeof blob === 'string') {
                    blob = new Blob([blob]);
                }
                saveAs(blob, 'pqGrid.xlsx');
            }
        },
        template: '<div :options="options"></div>'
    });

    var app = new Vue({
        el: '#app',
        data1: timeEntryForm,
        methods: {
            onExport: function() {
                debugger;
                this.$refs.grid.export();
            },
        },
        data: function() {

            this.options = {
                
                pqIS: {
                    totalRecords: 0,
                    pending: true,
                    data: [],
                    requestPage: 1,
                    rpp: 100, //records per request.
                    init: function () {
                        this.data = [];
                        this.requestPage = 1;
                        console.log(this.requestPage);
                    }
                },

                filterModel: { on: true, header: true, type: 'remote' },
                sortModel: { type: 'remote', sorter: [{ dataIndx: 'Date', dir: 'up'}] },
                beforeSort: function (evt) {
                    if (evt.originalEvent) {//only if sorting done through header cell click.
                        this.options.pqIS.init();
                    }
                },
                beforeTableView: function (evt, ui) {

                    var finalV = ui.finalV,
                        data = this.options.pqIS.data;
                    if (ui.initV == null) {
                        return;
                    }
                    if (!this.options.pqIS.pending && finalV >= data.length - 1 && data.length < this.options.pqIS.totalRecords) {
                        this.options.pqIS.requestPage++;
                        this.options.pqIS.pending = true;
                        //request more rows.
                        this.refreshDataAndView();
                    }
                },

                dataModel: {
                    dataType: "JSON",
                    location: "remote",
                    url: "/api/v1/timeEntrys",
                    postData: function () {
                        return {
                            pq_curpage: this.options.pqIS.requestPage,
                            pq_rpp: this.options.pqIS.rpp
                        };
                    },
                    getData: function (response) {
                        var data = response.data,
                        len = data.length,
                        curPage = response.curPage,
                        pq_data = this.options.pqIS.data,
                        init = (curPage - 1) * this.options.pqIS.rpp;
                        
                        console.log(this.options.pqIS);

                        this.options.pqIS.pending = false;
                        this.options.pqIS.totalRecords = response.totalRecords;
                        for (var i = 0; i < len; i++) {
                            pq_data[i + init] = calculateRow(data[i]);
                        }
                        return { data: pq_data }
                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        //alert(errorThrown);
                    }
                },

                showTitle: false,
                showTop: false,
                locale: 'en',
                height: '100%',
                
                collapsible: {
                    show: false,
                },
                columnTemplate: { width: 100 },
                colModel: this.$options.columns1,
                resizable: false,
                postRenderInterval: -1,
                virtualX: true, virtualY: true,

                cellSave: function(evt, ui){
                    var _self = this;
                    
                    _self.showLoading();
                    ui.rowData = calculateRow(ui.rowData);

                    var newData = {};
                    var oldData = {};
                    if(typeof ui.newVal != "object") {
                        newData[ui.column.dataIndx] = ui.newVal;
                        oldData[ui.column.dataIndx] = ui.oldVal;
                    }
                    else {
                        newData = ui.newVal;
                        oldData = ui.oldVal;
                    }

                    $.ajax({
                        url: "/api/v1/timeEntrys/" + ui.rowData.Time_Entry_Form_ROW_INDEX,
                        method: "PUT",
                        data: { rowData: JSON.stringify(ui.rowData),
                            newRowData: JSON.stringify(newData), 
                            oldRowData: JSON.stringify(oldData) }
                    }).done(function(){
                        _self.hideLoading();
                    });

                    this.refreshRow(ui);
                },
                    
                colModel: [
                    { title: "Edit", editable: false, width: 75, sortable: false,
                        render: function(ui) {
                            // console.log(ui.rowIndx);
                            return "<button class='btn btn-sm btn-outline-primary copy_btn'><i class='bi bi-files'></i></button> <button class='btn btn-sm btn-outline-danger delete_btn'><i class='bi bi-trash3'></i></button>";
                        },
                        postRender: function(ui) {
                            var _self = this;
                            var cell = _self.getCell(ui);
                            
                            // Copy button ---------------------------------------
                            cell.find(".copy_btn").bind("click", function(evt){

                                newRecieptnoVal = ui.rowData.RECIEPTNO.split("-")[0] + "_" + timeEntryForm.reduce(function(acc, x){
                                    if(x.RECIEPTNO.split("-")[0] == ui.rowData.RECIEPTNO.split("-")[0]) acc++;
                                    return acc;
                                },0);

                                _self.showLoading();
                                $.ajax({
                                    url: "/api/v1/timeEntrys",
                                    method: "POST",
                                    data: { rowIdx: ui.rowData.Time_Entry_Form_ROW_INDEX,
                                        newRecieptnoVal: newRecieptnoVal
                                    },
                                }).done(function(){

                                    var copedRowData = Object.assign({}, ui.rowData);
                                    copedRowData.RECIEPTNO = newRecieptnoVal;
                                    var rowIndex = _self.addRow({ rowIndxPage: 0, rowData: copedRowData, checkEditable: false, rowIndx: ui.rowIndx });
                                    _self.refreshRow({ rowIndx: rowIndex });

                                    _self.hideLoading();
                                });
                            });

                            // Delete button ---------------------------------------
                            cell.find(".delete_btn").bind("click", function(evt){
                                _self.showLoading();
                                deleteUrl = "/api/v1/timeEntrys/" + ui.rowData.Time_Entry_Form_ROW_INDEX;

                                $.ajax({
                                    url: deleteUrl,
                                    method: "DELETE",
                                    data: { reciept: ui.rowData.RECIEPTNO }
                                }).done(function(){
                                    _self.deleteRow({ rowIndx: ui.rowIndx });
                                    _self.hideLoading();
                                });

                            });
                        }
                    },
                    { title: "BlockID", width: 100, dataIndx: "BlockID", dataType: "integer",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] } },

                    { title: "Crew", dataIndx: "crew_info", width: 250, dataType: "string",
                        editor: {
                            type: 'select',
                            valueIndx: "CrewNumber",
                            labelIndx: "CrewName",
                            mapIndices: { CrewNumber: 'Crew', CrewName: 'crew_info' },
                            options: crew
                        },
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }
                    },

                    { dataIndx: "Crew", hidden:true, dataType: "integer" },

                    { title:'Field Vines per Acre', width:150, editable: false, dataIndx: "vines_per_acre", dataType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] } },

                    { title: "Field", width: 100, dataIndx: "FieldCode", dataType: "string",
                        editor: {
                            type: 'select',
                            valueIndx: "field_name",
                            labelIndx: "field_name",
                            options: polyfield
                        },
                        filter: { condition: 'begin', listeners: [{'change' : function(evt, item){
                            var grid = $(this).closest(".pq-grid");
                            grid.pqGrid("option").pqIS.init();
                            grid.pqGrid('filter', {
                                oper: 'replace',
                                data: [{dataIndx: item.dataIndx, value: item.value}]
                            });
                        }}], type: 'textbox', value: "", on: true }
                    },

                    { title: "Total Acres", width: 100, editable: false, dataIndx: "field_acres1", dataType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Variety Name", width: 100, dataIndx: "Variety_name", dataType: "string",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Field Total Vines", width: 100, editable: false, dataIndx: "vine_count", dataType: "integer",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Operation Name", width: 130, dataIndx: "description", dataType: "string",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},
                    
                    { title: "Crew Date", width: 100, dataIndx: "Date", dataType: "date",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Cost / Acre Actual", width: 100, editable: false, dataIndx: "acresPerHour", dataType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Man Hr / Acre Actual", width: 100, editable: false, dataIndx: "employeeAcresPerHr", dataType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Quality Score", width: 100, dataIndx: "QC_Average", dateType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Total Vines", width: 100, dataIndx: "Totalvines", dateType: "integer",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Acres", width: 100, editable: false, dataIndx: "vineacres", dateType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Leader Hours", width: 100, dataIndx: "TimeDiff", dateType: "string",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    {title: 'Assistant Hours', width: 100, dataIndx: "TimeDiff2nd", dataType: "string",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},
                    
                    { title: "QC_Hours", width: 100, dataIndx: "QC_Hours", dateType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    {title: 'Employee Hours', width:100, dataIndx: "employeeHours", editable: false, dateType: "integer",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Total Cost", width: 100, dataIndx: "total", editable: false, editable: false, dateType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Jobcode", width: 200, dataIndx: "jobcode_info", dateType: "string",
                        editor: {
                            type: 'select',
                            valueIndx: "jobcode",
                            labelIndx: "description",
                            mapIndices: {jobcode: "JobCode", description: "jobcode_info"},
                            options: jobcodes
                        },
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }
                    },

                    { dataIndx: "JobCode", hidden: true, dateType: "integer" },
                ]
            };
            return {
                rowIndex: -1,
            };
        }
    });

</script>