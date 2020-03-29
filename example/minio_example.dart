import 'dart:io';

import 'package:minio/minio.dart';

void main() async {
  final minio = Minio(
    endPoint: 'play.min.io',
    accessKey: 'Q3AM3UQ867SPQQA43P2F',
    secretKey: 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG',
    useSSL: false,
    // enableTrace: true,
  );

  final bucket = '00test';
  final object = 'teaweb.png';
  final copy1 = '$object.copy1';
  final copy2 = '$object.copy2';

  if (!await minio.bucketExists(bucket)) {
    await minio.makeBucket(bucket);
    print('bucket $bucket created');
  } else {
    print('bucket $bucket already exists');
  }

  final region = await minio.getBucketRegion('00test');
  print('--- object region:');
  print(region);

  final file = File('example/$object');
  final size = await file.length();
  final etag = await minio.putObject(bucket, object, file.openRead(), size);
  print('--- etag:');
  print(etag);

  final copyResult1 = await minio.copyObject(bucket, copy1, '$bucket/$object');
  final copyResult2 = await minio.copyObject(bucket, copy2, '$bucket/$object');
  print('--- copy1 etag:');
  print(copyResult1.eTag);
  print('--- copy2 etag:');
  print(copyResult2.eTag);

  await minio.listObjects(bucket).forEach((chunk) {
    print('--- objects:');
    chunk.objects.forEach((o) => print(o.key));
  });

  await minio.listObjectsV2(bucket).forEach((chunk) {
    print('--- objects(v2):');
    chunk.objects.forEach((o) => print(o.key));
  });

  final stat = await minio.statObject(bucket, object);
  print('--- object stat:');
  print(stat.etag);
  print(stat.size);
  print(stat.lastModified);
  print(stat.metaData);

  await minio.removeObject(bucket, object);
  print('--- object removed');

  await minio.removeObjects(bucket, [copy1, copy2]);
  print('--- copy1, copy2 removed');

  await minio.removeBucket(bucket);
  print('--- bucket removed');
}
