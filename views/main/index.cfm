<!--- <cfdump var="#prc.data#"> --->
<div id="app">
    <div style="height: calc(100vh - 115px);">
        <pq-grid ref="grid" :options="options"></pq-grid>
    </div>
</div>

<script>
    <cfoutput>queryData = #serializeJSON(prc.data)#</cfoutput>

    <cfoutput>queryTimeEntryForm = #serializeJSON(prc.timeEntryForm)#</cfoutput>
    <cfoutput>queryJobcodes = #serializeJSON(prc.jobcodes)#</cfoutput>
    <cfoutput>queryPolyfield = #serializeJSON(prc.polyfield)#</cfoutput>
    <cfoutput>queryCrew = #serializeJSON(prc.crew)#</cfoutput>
    // console.log(queryData);

    function numberFormat(val){
        return Math.round(val * 100)/100
    }

    var calculateRow = function(rowData) {
        rowData.vines_per_acre = 0;
        if( !isNaN(rowData.vine_count) && !isNaN(parseFloat(rowData.field_acres1))){
            rowData.vines_per_acre = numberFormat(rowData.vine_count/parseFloat(rowData.field_acres1));
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
            rowData.employeeAcresPerHr = rowData.employeeHours/rowData.vineacres;
        }

        rowData.acresPerHour = 0;
        if( rowData.vineacres > 0){
            rowData.acresPerHour = rowData.total/rowData.vineacres;
        }
        rowData.crew_info = rowData.Crew + ' ' + rowData.CrewName;
        
        return rowData;
    }

    queryData.map(function(x){
        return calculateRow(x);
    });

    // console.log(queryData);

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
        data1: queryData,
        methods: {
            onExport: function() {
                debugger;
                this.$refs.grid.export();
            }
        },
        data: function() {
            this.options = {
                cellSave: function(evt, ui){
                    ui.rowData = calculateRow(ui.rowData);
                    this.refreshRow(ui);
                },
                showTitle: false,
                locale: 'en',
                height: '100%',
                
                collapsible: {
                    show: false,
                },
                columnTemplate: { width: 100 },
                colModel: this.$options.columns1,
                // animModel: {
                //     on: true
                // },
                dataModel: {
                    data: this.$options.data1
                },
                postRenderInterval: -1,
                colModel: [
                    { title: "Edit", editable: false, width: 115, sortable: false,
                        render: function(ui) {
                            // console.log(ui.rowIndx);
                            return "<button class='btn btn-sm btn-outline-primary copy_btn'><i class='bi bi-files'></i></button>  <button class='btn btn-sm btn-outline-secondary edit_btn'><i class='bi bi-pencil-square'></i></button>  <button class='btn btn-sm btn-outline-danger delete_btn'><i class='bi bi-trash3'></i></button>";
                        },
                        postRender: function(ui) {
                            var _self = this;
                            var cell = _self.getCell(ui);

                            cell.find(".copy_btn").bind("click", function(evt){
                                console.log(ui.rowData.Time_Entry_Form_ROW_INDEX);
                                $.ajax({
                                    url: "/api/v1/timeEntrys",
                                    method: "POST",
                                    data: ui.rowData,
                                });
                            });

                            cell.find(".edit_btn").bind("click", function(evt){
                                console.log(ui.rowIndx + "edit");
                            });

                            cell.find(".delete_btn").bind("click", function(evt){
                                deleteUrl = "/api/v1/timeEntrys/" + ui.rowData.Time_Entry_Form_ROW_INDEX;
                                console.log(deleteUrl);
                                $.ajax({
                                    url: deleteUrl,
                                    method: "DELETE"
                                });
                            });
                        }
                    },
                    { title: "BlockID", width: 100, dataIndx: "BlockID" },

                    { title: "Crew", width: 50, dataIndx: "Crew", dataType: "float",
                        editor: {
                            type: 'select',
                            valueIndx: "value",
                            labelIndx: "label",
                            mapIndices: {"text": "ShipVia", "value": "ShipViaId"},
                            options: [
                                { "value": "", "label": "" },
                                { "value": "SE", "label": "Speedy Express" },
                                { "value": "UP", "label": "United Package" },
                                { "value": "FS", "label": "Federal Shipping" }
                            ]
                        }
                    },

                    { title:'Field Vines per Acre', width:150, editable: false, dataIndx: "vines_per_acre"},

                    { title: "Field", width: 100, dataIndx: "FieldCode" },

                    { title: "Total Acres", width: 100, editable: false, dataIndx: "field_acres1"},

                    { title: "Variety Name", width: 100, editable: false, dataIndx: "Variety_name" },

                    { title: "Field Total Vines", width: 100, editable: false, dataIndx: "vine_count"},

                    { title: "Operation Name", width: 130, editable: false, dataIndx: "description" },
                    
                    { title: "Crew Date", width: 100, dataIndx: "Date" },

                    { title: "Cost / Acre Actual", width: 100, editable: false, dataIndx: "acresPerHour" },

                    { title: "Man Hr / Acre Actual", width: 100, editable: false, dataIndx: "employeeAcresPerHr"},

                    { title: "Quality Score", width: 100, dataIndx: "QC_Average" },

                    { title: "Total Vines", width: 100, dataIndx: "Totalvines" },

                    { title: "Acres", width: 100, dataIndx: "vineacres"},

                    { title: "Leader Hours", width: 100, dataIndx: "TimeDiff"},

                    {title:'Assistant Hours', width: 100, dataIndx: "TimeDiff2nd"},
                    
                    { title: "QC_Hours", width: 100, dataIndx: "QC_Hours" },

                    {title:'Employee Hours', width:100, dataIndx: "employeeHours"},

                    { title: "Total Cost", width: 100, dataIndx: "total"},
                ]
            };
            return {
                rowIndex: -1,
            };
        }
    });

</script>