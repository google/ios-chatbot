# Chatbot with API.AI and Google Cloud APIs

This sample demonstrates how to build an iOS chatbot with Google Cloud Vision,
Speech, and Translate APIs and API.AI.

[![English Demo](http://img.youtube.com/vi/qDAP3ZFjO48/0.jpg)](https://youtu.be/qDAP3ZFjO48)
[![The Google Assistant / Google Home Demo](http://img.youtube.com/vi/_x5rlkpZiyc/0.jpg)](https://youtu.be/_x5rlkpZiyc)

## Prerequisites
- An iOS API key for the Cloud APIs (See
  [the docs][getting-started] to learn more)
- [Xcode 7][xcode]
- [Cocoapods][cocoapods] version 1.0 or later

## Quickstart
- Clone this repo and `cd` into this directory.
- Run `pod install` to download and build Cocoapods dependencies.
- Open the project by running `open ChatBot.xcworkspace`.
- In [CBDefines.m](ChatBot/ChatBot/Helpers/CBDefines.m), replace 
`your google API key` with the API key obtained above.
- Build and run the app.


## API keys
1. Create a new project on https://console.cloud.google.com.
1. Enable Billing.
1. Go to API Manager.
1. Go to Credentials
1. Create credentials. Choose API Key.
1. Replace @"your google API key" with your google API key in [CBDefines.m](ChatBot/ChatBot/Helpers/CBDefines.m)

## API.AI
Optionally, follow these steps to create your own API.AI agents.
1. Create TourGuide agent.
1. Go to Settings and import [api.ai/TourGuide.zip](api.ai/TourGuide.zip).
1. (Optional steps to support Chinese) Create TourGuideChinese agent with
language set to Chinese.
1. Go to Settings and import [api.ai/TourGuideChinese.zip](api.ai/TourGuideChinese.zip)
1. Replace CBApiAiToken with your API.AI token in [CBDefines.m](ChatBot/ChatBot/Helpers/CBDefines.m).
 You can find your token from the API.AI agent setting page.


# Chinese Demo
[![Chinese Demo](http://img.youtube.com/vi/Oy4oNNd1aGw/0.jpg)](https://youtu.be/Oy4oNNd1aGw)

## License

This sample is released under the [Apache 2.0 license](LICENSE).

## Disclaimer
This is not an official Google product.

## Authors
[Chang Luo][changluo] and [Bob Liu][bobliu]

[getting-started]: https://cloud.google.com/vision/docs/getting-started
[cloud-console]: https://console.cloud.google.com
[git]: https://git-scm.com/
[xcode]: https://developer.apple.com/xcode/
[billing]: https://console.cloud.google.com/billing?project=_
[enable-speech]: https://console.cloud.google.com/apis/api/speech.googleapis.com/overview?project=_
[api-key]: https://console.cloud.google.com/apis/credentials?project=_
[cocoapods]: https://cocoapods.org/
[changluo]: https://www.linkedin.com/in/changluo
[bobliu]: https://www.linkedin.com/in/bobyliu
[google-home]: https://www.youtube.com/watch?v=_x5rlkpZiyc&feature=youtu.be
