<img src="https://i.imgur.com/ANSqOBE.png" width="350">

Commonspeak is a wordlist generation tool that leverages public datasets from Google's BigQuery platform. By performing queries on large datasets that are updated frequently, commonspeak is able to generate wordlists that are "evolutionary", in the sense that they reflect the newest trends on the internet.

Commonspeak was made to generate content discovery and subdomain wordlists for use in application security testing. More details about this tool can be found [here](https://pentester.io/commonspeak-bigquery-wordlists/).

Requirements
----
* jq (`sudo apt-get install jq` or `brew install jq`)
* Google Cloud SDK (https://cloud.google.com/sdk/docs/)
* Google Cloud Account (https://cloud.google.com/storage/docs/gsutil_install#authenticate)

Instructions
----
- Install jq (`sudo apt-get install jq` or `brew install jq`)
- Clone the repository:

    git clone https://github.com/pentest-io/commonspeak

- Install Google Cloud SDK
- Create a Google Cloud project to use with BigQuery (mine was named crunchbox-160315)
- `cd` to the dataset you would like to pull down: `cd commonspeak/hackernews`
- Run the bash script, specifying the project name as the first argument: `bash hackernews-subdomains.sh crunchbox-160315`

The output will be located in `commonspeak/hackernews/output/compiled`

Features
----
Commonspeak currently supports the following datasets:

* StackOverflow, HackerNews
    - Directories
    - Filenames
    - Subdomains

* HTTPArchive
    - Directories
    - Filenames
    - Language based directories and filenames
    - Subdomains

* Certificate Transparency Logs
    - Subdomains

* Collection of bash scripts that can easily be automated by using cron jobs
* Easy to modify SQL queries for each separate dataset

Usage
----

Extracting the top 1 million unique subdomains from certificate transparency logs:

```
~/projects/commonspeak/ctldata
⟩ bash ctl-subdomains.sh crunchbox-160315
* Creating new dataset on BigQuery: crunchbox-160315:ctl_2017_12_02
* running bq mk crunchbox-160315:ctl_2017_12_02

Dataset 'crunchbox-160315:ctl_2017_12_02' successfully created.

* Running query to extract all_dns_names to ctl_2017_12_02.all_dns_names
Waiting on bqjob_r5535032cd1a736b2_000001601706601a_1 ... (139s) Current status: DONE
+----------------------------------------------+
|                  dns_names                   |
+----------------------------------------------+
| keralacinfo.com                              |
| decreask.online                              |
| www.tmbworld.com                             |
| www.metroaccess.dk                           |
| ungueskynso.gq                               |
| [...omitted for brevity...]                  |
| webdisk.forbesitservices.com                 |
| develop-cdn01.rockwoolgroup.com              |
| autodiscover.linaproperty.com.my             |
| accountserver.mydevices.thethings.industries |
+----------------------------------------------+

* Cleaning subdomains from all all_dns_names to ctl_2017_12_02.top_1m_all_dns_names
Waiting on bqjob_r236f25aea0828b3a_00000160170897a0_1 ... (657s) Current status: DONE
* Parsing results and saving to output/compiled/ctl_2017_12_02.subdomains.txt

* Compiled top 1000000 subdomains
```

Follow the pentester.io team on twitter
----

- https://twitter.com/infosec_au
- https://twitter.com/nnwakelam
- https://twitter.com/avlidienbrunn
- https://twitter.com/KasperFritzo