# DiscogsAPI

[![CI Status](http://img.shields.io/travis/maxep/DiscogsAPI.svg?style=flat)](https://travis-ci.org/maxep/DiscogsAPI)
[![Version](https://img.shields.io/cocoapods/v/DiscogsAPI.svg?style=flat)](http://cocoadocs.org/docsets/DiscogsAPI)
[![License](https://img.shields.io/cocoapods/l/DiscogsAPI.svg?style=flat)](http://cocoadocs.org/docsets/DiscogsAPI)
[![Platform](https://img.shields.io/cocoapods/p/DiscogsAPI.svg?style=flat)](http://cocoadocs.org/docsets/DiscogsAPI)

An Objective-C interface for [Discogs API v2.0](http://www.discogs.com/developers/).

The implementation is based on the [RestKit](http://restkit.org/) framework.

##Features
- Handle OAuth process and store the token in keychain.
- Database support: Release, Master Release, Master Release Versions, Artist, Artist Releases, Label, All Label Releases, Search.
- User support: Identify, Profile, Collection, Wantlist.
- Image support.

## Usage


### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects.

##### Podfile

```ruby
platform :ios, '7.1'
pod 'DiscogsAPI'
```

### Configure Xcode Project

Configure the .plist for your project:

In Xcode right-click your .plist file and choose "Open As Source Code".
Copy & Paste the XML snippet into the body of your file (`<dict>...</dict>`).
Replace DISCOGS_APP_CONSUMER_KEY and DISCOGS_APP_CONSUMER_SECRET with your Discogs App consumer key and secret. You can create them in your [profile settings](https://www.discogs.com/settings/developers).

```xml
<key>DiscogsConsumerKey</key>
<string>DISCOGS_APP_CONSUMER_SECRET</string>
<key>DiscogsConsumerSecret</key>
<string>DISCOGS_APP_CONSUMER_KEY</string>
```

### Authenticate the user

OAuth process is all handled by the 'authentication' endpoint. You just have to show the 'authView' view to let the user enter his credentials and authorize the application. The token will be automatically stored in the Apple keychain.

```objective-c
	DiscogsAPI* discogs = [DiscogsAPI sharedClient];
    
    [discogs.authentication authenticateWithPreparedAuthorizationViewHandler:^(UIView *authView) {
        [authView setFrame:[[UIScreen mainScreen] bounds]];
        [self.view addSubview:authView];
        
    } success:^{
        NSLog(@"The user has been successfully authentified");
    } failure:^(NSError *error) {
    	NSLog(@"Error: %@", error);
    }];
```

### Search on Discogs database

```objective-c

	DGSearchRequest* request = [DGSearchRequest request];
    request.query = @"Cool band";
    request.type = @"artist";
    request.pagination.perPage = @25;
    
	DiscogsAPI* discogs = [DiscogsAPI sharedClient];
    
    [discogs.database searchFor:request success:^(DGSearchResponse *response) {
        [self.searchView setResponse:response];
    } failure:^(NSError *error) {
         NSLog(@"Error: %@", error);
    }];
```

## Documentation

Documentation is available through [CocoaDocs](http://cocoadocs.org/docsets/DiscogsAPI)

## Author

[![GitHub](https://img.shields.io/badge/github-maxep-lightgrey.svg?style=flat)](https://github.com/maxep)
[![Twitter](https://img.shields.io/badge/twitter-%40MaximeEpain-blue.svg?style=flat)](https://twitter.com/MaximeEpain)
[![Email](https://img.shields.io/badge/email-maxime.epain%40gmail.com-red.svg?style=flat)](mailto:maxime.epain@gmail.com)

## License

DiscogsAPI is available under MIT License. See the [LICENSE](LICENSE) for more info.
