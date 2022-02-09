#  Custom UI - Best Practice App

The Custom UI project demonstrates how to create interfaces and a user experience from scratch, only using the JWPlayerView. The JWPlayerView is nested and managed by a reuseable PlayerViewController, which can be embedded into any view hierarchy using a Container View.

## Feature Overview

This project implements two different interfaces.

### AD Interface

This project uses JW Player VAST advertisements. When using our VAST implementation it is possible to display your own user interface. If you are using Google IMA or Google DAI, this is not possible because those libraries display their own interfaces.

| Feature | Description |
| --- | --- |
| Play/Pause | A button is displayed which allows the user to play or pause the current ad. The button icon changes based on the state of the video. |
| Skip Ad | A button is displayed which allows the user to skip the ad. |
| Learn More | A 'Learn More' button is displayed, and when clicked, takes the user to their web browser to view a site specified in the  advertisement's click-through url. |

### Video Inteface

When viewing the video we display a new, custom interface.

| Feature | Description |
| --- | --- |
| Play/Pause | A button is displayed which allows the user to play or pause the video. The button icon changes based on the state of the video. |
| Progress | A progress bar displays how far into the video you are. |
| Full Screen | When pressed, the full screen button displays the video across the entire screen. When in full screen, the button icon changes to an exit full screen icon. |

## Code Overview

The primary classes and interfaces within this example are defined below.

**PlayerViewController**

The central class for this implementation is PlayerViewController. This UIViewController can be embedded within any view hierarchy programmatically, or as we do in this example, using a Container View in Interface Builder. This class receives all input from the player, JWPlayer, and from the buttons. The responsibility of how to handle input and events is PlayerViewController's responsibility. Views are managed by PlayerViewManager.

**PlayerViewManager**

The PlayerViewManager manages the views. It is instantiated by PlayerViewController, and is responsible for presenting the correct interface, and managing the view hierarchy. This manager is essential for migrating the view hierarchy to other UIViewControllers, such as when the player goes into a full screen presentation. The manager, and views, report button presses to the PlayerViewController.

**FullScreenPlayerViewController**

This UIViewController is responsibile for displaying the player in full screen mode. Because PlayerViewController can be embedded anywhere inside of an application's view hierarchy, displaying the video as full screen must be done with a full screen overlay. When the full screen button is tapped, PlayerViewController instantiates a FullScreenPlayerViewController and covers the screen. This view controller is set to force landscape orientation.

**XibView, AdControlsView, VideoControlsView**

These classes represent our user interfaces. Both AdControlsView and VideoControlsView inherit from XibView. Each is defined in similarly named xib files, and XibView handles the loading of the interfaces automatically. When buttons in these interfaces are tapped, the InterfaceButtonListener (PlayerViewController) is informed of the event.
