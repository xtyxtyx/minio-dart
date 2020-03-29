This is the _unofficial_ MinIO Dart Client SDK that provides simple APIs to access any Amazon S3 compatible object storage server.

## API

| Bucket operations     	| Object operations      	| Presigned operations 	| Bucket Policy & Notification operations 	|
|-----------------------	|------------------------	|----------------------	|-----------------------------------------	|
| `makeBucket`           	| `getObject`            	| presignedUrl         	| getBucketNotification                   	|
| `listBuckets`          	| `getPartialObject`     	| presignedGetObject   	| setBucketNotification                   	|
| `bucketExists`         	| `fGetObject`           	| presignedPutObject   	| removeAllBucketNotification             	|
| `removeBucket`         	| `putObject`            	| presignedPostPolicy  	| getBucketPolicy                         	|
| `listObjects`          	| `fPutObject`           	|                      	| setBucketPolicy                         	|
| `listObjectsV2`        	| `copyObject`           	|                      	| listenBucketNotification                	|
| `listIncompleteUploads`	| `statObject`           	|                      	|                                         	|
|                       	| `removeObject`         	|                      	|                                         	|
|                       	| `removeObjects`        	|                      	|                                         	|
|                       	| `removeIncompleteUpload`|                      	|                                         	|


## Usage

### Initialize MinIO Client

**MinIO**

```dart
import 'package:minio/minio.dart';

final minio = Minio(
  endPoint: 'play.min.io',
  accessKey: 'Q3AM3UQ867SPQQA43P2F',
  secretKey: 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG',
);
```

**AWS S3**

```dart
import 'package:minio/minio.dart';

final minio = Minio(
  endPoint: 's3.amazonaws.com',
  accessKey: 'YOUR-ACCESSKEYID',
  secretKey: 'YOUR-SECRETACCESSKEY',
);
```

For complete example, see: [example]

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

Contributions to this repository are welcomed.

## Lisence

MIT

[tracker]: https://github.com/xtyxtyx/minio-dart/issues
[example]: https://example.com
[link text itself]: http://www.reddit.com