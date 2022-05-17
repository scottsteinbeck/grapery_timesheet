<div id="mainVue">

    <ul class="nav nav-tabs">
        <li class="nav-item">
            <a class="nav-link" href="/main">Data</a>
        </li>
        <li class="nav-item">
            <a class="nav-link active" href="#">Change log</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="/main/payrates">Payrates</a>
        </li>
    </ul>

    <table class="table">
        <thead class="table-dark">
            <tr>
                <th>Action</th>
                <th>Reciept</th>
                <th>Changes</th>
                <th>Undo</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="logData in changeLogData" :class="{'table-secondary': logData.clRestoreDate}">
                <td>{{logData.clAction}}</td>
                <td>{{logData.clReciept}}</td>
                <td>
                    <div v-if="logData.clAction == 'edit'" v-for="change in logData.clChanges">
                        {{change.path[0]}}: &nbsp; 
                        <template v-if="change.old == ''">Nothing</template>{{change.old}} &nbsp; 
                        <i class="bi bi-arrow-right"></i> &nbsp; 
                        {{change.new}}
                    </div>
                </td>
                <td>
                    <div v-if="!logData.clRestoreDate">
                        <button class="btn btn-primary" @click="undo(logData.clOldRowData, logData.clTEFID, logData.clAction, logData.clID)"><i class="bi bi-arrow-counterclockwise"></i></button>
                    </div>
                    <div v-if="logData.clRestoreDate">
                        Restored
                    </div>
                </td>
            </tr>
        </tbody>
    </table>

</div>

<script>
    
    <cfoutput>changeLogData = #serializeJSON(prc.changeLogData)#</cfoutput>

    changeLogData.map(function(x){
        if(x.clChanges != "") x.clChanges = JSON.parse(x.clChanges);
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
                var _self = this;
                
                $.ajax({
                    url: "/api/v1/changeLog/" + clTEFID,
                    method: "PATCH",
                    data: { clOldData: JSON.stringify(clOldData), clAction, clID}
                }).done(function () {

                    _self.changeLogData.find(function(x) {
                        return x.clID == clID;
                    }).clRestoreDate = true;

                });
            },
        }
    });
</script>