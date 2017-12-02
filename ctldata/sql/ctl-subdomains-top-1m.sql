CREATE TEMPORARY FUNCTION getSubdomain(x STRING)  
RETURNS STRING  
  LANGUAGE js AS """
  // Helper function for error handling
  function getSubdomain(s) {
    try {
      var url = 'http://' + s;
      var subdomain = URI(url).subdomain();
      if (subdomain == '*' || subdomain == ' ') {
        // do nothing
      } else {
        // clean subdomain further
        if (subdomain.startsWith('*.')) {
          subdomain = subdomain.replace('*.', '');
        }
        return subdomain;
      }
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
  getSubdomain( dns_names ) AS dns_names, APPROX_COUNT_DISTINCT(dns_names) AS cnt
FROM  
  `${1}`
GROUP BY
  dns_names
ORDER BY
  cnt DESC
LIMIT
  1000000;