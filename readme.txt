
1. To download/update configs  run from root
./downloadConfigs/download_all_configs_prod.sh
./downloadConfigs/download_all_configs_stage.sh


2. Clean up those witout platformID - too old, not used
./cleanup/cleanup_noplatformID.sh

3. Merge all in one
./merge/grandmerge.sh


4. ??maybenot needed??? 
To extract keys from configs from root run - this will update the keys.json
./extractKeys/extract_keys.sh


5. To serve on http://localhost:8000/ from root run
python3 -m http.server



#### TO DO:
1. download results summary - short version - then click for big version
2. 3 columns for results - false true not found
3. not found - make missing or smth better
4. standalone app to avoid the Backend???!! (Electron App)
5. add timestamp to downloads logs
6. compare few configs feature
7. beautify the search flags - some lines around that itch my eye - font increase, and colour change
8. add not working fro now on Update CTA's