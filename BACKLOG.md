# Backlog

Features
--------
* Search bar
* Wait N minutes before requiring re-auth.
* Allow copy on username and pw text on PasswordDetail view
* String localization
* UIStateRestoration

Design
------
* Grouping on app name (currently string matching) should be made fuzzier. Possibly make App its own entity.
* Base UI/UX patterns off of Apple TODO's app, which is done quite nicely.

Refactoring
-----------
* Simplify PasswordService
* Modernize KeychainWrapper
* Remove globals from AppDelegate

Bugs
----
* PasswordEditViewController prevents re-auth screen from being shown (likely due to the fact that both are modals)
