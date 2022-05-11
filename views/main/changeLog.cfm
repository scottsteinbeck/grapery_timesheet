<div id="mainVue">

    <ul class="nav nav-tabs">
        <li class="nav-item">
            <a class="nav-link" href="/main">Data</a>
        </li>
        <li class="nav-item">
            <a class="nav-link active" href="#">Change log</a>
        </li>
    </ul>

    <table class="table table-striped">
        <thead class="table-dark">
            <tr>
                <th>Action</th>
                <th>Reciept</th>
                <th>Changes</th>
                <th>Undo</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="logData in changeLogData">
                <td>{{logData.clAction}}</td>
                <td>{{logData.clReciept}}</td>
                <td>
                    <div v-if="logData.clAction == 'edit'" v-for="(change, key) in logData.clNewRowData">
                        {{key}}: &nbsp;{{logData.clOldRowData[key]}} &nbsp; <i class="bi bi-arrow-right"></i> &nbsp; {{change}}
                    </div>
                </td>
                <td><button class="btn btn-primary" @click="undo(logData.clOldRowData, logData.clTEFID, logData.clAction, logData.clID)"><i class="bi bi-arrow-counterclockwise"></i></button></td>
            </tr>
        </tbody>
    </table>

</div>

<script>
    
    <cfoutput>changeLogData = #serializeJSON(prc.changeLogData)#</cfoutput>

    changeLogData.map(function(x){
        if(x.clNewRowData != "") x.clNewRowData = JSON.parse(x.clNewRowData);
        if(x.clOldRowData != "") x.clOldRowData = JSON.parse(x.clOldRowData);
        return x;
    });

    var vueObj = new Vue({
        el: "#mainVue",

        data: {
            changeLogData: changeLogData,
        },

        methods: {
            undo: function(clOldData, clTEFID, clAction, clID) {
                $.ajax({
                    url: "/api/v1/changeLog/" + clTEFID,
                    method: "PATCH",
                    data: { clOldData: JSON.stringify(clOldData), clAction, clID}
                });
            },
        }
    });
</script>