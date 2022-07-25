# Generate and Classify Popular Java Projects

The top 1000 java projects from 2017 to 2021 have been generated and stored in the `json` directory. Each `json` file consists of references to 100 java projects.

## Clone and Classify projects


To clone and classify java projects into Maven, Gradle (Non-Android), Gradle(Android), run
```
run_All.sh json
```

To only clone and classify java projects from one json file, run
```
./download_java_projects.sh json/<filename>
```
  
  
  
 
 
 
 #### [Optional], download your own json files
 
 ``` 
 cd github_api
 runAll.sh <START_DATE> <END_DATE>
 ```
 
 Note: format for years is given by yyyy-mm-dd
 
