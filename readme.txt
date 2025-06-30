
HOW-TO-USE

1. To download/update configs run from root
./downloadConfigs/download_all_configs_prod.sh
./downloadConfigs/download_all_configs_stage.sh
./downloadConfigs/download_all_configs_test.sh

2. Clean up those without platformID - some are too old, not json
./cleanup/cleanup_noplatformID.sh

3. Merge all in one
./merge/grandmerge.sh


4. To extract keys from configs from root run - this will update the keys.json
./extractKeys/extract_keys.sh


5. To serve on http://localhost:8000/ from root run
python3 -m http.server



#### TO DO:
1. Show Summary for downloads - short version only - then click for full log
2. Backend or localforage standalone app wrapper Electron App so that Update CTA's do work
3. Compare few configs feature
8. Add timestamp next to Update CTA's