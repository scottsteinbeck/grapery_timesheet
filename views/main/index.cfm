<!--- <cfdump var="#prc.data#"> --->
<div id="app">

    <div v-if="filterWarning != ''" class="bg-warning m-2 p-2">{{filterWarning}}</div>

    <div class="row m-0">
        <div class="col-2">

            <select class="form-control form-select m-2" id="filterCol" v-model="filterCol">
                <option :selected="col.title == 'Field'" v-for="col in options.colModel" v-if="col.title != 'Edit'" :value="col.dataIndx">{{col.title}}</option>
            </select>
        </div>
        <div class="col-2">
            <select class="form-control form-select m-2" id="filterType" v-model="filterType">
                <option> Contains </option>
                <option> = </option>
                <option> &lt; </option>
                <option> &gt; </option>
            </select>
        </div>
        <div class="col-2">
            <input type="text" class="form-control m-2" id="filterData" placeholder="Filter by..." v-model="filterBy">
        </div>
        <div class="col-2">
            <button class="btn btn-outline-primary copy_btn m-2" @click="filterData()"><i class="bi bi-search"></i></button>
            <button v-if="filterCol != 'FieldCode' || filterType != 'Contains' || filterBy != ''" class="btn btn-outline-danger delete_btn m-2" @click="clearFilter()"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="col-2 offset-md-2">
            <button class="btn btn-outline-success delete_btn m-2" @click="addRow()"><i class="bi bi-plus-lg"></i> Add Record</button>
        </div>
    </div>
    <div style="height: calc(100vh - 130px);">
        <pq-grid ref="grid" :options="options"></pq-grid>
    </div>

</div>

