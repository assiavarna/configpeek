
1. To download/update configs  run from root
./downloadConfigs/download_all_configs_prod.sh
./downloadConfigs/download_all_configs_stage.sh


2. Clean up those witout platformID - too old, not used
./cleanup/cleanup_noplatformID.sh

4. Merge all in one
./merge/grandmerge.sh


3. ??maybenot needed??? 
To extract keys from configs from root run - this will update the keys.json
./extractKeys/extract_keys.sh


3. To serve on http://localhost:8000/ from root run
python3 -m http.server



#### TO DO:
1. download results summary - short verrsion - then big version
2. 3 columns for results - false true missing
3. standalone app to avoid the Backend???!! (Electron App)
