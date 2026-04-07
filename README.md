1) Install Bitdefender_JumpcloudMDM | CREATION: Circa Aprl 2023 \
A) Our MDM partner, JumpCloud, did not have an easy way to install DMGs. This script installs Bitdefender using a link from our gravity zone portal. \
B) It's just a bash script, and is not reliant on JumpCloud as an MDM. So long as you can have it run as root, should run easy peasy. 

2) Update Slack_JumpCloudMDM | CREATION: Circa December 2025 \
A) Every bit of documentation I could find to update Slack without admin rights for end users did not work. So I created this montrosity after a lot of hair pulling and googling, and I can share that it works. \
B) It's just a bash script, and is not reliant on JumpCloud as an MDM. So long as you can have it run as root, should run easy peasy. \
C) This does quit Slack as part of the process, as otherwise Slack had a decent chance of freezing or crashing until it was able to quit and reopen. Keep this in mind when you deploy, and try to set it to run on user login or something like that. 
