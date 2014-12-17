Questor!
=============================

The CS 263 project for Chad Simmons

* Uses GAE datastore to hold quest and users. 
* Uses the memcache service to cache search results. 
* Uses push queues to expire quests and manage avatar updates
* Uses blobstore for user avatars
* Quest creation/searching/accepting/completing is implemented with a REST JSON API (POST/GET/PUT)
* Project is built and deployed with maven
* All java classes are fully documented via JavaDoc

The running application can be seen on google app engine [here](http://http://stunning-shadow-733.appspot.com)

Selenium tests are included in the github project [here](https://github.com/polpak/cs263-project/tree/master/selenium-tests), and can be run using the Selenium IDE.

Video demo is [here](https://vimeo.com/114751036)
