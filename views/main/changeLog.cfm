<style>
    thead {
        position: sticky;
        background: white;
        top: 140px;
    }
    .topBar {
        height: 90px;
        width: 100%;
        position: sticky;
        background: white;
        top: 55px;
    }

    /* The switch - the box around the slider */
    .switch {
        position: relative;
        display: inline-block;
        width: 60px;
        height: 34px;
    }

    /* Hide default HTML checkbox */
    .switch input {
        opacity: 0;
        width: 0;
        height: 0;
    }

    /* The slider */
    .slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: #ccc;
        -webkit-transition: .4s;
        transition: .4s;
    }

    .slider:before {
        position: absolute;
        content: "";
        height: 26px;
        width: 26px;
        left: 4px;
        bottom: 4px;
        background-color: white;
        -webkit-transition: .4s;
        transition: .4s;
    }

    input:checked + .slider {
        background-color: #2196F3;
    }

    input:focus + .slider {
        box-shadow: 0 0 1px #2196F3;
    }

    input:checked + .slider:before {
        -webkit-transform: translateX(26px);
        -ms-transform: translateX(26px);
        transform: translateX(26px);
    }

    /* Rounded sliders */
    .slider.round {
        border-radius: 34px;
    }

    .slider.round:before {
        border-radius: 50%;
    }
</style>

<div id="mainVue">

    <div class="topBar p-2">
        <div>Only show records within the last 30 days.</div>
        <label class="switch">
            <input type="checkbox" v-model="ShowOrHideAll" @click="showOrHideOld()">
            <span class="slider round"></span>
        </label>
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
            <tr v-for="logData in changeLogItems" :class="{'table-secondary': logData.clRestoreDate}">
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
    <cfoutput>changeLogDataPRC = #serializeJSON(prc.changeLogData)#</cfoutput>

    var vueObj = new Vue({
        el: "#mainVue",
        computed:{
            changeLogItems: function () {
                
                return this.changeLogData.map(function(x){
                    try{
                        x.clChanges = JSON.parse(x.clChanges);
                    } catch(e){}
                    try{    
                        x.clOldRowData = JSON.parse(x.clOldRowData);
                    } catch(e){}
                    return x;
                });
            }
        },
        data: {
            changeLogData: changeLogDataPRC,

            timeEntryFormColNms: [
                    "BlockID", "Crew",
                    "FieldCode", "TIME_ENTRY_FORM_V2.JobCode", "Date",
                    "QC_Average", "Totalvines", "QC_Hours",
                    "TotalCalculatedTime",
                    "RECIEPTNO",
                    "TimeDiff", "TimeDiff2nd", "TimeDiff3rd"
                ],

            ShowOrHideAll: true,
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

            showOrHideOld: function() {
                var _self = this;

                if(_self.ShowOrHideAll) {
                    $.ajax({
                        url: "api/v1/changeLog",
                        method: "GET",
                        success: function(data){
                            for(var i=0; i < data.length; i++) {
                                _self.changeLogData.push(data[i]);
                            }
                        }
                    });
                }
                else {
                    pastDate = new Date();
                    pastDate.setTime(pastDate.getTime() - ((24*60*60*1000) * 30));
    
                    for(var i=0; i<_self.changeLogData.length; i++) {
                        itemDate = new Date(_self.changeLogData[i].clDate);
                        if(itemDate.getTime() <= pastDate.getTime(pastDate)) {
                            _self.changeLogData.splice(i,1);
                        }
                    }
                }
                // _self.ShowOrHideAll = false;
            },

            hideOld: function() {
                var _self = this;

                pastDate = new Date();
                pastDate.setTime(pastDate.getTime() - ((24*60*60*1000) * 30));

                for(var i=0; i<_self.changeLogData.length; i++) {
                    itemDate = new Date(_self.changeLogData[i].clDate);
                    if(itemDate.getTime() <= pastDate.getTime(pastDate)) {
                        _self.changeLogData.splice(i,1);
                    }
                }

                _self.ShowOrHideAll = true;
            }
        },
    });

    $('html,body').animate({scrollTop: document.body.scrollHeight},"fast");
</script>