today=`date +%Y_%m_%d`
datasetname="stackoverflow_$today"
#provide your project name as the first argument, (e.g. bash datasource-webdiscovery.sh crunchbox-160315)
projectname=$1
projectdataset=$projectname:$datasetname

echo "* Creating new dataset on BigQuery: $projectdataset"
echo "> running bq mk $projectdataset"

bq mk $projectdataset

desttable=${datasetname}.urls
querytable=${projectname}.${datasetname}.urls
directoriestable=${datasetname}.dirs
filenamestable=${datasetname}.filenames

echo -e "\n* Running query to extract all URLs to $desttable"
bq query --project_id=$projectname --destination_table=$desttable --allow_large_results "SELECT website_url, count(website_url) as cnt FROM [bigquery-public-data:stackoverflow.users] GROUP BY url ORDER BY cnt DESC;"

directoryquery=$(sed -e "s/\${1}/$querytable/" sql/stackoverflow-directories.sql)
echo -e "\n* Extracting directories from all URLs to $datasetname.urls_directories"
bq query --replace --format=prettyjson --use_legacy_sql=false --project_id=$projectname --destination_table=${datasetname}.urls_directories --n=10000000 "$directoryquery" > output/json/${datasetname}.urls_directories.json

filenamesquery=$(sed -e "s/\${1}/$querytable/" sql/stackoverflow-filenames.sql)
echo -e "\n* Extracting filenames from all URLs to $datasetname.urls_filenames"
bq query --replace --format=prettyjson --use_legacy_sql=false --project_id=$projectname --destination_table=${datasetname}.urls_filenames --n=10000000 "$filenamesquery" > output/json/${datasetname}.urls_filenames.json

echo -e "\n* Parsing results and saving to output/compiled/${datasetname}.urls_directories.txt"
jq -r '.[]["website_url"]' < output/json/${datasetname}.urls_directories.json > output/compiled/${datasetname}.urls_directories.txt
echo -e "\n* Compiled $(wc -l < output/compiled/${datasetname}.urls_directories.txt) directory names"

echo -e "\n* Parsing results and saving to output/compiled/${datasetname}.urls_filenames.txt"
jq -r '.[]["website_url"]' < output/json/${datasetname}.urls_filenames.json > output/compiled/${datasetname}.urls_filenames.txt
echo -e "\n* Compiled $(wc -l < output/compiled/${datasetname}.urls_filenames.txt) file names"