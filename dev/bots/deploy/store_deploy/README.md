# store_deploy

## Android

1. Create a project for your app https://console.cloud.google.com/home/dashboard
1. Enable "Google Play Android Developer API" https://console.cloud.google.com/apis/library?q=play%20developer
1. Add a service account in Credentials https://console.cloud.google.com/apis/credentials
    1. grant Editor permissions(?)
    1. Save the JSON file
1. Link Google Cloud Console project to Google Play Console Developer account https://play.google.com/apps/publish/#ApiAccessPlace
1. Grant access to your service account https://play.google.com/apps/publish/#ApiAccessPlace
    1. Check "Create & edit draft apps", "Manage production releases", "Manage alpha & beta releases", "Manage alpha and beta test configuration", "Edit store listing, pricing & distribution"
