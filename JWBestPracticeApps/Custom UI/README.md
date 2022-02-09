#  Custom UI - Best Practice App
The Custom UI project demonstrates how to create interfaces and a user experience from scratch, only using the JWPlayerView. The JWPlayerView is nested and managed by a reuseable PlayerViewController, which can be embedded into any view hierarchy using a Container View.

## Feature Overview
This project implements two different interfaces.

### AD Interface
This project uses JW Player VAST advertisements. When using our VAST implementation it is possible to display your own user interface. If you are using Google IMA or Google DAI, this is not possible because those libraries display their own interfaces.

*Features:* 
| Play/Pause | A button is displayed which allows the user to play or pause the current ad. The button icon changes based on the state of the video. |
| Skip Ad | A button is displayed which allows the user to skip the ad. |
| Learn More | A 'Learn More' button is displayed, and when clicked, takes the user to their web browser to view a site specified in the  advertisement's click-through url. |

### Video Inteface
When viewing the video we display a new, custom interface.

*Features:* 
| Play/Pause | A button is displayed which allows the user to play or pause the video. The button icon changes based on the state of the video. |
| Progress | A progress bar displays how far into the video you are. |
| Full Screen | When pressed, the full screen button displays the video across the entire screen. When in full screen, the button icon changes to an exit full screen icon. |

## Code Overview
