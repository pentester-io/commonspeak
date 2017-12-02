extensions=(php aspx asp cfm jsp do jspa page xml pl html phtml)
today=`date +%Y_%m_%d`
datasetname="httparchive_$today"
#provide your project name as the first argument, (e.g. bash datasource-webdiscovery.sh crunchbox-160315)
projectname=$1
projectdataset=$projectname:$datasetname

echo "* Creating new dataset on BigQuery: $projectdataset"
echo "> running bq mk $projectdataset"

bq mk $projectdataset

for ext in ${extensions[@]}
do
	desttable=$datasetname.$ext
	echo -e "\n* Running query to extract $ext to table $desttable"
	bq query --project_id=$projectname --destination_table=$desttable "SELECT url, COUNT(url) AS cnt FROM [httparchive:runs.latest_requests] WHERE ext = '$ext' GROUP BY url ORDER BY cnt DESC;"
	querytable=$projectname.$datasetname.$ext
	# extract directories
	directoryquery=$(sed -e "s/\${1}/$querytable/" sql/httparchive-directories.sql)
	echo -e "\n* Extracting folder names from $desttable to ${desttable}_dirs"
	bq query --replace --format=prettyjson --use_legacy_sql=false --project_id=$projectname --destination_table=${desttable}_dirs --n=10000000 "$directoryquery" > output/json/${desttable}_dirs.json
	# convert json to new line delimited txt file
	jq -r '.[]["url"]' < output/json/${desttable}_dirs.json > output/language_based/${desttable}_dirs.txt
	echo -e "\n* Line count for ${desttable}_dirs: $(wc -l < output/language_based/${desttable}_dirs.txt)"
	# add contents of text file into compiled folders wordlist
	cat output/language_based/${desttable}_dirs.txt >> output/compiled/${today}_dirs.txt
	# extract file names
	filenamesquery=$(sed -e "s/\${1}/$querytable/" sql/httparchive-filenames.sql)
	echo -e "\n* Extracting file names from $desttable to ${desttable}_filenames"
	bq query --replace --format=prettyjson --use_legacy_sql=false --project_id=$projectname --destination_table=${desttable}_filenames --n=10000000 "$filenamesquery" > output/json/${desttable}_filenames.json
	# convert json to new line delimited txt file
	jq -r '.[]["url"]' < output/json/${desttable}_filenames.json > output/language_based/${desttable}_filenames.txt
	echo -e "\n* Line count for ${desttable}_filenames: $(wc -l < output/language_based/${desttable}_filenames.txt)"
	# add contents of text file into compiled folders wordlist
	cat output/language_based/${desttable}_filenames.txt >> output/compiled/${today}_filenames.txt
done