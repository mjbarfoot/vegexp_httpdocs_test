<cfscript>
component name="util" displayname="util" output="false" {
  function htmlOut(strArr) {
    wrapHTML = '<html lang="en">
    <head>
      <meta charset="utf-8">

      <title>Sage 200 Sync</title>
      <meta name="description" content="Sage 200 Sync">
      <meta name="author" content="Clearview Webmedia">
      <style>
        * {font-family: Calibra, Arial, Sans-serif;}
      </style>
    </head>

    <body>
      <h1>Sage 200 Sync Setup</h1>
      <p>';

      for (msg in strArr) {
          wrapHTML&=msg & "<br/>";
      }

    wrapHtml&="</p></body>
    </html>";

    return wrapHTML;
  };
}
</cfscript>
