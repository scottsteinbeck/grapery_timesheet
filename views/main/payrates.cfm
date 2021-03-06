<div id="app">
    <div style="height: calc(100vh - 115px);">
        <pq-grid ref="grid" :options="options"></pq-grid>
    </div>
</div>

<script>
    <cfoutput>payrateData = #serializeJSON(prc.payrateData)#</cfoutput>

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
        data1: payrateData,
        methods: {
            onExport: function() {
                debugger;
                this.$refs.grid.export();
            }
        },
        data: function() {

            this.options = {
                
                showTitle: false,
                showTop: false,
                showToolbar: false,
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
                
                dataModel: {
                    data: this.$options.data1
                },

                cellSave: function(evt, ui){
                    $.ajax({
                        url: "/api/v1/payrates/" + ui.rowData.pSeason,
                        method: "PUT",
                        data: {updatedVal: JSON.stringify(ui.rowData)}
                    });
                },

                colModel: [
                    { title: 'Season', width: 100, dataType: 'integer', dataIndx: 'pSeason'},
                    { title: 'Leader', width: 200, dataType: 'float', dataIndx: 'pLeader' },
                    { title: 'Assistant', width: 200, dataType: 'float', dataIndx: 'pAssistant' },
                    { title: 'QC', width: 200, dataType: 'float', dataIndx: 'pQC' },
                    { title: 'Field Worker', width: 200, dataType: 'float', dataIndx: 'pFieldWorker' }
                ],
            };
            return {};
        }
    });
</script>