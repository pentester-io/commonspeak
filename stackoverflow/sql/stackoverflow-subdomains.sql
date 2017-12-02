CREATE TEMPORARY FUNCTION getSubdomain(x STRING)  
RETURNS STRING  
  LANGUAGE js AS """
  // Helper function for error handling
  function getSubdomain(s) {
    try {
      return URI(s).subdomain();
    } catch (ex) {
      return s;
    }
  }
  return getSubdomain(x);
"""
OPTIONS (  
  library="gs://commonspeak-udf/URI.min.js"
);

SELECT  
  getSubdomain(website_url) AS website_url
FROM  
  `${1}`
GROUP BY website_url