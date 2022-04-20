<!--- <cfdump var="#prc.data#"> --->
<div id="app">
    <div style="height: calc(100vh - 115px);">
        <pq-grid ref="grid" :options="options"></pq-grid>
    </div>
</div>

<script>
    <cfoutput>queryData = #serializeJSON(prc.data)#</cfoutput>

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

                            cell.find(".copy_btn").bind("click", function(evt){ console.log(ui.rowIndx + "copy"); });
                            cell.find(".edit_btn").bind("click", function(evt){ console.log(ui.rowIndx + "edit"); });
                            cell.find(".delete_btn").bind("click", function(evt){ 
                                console.log("/api/v1/timeEntrys/" + ui.rowData.Time_Entry_Form_ROW_INDEX);
                                $.ajax({
                                    url: "/api/v1/timeEntrys/" + ui.rowData.Time_Entry_Form_ROW_INDEX,
                                    method: "DELETE"
                                });
                            });
                        }
                    },
                    { title: "BlockID", width: 100, dataIndx: "BlockID" },
                    { title: "Crew", width: 50, dataIndx: "Crew" },
                    { title: "CrewLead", width: 100, dataIndx: "CrewLead" },
                    { title: "CrewName", width: 100, dataIndx: "CrewName" },
                    { title: "CrewNumber", width: 100, dataIndx: "CrewNumber" },
                    { title: "Date", width: 100, dataIndx: "Date" },
                    { title: "description", width: 130, dataIndx: "description" },
                    { title: "field_acres1", width: 100, dataIndx: "field_acres1" },
                    { title: "FieldCode", width: 100, dataIndx: "FieldCode" },
                    { title: "JobCode", width: 100, dataIndx: "JobCode" },
                    { title: "QC_Average", width: 100, dataIndx: "QC_Average" },
                    { title: "QC_Hours", width: 100, dataIndx: "QC_Hours" },
                    { title: "TotalCalculatedTime", width: 100, dataIndx: "TotalCalculatedTime" },
                    { title: "Totalvines", width: 100, dataIndx: "Totalvines" },
                    { title: "Variety_name", width: 100, dataIndx: "Variety_name" },
                    { title: "vine_count", width: 100, dataIndx: "vine_count" },
                ]
            };
            return {
                rowIndex: -1,
            };
        }
    });

</script>