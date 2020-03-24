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

  // print(await minio.bucketExists('02test'));
  // await minio.makeBucket('05test');
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
}
