CREATE TEMPORARY FUNCTION getPath(x STRING)  
RETURNS STRING  
  LANGUAGE js AS """
  // Helper function for error handling
  function getPath(s) {
    try {
      return URI(s).filename(true);
    } catch (ex) {
      return s;
    }
  }
  return getPath(x);
"""
OPTIONS (  
  library="gs://commonspeak-udf/URI.min.js"
);

SELECT  
  getPath(website_url) AS website_url
FROM  
  `${1}`
GROUP BY website_url