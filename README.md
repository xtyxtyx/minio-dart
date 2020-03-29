A library for Dart developers.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## API

| Bucket operations     	| Object operations      	| Presigned operations 	| Bucket Policy & Notification operations 	|
|-----------------------	|------------------------	|----------------------	|-----------------------------------------	|
| `makeBucket`           	| `getObject`            	| presignedUrl         	| getBucketNotification                   	|
| `listBuckets`          	| `getPartialObject`     	| presignedGetObject   	| setBucketNotification                   	|
| `bucketExists`         	| fGetObject             	| presignedPutObject   	| removeAllBucketNotification             	|
| `removeBucket`         	| `putObject`            	| presignedPostPolicy  	| getBucketPolicy                         	|
| `listObjects`          	| fPutObject             	|                      	| setBucketPolicy                         	|
| `listObjectsV2`        	| `copyObject`           	|                      	| listenBucketNotification                	|
| `listIncompleteUploads`	| `statObject`           	|                      	|                                         	|
|                       	| `removeObject`         	|                      	|                                         	|
|                       	| `removeObjects`        	|                      	|                                         	|
|                       	| removeIncompleteUpload 	|                      	|                                         	|

## Usage

A simple usage example:

```dart
import 'package:minio/minio.dart';

main() {
  var awesome = new Awesome();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
