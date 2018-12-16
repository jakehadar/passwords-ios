Passwords
---------
A password manager for you to build and install on your own iPhone :)

![Applications list view](https://github.com/jakehadar/Passwords/blob/master/screenshots/Screen%20Shot%202018-12-15%20at%207.47.12%20PM%20@half.png)

Features
--------
* Face ID authentication.
* Does not send any data over the internet.
* Unlimited entries.
* FREE!

Motivation
----------
I needed a way to keep track of login credentials for infrequently used apps, but felt uncomfortable trusting a third party password manager to hold my sensitive information securely. So I decided to build my own password manager and share it! You can look thru the source code yourself and see that your passwords won't be leaked!

More truthfully, I thought this would be a cool project to learn some of the basics of iOS development by building an app from start to finish to solve a non-contrived problem.

Notes on architecture
---------------------
I used the [Application Controller](https://martinfowler.com/eaaCatalog/applicationController.html) pattern (aka [Coordinator](https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps)) to decouple navigation and domain logic from the ViewControllers. This may be a bit overengineered given the app's size, but UIKit's segue API (fully integrated into Xcode's Interface Builder) seems to force the developer into defining a static view hierarchy, which feels like an anti-pattern. 

If you know of a more scalable pattern for managing navigation and application flow in UIKit (especially for more complex apps), I'd love to hear from you!

Screenshot tour
---------------

**Applications list view**

* Tap "+" to add a new login/password credential.
* Tap an existing record to view/edit/delete.

![Applications list view](https://github.com/jakehadar/Passwords/blob/master/screenshots/Screen%20Shot%202018-12-15%20at%207.47.12%20PM%20@half.png)

**Adding a new login/password credential**

* Credentials will be grouped in the Application list view by the Application name you set here.
* Toggle the Secure Entry switch to show/mask password text.

![Adding a new login/password credential**](https://github.com/jakehadar/Passwords/blob/master/screenshots/Screen%20Shot%202018-12-15%20at%207.47.21%20PM%20@half.png)

**Viewing an existing credential**

* Tap "Edit" to modify or delete the selected credential.
* Press and hold "Hold to unmask password" to, well... :)

![Viewing an existing credential](https://github.com/jakehadar/Passwords/blob/master/screenshots/Screen%20Shot%202018-12-15%20at%207.47.05%20PM%20@half.png)

**Editing/deleting an existing credential**

![Editing/deleting an existing credential](https://github.com/jakehadar/Passwords/blob/master/screenshots/Screen%20Shot%202018-12-15%20at%207.46.05%20PM%20@half.png)

Notes on current version
------------------------
* *Passwords* (this app) is not available on the App store. You must have an Apple developer license to build and install to your iPhone.
* You must have a newer iPhone with Face ID enabled to use and unlock the app.
* Credentials stored in this app are persisted against your Apple keychain. *Passwords* uses a Keychain policy that prevents credentials from migrating to new devices. Thus, after buying a new iPhone or restoring a backup from a different device, all of your password data will be missing from the new device.

Disclaimer
----------
* This codebase is made publically available for educational purposes only. *Passwords* (the compiled application) has not been adequately tested for commercial or production use. No contract or warrenty is implied. Use at your own risk.
