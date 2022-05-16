<div id="app">

    <ul class="nav nav-tabs">
        <li class="nav-item">
            <a class="nav-link" href="main/index">Data</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="/main/changeLog">Change log</a>
        </li>
        <li class="nav-item">
            <a class="nav-link active" href="#">Payrates</a>
        </li>
    </ul>

    <div style="height: calc(100vh - 115px);">
        <pq-grid ref="grid" :options="options"></pq-grid>
    </div>
</div>

<script>
    <cfoutput>payrateData = #serializeJSON(prc.payrateData)#</cfoutput>
    // console.log(payrateData);

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

                dataModel: {
                    data: this.$options.data1
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
                                    pSeason: new Date(0),
                                    pLeader: 0,
                                    pAssistant: 0,
                                    pQC: 0,
                                    pFieldWorker: 0,
                                };
                                var rowIndx = _self.addRow({ rowIndxPage: 0, rowData: rowData, checkEditable: false, rowIndx: 0 });
                                _self.options.editRow(rowIndx, this);
                            }
                        }
                    ]
                },

                editRow: function(rowIndx, grid) {
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

                colModel: [
                    { title: 'edit', width: 40, editable: false, sortable: false,
                        render: function(ui) {
                            return "<button class='btn btn-sm btn-outline-success edit_btn'><i class='bi bi-pencil'></i></button>";
                        },
                        postRender: function(ui) {
                            var _self = this;
                            var cell = _self.getCell(ui);

                            cell.find(".edit_btn").bind("click", function(evt){
                                    _self.options.editRow(ui.rowIndx, _self);
                                });
                        }
                    },
                    { title: 'Season', width: 100, dataType: 'date', dataIndx: 'pSeason', format: "yy-mm-dd" },
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

<style>
    tr.pq-grid-row.pq-row-edit {
        background: #b2ffbe;
    }

    td.futer_date_error {
        background: #ff2f2f3b;
    }
</style>