# AsyncSocketDemo
ios长连接的一个demo
IOS应用的长连接如果保证效率的话，一般在应用内使用自己的socket长连接，在退出应用或者应用切换到后台之后使用苹果的推送来通知，这样就保证了在软件使用过程中，如果苹果服务器出问题不至于影响软件使用的情况。

这个demo使用了一个第三方库：CocoaAsyncSocket，通过这个库来实现长连接


demo详细说明可参考这个文章《[IOS开发之SOCKET长连接的使用](http://www.hudongdong.com/ios/351.html)》
