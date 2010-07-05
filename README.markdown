RBSplitView by [Rainer Brockerhoff][1]
======================================

[RBSplitView][2] is a replacement for Cocoa’s NSSplitView. There are some serious limitations with NSSplitView if you need to limit subview’s sizes, expand or collapse subviews programmatically or by double-clicking, or resize the split view frequently.

RBSplitView has special content views - RBSplitSubviews - that handle details of subview limitations and properties. So there’s less or no work to be done by the delegate. RBSplitView also has built-in support for nesting any number of levels, and automatically generates a two-axis thumb to resize in two dimensions.

This latest release of RBSplitView is compatible with Leopard and Snow Leopard, runs on 32-bit or 64-bit, and supports optional garbage-collection.

The version in this repository includes the basic RBSplitView and RBSplitSubview classes, an Interface Builder plug-in, full source code with Xcode project (for version 3.1), full documentation, and a sample application showing most features. If you’re still on Tiger, you should stay with the previous RBSplitView 1.1.4, which is the initial commit in this repository. 

Simplified build settings
-------------------------

Jan has changed the build settings to be more simple and developer friendly. The new settings are designed to mimic the integration of the Interface Builder plug-in of [BGHUDAppKit][4]. As your users don’t need the IB plug-in you can do the following, as adapted from BGHUDAppKit’s documentation:

Shrinking
---------

RBSplitView is approx. 1.0 Mb in size. The extra disk space is taken up by the RBSplitView.ibplugin. This really doesn’t need to be in your distributed app, the framework will function normally without it. Do NOT delete RBSplitView.ibplugin from your source RBSplitView.framework.

The reason the framework is build this way is because IB will automatically look in a linked framework for a plugin. A way to shrink your final APP size is really simple. Create a new “Run Script” build phase and copy the following line to it.

    rm -fR "${CONFIGURATION_BUILD_DIR}/${WRAPPER_NAME}/Contents/Frameworks/RBSplitView.framework/Versions/Current/Resources/RBSplitView.ibplugin"

What happens is this: When you build, Xcode will look in your final .app folder and	remove the unneeded RBSplitView.ibplugin. This shrinks RBSplitView.framework down by approx. 200k. 

Important
---------

The previous beta version of the RBSplitView plug-in for Interface Builder had a misspelling in its bundle ID ("RBsplitView" instead of "RBSplitView"), causing nib files built by it to be incompatible with the newer plug-in (where the misspelling was fixed). You can either hand-edit the files inside the nib/xib to fix this, or use the [RBSplitViewFixer droplet application][3].
 
Just download it and drop your .lproj folders onto the application’s icon; source code is included.

  [1]: http://www.brockerhoff.net/
  [2]: http://brockerhoff.net/src/rbs.html
  [3]: http://brockerhoff.net/src/RBSplitViewFixer.zip
  [4]: http://www.binarymethod.com/bghudappkit/
  