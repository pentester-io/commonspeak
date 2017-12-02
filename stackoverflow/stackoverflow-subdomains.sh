today=`date +%Y_%m_%d`
datasetname="stackoverflow_$today"
#provide your project name as the first argument, (e.g. bash datasource-webdiscovery.sh crunchbox-160315)
projectname=$1
projectdataset=$projectname:$datasetname

echo "* Creating new dataset on BigQuery: $projectdataset"
echo "* running bq mk $projectdataset"

bq mk $projectdataset

desttable=${datasetname}.urls
querytable=${projectname}.${datasetname}.urls

echo -e "\n* Running query to extract all URLs to $desttable"
bq query --project_id=$projectname --destination_table=$desttable --allow_large_results "SELECT website_url, count(website_url) as cnt FROM [bigquery-public-data:stackoverflow.users] GROUP BY website_url ORDER BY cnt DESC;"

subdomainquery=$(sed -e "s/\${1}/$querytable/" sql/stackoverflow-subdomains.sql)
echo -e "\n* Extracting subdomains from all URLs to $datasetname.urls_subdomains"
bq query --replace --format=prettyjson --use_legacy_sql=false --project_id=$projectname --destination_table=${datasetname}.urls_subdomains --n=10000000 "$subdomainquery" > output/json/${datasetname}.urls_subdomains.json

echo -e "\n* Parsing results and saving to output/compiled/${datasetname}.urls_subdomains.txt"
jq -r '.[]["website_url"]' < output/json/${datasetname}.urls_subdomains.json > output/compiled/${datasetname}.urls_subdomains.txt
echo -e "\n* Compiled $(wc -l < output/compiled/${datasetname}.urls_subdomains.txt) subdomains"