import 'package:minio/minio.dart';

void main() async {
  final minio = Minio(
    endPoint: 'play.min.io',
    accessKey: 'Q3AM3UQ867SPQQA43P2F',
    secretKey: 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG',
    useSSL: true,
    // enableTrace: true,
  );

  // await minio.makeBucket('test00');
  await minio.putObject('test00', 'new folder/a.txt', Stream.value([1, 2, 3]));
  await minio.putObject('test00', 'new folder/b.txt', Stream.value([1, 2, 3]));
  print(await minio.listAllObjects('test00', prefix: 'new folder/'));
}
