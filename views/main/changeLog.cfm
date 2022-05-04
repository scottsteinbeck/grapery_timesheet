<!--- <cfquery name="changeLogData" returntype="array">
    SELECT *
    FROM change_log
    WHERE clUserID = 1
</cfquery> --->

<div id="mainVue">

    <table class="table table-striped">
        <thead class="table-dark">
            <tr>
                <th>Action</th>
                <th>Reciept</th>
                <th>Changes</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="logData in changeLogData">
                <td>{{logData.clAction}}</td>
                <td>{{logData.clReciept}}</td>
                <td >
                    <div v-if="logData.clAction == 'edit'" v-for="(change, key) in logData.clNewRowData">
                        {{key}}: &nbsp;{{change}} &nbsp; <i class="bi bi-arrow-right"></i> &nbsp; {{logData.clOldRowData[key]}}
                        <!--- <div class="border-bottom"></div> --->
                    </div>
                </td>
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
    });
</script>