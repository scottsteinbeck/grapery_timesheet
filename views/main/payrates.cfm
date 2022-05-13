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
    console.log(payrateData);

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
        columns1: [
            { title: 'Season', width: 100, dataType: 'date', dataIndx: 'pSeason' },
            { title: 'Leader', width: 200, dataType: 'float', dataIndx: 'pLeader' },
            { title: 'Assistant', width: 200, dataType: 'float', dataIndx: 'pAssistant' },
            { title: 'QC', width: 200, dataType: 'float', dataIndx: 'pQC' },
            { title: 'Field Worker', width: 200, dataType: 'float', dataIndx: 'pFieldWorker' }
        ],
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
            height: 'flex',
            numberCell: {
                show: false
            },
            columnTemplate: { width: 100 },
            pageModel: {
                type: 'local',
                rPP: 5,
                rPPOptions: [3, 5, 10],
                layout: ['strDisplay', '|', 'prev', 'next']
            },
            colModel: this.$options.columns1,
            animModel: {
                on: true
            },
            dataModel: {
                data: this.$options.data1
            }
            };
            return {};
        }
    });
</script>