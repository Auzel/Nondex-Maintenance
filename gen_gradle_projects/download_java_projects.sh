#!/bin/bash

JSON_FILE=$1
PROJECTS_FOLDER=projects
MAVEN='Maven'
ANDROID='Gradle/Android'
NON_ANDROID='Gradle/Non_Android'
CURL_ERROR_CODE=22
TIMESTAMP=$(date "+%Y%m%d-%H%M%S")


if [[ $# -ne 1 ]]; then
	echo "Json file must be supplied as an argument."
	exit 1
fi

if [[ ! -d ${PROJECTS_FOLDER}/${NON_ANDROID} ]]; then
	mkdir -p ${PROJECTS_FOLDER}/${NON_ANDROID}
fi

if [[ ! -d ${PROJECTS_FOLDER}${ANDROID} ]]; then
	mkdir -p ${PROJECTS_FOLDER}/${ANDROID}
fi

if [[ ! -d ${PROJECTS_FOLDER}/${MAVEN} ]]; then
        mkdir -p ${PROJECTS_FOLDER}/${MAVEN}
fi

	
default_branches_str=$(grep default_branch "$JSON_FILE" | cut -f4 -d\")
default_branches_list=(${default_branches_str})

raw_htmls=$(grep html_url "$JSON_FILE" | grep '.*//.*/.*/' | cut -f4 -d\" | sed 'sXgithub.comXraw.githubusercontent.comX')
raw_html_list=(${raw_htmls})


for i in "${!raw_html_list[@]}"; do 
	default_branch=${default_branches_list[$i]}
	raw_html=${raw_html_list[$i]}

	project_type=""
	pom_url=$(echo "$raw_html" | sed 'sX$X/'"$default_branch"'/pom.xmlX')
	curl -s -f -o /dev/null $pom_url
	if [[ $? -ne $CURL_ERROR_CODE ]]; then
		project_type=$MAVEN
	else
		gradle_url=$(echo "$raw_html" | sed 'sX$X/'"$default_branch"'/build.gradleX')
		gradle_file=$(curl -s -f $gradle_url)
		if [[ $? -ne $CURL_ERROR_CODE ]]; then
			if echo $gradle_file | grep -q 'com.android.tools.build'; then
				project_type=$ANDROID
			else
				project_type=$NON_ANDROID
			fi
		fi
	fi
	
	orig_html=$(echo "$raw_html" | sed 'sXraw.githubusercontent.comXgithub.comX')
	if  [[ ! -z "$project_type" ]]; then
		cd "${PROJECTS_FOLDER}/${project_type}"
		git clone ${orig_html}.git && echo "${orig_html}.git success"
		cd - > /dev/null
		echo "Project Type: $project_type, URL: $orig_html" >> logs/downloaded_${TIMESTAMP}.txt
	else	
		echo $raw_html $project_type
		echo "URL: $orig_html" >> logs/not_downloaded_${TIMESTAMP}.txt
	fi

	
done

