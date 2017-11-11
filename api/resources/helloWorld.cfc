component
        extends="taffy.core.resource"
        taffy_uri="/hello"
{
    public function get(){
//query the database for matches, making use of optional parameter "eyeColor" if provided
//then...
        return representationOf("Hello World").withStatus(200); //collection might be query, array, etc
    }
}