import 'package:minio/minio.dart';

void main() async {
  final minio = Minio(
    endPoint: 'play.min.io',
    useSSL: false,
    accessKey: 'Q3AM3UQ867SPQQA43P2F',
    secretKey: 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG',
  );

  print(await minio.bucketExists('00testaaa'));
  print(await minio.getBucketRegion('00testaaa'));
}
