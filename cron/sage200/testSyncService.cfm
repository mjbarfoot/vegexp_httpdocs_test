<!---
  Created by mbarfoot on 11/07/15.
--->

<cfscript>
    data = FileRead(expandPath(".") & "/customers1.json", "utf-8");

    // create new http service
    httpService = new http();
    httpService.setMethod("post");
    httpService.setCharset("utf-8");
    httpService.setUrl("http://dev.vegetarianexpress.co.uk/api/sync/1");
    httpService.addParam(type="formfield", name="data", value="#data#");
    result = httpService.send().getPrefix();
    r = result.filecontent;
    rJSON = deserializeJSON(r);
    writeOutput(r);
</cfscript>

<!---<cfhttp url="http://dev.vegetarianexpress.co.uk/api/sync/1" result="r" method="post" charset="utf-8" timeout="60">
    <cfhttpparam name="data" type="formfield" value="#data#" />
</cfhttp>

<cfdump var="#r#"/>--->