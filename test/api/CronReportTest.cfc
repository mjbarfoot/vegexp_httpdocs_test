/**
 * Created by mbarfoot on 08/01/2016.
 */
component extends="mxunit.framework.TestCase" displayName="CronReportTest" {
  // Place your content here


    public void function setUp(){

    }

    public void function tearDown(){

    }

    public void function test1() {
        assertEquals("1","2", "the numbers should be equal");

    }

    private boolean function isTestCase(required component cfc) {
        return isInstanceof(cfc,'mxunit.framework.TestCase') || isInstanceof(cfc,'testbox.system.testing.compat.framework.TestCase');
    }

}
