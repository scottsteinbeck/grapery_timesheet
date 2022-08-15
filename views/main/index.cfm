<!--- <cfdump var="#prc.data#"> --->
<div id="app">

    <div v-if="filterWarning != ''" class="bg-warning m-2 p-2">{{filterWarning}}</div>

    <div class="row m-0">
        <div class="col-2">

            <select class="form-control form-select m-2" id="filterCol" v-model="filterCol">
                <option :selected="col.title == 'Field'" v-for="col in filterColumns" v-if="col.title != 'Edit'" :value="col.dataIndx">{{col.title}}</option>
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
                            <label for="RECIEPTNO">Reciept Number</label>
                            <input class="form-control" type="text" id="RECIEPTNO"></input>
                        </div>
                        <br>
                        `
        
        return `<div class="overflow-auto container" style="max-height: 60vh">
                `+ ((rowDt) ? '' : addHtml) +`
                <div class='row'>
                    <div class="form-group col-4">
                        <label for='Date'>Date</label>
                        <input type='date' id='Date' class="form-control" value="`+ rowDt?.Date +`">
                    </div>

                    <div class="form-group col-8">
                        <label for="JobCode">Jobcode Name</label>
                        <select id="JobCode" class="form-control">
                            ` + jobcodes.reduce(function(acc, x){
                                var opiningOptionTag = "<option" +( (x.jobcode == rowDt?.JobCode) ? " selected = selected " : "" )+ " value='"+ x.jobcode +"'>";
                                var closingOptionTag = "</option>";
                                acc += opiningOptionTag + x.description + closingOptionTag;
                                return acc;
                            }) + `
                        </select>
                    </div>
                </div>

                <div class='row mt-3'>  


                    <div class="form-group col-6">
                        <label for='Crew'>Crew</label>
                        <select id='Crew' value="`+ rowDt?.Crew + `" class="form-control">
                            ` + crew.reduce(function(acc, x){
                                var opiningOptionTag = "<option" +( (x.CrewNumber == rowDt?.Crew) ? " selected = selected " : "" )+ " value='"+ x.CrewNumber +"'>";
                                var closingOptionTag = "</option>";
                                acc += opiningOptionTag + x.CrewNumber + ' - ' + x.CrewLead + closingOptionTag;
                                return acc;
                            }, "") + `
                        </select>
                    </div>
                    <div class="form-group col-6">
                        <label for="FieldCode">Field</label>
                        <select id="FieldCode" class="form-control">
                            ` + polyfield.reduce(function(acc, x){
                                var opiningOptionTag = "<option" +( (x.field_name == rowDt?.FieldCode) ? " selected = selected " : "" )+ ">";
                                var closingOptionTag = "</option>";
                                acc += opiningOptionTag + x.field_name + closingOptionTag;
                                return acc;
                            }, "") + `
                        </select>
                    </div>
                </div>

                <div class='row mt-3'>  
                    <div class="form-group col-4">
                        <label for='Totalvines'>Total Vines</label>
                        <input type='number' id='Totalvines' class="form-control" value="`+ rowDt?.Totalvines +`">
                    </div>
                    <div class="form-group col-4">
                        <label for='Totalunits'>Total Units</label>
                        <input type='number' id='Totalunits' class="form-control" value="`+ rowDt?.Totalunits +`">
                    </div>
                    <div class="form-group col-4">
                        <label for='costOverride'>Total Cost Override</label>
                        <input type='number' id='costOverride' class="form-control" value="`+ rowDt?.costOverride +`">
                    </div>
                </div>
                <hr/>

                <div class='row mt-2'>
                   
                    <div class="form-group col-4">
                        <label for='QC_Average'>Quality Score</label>
                        <input type='number' id='QC_Average' class="form-control" value="`+ rowDt?.QC_Average +`">
                    </div>
                    <div class="form-group col-4">
                        <label for='Total_Hours'>Employee</label>
                        <input type='number' id='Total_Hours' class="form-control" value="`+ rowDt?.Total_Hours +`">
                        <div class="form-text text-muted">Hours</div>
                    </div>
                    <div class="form-group col-4">
                        <label for='TimeDiff'>Leader</label>
                        <input type='number' id='TimeDiff' class="form-control" value="`+ rowDt?.TimeDiff +`">
                        <div class="form-text text-muted">Minutes</div>
                    </div>
                </div>

                <div class='row mt-2'>
                    <div class="form-group col-4">
                        <label for='TimeDiff2nd'>Assistant</label>
                        <input type='number' id='TimeDiff2nd' class="form-control" value="`+ rowDt?.TimeDiff2nd +`">
                        <div class="form-text text-muted">Minutes</div>
                    </div>
                    <div class="form-group col-4">
                        <label for='TimeDiff3rd'>Assistant 2</label>
                        <input type='number' id='TimeDiff3rd' class="form-control" value="`+ rowDt?.TimeDiff3rd +`">
                        <div class="form-text text-muted">Minutes</div>
                    </div>
                    <div class="form-group col-4">
                        <label for='QC_Hours'>Inspector</label>
                        <input type='number' id='QC_Hours' class="form-control" value="`+ rowDt?.QC_Hours +`">
                        <div class="form-text text-muted">Hours</div>
                    </div>
                </div>
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

    function toNumber(value){
        if(!isNaN(parseFloat(value))) return parseFloat(value);
        return 0
    }

    var calculateRow = function(rowData) {

        //Pull in joined Field Data
        var getField = polyfield.filter(function(x){ return x.field_name == rowData.FieldCode; });
        if(getField.length){
            rowData.Variety_name = getField[0].Variety_name;
            rowData.field_acres1 = getField[0].field_acres1;
            rowData.field_name = getField[0].field_name;
            rowData.vine_count = getField[0].vine_count;
        }

        //Pull in joined Crew Data
        var getCrew = crew.filter(function(x){ return x.CrewNumber == rowData.Crew; });
        if(getField.length && getCrew.length){
            rowData.CrewLead = getCrew[0].CrewLead;
            rowData.CrewName = getCrew[0].CrewName;
            rowData.contractor_name = getCrew[0].contractor_name;
        }


        //Calculate Hours
        rowData.employee_hrs =  toNumber(rowData.Total_Hours);
        rowData.leader_hrs =    numberFormat(toNumber(rowData.TimeDiff)/60);

        var assistant_hrs1 =     numberFormat(toNumber(rowData.TimeDiff2nd)/60);
        var assistant_hrs2 =     numberFormat(toNumber(rowData.TimeDiff3rd)/60);
        rowData.assistant_hrs = assistant_hrs1 + assistant_hrs2;
        rowData.inspector_hours = toNumber(rowData.QC_Hours);

        //Calculate Total Cost
        rowData.costOverride = toNumber(rowData.costOverride);
        if(rowData.costOverride > 0 ) {
            rowData.total = rowData.costOverride
        } else {
            var pLeader = 0;
            var pAssistant = 0;
            var pFieldWorker = 0;
            var pQC = 0;
            if(payrates[new Date(rowData.Date).getFullYear()] != undefined){
                rowYear = new Date(rowData.Date).getFullYear()
                pLeader = payrates[rowYear].pLeader;
                pAssistant = payrates[rowYear].pAssistant;
                pFieldWorker = payrates[rowYear].pFieldWorker;
                pQC = payrates[rowYear].pQC;
            }
            rowData.total = sumArray([
                (rowData.employee_hrs * pFieldWorker), 
                (rowData.leader_hrs * pLeader), 
                (rowData.assistant_hrs * pAssistant), 
                (rowData.inspector_hours * pQC)
            ]);
            if(rowData.JobCode == '4940') rowData.total += ( toNumber(rowData.Totalunits) * 0.6832)
        }
        rowData.total= numberFormat(rowData.total);


        rowData.vines_per_acre = 0;
        rowData.field_acres1 = toNumber(rowData.field_acres1);
        rowData.vine_count = toNumber(rowData.vine_count);
        if( rowData.vine_count > 0 && rowData.field_acres1 > 0){
            rowData.vines_per_acre = numberFormat(rowData.vine_count / rowData.field_acres1);
        }

        // Calculate vineacres, employeeAcresPerHr, acresPerHour
        rowData.vineacres = 0;
        rowData.Totalvines = toNumber(rowData.Totalvines);
        if( rowData.vines_per_acre > 0 && rowData.Totalvines > 0){
            rowData.vineacres = rowData.Totalvines/rowData.vines_per_acre;
        }

        rowData.employeeAcresPerHr = 0;
        if( rowData.vineacres > 0 && !isNaN(parseFloat(rowData.employeeHours))){
            rowData.employeeAcresPerHr = numberFormat(rowData.employeeHours/rowData.vineacres);
        }

        rowData.acresPerHour = 0;
        if( rowData.vineacres > 0){
            rowData.acresPerHour = numberFormat(rowData.total/rowData.vineacres);
        }

        rowData.vineacres = numberFormat(rowData.vineacres);
        
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
        computed: {
            filterColumns: function(){
                var nonFilterColumns = ['employeeHours','vines_per_acre','vineacres','employeeAcresPerHr','acresPerHour'];       
                return this.options.colModel.filter(function(x){
                    return !!x.dataIndx && nonFilterColumns.indexOf(x.dataIndx) == -1 && !x.hidden;
                })

            }
        },
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
                                    RECIEPTNO: $('#RECIEPTNO').val(),
                                    Date: $('#Date').val(),
                                    JobCode: $('#JobCode').val(),
                                    Crew: $('#Crew').val(),
                                    FieldCode: $('#FieldCode').val(),
                                    Totalvines: $('#Totalvines').val(),
                                    Totalunits: $('#Totalunits').val(),
                                    costOverride: $('#costOverride').val(),
                                    QC_Average: $('#QC_Average').val(),
                                    Total_Hours: $('#Total_Hours').val(),
                                    TimeDiff: $('#TimeDiff').val(),
                                    TimeDiff2nd: $('#TimeDiff2nd').val(),
                                    TimeDiff3rd: $('#TimeDiff3rd').val(),
                                    QC_Hours: $('#QC_Hours').val(),
                                    description: jobcodesByJobcode[$('#JobCode').val()],
                                    jobdescription: jobcodesByJobcode[$('#JobCode').val()]
                                }


                                var rowIndx = 0;

                                _grid.showLoading();
                                $.ajax({
                                    url: "api/v1/timeEntrys",
                                    method: "POST",
                                    data: {newRowData: JSON.stringify(newRowData)},
                                    success: function(data){
                                        newRowData.ROW_INDEX = data.generatedKey;
                                        newRowData.contractor_name = data.extraRowData.contractor_name;
                                        newRowData.field_acres1 = data.extraRowData.field_acres1;
                                        newRowData.vine_count = data.extraRowData.vine_count;

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
                sortModel: { type: 'remote', sorter: [{ dataIndx: 'Date', dir: 'up' }] },
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
                        return { cls: "duplicate_record_worning" }
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
                                        data: { rowIdx: ui.rowData.ROW_INDEX,
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
                                                    deleteUrl = "/api/v1/timeEntrys/" + ui.rowData.ROW_INDEX;
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
                                                        Date: $('#Date').val(),
                                                        JobCode: $('#JobCode').val(),
                                                        Crew: $('#Crew').val(),
                                                        crew_info: crewByOid[$('#Crew').val()],
                                                        FieldCode: $('#FieldCode').val(),
                                                        Totalvines: $('#Totalvines').val(),
                                                        Totalunits: $('#Totalunits').val(),
                                                        costOverride: $('#costOverride').val(),
                                                        QC_Average: $('#QC_Average').val(),
                                                        Total_Hours: $('#Total_Hours').val(),
                                                        TimeDiff: $('#TimeDiff').val(),
                                                        TimeDiff2nd: $('#TimeDiff2nd').val(),
                                                        TimeDiff3rd: $('#TimeDiff3rd').val(),
                                                        QC_Hours: $('#QC_Hours').val(),
                                                        description: jobcodesByJobcode[$('#JobCode').val()],
                                                        jobdescription: jobcodesByJobcode[$('#JobCode').val()]
                                                    }
                                                    

                                                    newRowData = calculateRow(newRowData);

                                                    var updateData = {};
                                                    for(var col in _self.colModel){
                                                        var modelCol = _self.colModel[col].dataIndx;
                                                        if(ui.rowData.hasOwnProperty(modelCol)){
                                                            updateData[modelCol] = ui.rowData[modelCol];
                                                        }
                                                         var modelCol = _self.colModel[col].dataIndx;
                                                        if(newRowData.hasOwnProperty(modelCol)){
                                                            updateData[modelCol] = newRowData[modelCol];
                                                        }
                                                    }
                                                    
                                                    
                                                    console.log(JSON.parse(JSON.stringify(updateData)));

                                                    ui.rowData.Crew = $('#Crew').val(),
                                                    ui.rowData.JobCode = $('#JobCode').val();
                                                    
                                                    _self.updateRow({rowIndx: ui.rowIndx, newRow: updateData, checkEditable: false});

                                                    _self.showLoading();
                                                    _self.options.pqIS.data[ui.rowIndx+1] = calculateRow(_self.options.pqIS.data[ui.rowIndx+1]);
                                                    oldRowData = ui.rowData;
                                                    rowData = _self.getRowData({ rowIndx: ui.rowIndx });

                                                    $.ajax({
                                                        url: "/api/v1/timeEntrys/" + rowData.ROW_INDEX,
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
                    { title: "Recipt No", width: 120, dataIndx: "RECIEPTNO", dataType: "string", editable: false },
                    { title: "Operation Name", width: 150, dataIndx: "description", dateType: "string", editable: false },

                    { title: "Contractor Name", width: 120, dataIndx: "contractor_name", dataType: "string", editable: false },

                    { title: "Crew", dataIndx: "CrewName", width: 150, dataType: "string", editable: false },

                    { title:'Field Vines per Acre', width: 135, dataIndx: "vines_per_acre", dataType: "float", editable: false },

                    { title: "Field", width: 100, dataIndx: "FieldCode", dataType: "string", editable: false },

                    { title: "Total Acres", width: 100, dataIndx: "field_acres1", dataType: "float", editable: false },

                    { title: "Total Units", width: 115, dataIndx: "Totalunits", dataType: "integer", editable: false },

                    { title: "Field Total Vines", width: 115, dataIndx: "vine_count", dataType: "integer", editable: false },

                        
                    { title: "Cost / Acre Actual", width: 150, dataIndx: "acresPerHour", dataType: "float", editable: false },

                    { title: "Man Hr / Acre Actual", width: 150, dataIndx: "employeeAcresPerHr", dataType: "float", editable: false },

                    { title: "Quality Score", width: 100, dataIndx: "QC_Average", dateType: "float", editable: false },

                    { title: "Total Vines", width: 100, dataIndx: "Totalvines", dateType: "integer", editable: false },

                    { title: "Acres", width: 100, dataIndx: "vineacres", dateType: "float", editable: false },

                    { title: "Leader Hours", width: 100, dataIndx: "leader_hrs", dateType: "string", editable: false }, 
                    {title: 'Assistant Hours', width: 110, dataIndx: "assistant_hrs", dataType: "string", editable: false },
                    { title: "Inspector Hours", width: 120, dataIndx: "inspector_hours", dateType: "float", editable: false},
                    { title: 'Employee Hours', width:115, dataIndx: "employee_hrs", dateType: "integer", editable: false },
                    { title: "Total Cost", width: 100, dataIndx: "total", dateType: "float", editable: false ,
                        render: function(ui){
                             if(toNumber(ui.rowData.costOverride) > 0){
                                return { cls: 'override_cost' };
                            }
                            return {};
                        }},
                    { dataIndx: "Total_Hours",  hidden:true },
                    { dataIndx: "TimeDiff",  hidden:true },
                    { dataIndx: "QC_Average",  hidden:true },
                    { dataIndx: "TimeDiff2nd",  hidden:true },
                    { dataIndx: "TimeDiff3rd",  hidden:true },
                    { dataIndx: "Crew",  hidden:true },
                    { dataIndx: "costOverride",  hidden:true },

                    // { title: "temp", width: 100, dataIndx: "ROW_INDEX", dataType: "string", editable: true },
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
    td.override_cost {
        background: #ed25df47;
    }

    tr.duplicate_record_worning {
        background: #fff5ba;
    }
</style>