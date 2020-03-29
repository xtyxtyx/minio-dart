import 'dart:io';

import 'package:minio/minio.dart';
import 'package:minio/models.dart';

void main() async {
  final minio = Minio(
    endPoint: 'play.min.io',
    accessKey: 'Q3AM3UQ867SPQQA43P2F',
    secretKey: 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG',
    useSSL: false,
    enableTrace: true,
  );

  final bucket = '00test';
  final object = 'teaweb.png';
  final copy1 = '$object.copy';
  final copy2 = '$object.copy2';

  if (!await minio.bucketExists(bucket)) {
    await minio.makeBucket(bucket);
    print('bucket $bucket created');
  } else {
    print('bucket $bucket already exists');
  }

  // print(await minio.bucketExists('02test'));
  // await minio.makeBucket('00test');
  // await minio.removeBucket('05test');
  // print(await minio.getBucketRegion('00test'));
  // print(await minio.getBucketRegion('00test'));
  // print((await minio.listBuckets()).map((e) => e.name));
  // print(await minio.listObjectsQuery('00test', '/', null, '', null));

  // await minio.listObjects('0inst').forEach((chunk) {
  //   print(chunk.objects.join('\n'));
  //   print(chunk.prefixes.join('\n'));
  // });

  // await minio.listObjects('0inst', recursive: true).forEach((o) => print(o.key));

  // final object = await minio.getObject('00test', 'sys8_captcha.png');
  // await File('sys8_captcha.png').openWrite().addStream(object);

  final file = File('example/$object');
  final size = await file.length();
  final etag = await minio.putObject(bucket, object, file.openRead(), size);
  print('---');
  print('etag:');
  print(etag);

  final copyResult1 = await minio.copyObject(bucket, copy1, '$bucket/$object');
  final copyResult2 = await minio.copyObject(bucket, copy2, '$bucket/$object');
  print('---');
  print('Copy1 etag:');
  print(copyResult1.eTag);
  print('---');
  print('Copy2 etag:');
  print(copyResult2.eTag);

  final stat = await minio.statObject(bucket, object);
  print('Stat:');
  print(stat.etag);
  print(stat.size);
  print(stat.lastModified);
  print(stat.metaData);

  await minio.removeObject(bucket, object);
  print('---');
  print('Removed');

  await minio.removeObjects(bucket, [copy1, copy2]);
  print('---');
  print('Copy removed');
}
