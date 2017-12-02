today=`date +%Y_%m_%d`
datasetname="ctl_$today"
#provide your project name as the first argument, (e.g. bash datasource-webdiscovery.sh crunchbox-160315)
projectname=$1
projectdataset=$projectname:$datasetname

echo "* Creating new dataset on BigQuery: $projectdataset"
echo "* running bq mk $projectdataset"

bq mk $projectdataset

desttable=${datasetname}.all_dns_names
querytable=${projectname}.${datasetname}.all_dns_names

echo -e "\n* Running query to extract all_dns_names to $desttable"

bq query --project_id=$projectname --destination_table=$desttable --allow_large_results "SELECT LOWER(SPLIT(all_dns_names, ' ')) as dns_names FROM [ctl-lists:ctl_data.cert_data];"

subdomainquery_top_1m=$(sed -e "s/\${1}/$querytable/" sql/ctl-subdomains-top-1m.sql)

echo -e "\n* Cleaning subdomains from all all_dns_names to $datasetname.top_1m_all_dns_names"

bq query --replace --format=prettyjson --use_legacy_sql=false --project_id=$projectname --destination_table=${datasetname}.top_1m_all_dns_names --n=10000000 "$subdomainquery_top_1m" > output/json/${datasetname}.subdomains.json

echo -e "\n* Parsing results and saving to output/compiled/${datasetname}.subdomains.txt"

jq -r '.[]["dns_names"]' < output/json/${datasetname}.subdomains.json > output/compiled/${datasetname}.subdomains.txt

echo -e "\n* Compiled top $(wc -l < output/compiled/${datasetname}.subdomains.txt) subdomains"