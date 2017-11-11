
component
        extends="taffy.core.resource"
        taffy_uri="/syncCustomers"
{
    public function get()
    {
        return representationOf("Hello World").withStatus(200);
    }

    public function post(data) {
        var customerData = "";
        var result= {};
        var record = {};
        var lastUpdated = "";
        var modified = false;
        var modifiedCount=0;
        var dataService = createObject("component", "dataService");

        result.readJSON = false;
        result.countUpdated = 0;
        result.countCreated = 0;
        result.countSkipped = 0;
        result.recordsSkipped = [];
        result.recordsUpdated = [];
        result.recordsCreated = [];


        if (isJSON(data)) {

            customerData = DeserializeJSON(data);


            for (i=1; i lte arraylen(customerData); i++) {
                record = customerData[i];
                lastUpdated = getCustomerLastUpdated(record.account_ref);
                if (isDate(lastUpdated)) {

                    if (lastUpdated lt record.dateaccountdetailslastchanged) {
                        dataService.updateCustomer(record);
                        arrayAppend(result.recordsUpdated, record.account_ref);

                        result.countUpdated++;
                    } else {
                        arrayAppend(result.recordsSkipped, record.account_ref);
                        result.countSkipped++;
                    }


                } else {
                    dataService.createCustomer(record);
                    result.countCreated++;
                    arrayAppend(result.recordsCreated, record.account_ref);
                }
            }
        }


        return representationOf(result).withStatus(200);

    }

    private function getCustomerLastUpdated(accountid) {
        var r = "";
        queryService = new query();
        queryService.setDataSource("vegexp_mysql");
        queryService.setName("q");
        queryService.addParam(name="accountid", value=ARGUMENTS.ACCOUNTID, cfsqltype="cf_sql_varchar");

        result = queryService.execute(sql="select lastUpdatedDate from veappdata.tblUsers where accountid = :accountid");

        q = result.getResult();
        metaInfo = result.getPrefix();

        if (q.recordCount eq 1) {
            r = q.lastUpdatedDate;
        }

        return r;
    }


}

