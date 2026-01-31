In this article, I will tell you how to develop a simple iOS app can recognize face with high accuracy. I have tested with 70 users.

The ability to recognize of this application is based on a pre-trained [**FaceNe**](https://github.com/davidsandberg/facenet)**t&#xA0;**&#x6D;odel “_has been trained on the&#xA0;_[**VGGFace2**](https://www.robots.ox.ac.uk/~vgg/data/vgg_face2/)_&#xA0;dataset consisting of \~3.3M faces and \~9000 classes_”.

Press enter or click to view image in full size

<img src="https://miro.medium.com/v2/resize:fit:700/1*mWGIxupRFvmB1pXsf-vXEw.png" alt="" width="700" height="758">

But, how to use FaceNet in iOS device is the main problem. Because I’m just a iOS dev and don’t have experience in Machine Learning or Image Processing, I have been struggling with it in a long time.

**In the first time**, I try to train a classification model by Create ML tool, it’s quite easy. Just create two folders for two classes, then drag it to Training Data and start “Train”. Wait and export to \*.mlmodel file. You can read [Apple document](https://developer.apple.com/documentation/vision/training_a_create_ml_model_to_classify_flowers) for tutorial.

The model working well, but when I have more than 3 users, it give me wrong result. Ignore it!

Press enter or click to view image in full size

<img src="https://miro.medium.com/v2/resize:fit:700/1*BIKa6eY9wsgQSn9b5DdzPw.png" alt="" width="700" height="549">

Create ML screenshot

**In the second time**, I try to use [turi create tool](https://github.com/apple/turicreate) by Apple, it is better, I can choose the model architecture. We have 3 pre-trained model. I choosed “resnet-50” for the best result. If you want to try, read [this tutorial.](https://www.appcoda.com/core-ml-model-with-python/) This way, my model give me accurate result with 10 users, not more! So, I ignore it too.

Press enter or click to view image in full size

<img src="https://miro.medium.com/v2/resize:fit:700/1*AmUZYsK2PIcII9kNkkdtnA.png" alt="" width="700" height="260">

Pretrained model list from [turicreate](https://apple.github.io/turicreate/docs/api/generated/turicreate.image_classifier.create.html)

I thought about building a python server, use FaceNet or ArcFace to recognize. Then in my iOS app, I will send image to my server and receive the result. It will give me the best result, but the problem is “**We have to wait for network, surely this application can’t recognize in real-time**”. So, I tried to convert Tensorflow model to Core ML format by [coremltools](https://coremltools.readme.io/docs), and use it in my iOS application. You can download FaceNet with Core ML format [here.](https://drive.google.com/file/d/1wfGI02wY-RKP4-WSyTuOVXf7GcB16fcC/view?usp=sharing)

Input is an Image (Color 160x160), and Output is MultiArray (Double 512), it is an Array with 512 double elements.

Press enter or click to view image in full size

<img src="https://miro.medium.com/v2/resize:fit:700/1*JJ9uGSaoWkZug8wwRigQqw.png" alt="" width="700" height="314">

FaceNet with Core ML format

Import “facenet.mlmodel “ to your project, then create some extensions:

You need to resize input image to 160x160 before convert it into CVPixelBuffer. Simple demo code:

This is output printed, and double array with 512 elements. Our model has converted my face into Double 512 vectors.

Press enter or click to view image in full size

<img src="https://miro.medium.com/v2/resize:fit:700/1*XIhBjjJhZnxkKELwpuz7Ag.png" alt="" width="700" height="283">

output of facenet model

I will use two faces of two people, convert it into two vectors. Keep in mind that the vector I have just generated is face database 😂. Once I have new face image, I will use facenet model and convert it to another vector, then calculate distance of two vectors. This is function to calculate distance:

**The nearest vectors in database is the result of prediction.**

**But in the final way, I used FaceNet directly in my application.&#xA0;**&#x55;sing “[_TensorFlow Experimental_](https://cocoapods.org/pods/TensorFlow-experimental)” on CocoaPods. If you haven’t used CoacoaPods yet, you should read [this](https://guides.cocoapods.org/using/getting-started.html).

Installation:

```javascript
pod 'TensorFlow-experimental'
```

## **1. What is FaceNet?**

_“This is a TensorFlow implementation of the face recognizer described in the paper&#xA0;_[_“FaceNet: A Unified Embedding for Face Recognition and Clustering”_](http://arxiv.org/abs/1503.03832)_. The project also uses ideas from the paper&#xA0;_[_“Deep Face Recognition”_](http://www.robots.ox.ac.uk/~vgg/publications/2015/Parkhi15/parkhi15.pdf)_&#xA0;from the&#xA0;_[_Visual Geometry Group_](http://www.robots.ox.ac.uk/~vgg/)_&#xA0;at Oxford.”_

In short, this is and *embedding model*, all the important information from an image is **\*embedded\*\*\*** \*\*into vector. Basically, FaceNet takes a person’s face and compresses it into a vector of 128 numbers.

**Ideally, embeddings of similar faces are \*\*\***&#x61;lso\*\*\*\*\* similar.\*\*

Press enter or click to view image in full size

<img src="https://miro.medium.com/v2/resize:fit:700/1*BuLCaciEx6GHz2E2C_t5Bg.png" alt="" width="700" height="323">

how facenet model work

This is my vector struct:

## 2. How the application work?

### 2.1. How to use FaceNet in our iOS app?

I have been struggling with “how to use TensorFlow in iOS”. I read “[FaceNet on Mobile](https://medium.com/analytics-vidhya/facenet-on-mobile-cb6aebe38505)”, try to convert FaceNet (.pb) into FaceNet (.tflite). It is crossing the ocean time.

When I found [this project](https://github.com/IDLabs-Gate/enVision/tree/master/enVision) from GitHub, it is much easier to use FaceNet (.pb) in my project. You can download the most important files [here](https://drive.google.com/drive/folders/12ynSY4Tlo8krk_i-IZjp8Ktu7Ju9BraW?usp=sharing). He created *bridging header* and import Objective-C into Swift. Read [this document](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift) for tutorial.

I think you should download my file, it is much faster. Suppose you have done with using FaceNet in your application. Take a look in this file, you should know how can you do with it:

### 2.2. Get face data

Press enter or click to view image in full size

<img src="https://miro.medium.com/v2/resize:fit:700/1*LNyETSfP9vwpN5MLH4uU6A.png" alt="" width="700" height="758">

Add user screenshot

I will record a 5 seconds video, extract to 50 pictures (5 pictures/1 seconds). Using FaceNet to generate 50 vectors from those pictures. Save vectors in database or anything else, you need to use it for prediction.

### 2.3. How to recognize?

Suppose you have add 10 users, now you have 10 x 50 = 500 vectors in your database. Create a ViewController can handle frame from camera:

**And, the main function here:**

Look at this line:

```javascript
let res = vectorHelper.getResult(image: frame)
```

It is the most important line, this is getResult function, it will return *nearest vector in database.&#xA0;*&#x49; think it is not difficult to understand what I’m writing, calculate distance, and find minimum distance. I used distance property for “Accurate value” and “Distance to another vector”, just a bit ambiguous 😂😂

Now, you have name of face in the current frame, let’s draw it in frame 😌 . See this line in FrameViewController.swift file:

```javascript
guard let results = request.results as? [VNFaceObservation] else { return }self.previewView.removeMask()let lb = self.getLabel(image: self.currentFrame)for face in results {self.previewView.drawFaceboundingBox(face: face, label: lb)}
```

previewView is a UIView, it is where we show the output of camera frame. “face” is VNFaceObservation, in short, I will get bounding box of the face from that value. Read more about VNFaceObservation [here](https://developer.apple.com/documentation/vision/vnfaceobservation) and Apple Vision Framework [here](https://developer.apple.com/documentation/vision/tracking_the_user_s_face_in_real_time). This is PreviewView:

Anything important has done. You should know how to do more. Otherwise, feel free to clone [**my project**](https://github.com/hosituanit/clockon-clockoff-face-recognition)**&#xA0;**&#x61;nd modify it. I done a lot of thing in it (speak current name, send “time log” to server, etc,…” Don’t forget give me a star 😅😅😅.

Press enter or click to view image in full size

<img src="https://miro.medium.com/v2/resize:fit:700/1*ueRja7Jxsd65AhTru_9AtQ.png" alt="" width="700" height="758">

screenshot of Log time and Predict Image

I use Firebase realtime database. This is my database structure:

Press enter or click to view image in full size

<img src="https://miro.medium.com/v2/resize:fit:700/1*lr5wXnw7uupd1KgP-Fo2ww.png" alt="" width="700" height="371">

firebase database structure

Example, you have 100 users, so you have 50 x 100 = 5000 vectors. How to find the nearest vector in the short time? *For loop is not the best solution, you should read more about&#xA0;*[**k-Means Clustering**](https://github.com/raywenderlich/swift-algorithm-club/tree/master/K-Means)**,&#xA0;**[**k-d Tree**](https://en.wikipedia.org/wiki/K-d_tree)**&#xA0;or&#xA0;**[**kNN**](https://github.com/mmahler2/Swift-DTW-KNN)**.&#xA0;**&#x49; have tested with 70 users, and get result in 0.12 seconds. So, my application reach around 8 fps.

Thanks for your time. If my story help you, don’t forget give me a clap ❤️❤️