<script>
    <cfoutput>jobcodes = #serializeJSON(prc.jobcodes)#</cfoutput>
    <cfoutput>polyfield = #serializeJSON(prc.polyfield)#</cfoutput>
    <cfoutput>crew = #serializeJSON(prc.crew)#</cfoutput>
    <cfoutput>duplicates = #serializeJSON(prc.duplicateRecords)#</cfoutput>
    <cfoutput>payrates = #serializeJSON(prc.payrates)#</cfoutput>

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

    var sumArray = function(arrayOfNumbers){
        return arrayOfNumbers.reduce(function(acc, x){
            return acc += (x) ? x : 0;
        }, 0);
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
            // rowData.TotalCalculatedTime = rowData.TimeDiff + rowData.TimeDiff2nd + rowData.TimeDiff3rd;
            rowData.TotalCalculatedTime = 0;
            if(rowData.TimeDiff > 0) rowData.TotalCalculatedTime += parseFloat(rowData.TimeDiff);
            if(rowData.TimeDiff2nd > 0) rowData.TotalCalculatedTime += parseFloat(rowData.TimeDiff2nd);
            if(rowData.TimeDiff3rd > 0) rowData.TotalCalculatedTime += parseFloat(rowData.TimeDiff3rd);
        }

        if( new Date(rowData.TotalCalculatedTime) != 'Invalid Date'){
            rowData.employeeHours = new Date(rowData.TotalCalculatedTime).getHours();
        } else if( !isNaN(rowData.TotalCalculatedTime)){
            rowData.employeeHours = parseFloat(rowData.TotalCalculatedTime);
        }

        var pLeader = 0;
        var pAssistant = 0;
        var pQC = 0;
        if(payrates[new Date(rowData.Date).getFullYear()] != undefined){
            rowYear = new Date(rowData.Date).getFullYear()
            pLeader = payrates[rowYear].pLeader;
            pAssistant = payrates[rowYear].pAssistant;
            pQC = payrates[rowYear].pQC;
        }
        rowData.total = sumArray([(rowData.TimeDiff * pLeader), (rowData.TimeDiff2nd * pAssistant), (rowData.TimeDiff3rd * pAssistant), (rowData.QC_Hours * pQC)]);

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
            },
            filterData: function() {
                var grid = this.$refs.grid.grid;
                this.filterWarning = '';

                if( $('#filterData').val() == '') this.filterWarning = "Must enter a value to filter by!";
                else {
                    grid.scrollRow({rowIndxPage: 0});
                    grid.options.pqIS.init();
                    grid.refreshDataAndView();
                }
            },
            clearFilter: function() {
                var grid = this.$refs.grid.grid;
                
                $('#filterCol').val('FieldCode');
                $('#filterType').val('Contains');
                $('#filterData').val('');

                this.filterCol = 'FieldCode';
                this.filterType = 'Contains';
                this.filterBy = '';
                
                grid.scrollRow({rowIndxPage: 0});
                grid.options.pqIS.init();
                grid.refreshDataAndView();

                console.log(this.filterCol != 'FieldCode', this.filterType != 'Contains', this.filterBy != '');
            },
            addRow: function(){
                var _grid = this.$refs.grid.grid;

                $('<div></div>').appendTo('body')
                .html(editAddBtnHtml(undefined))
                .dialog({
                    modal: true,
                    title: 'Add row',
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

                                _grid.showLoading();
                                $.ajax({
                                    url: "api/v1/timeEntrys",
                                    method: "POST",
                                    data: {newRowData: JSON.stringify(newRowData)},
                                    success: function(data){
                                        newRowData.Time_Entry_Form_ROW_INDEX = data.GENERATEDKEY;
                                        newRowData.contractor_name = data.EXTRAROWDATA.contractor_name;
                                        newRowData.field_acres1 = data.EXTRAROWDATA.field_acres1;
                                        newRowData.vine_count = data.EXTRAROWDATA.vine_count;

                                        _grid.addRow({newRow: calculateRow(newRowData), rowIndx: rowIndx, checkEditable: false});
                                        _grid.refreshRow({rowIndx: rowIndx});
                                    }
                                }).done(function() {
                                    _grid.hideLoading();
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
        },

        data: function() {

            this.filterWarning = '';

            this.options = {

                showTitle: false,
                showTop: false,
                locale: 'en',
                height: '100%',
                
                collapsible: {
                    show: false,
                },
                // columnTemplate: { width: '100%', minWidth: 50 },
                // colModel: this.$options.columns1,
                resizable: false,
                postRenderInterval: -1,
                virtualX: true,
                virtualY: true,
                selectionModel: { type: null },

                filterModel: { on: true, header: false, type: 'remote' },
                sortModel: { type: 'remote', sorter: [{ dataIndx: 'Date', dir: 'up' }, { dataIndx: 'RECIEPTNO', dir: 'up' }] },
                beforeSort: function (evt) {
                    if (evt.originalEvent) {//only if sorting done through header cell click.
                        this.options.pqIS.init();
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
                            pq_rpp: this.options.pqIS.rpp,
                            filterCol: $('#filterCol').val(),
                            filterData: $('#filterData').val(),
                            filterType: $('#filterType').val(),
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

                                                    _self.showLoading();
                                                    _self.options.pqIS.data[ui.rowIndx+1] = calculateRow(_self.options.pqIS.data[ui.rowIndx+1]);
                                                    oldRowData = ui.rowData;
                                                    rowData = _self.getRowData({ rowIndx: ui.rowIndx });

                                                    $.ajax({
                                                        url: "/api/v1/timeEntrys/" + rowData.Time_Entry_Form_ROW_INDEX,
                                                        method: "PUT",
                                                        data: { newRowData: JSON.stringify(rowData), 
                                                            oldRowData: JSON.stringify(oldRowData) }
                                                    }).done(function(){
                                                        _self.hideLoading();
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
                                });
                            }
                        }
                    },

                    { title: "Contractor Name", width: 120, dataIndx: "contractor_name", dataType: "string", editable: false },

                    { title: "Crew Code", width: 120, dataIndx: "Crew", dataType: "string", editable: false },

                    { title: "Crew", dataIndx: "crew_info", width: 150, dataType: "string", editable: false },

                    { title:'Field Vines per Acre', width: 135, dataIndx: "vines_per_acre", dataType: "float", editable: false },

                    { title: "Field", width: 100, dataIndx: "FieldCode", dataType: "string", editable: false },

                    { title: "Total Acres", width: 100, dataIndx: "field_acres1", dataType: "float", editable: false },

                    { title: "Variety Name", width: 100, dataIndx: "Variety_name", dataType: "string", editable: false },

                    { title: "Field Total Vines", width: 115, dataIndx: "vine_count", dataType: "integer", editable: false },

                    { title: "Operation", width: 115, dataIndx: "JobCode", dataType: "integer", editable: false },

                    { title: "Operation Name", width: 150, dataIndx: "description", dateType: "string", editable: false },
                        
                    { title: "Crew Date", width: 100, dataIndx: "Date", dataType: "string", editable: false,
                        render: function(ui){
                            var curDate = new Date();
                            var dataIdxDate = new Date(ui.rowData.Date);
                            if(dataIdxDate > curDate){
                                return { cls: 'futer_date_error' };
                            }
                            return {};
                        }
                    },

                    { title: "Cost / Acre Actual", width: 150, dataIndx: "acresPerHour", dataType: "float", editable: false },

                    { title: "Man Hr / Acre Actual", width: 150, dataIndx: "employeeAcresPerHr", dataType: "float", editable: false },

                    { title: "Quality Score", width: 100, dataIndx: "QC_Average", dateType: "float", editable: false },

                    { title: "Total Vines", width: 100, dataIndx: "Totalvines", dateType: "integer", editable: false },

                    { title: "Acres", width: 100, dataIndx: "vineacres", dateType: "float", editable: false },

                    { title: "Leader Hours", width: 100, dataIndx: "TimeDiff", dateType: "string", editable: false }, 

                    {title: 'Assistant Hours', width: 110, dataIndx: "TimeDiff2nd", dataType: "string", editable: false },
                    
                    { title: "Inspector Hours", width: 120, dataIndx: "QC_Hours", dateType: "float", editable: false },
                        
                    {title: 'Employee Hours', width:115, dataIndx: "employeeHours", dateType: "integer", editable: false },

                    { title: "Total Cost", width: 100, dataIndx: "total", dateType: "float", editable: false },

                    // { title: "temp", width: 100, dataIndx: "Time_Entry_Form_ROW_INDEX", dataType: "string", editable: true },
                ],
            };

            return {
                rowIndex: -1,
                filterWarning: this.filterWarning,
                filterCol: 'FieldCode',
                filterType: 'Contains',
                filterBy: '',
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