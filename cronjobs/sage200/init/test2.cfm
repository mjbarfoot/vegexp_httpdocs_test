<cfscript>
writeOutput("
<style>
     p {color: green; font-style: courier;};
</style>");
writeOutput("<p>2 - Here I am</p>");
cfflush();
sleep(1000);
writeOutput("<p>2 - Here I am 1 second later!</p>");
</cfscript>
