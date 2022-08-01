#!/bin/bash

JSON_FILES=$1
PROJECTS_FOLDER='projects'
MAVEN='Maven'
GRADLE='Gradle'
BOTH_SYSTEMS="${MAVEN}_And_${GRADLE}"
BUILD_SYSTEMS=("$MAVEN" "$GRADLE" "$BOTH_SYSTEMS")
ANDROID='Android'
NON_ANDROID='Non_Android'
APPS=("$ANDROID" "$NON_ANDROID")
SUCCESS_EXIT_CODE=0
TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
LOG_FOLDER='logs'
TEMP_FOLDER='temp'


if [[ $# -ne 1 ]]; then
	echo "Json file must be supplied as an argument."
	exit 1
fi

folders=("$LOG_FOLDER" "$TEMP_FOLDER")
for app in "${APPS[@]}"; do
	for system in "${BUILD_SYSTEMS[@]}"; do
		folders+=("$PROJECTS_FOLDER/$app/$system")
	done
done
for folder in "${folders[@]}"; do
	if [[ ! -d $folder ]]; then
		mkdir -p $folder;
	fi
done


default_branches_str=$(grep -r default_branch "$JSON_FILES" | cut -f4 -d\")
default_branches_list=($default_branches_str)

htmls_str=$(grep -r html_url "$JSON_FILES" | grep '.*//.*/.*/' | cut -f4 -d\")
htmls_list=($htmls_str)

for i in "${!htmls_list[@]}"; do 
	default_branch=${default_branches_list[$i]}
	html=${htmls_list[$i]}

	pom_url=$(echo "$html" | sed 'sX$X/blob/'"$default_branch"'/pom.xmlX')
	curl -s -f -o /dev/null $pom_url
	pom_return_code=$?

	gradle_url=$(echo "$html" | sed 'sX$X/blob/'"$default_branch"'/build.gradleX')
	curl -s -f -o /dev/null $gradle_url
	gradle_return_code=$?

	build_system=""
	if [[ $pom_return_code -eq $SUCCESS_EXIT_CODE && $gradle_return_code -eq $SUCCESS_EXIT_CODE ]]; then
		build_system=$BOTH_SYSTEMS
	elif [[ $pom_return_code -eq $SUCCESS_EXIT_CODE ]]; then
		build_system=$MAVEN
	elif [[ $gradle_return_code -eq $SUCCESS_EXIT_CODE ]]; then
		build_system=$GRADLE
	fi

	if  [[ ! -z "$build_system" ]]; then
		project_name=$(echo $html | cut -d/ -f4-5 | sed 'sX/X__X')    #allows for sharing of repo names among different users
		temp_file="$TEMP_FOLDER/$project_name"
		if git clone $html "$temp_file"; then
			find "$temp_file" -name AndroidManifest.xml | grep -q .  
			if [[ $? -eq $SUCCESS_EXIT_CODE ]]; then project_type=$ANDROID; else project_type=$NON_ANDROID; fi 
			permanent_loc="$PROJECTS_FOLDER/$project_type/$build_system/"
			mv $temp_file  $permanent_loc
			echo "Build System: $build_system, URL: $html" >> $LOG_FOLDER/downloaded_$TIMESTAMP.txt
		else
			echo "Build System: $build_system, URL: $html, Reason for Failure: Git clone crashed" >> $LOG_FOLDER/not_downloaded_$TIMESTAMP.txt
		fi
	else	
		echo "Build System: unknown, URL: $html, Reason for Failure: Not Maven/Gradle" >> $LOG_FOLDER/not_downloaded_$TIMESTAMP.txt
	fi


done

rm -rf $TEMP_FOLDER


