<!--- <cfdump var="#prc.data#"> --->
<div id="app">

    <div style="height: calc(100vh - 115px);">
        <pq-grid ref="grid" :options="options"></pq-grid>
    </div>

</div>

<script>
    <cfoutput>jobcodes = #serializeJSON(prc.jobcodes)#</cfoutput>
    <cfoutput>polyfield = #serializeJSON(prc.polyfield)#</cfoutput>
    <cfoutput>crew = #serializeJSON(prc.crew)#</cfoutput>
    <cfoutput>duplicates = #serializeJSON(prc.duplicateRecords)#</cfoutput>

    function editAddBtnHtml(rowDt) {

        var addHtml = `<div class="form-group">
                            <label for="reciept">Reciept Number</label>
                            <input class="form-control" type="text" id="reciept"></input>
                        </div>
                        <br>
                        `
        
        return `<div class="overflow-auto container" style="max-height: 60vh">
                `+ ((rowDt) ? '' : addHtml) +`
                <div class='row'>
                    <div class="form-group col-6">
                        <label for='crew'>Crew</label>
                        <select id='crew' value="`+ rowDt?.Crew + `" class="form-control">
                            ` + crew.reduce(function(acc, x){
                                var opiningOptionTag = "<option" +( (x.CrewNumber == rowDt?.Crew) ? " selected = selected " : "" )+ " value='"+ x.CrewNumber +"'>";
                                var closingOptionTag = "</option>";
                                acc += opiningOptionTag + x.CrewLead + closingOptionTag;
                                return acc;
                            }, "") + `
                        </select>
                    </div>
                
                    <div class="form-group col-6">
                        <label for="field">Field</label>
                        <select id="field" class="form-control">
                            ` + polyfield.reduce(function(acc, x){
                                var opiningOptionTag = "<option" +( (x.field_name == rowDt?.FieldCode) ? " selected = selected " : "" )+ ">";
                                var closingOptionTag = "</option>";
                                acc += opiningOptionTag + x.field_name + closingOptionTag;
                                return acc;
                            }, "") + `
                        </select>
                    </div>
                </div>

                <br>

                <div class='row'>
                    <div class="form-group col-6">
                        <label for='crewData'>Crew Date</label>
                        <input type='date' id='crewData' class="form-control" value="`+ rowDt?.Date +`">
                    </div>

                    <div class="form-group col-6">
                        <label for='qcAverage'>Quality Score</label>
                        <input type='number' id='qcAverage' class="form-control" value="`+ rowDt?.QC_Average +`">
                    </div>
                </div>

                <br>

                <div class='row'>
                    <div class="form-group col-6">
                        <label for='totalVines'>Total Vines</label>
                        <input type='number' id='totalVines' class="form-control" value="`+ rowDt?.Totalvines +`">
                    </div>

                    <div class="form-group col-6">
                        <label for='leaderHours'>Leader Hours</label>
                        <input type='number' id='leaderHours' class="form-control" value="`+ rowDt?.TimeDiff +`">
                    </div>
                </div>

                <br>

                <div class='row'>
                    <div class="form-group col-6">
                        <label for='assistantHours'>Assistant Hours</label>
                        <input type='number' id='assistantHours' class="form-control" value="`+ rowDt?.TimeDiff2nd +`">
                    </div>

                    <div class="form-group col-6">
                        <label for='qcHours'>Inspector Hours</label>
                        <input type='number' id='qcHours' class="form-control" value="`+ rowDt?.QC_Hours +`">
                    </div>
                </div>

                <br>

                <div class="form-group">
                    <label for="jobcodes">Jobcode Name</label>
                    <select id="jobcodes" class="form-control">
                        ` + jobcodes.reduce(function(acc, x){
                            var opiningOptionTag = "<option" +( (x.jobcode == rowDt?.JobCode) ? " selected = selected " : "" )+ " value='"+ x.jobcode +"'>";
                            var closingOptionTag = "</option>";
                            acc += opiningOptionTag + x.description + closingOptionTag;
                            return acc;
                        }) + `
                    </select>
                </div>

                <br>
            </div>
        `;
    }

    var duplicates = duplicates.reduce(function(acc,x){
        acc[x.RECIEPTNO] = x.numberOfDuplicates;
        return acc;
    },{});

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

    // function cellEditable(ui){ return this.hasClass({ rowIndx: ui.rowIndx, cls: 'pq-row-add' }); }

    function numberFormat(val){
        return Math.round(val * 100)/100
    }

    var calculateRow = function(rowData) {

        rowData.polyfield = polyfieldByFieldName[rowData.FieldCode]?.displayName;
        rowData.vine_count = polyfieldByFieldName[rowData.FieldCode]?.vine_count;
        rowData.field_acres1 = polyfieldByFieldName[rowData.FieldCode]?.field_acres1;

        rowData.crew_info = crewByOid[rowData.Crew];

        if(rowData.BlockID == undefined) rowData.BlockID = "";

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

        if(!rowData.TotalCalculatedTime){
            rowData.TotalCalculatedTime = rowData.TimeDiff + rowData.TimeDiff2nd + rowData.TimeDiff3rd;
        }

        if( new Date(rowData.TotalCalculatedTime) != 'Invalid Date'){
            rowData.employeeHours = new Date(rowData.TotalCalculatedTime).getHours();
        } else if( !isNaN(rowData.TotalCalculatedTime)){
            rowData.employeeHours = parseFloat(rowData.TotalCalculatedTime);
        }

        rowData.total = (rowData.total) ? numberFormat(rowData.total) : 0

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
                // colModel: this.$options.columns1,
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
                            label: 'Add Record',
                            listener: function () {
                                var _self = this;

                                $('<div></div>').appendTo('body')
                                .html(editAddBtnHtml(undefined))
                                .dialog({
                                    modal: true,
                                    title: 'Edit row',
                                    zIndex: 10000,
                                    classes:{
                                        'ui-dialog-titlebar-close': 'ui-button ui-corner-all ui-widget ui-button-icon-only'
                                    },
                                    autoOpen: true,
                                    width: 'auto',
                                    resizable: false,
                                    buttons: [
                                        {
                                            text: "Ok",
                                            class:"ui-button ui-corner-all ui-widget",
                                            click: function() {
                                            
                                                var newRowData = {
                                                    RECIEPTNO: $('#reciept').val(),
                                                    Crew: $('#crew').val(),
                                                    FieldCode: $('#field').val(),
                                                    Date: $('#crewData').val(),
                                                    QC_Average: $('#qcAverage').val(),
                                                    Totalvines: $('#totalVines').val(),
                                                    TimeDiff2nd: $('#assistantHours').val(),
                                                    TimeDiff: $('#leaderHours').val(),
                                                    QC_Hours: $('#qcHours').val(),
                                                    description: jobcodesByJobcode[$('#jobcodes').val()],
                                                    BlockID: $('#blockID').val(),
                                                    JobCode: $('#jobcodes').val()
                                                }

                                                var rowIndx = 0;
                                                _self.addRow({newRow: calculateRow(newRowData), rowIndx: rowIndx, checkEditable: false});
                                                _self.refreshRow({rowIndx: rowIndx});
                                                rowData = _self.getRowData({ rowIndx: rowIndx });
                                                
                                                $.ajax({
                                                    url: "api/v1/timeEntrys",
                                                    method: "POST",
                                                    data: {newRowData: JSON.stringify(rowData)},
                                                    success: function(data){
                                                        _self.getRowData({ rowIndx: rowIndx }).Time_Entry_Form_ROW_INDEX = data;
                                                    }
                                                });
                                                
                                                $( this ).dialog( "close" );
                                            }
                                        },
                                        {
                                            text: "Cancel",
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
                            }
                        }
                    ]
                },

                update: function(rowIndx, grid, oldRowData){

                    // if (grid.saveEditCell() == false) {
                    //     return false;
                    // }
                    
                    // grid.showLoading();
                    grid.options.pqIS.data[rowIndx+1] = calculateRow(grid.options.pqIS.data[rowIndx+1]);
                    rowData = grid.getRowData({ rowIndx: rowIndx });

                    if(rowData["Time_Entry_Form_ROW_INDEX"] == undefined){
                        $.ajax({
                        url: "/api/v1/timeEntrys",
                        method: "POST",
                        data: { newRowData: JSON.stringify(rowData),
                            oldRowData: JSON.stringify(oldRowData) }
                        }).done(function(){
                            grid.hideLoading();
                        });
                    }
                    else{
                        $.ajax({
                            url: "/api/v1/timeEntrys/" + rowData.Time_Entry_Form_ROW_INDEX,
                            method: "PUT",
                            data: { newRowData: JSON.stringify(rowData), 
                                oldRowData: JSON.stringify(oldRowData) }
                        }).done(function(){
                            grid.hideLoading();
                        });
                    }
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

                rowInit: function(ui){
                    var _self = this;

                    if( duplicates[ui.rowData.RECIEPTNO] ){
                        return { cls: "duplicet_record_worning" }
                    }
                },

                freezeCols: 1,
                colModel: [
                    { title: "Edit", editable: false, width: 120, sortable: false,
                        render: function(ui) {
                            return "<button class='btn btn-sm btn-outline-primary copy_btn'><i class='bi bi-files'></i></button> <button class='btn btn-sm btn-outline-danger delete_btn'><i class='bi bi-trash3'></i></button> <button class='btn btn-sm btn-outline-success edit_btn'><i class='bi bi-pencil'></i></button>";
                        },
                        postRender: function(ui) {
                            var _self = this;
                            var cell = _self.getCell(ui);

                            if(!_self.getRowsByClass({ cls: 'pq-row-edit' }).length){
                                
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

                                    $('<div></div>').appendTo('body')
                                    .html(editAddBtnHtml(ui.rowData))
                                    .dialog({
                                        modal: true,
                                        title: 'Edit row',
                                        zIndex: 10000,
                                        classes:{
                                            'ui-dialog-titlebar-close': 'ui-button ui-corner-all ui-widget ui-button-icon-only'
                                        },
                                        autoOpen: true,
                                        width: 'auto',
                                        resizable: false,
                                        buttons: [
                                            {
                                                text: "Ok",
                                                class:"ui-button ui-corner-all ui-widget",
                                                click: function() {
                                                   
                                                    var newRowData = {
                                                        crew_info: crewByOid[$('#crew').val()],
                                                        FieldCode: $('#field').val(),
                                                        Date: $('#crewData').val(),
                                                        QC_Average: $('#qcAverage').val(),
                                                        Totalvines: $('#totalVines').val(),
                                                        TimeDiff2nd: $('#assistantHours').val(),
                                                        TimeDiff: $('#leaderHours').val(),
                                                        QC_Hours: $('#qcHours').val(),
                                                        description: jobcodesByJobcode[$('#jobcodes').val()],
                                                    }
                                                    ui.rowData.Crew = $('#crew').val();
                                                    ui.rowData.JobCode = $('#jobcodes').val();
                                                    
                                                    _self.updateRow({rowIndx: ui.rowIndx, newRow: newRowData, checkEditable: false});
                                                    
                                                    app.options.update(ui.rowIndx, _self, ui.rowData);

                                                    $( this ).dialog( "close" );
                                                }
                                            },
                                            {
                                                text: "Cancel",
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
                            }
                        }
                    },

                    { title: "Contractor Name", width: 120, dataIndx: "contractor_name", dataType: "string",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }
                    },

                    { title: "Crew Code", width: 120, dataIndx: "Crew", dataType: "string",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }
                    },

                    { title: "Crew", dataIndx: "crew_info", width: 150, dataType: "string", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }
                    },

                    // { title: "Reciept Number", width: 120, dataIndx: "RECIEPTNO", datatype: "string", editable: false, 
                    //     filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }
                    // },

                    // { dataIndx: "Crew", hidden:true, dataType: "integer" },

                    { title:'Field Vines per Acre', width: 135, editable: false, dataIndx: "vines_per_acre", dataType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] } },

                    { title: "Field", width: 100, dataIndx: "FieldCode", dataType: "string", editable: false,
                        filter: { condition: 'begin', listeners: [{'change' : function(evt, item){
                            var grid = $(this).closest(".pq-grid");
                            // grid.pqGrid( { dataModel: { data: grid.pqGrid("option").pqIS.data } });

                            grid.pqGrid('filter', {
                                oper: 'replace',
                                data: [{dataIndx: item.dataIndx, value: item.value}]
                            });
                        }}], type: 'textbox', value: "", on: true }
                    },

                    { title: "Total Acres", width: 100, dataIndx: "field_acres1", dataType: "float", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Variety Name", width: 100, dataIndx: "Variety_name", dataType: "string", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Field Total Vines", width: 115, dataIndx: "vine_count", dataType: "integer", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Operation", width: 115, dataIndx: "JobCode", dataType: "integer", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Operation Name", width: 150, dataIndx: "description", dateType: "string", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},
                        
                    { title: "Crew Date", width: 100, dataIndx: "Date", dataType: "string", editable: false,
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

                    { title: "Cost / Acre Actual", width: 150, editable: false, dataIndx: "acresPerHour", dataType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Man Hr / Acre Actual", width: 150, editable: false, dataIndx: "employeeAcresPerHr", dataType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Quality Score", width: 100, dataIndx: "QC_Average", dateType: "float", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Total Vines", width: 100, dataIndx: "Totalvines", dateType: "integer", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Acres", width: 100, dataIndx: "vineacres", dateType: "float", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Leader Hours", width: 100, dataIndx: "TimeDiff", dateType: "string", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }}, 

                    {title: 'Assistant Hours', width: 110, dataIndx: "TimeDiff2nd", dataType: "string", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},
                    
                    { title: "Inspector Hours", width: 120, dataIndx: "QC_Hours", dateType: "float", editable: false,
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},
                        
                    {title: 'Employee Hours', width:115, dataIndx: "employeeHours", editable: false, dateType: "integer",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    { title: "Total Cost", width: 100, dataIndx: "total", editable: false, dateType: "float",
                        filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] }},

                    // { title: "BlockID", width: 100, dataIndx: "BlockID", dataType: "string", editable: false,
                    //     filter: { type: 'textbox', condition: 'begin', value: "", listeners: ['keyup'] } },
                ],
            };

            return {
                rowIndex: -1,
            };
        }
    });

    

</script>

<style>

    td.futer_date_error {
        background: #ff2f2f3b;
    }

    tr.duplicet_record_worning {
        background: #fff5ba;
    }
</style>