# ISAudioRecorder
AVAudioRecord&amp;AVAudioPlayer Controller

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

# Thanks & Dependencies:

Thanks To [Stefan Ceriu](https://github.com/stefanceriu) for:

[SCSiriWaveformView](https://github.com/stefanceriu/SCSiriWaveformView)


Thanks to [Carlos Eduardo Arantes Ferreira](https://github.com/carantes) for: 

[Cricle Progress Controll View](https://github.com/carantes/CircularProgressControl)

## License

`ISAudioRecorderController` is released under an [MIT License](http://opensource.org/licenses/MIT). See `LICENSE` for details.

>**Copyright &copy; 2015-present Igor Sokolovsky.**

*Please provide attribution, it is greatly appreciated.*
