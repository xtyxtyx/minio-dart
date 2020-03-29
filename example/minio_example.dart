import 'dart:io';

import 'package:minio/minio.dart';
import 'package:minio/models.dart';

void main() async {
  final minio = Minio(
    endPoint: 'play.min.io',
    useSSL: false,
    accessKey: 'Q3AM3UQ867SPQQA43P2F',
    secretKey: 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG',
  );

  final bucket = '00test';
  final object = 'teaweb.png';

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
  print(etag);

  final copyResult = await minio.copyObject(
    bucket,
    '$object.copy',
    '$bucket/$object',
  );
  print(copyResult.eTag);

  final stat = await minio.statObject(bucket, object);
  print('Stat:');
  print(stat.etag);
  print(stat.size);
  print(stat.lastModified);
  print(stat.metaData);
}
