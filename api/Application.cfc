component
        extends="taffy.core.api"
{

//the name can be anything you like
    this.name = 'VE-WebOrders-API';
    this.mappings['/resources'] = expandPath('./resources');

    variables.framework = {};
    variables.framework.returnExceptionsAsJson = true;
    variables.framework.reloadOnEveryRequest = true;
    APPLICATION.DSN = "vegexp_mysql";

    function onApplicationStart()
    {
        return super.onApplicationStart();
    }

    function onRequestStart()
    {
        return super.onRequestStart();
    }

}