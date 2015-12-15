# ISAudioRecorder
AVAudioRecord&amp;AVAudioPlayer Controller

### Any issues, bugs and improvments reported are highly appreciated

![Screenshot0][img0] &nbsp;&nbsp; ![Screenshot1][img1] &nbsp;&nbsp; 

## Getting Started

####### Swift 
[create new objc header](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) and add:

````objective-c
#import "ISHeader.h"   // import all the Dependencies
````
####### Objc

````objective-c
#import "ISHeader.h"   // import all the Dependencies
````

####### Swift 

and then its simple use, just create an instance:

````Swift
let rvc = ISAudioRecorderViewController()
````

then just call 

````Swift
rvc.prepareViewForLoading(self)
````

if you want delegate add:

````Swift
class YourViewController: UIViewController,ISAudioRecorderViewDelegate
````

then :

````Swift
rvc.recorderDelegate = self
````

and implement :

````Swift
func ISAudioRecorderViewWillDismiss(fileName: String, audioDuration: Int)
````

its saves all the audio to App Documents so to get the audio by file name use:

````Swift
let docDir = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
let url = docDir.URLByAppendingPathComponent(fileName)
````

#Update:

###### added comments and new access controlls

##### example at the end of this update 

* *delegate that pass the data to parent controller.*
````Swift
var recorderDelegate:ISAudioRecorderViewDelegate?
````

* *blure effect style (ExtraLight,light,Dark) - default is Dark.*
````Swift
var blurEffectType:UIBlurEffectStyle?
````
    
    
* *left UIBarButtonItem Label title - default is Cancel.*
````Swift
var leftToolBarLabelText:String?
````
    
* *right UIBarButtonItem Label title - default is Send.*
````Swift
var rightToolBarLabelText:String?
````
    
* *title for recorded file that adds this title to the name of the file, (record_title_NSDate().m4a) - default is (record_NSDate().m4a)*
````Swift
var soundFileTitle:String?
````

* *recorder limit time - default is 30 secend (00:30).*
````Swift
var recorderLimitTime:Double?
````

* *the tool bar color you desire - default is darkGrayColor.*
````Swift
var toolBarTintColor:UIColor?
````
    
* *the tool bar color you desire - default is whiteColor.*
````Swift
var timeLimitLabelColor:UIColor?
````
    
* *the inner line color of the circle line*
````Swift
var innerCircleColor:UIColor?
````

###### Example:
````Swift
rvc.blurEffectType = UIBlurEffectStyle.Dark
````

# Thanks & Dependencies:

Thanks To [Stefan Ceriu](https://github.com/stefanceriu) for:

[SCSiriWaveformView](https://github.com/stefanceriu/SCSiriWaveformView)


Thanks to [Carlos Eduardo Arantes Ferreira](https://github.com/carantes) for: 

[Cricle Progress Controll View](https://github.com/carantes/CircularProgressControl)

## License

`ISAudioRecorderController` is released under an [MIT License](http://opensource.org/licenses/MIT). See `LICENSE` for details.

>**Copyright &copy; 2015-present Igor Sokolovsky.**

*Please provide attribution, it is greatly appreciated.*


[img0]:https://raw.githubusercontent.com/MurLuck/ISAudioRecorder/ISAudioRecorder/IMG_0212.jpg
[img1]:https://raw.githubusercontent.com/MurLuck/ISAudioRecorder/ISAudioRecorder/IMG_0215.jpg
