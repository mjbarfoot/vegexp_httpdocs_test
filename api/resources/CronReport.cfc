/*
*
*
*/

component
        extends="taffy.core.resource"
        taffy_uri="/cronReporter"
{
    public function get()
    {
      return representationOf("Hello World").withStatus(200);
    }

}