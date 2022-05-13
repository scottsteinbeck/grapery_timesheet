<!--- <cfdump var="#prc.data#"> --->
<div id="app">
    
    <ul class="nav nav-tabs">
        <li class="nav-item">
            <a class="nav-link active" href="#">Data</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="/main/changeLog">Change log</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="/main/payrates">Payrates</a>
        </li>
    </ul>

    <div style="height: calc(100vh - 115px);">
        <pq-grid ref="grid" :options="options"></pq-grid>
    </div>

</div>

<script>
    <cfoutput>jobcodes = #serializeJSON(prc.jobcodes)#</cfoutput>
    <cfoutput>polyfield = #serializeJSON(prc.polyfield)#</cfoutput>
    <cfoutput>crew = #serializeJSON(prc.crew)#</cfoutput>

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
            acc[x.CrewNumber] = String(x.CrewName);
        else acc[x.CrewNumber] = String(x.CrewLead);
        return acc;
    },{});

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
        // data1: timeEntryForm,
        methods: {
            onExport: function() {
                debugger;
                this.$refs.grid.export();
            }
        },

        data: function() {

            this.options = {

                showTitle: false,
                showTop: true,
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
                selectionModel: { type: null },
                
                filterModel: { on: true, header: true, type: 'remote' },
                sortModel: { type: 'remote', sorter: [{ dataIndx: 'Date', dir: 'up' }, { dataIndx: 'RECIEPTNO', dir: 'up' }] },
                beforeSort: function (evt) {
                    if (evt.originalEvent) {//only if sorting done through header cell click.
                        this.options.pqIS.init();
                    }
                },

                toolbar:{
                    items: [
                        {
                            type: 'button',
                            icon: 'ui-icon-plus',
                            label: 'Add Product',
                            listener: function () {
                                var _self = this;

                                var rowData = {
                                    RECIEPTNO: "",
                                    crew_info: "",
                                    Crew: 0,
                                    vines_per_acre: 0,
                                    FieldCode: "",
                                    field_acres1: 0,
                                    Variety_name: "",
                                    vine_count: 0,
                                    description: "",
                                    Date: new Date(0),
                                    acresPerHour: 0,
                                    employeeAcresPerHr: 0,
                                    QC_Average: 0,
                                    Totalvines: 0,
                                    vineacres: 0,
                                    TimeDiff: "",
                                    TimeDiff2nd: "",
                                    QC_Hours: 0,
                                    employeeHours: 0,
                                    total: 0,
                                    jobcode_info: ""
                                };
                                var rowIndx = _self.addRow({ rowIndxPage: 0, rowData: rowData, checkEditable: false, rowIndx: 0 });
                                _self.options.editRow(rowIndx, this);
                            }
                        }
                    ]
                },

                editRow: function(rowIndx, grid){
                    var _self = this;
                    var oldRowData = grid.getRowData({ rowIndx: rowIndx });

                    grid.addClass({ rowIndx: rowIndx, cls: "pq-row-edit" });
                    
                    grid.editFirstCellInRow({ rowIndx: rowIndx });

                    var tr = grid.getRow({ rowIndx: rowIndx });
                    var btn = tr.find("button.copy_btn");

                    btn.unbind("click")
                        .click(function (evt) {
                            evt.preventDefault();
                            _self.options.update(rowIndx, grid, oldRowData);
                            return false;
                        });

                    btn.next().button("option", { label: "cancel", icons: {primary: "ui-icon-cancel"} })
                        .unbind("click")
                        .click(function (evt) {
                            grid.quitEditMode();
                            grid.removeClass({ rowIndx: rowIndx, cls: "pq-row-edit" });
                            grid.rollback();
                        });
                },

                update: function(rowIndx, grid, oldRowData){
                    var _self = this;
                    return;
                    _self.showLoading();
                    rowData = calculateRow(grid.getRowData({ rowIndx: rowIndx }));

                    var newData = {};
                    var oldData = {};
                    if(typeof ui.newVal != "object") {
                        newData[ui.column.dataIndx] = rowData;
                        oldData[ui.column.dataIndx] = oldRowData;
                    }
                    else {
                        newData = rowData;
                        oldData = oldRowData;
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

                pqIS: {
                    totalRecords: 0,
                    pending: true,
                    data: [],
                    requestPage: 1,
                    rpp: 100, //records per request.
                    init: function () {
                        this.data = [];
                        this.requestPage = 1;
                        return this.data;
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
                    
                colModel: [
                    { title: "Edit", editable: false, width: 110, sortable: false,
                        render: function(ui) {
                            return "<button class='btn btn-sm btn-outline-primary copy_btn'><i class='bi bi-files'></i></button> <button class='btn btn-sm btn-outline-danger delete_btn'><i class='bi bi-trash3'></i></button> <button class='btn btn-sm btn-outline-success edit_btn'><i class='bi bi-pencil'></i></button>";
                        },
                        postRender: function(ui) {
                            var _self = this;
                            var cell = _self.getCell(ui);
                            
                            // Copy button ---------------------------------------
                            cell.find(".copy_btn").bind("click", function(evt){

                                _self.showLoading();
                                $.ajax({
                                    url: "/api/v1/timeEntrys",
                                    method: "POST",
                                    data: { rowIdx: ui.rowData.Time_Entry_Form_ROW_INDEX,
                                        copyReciept: ui.rowData.RECIEPTNO.split("_")[0]
                                    },
                                    success: (function(data){
                                        var copedRowData = Object.assign({}, ui.rowData);
                                        copedRowData.RECIEPTNO = data;
                                        var rowIndex = _self.addRow({ rowIndxPage: 0, rowData: copedRowData, checkEditable: false, rowIndx: ui.rowIndx });
                                        _self.refreshRow({ rowIndx: rowIndex });

                                        _self.hideLoading();
                                    })
                                });
                            });

                            // Delete button ---------------------------------------
                            cell.find(".delete_btn").bind("click", function(evt){

                                $('<div></div>').appendTo('body')
                                .html('<div><h6> Are you sure you want to delete this item?</h6></div>')
                                .dialog({
                                    modal: true,
                                    title: 'Delete message',
                                    zIndex: 10000,
                                    classes:{
                                        'ui-dialog-titlebar-close': 'ui-button ui-corner-all ui-widget ui-button-icon-only'
                                    },
                                    autoOpen: true,
                                    width: 'auto',
                                    resizable: false,
                                    buttons: [{
                                        text: "Yes",
                                        class:"ui-button ui-corner-all ui-widget",
                                        click: function() {
                                                $( this ).dialog( "close" );
                                                
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
                                            }
                                        },
                                        {
                                            text: "No",
                                            class:"ui-button ui-corner-all ui-widget",
                                            click: function() {
                                                $( this ).dialog( "close" );
                                                resolt = false;
                                            }
                                        }
                                    ],
                                    close: function(event, ui) {
                                        $(this).remove();
                                    }
                                });
                            });

                            // Edit button ---------------------------------------
                            cell.find(".edit_btn").bind("click", function(evt){
                                _self.options.editRow(ui.rowIndx, _self);
                            });
                        }
                    },

                    { title: "Reciept Number", width: 100, editable: false, dataIndx: "RECIEPTNO", datatype: "string",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] } },

                    { title: "Crew", dataIndx: "crew_info", width: 250, dataType: "string",
                        editor: {
                            type: 'select',
                            valueIndx: "CrewNumber",
                            labelIndx: "CrewLead",
                            mapIndices: { CrewNumber: 'Crew', CrewLead: 'crew_info' },
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
                            // grid.pqGrid( { dataModel: { data: grid.pqGrid("option").pqIS.data } });

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
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] },
                        render: function(ui){
                            var curDate = new Date();
                            var dataIdxDate = new Date(ui.rowData.Date);

                            if(dataIdxDate > curDate){
                                return { cls: 'futer_date_error' };
                            }
                            return {};
                        }
                    },

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

                    { title: "BlockID", width: 100, dataIndx: "BlockID", dataType: "integer",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] } },

                    { title: "Leader Payrates", width: 100, dataIndx: "qLeader", dataType: "integer",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] } },

                    { title: "Assistant Payrates", width: 100, dataIndx: "pAssistant", dataType: "integer",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] } },

                    { title: "QC Payrates", width: 100, dataIndx: "pQC", dataType: "integer",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] } },

                    { title: "Field Worker Payrates", width: 100, dataIndx: "pFieldWorker", dataType: "integer",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] } },
                ],

                editable: function(ui){
                    return this.hasClass({ rowIndx: ui.rowIndx, cls: 'pq-row-edit' });
                }
            };
            return {
                rowIndex: -1,
            };
        }
    });

    

</script>

<style>
    tr.pq-grid-row.pq-row-edit {
        background: #b2ffbe;
    }

    td.futer_date_error {
        background: #ff2f2f3b;
    }
</style>