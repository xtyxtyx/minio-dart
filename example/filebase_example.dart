import 'package:minio/minio.dart';

void main() async {
  final minio = Minio(
    endPoint: 's3.filebase.com',
    accessKey: '<YOUR_ACCESS_KEY>',
    secretKey: '<YOUR_SECRET_KEY>',
    useSSL: true,
  );

  final buckets = await minio.listBuckets();
  print('buckets: $buckets');

  final objects = await minio.listObjects(buckets.first.name).toList();
  print('objects: $objects');
}
