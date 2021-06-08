# Welcome to TPHCloudAnalytics

This is a lightweight project that will allow you to add analytics to your app, sending the data to your app's CloudKit public database.

## Installation
Using Swift Package Manager, add the repository to your project.

## Usage
Your app must have the iCloud capability turned on, and the CloudKit entitlement setup.

The session is started by calling `TPHCloudAnalyticsReporter.start(withContainerID:)`. Once this is done, you use the `shared` singleton to send custom events or screen views. You must pass in the iCloud container ID manaully to startup the reporter.
