# Welcome to TPHCloudAnalytics

This is a lightweight project that will allow you to add analytics to your app, sending the data to your app's CloudKit public database.

## Installation
I built this framework as a git submodule. Configure it like so:

1. Add this repo as a submodule to your app's
2. Add the TPHCloudAnalytics Xcode project as a sub-project
3. Add the project as a target dependency to your app's in Build Settings
4. Add the framework as an embedded binary to your main app's.

## Usage
Your app must have the iCloud capability turned on, and the CloudKit entitlement setup.

The session is started by calling `TPHCloudAnalyticsReporter.start(withContainerID:)`. Once this is done, you use the `shared` singleton to send custom events or screen views. You must pass in the iCloud container ID manaully to startup the reporter.
