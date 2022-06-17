<style>
    thead {
        position: sticky;
        background: white;
        top: 100px;
    }
    .topBar {
        height: 60px;
        width: 100%;
        position: sticky;
        background: white;
        top: 55px;
    }
</style>
<div id="mainVue">

    <div class="topBar p-2">
        <button class="btn btn-outline-success btn-sm" @click="showAll()">Show All</button>
    </div>

    <table class="table table-sm table-striped">
        <thead>
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

                    <div v-if="logData.clAction == 'add'">
                        <span v-for="col in timeEntryFormColNms">
                            <template v-if="logData[col]">
                                {{col}} = {{logData[col]}}, &nbsp;
                            </template>
                        </span>
                    </div>
                </td>

                <td>
                    <div v-if="!logData.clRestoreDate">
                        <button class="btn btn-outline-primary" @click="undo(logData.clOldRowData, logData.clTEFID, logData.clAction, logData.clID)"><i class="bi bi-arrow-counterclockwise"></i></button>
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

            timeEntryFormColNms: [
                    "BlockID", "Crew",
                    "FieldCode", "TIME_ENTRY_FORM_V2.JobCode", "Date",
                    "QC_Average", "Totalvines", "QC_Hours",
                    "TotalCalculatedTime",
                    "RECIEPTNO",
                    "TimeDiff", "TimeDiff2nd", "TimeDiff3rd"
                ],
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

            showAll: function() {
                _self = this;

                $.ajax({
                    url: "api/v1/changeLog",
                    method: "GET",
                    success: function(data){
                        for(var i=0; i < data.length; i++) {
                            changeLogData.push({});
                            for(item in data[i]) {
                                console.log([changeLogData[i], item, data[i][item]]);
                                // Vue.set(changeLogData[i], item, data[i][item]);
                            }
                        }
                    }
                });
            },
        }
    });

    $('html,body').animate({scrollTop: document.body.scrollHeight},"fast");
</script>