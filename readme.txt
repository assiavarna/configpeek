ConfigPeek
A web application for exploring and comparing environment configuration files across Production, Staging, and Test environments.


FEATURES

1. Environment Coverage: Supports Production, Staging, and Test environments.
2. Some level of responsive Layout present 
3. Click on Update CTA will reveal a Show Summary CTA and an input field for cookie
4. Show Summary CTA displays a brief overview and the timestamp of the last configuration update.
5. Search Functionality:
5.1. Single-Flag Search: Displays results in columns, each showing a count and the selected flag’s values.
5.2. Multi-Flag Search: Falls back to a detailed list view, grouping all selected flags and their values.
6. Combined Filters: Any combination of filters (platform ID, config name, key, or value) can be applied simultaneously.
7. Sorted Results: Search results are sorted with the newest entries on top for quick access.
8. Result Details: Each entry includes the platform, environment, config name, file name, and a direct link to Cassie.



HOW TO UPDATE DATA
1. Clone the repository:
git clone https://github.com/assiavarna/configpeek.git
cd configpeek

2. Download or update app configs 
- when needed add your COOKIE="_cassie_session in the script (though ut seems these never expire)
- takes about 2-3 min per env

./downloadConfigs/download_all_configs_prod.sh
./downloadConfigs/download_all_configs_stage.sh
./downloadConfigs/download_all_configs_test.sh

3. Cleanup invalid entries 
- this will clean too old non json files
- takes less than 30 sec

./cleanup/cleanup_noplatformID.sh

4. Merge all configurations 
- takes less than 30 sec

./merge/grandmerge.sh

5. Extract keys (updates keys.json) 
- this will build up and update the feature flag search 
- takes less than 30 sec
./extractKeys/extract_keys.sh

6. Serve the app:
6.1. Push to GitHub Pages: https://assiavarna.github.io/configpeek/
or
6.2. Run locally: python3 -m http.server 8000



ROADMAP - TO DO LIST
1. Enhance download summaries (compact view with expandable full logs).
2. Make  Update CTA's to  work - Backend or localforage or standalone app wrapper Electron App or else
3. Add Compare Configs feature to diff multiple configuration files.
4. Display update timestamps next to each Update button.

CONTRIBUTIONS AND FEEDBACK ARE WELCOME!