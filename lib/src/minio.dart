import 'dart:convert';

import 'package:http/http.dart';
import 'package:minio/models.dart';
import 'package:minio/src/minio_client.dart';
import 'package:minio/src/minio_errors.dart';
import 'package:minio/src/minio_helpers.dart';
import 'package:minio/src/minio_poller.dart';
import 'package:minio/src/minio_sign.dart';
import 'package:minio/src/minio_uploader.dart';
import 'package:minio/src/utils.dart';
import 'package:xml/xml.dart' as xml;

import '../models.dart';
import 'minio_helpers.dart';

class Minio {
  /// Initializes a new client object.
  Minio({
    this.endPoint,
    this.port,
    this.useSSL = true,
    this.accessKey = '',
    this.secretKey = '',
    this.sessionToken,
    this.region,
    this.enableTrace = false,
  })  : assert(isValidEndpoint(endPoint)),
        assert(port == null || isValidPort(port)),
        assert(useSSL != null),
        assert(accessKey != null),
        assert(secretKey != null) {
    _client = MinioClient(this);
  }

  /// default part size for multipart uploads.
  final partSize = 64 * 1024 * 1024;

  /// maximum part size for multipart uploads.
  final maximumPartSize = 5 * 1024 * 1024 * 1024;

  /// maximum object size (5TB)
  final maxObjectSize = 5 * 1024 * 1024 * 1024 * 1024;

  /// endPoint is a host name or an IP address.
  final String endPoint;

  /// TCP/IP port number. This input is optional. Default value set to 80 for HTTP and 443 for HTTPs.
  final int port;

  /// If set to true, https is used instead of http. Default is true.
  final bool useSSL;

  /// accessKey is like user-id that uniquely identifies your account.
  final String accessKey;

  /// secretKey is the password to your account.
  final String secretKey;

  /// Set this value to provide x-amz-security-token (AWS S3 specific). (Optional)
  final String sessionToken;

  /// Set this value to override region cache. (Optional)
  final String region;

  /// Set this value to enable tracing. (Optional)
  final bool enableTrace;

  MinioClient _client;
  final _regionMap = <String, String>{};

  /// Checks if a bucket exists.
  ///
  /// Returns `true` only if the [bucket] exists and you have the permission
  /// to access it. Returns `false` if the [bucket] does not exist or you
  /// don't have the permission to access it.
  Future<bool> bucketExists(String bucket) async {
    MinioInvalidBucketNameError.check(bucket);
    try {
      final response = await _client.request(method: 'HEAD', bucket: bucket);
      validate(response);
      return response.statusCode == 200;
    } on MinioS3Error catch (e) {
      final code = e.error.code;
      if (code == 'NoSuchBucket' || code == 'NotFound' || code == 'Not Found') {
        return false;
      }
      rethrow;
    } on StateError catch (e) {
      // Insight from testing: in most cases, AWS S3 returns the HTTP status code
      // 404 when a bucket does not exist. Whereas in other cases, when the bucket
      // does not exist, S3 returns the HTTP status code 301 Redirect instead of
      // status code 404 as officially documented. Then, this redirect response
      // lacks the HTTP header `location` which causes this exception in Dart's
      // HTTP library (`http_impl.dart`).
      if (e.message == 'Response has no Location header for redirect') {
        return false;
      }
      rethrow;
    }
  }

  int _calculatePartSize(int size) {
    assert(size != null && size >= 0);

    if (size > maxObjectSize) {
      throw ArgumentError('size should not be more than $maxObjectSize');
    }

    if (this.partSize != null) {
      return this.partSize;
    }

    var partSize = this.partSize;
    while (true) {
      if ((partSize * 10000) > size) {
        return partSize;
      }
      partSize += 16 * 1024 * 1024;
    }
  }

  /// Complete the multipart upload. After all the parts are uploaded issuing
  /// this call will aggregate the parts on the server into a single object.
  Future<String> completeMultipartUpload(
    String bucket,
    String object,
    String uploadId,
    List<CompletedPart> parts,
  ) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    assert(uploadId != null);
    assert(parts != null);

    var queries = {'uploadId': uploadId};
    var payload = CompleteMultipartUpload(parts).toXml().toString();

    final resp = await _client.request(
      method: 'POST',
      bucket: bucket,
      object: object,
      queries: queries,
      payload: payload,
    );
    validate(resp, expect: 200);

    final node = xml.XmlDocument.parse(resp.body);
    final errorNode = node.findAllElements('Error');
    if (errorNode.isNotEmpty) {
      final error = Error.fromXml(errorNode.first);
      throw MinioS3Error(error.message, error, resp);
    }

    final etag = node.findAllElements('ETag').first.text;
    return etag;
  }

  /// Copy the object.
  Future<CopyObjectResult> copyObject(
    String bucket,
    String object,
    String srcObject, [
    CopyConditions conditions,
  ]) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);
    MinioInvalidObjectNameError.check(srcObject);

    final headers = <String, String>{};
    headers['x-amz-copy-source'] = srcObject;

    if (conditions != null) {
      if (conditions.modified != null) {
        headers['x-amz-copy-source-if-modified-since'] = conditions.modified;
      }
      if (conditions.unmodified != null) {
        headers['x-amz-copy-source-if-unmodified-since'] =
            conditions.unmodified;
      }
      if (conditions.matchETag != null) {
        headers['x-amz-copy-source-if-match'] = conditions.matchETag;
      }
      if (conditions.matchETagExcept != null) {
        headers['x-amz-copy-source-if-none-match'] = conditions.matchETagExcept;
      }
    }

    final resp = await _client.request(
      method: 'PUT',
      bucket: bucket,
      object: object,
      headers: headers,
    );

    validate(resp);

    final node = xml.XmlDocument.parse(resp.body);
    final result = CopyObjectResult.fromXml(node.rootElement);
    result.eTag = trimDoubleQuote(result.eTag);
    return result;
  }

  /// Find uploadId of an incomplete upload.
  Future<String> findUploadId(String bucket, String object) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    MultipartUpload latestUpload;
    String keyMarker;
    String uploadIdMarker;
    var isTruncated = false;

    do {
      final result = await listIncompleteUploadsQuery(
        bucket,
        object,
        keyMarker,
        uploadIdMarker,
        '',
      );
      for (var upload in result.uploads) {
        if (upload.key != object) continue;
        if (latestUpload == null ||
            upload.initiated.isAfter(latestUpload.initiated)) {
          latestUpload = upload;
        }
      }
      keyMarker = result.nextKeyMarker;
      uploadIdMarker = result.nextUploadIdMarker;
      isTruncated = result.isTruncated;
    } while (isTruncated);

    return latestUpload?.uploadId;
  }

  /// Return the list of notification configurations stored
  /// in the S3 provider
  Future<NotificationConfiguration> getBucketNotification(String bucket) async {
    MinioInvalidBucketNameError.check(bucket);

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      resource: 'notification',
    );

    validate(resp, expect: 200);

    final node = xml.XmlDocument.parse(resp.body);
    return NotificationConfiguration.fromXml(node.rootElement);
  }

  /// Get the bucket policy associated with the specified bucket. If `objectPrefix`
  /// is not empty, the bucket policy will be filtered based on object permissions
  /// as well.
  Future<Map<String, dynamic>> getBucketPolicy(bucket) async {
    MinioInvalidBucketNameError.check(bucket);

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      resource: 'policy',
    );

    validate(resp, expect: 200);

    return json.decode(resp.body);
  }

  /// gets the region of the bucket
  Future<String> getBucketRegion(String bucket) async {
    MinioInvalidBucketNameError.check(bucket);

    if (region != null) return region;
    if (_regionMap.containsKey(bucket)) return _regionMap[bucket];

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      region: 'us-east-1',
      queries: <String, dynamic>{'location': null},
    );

    validate(resp);

    final node = xml.XmlDocument.parse(resp.body);

    var location = node.findAllElements('LocationConstraint').first.text;
    if (location == null || location.isEmpty) {
      location = 'us-east-1';
    }

    _regionMap[bucket] = location;
    return location;
  }

  /// get a readable stream of the object content.
  Future<ByteStream> getObject(String bucket, String object) {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);
    return getPartialObject(bucket, object, null, null);
  }

  /// get a readable stream of the partial object content.
  Future<ByteStream> getPartialObject(
    String bucket,
    String object, [
    int offset,
    int length,
  ]) async {
    assert(offset == null || offset >= 0);
    assert(length == null || length > 0);

    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    String range;
    if (offset != null || length != null) {
      if (offset != null) {
        range = 'bytes=$offset-';
      } else {
        range = 'bytes=0-';
        offset = 0;
      }
      if (length != null) {
        range += '${(length + offset) - 1}';
      }
    }

    final headers = range != null ? {'range': range} : null;
    final expectedStatus = range != null ? 206 : 200;

    final resp = await _client.requestStream(
      method: 'GET',
      bucket: bucket,
      object: object,
      headers: headers,
    );

    await validateStreamed(resp, expect: expectedStatus);
    return resp.stream;
  }

  /// Initiate a new multipart upload.
  Future<String> initiateNewMultipartUpload(
    String bucket,
    String object,
    Map<String, String> metaData,
  ) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    final resp = await _client.request(
      method: 'POST',
      bucket: bucket,
      object: object,
      headers: metaData,
      resource: 'uploads',
    );

    validate(resp, expect: 200);

    final node = xml.XmlDocument.parse(resp.body);
    return node.findAllElements('UploadId').first.text;
  }

  /// Returns a stream that emits objects that are partially uploaded.
  Stream<IncompleteUpload> listIncompleteUploads(
    String bucket,
    String prefix, [
    bool recursive = false,
  ]) async* {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidPrefixError.check(prefix);

    final delimiter = recursive ? '' : '/';

    String keyMarker;
    String uploadIdMarker;
    var isTruncated = false;

    do {
      final result = await listIncompleteUploadsQuery(
        bucket,
        prefix,
        keyMarker,
        uploadIdMarker,
        delimiter,
      );
      for (var upload in result.uploads) {
        final parts = await listParts(bucket, upload.key, upload.uploadId);
        final size = await parts.fold(0, (acc, item) => acc + item.size);
        yield IncompleteUpload(upload: upload, size: size);
      }
      keyMarker = result.nextKeyMarker;
      uploadIdMarker = result.nextUploadIdMarker;
      isTruncated = result.isTruncated;
    } while (isTruncated);
  }

  /// Called by listIncompleteUploads to fetch a batch of incomplete uploads.
  Future<ListMultipartUploadsOutput> listIncompleteUploadsQuery(
    String bucket,
    String prefix,
    String keyMarker,
    String uploadIdMarker,
    String delimiter,
  ) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidPrefixError.check(prefix);

    var queries = <String, dynamic>{
      'uploads': null,
      'prefix': prefix,
      'delimiter': delimiter,
    };

    if (keyMarker != null) {
      queries['key-marker'] = keyMarker;
    }
    if (uploadIdMarker != null) {
      queries['upload-id-marker'] = uploadIdMarker;
    }

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      resource: 'uploads',
      queries: queries,
    );

    validate(resp);

    final node = xml.XmlDocument.parse(resp.body);
    return ListMultipartUploadsOutput.fromXml(node.root);
  }

  /// Listen for notifications on a bucket. Additionally one can provider
  /// filters for prefix, suffix and events. There is no prior set bucket notification
  /// needed to use this API. **This is an MinIO extension API** where unique identifiers
  /// are regitered and unregistered by the server automatically based on incoming requests.
  NotificationPoller listenBucketNotification(
    String bucket, {
    String prefix,
    String suffix,
    List<String> events,
  }) {
    MinioInvalidBucketNameError.check(bucket);

    final listener =
        NotificationPoller(_client, bucket, prefix, suffix, events);
    listener.start();

    return listener;
  }

  /// List of buckets created.
  Future<List<Bucket>> listBuckets() async {
    final resp = await _client.request(
      method: 'GET',
      region: region ?? 'us-east-1',
    );
    validate(resp);
    final bucketsNode =
        xml.XmlDocument.parse(resp.body).findAllElements('Buckets').first;
    return bucketsNode.children.map((n) => Bucket.fromXml(n)).toList();
  }

  /// Returns all [Object]s in a bucket.
  /// If recursive is true, the returned stream may also contains [CommonPrefix]
  Stream<ListObjectsChunk> listObjects(
    String bucket, {
    String prefix = '',
    bool recursive = false,
  }) async* {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidPrefixError.check(prefix);
    final delimiter = recursive ? '' : '/';

    String marker;
    var isTruncated = false;

    do {
      final resp = await listObjectsQuery(
        bucket,
        prefix,
        marker,
        delimiter,
        1000,
      );
      isTruncated = resp.isTruncated;
      marker = resp.nextMarker;
      yield ListObjectsChunk()
        ..objects = resp.contents
        ..prefixes = resp.commonPrefixes.map((e) => e.prefix).toList();
    } while (isTruncated);
  }

  /// list a batch of objects
  Future<ListObjectsOutput> listObjectsQuery(
    String bucket,
    String prefix,
    String marker,
    String delimiter,
    int maxKeys,
  ) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidPrefixError.check(prefix);

    final queries = <String, dynamic>{};
    queries['prefix'] = prefix;
    queries['delimiter'] = delimiter;

    if (marker != null) {
      queries['marker'] = marker;
    }

    if (maxKeys != null) {
      maxKeys = maxKeys >= 1000 ? 1000 : maxKeys;
      queries['maxKeys'] = maxKeys.toString();
    }

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      queries: queries,
    );

    validate(resp);

    final node = xml.XmlDocument.parse(resp.body);
    final isTruncated = getNodeProp(node.rootElement, 'IsTruncated')?.text;
    final nextMarker = getNodeProp(node.rootElement, 'NextMarker')?.text;
    final objs = node.findAllElements('Contents').map((c) => Object.fromXml(c));
    final prefixes = node
        .findAllElements('CommonPrefixes')
        .map((c) => CommonPrefix.fromXml(c));

    return ListObjectsOutput()
      ..contents = objs.toList()
      ..commonPrefixes = prefixes.toList()
      ..isTruncated = isTruncated.toLowerCase() == 'true'
      ..nextMarker = nextMarker;
  }

  /// Returns all [Object]s in a bucket.
  /// If recursive is true, the returned stream may also contains [CommonPrefix]
  Stream<ListObjectsChunk> listObjectsV2(
    String bucket, {
    String prefix = '',
    bool recursive = false,
    String startAfter,
  }) async* {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidPrefixError.check(prefix);
    final delimiter = recursive ? '' : '/';

    var isTruncated = false;
    String continuationToken;

    do {
      final resp = await listObjectsV2Query(
        bucket,
        prefix,
        continuationToken,
        delimiter,
        1000,
        startAfter,
      );
      isTruncated = resp.isTruncated;
      continuationToken = resp.nextContinuationToken;
      yield ListObjectsChunk()
        ..objects = resp.contents
        ..prefixes = resp.commonPrefixes.map((e) => e.prefix).toList();
    } while (isTruncated);
  }

  /// listObjectsV2Query - (List Objects V2) - List some or all (up to 1000) of the objects in a bucket.
  Future<ListObjectsV2Output> listObjectsV2Query(
    String bucket,
    String prefix,
    String continuationToken,
    String delimiter,
    int maxKeys,
    String startAfter,
  ) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidPrefixError.check(prefix);

    final queries = <String, dynamic>{};
    queries['prefix'] = prefix;
    queries['delimiter'] = delimiter;
    queries['list-type'] = '2';

    if (continuationToken != null) {
      queries['continuation-token'] = continuationToken;
    }

    if (startAfter != null) {
      queries['start-after'] = startAfter;
    }

    if (maxKeys != null) {
      maxKeys = maxKeys >= 1000 ? 1000 : maxKeys;
      queries['maxKeys'] = maxKeys.toString();
    }

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      queries: queries,
    );

    validate(resp);

    final node = xml.XmlDocument.parse(resp.body);
    final isTruncated = getNodeProp(node.rootElement, 'IsTruncated')?.text;
    final nextContinuationToken =
        getNodeProp(node.rootElement, 'NextContinuationToken')?.text;
    final objs = node.findAllElements('Contents').map((c) => Object.fromXml(c));
    final prefixes = node
        .findAllElements('CommonPrefixes')
        .map((c) => CommonPrefix.fromXml(c));

    return ListObjectsV2Output()
      ..contents = objs.toList()
      ..commonPrefixes = prefixes.toList()
      ..isTruncated = isTruncated.toLowerCase() == 'true'
      ..nextContinuationToken = nextContinuationToken;
  }

  /// Get part-info of all parts of an incomplete upload specified by uploadId.
  Stream<Part> listParts(
    String bucket,
    String object,
    String uploadId,
  ) async* {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    var marker = 0;
    var isTruncated = false;
    do {
      final result = await listPartsQuery(bucket, object, uploadId, marker);
      marker = result.nextPartNumberMarker;
      isTruncated = result.isTruncated;
      yield* Stream.fromIterable(result.parts);
    } while (isTruncated);
  }

  /// Called by listParts to fetch a batch of part-info
  Future<ListPartsOutput> listPartsQuery(
    String bucket,
    String object,
    String uploadId,
    int marker,
  ) async {
    var queries = <String, dynamic>{'uploadId': uploadId};

    if (marker != null && marker != 0) {
      queries['part-number-marker'] = marker.toString();
    }

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      object: object,
      queries: queries,
    );

    validate(resp);

    final node = xml.XmlDocument.parse(resp.body);
    return ListPartsOutput.fromXml(node.root);
  }

  /// Creates the bucket [bucket].
  Future<void> makeBucket(String bucket, [String region]) async {
    MinioInvalidBucketNameError.check(bucket);
    if (this.region != null && region != null && this.region != region) {
      throw MinioInvalidArgumentError(
        'Configured region ${this.region}, requested $region',
      );
    }

    region ??= this.region ?? 'us-east-1';
    final payload = region == 'us-east-1'
        ? ''
        : CreateBucketConfiguration(region).toXml().toString();

    final resp = await _client.request(
      method: 'PUT',
      bucket: bucket,
      region: region,
      payload: payload,
    );

    validate(resp);
    return resp.body;
  }

  /// Generate a presigned URL for GET
  ///
  /// - [bucketName]: name of the bucket
  /// - [objectName]: name of the object
  /// - [expires]: expiry in seconds (optional, default 7 days)
  /// - [respHeaders]: response headers to override (optional)
  /// - [requestDate]: A date object, the url will be issued at (optional)
  Future<String> presignedGetObject(
    String bucket,
    String object, {
    int expires,
    Map<String, String> respHeaders,
    DateTime requestDate,
  }) {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    return presignedUrl(
      'GET',
      bucket,
      object,
      expires: expires,
      reqParams: respHeaders,
      requestDate: requestDate,
    );
  }

  /// presignedPostPolicy can be used in situations where we want more control on the upload than what
  /// presignedPutObject() provides. i.e Using presignedPostPolicy we will be able to put policy restrictions
  /// on the object's `name` `bucket` `expiry` `Content-Type`
  Future presignedPostPolicy(PostPolicy postPolicy) async {
    if (_client.anonymous) {
      throw MinioAnonymousRequestError(
        'Presigned POST policy cannot be generated for anonymous requests',
      );
    }

    final region = await getBucketRegion(postPolicy.formData['bucket']);
    var date = DateTime.now().toUtc();
    var dateStr = makeDateLong(date);

    if (postPolicy.policy['expiration'] == null) {
      // 'expiration' is mandatory field for S3.
      // Set default expiration date of 7 days.
      var expires = DateTime.now().toUtc();
      expires.add(Duration(days: 7));
      postPolicy.setExpires(expires);
    }

    postPolicy.policy['conditions'].push(['eq', r'$x-amz-date', dateStr]);
    postPolicy.formData['x-amz-date'] = dateStr;

    postPolicy.policy['conditions']
        .push(['eq', r'$x-amz-algorithm', 'AWS4-HMAC-SHA256']);
    postPolicy.formData['x-amz-algorithm'] = 'AWS4-HMAC-SHA256';

    postPolicy.policy['conditions'].push(
        ['eq', r'$x-amz-credential', accessKey + '/' + getScope(region, date)]);
    postPolicy.formData['x-amz-credential'] =
        accessKey + '/' + getScope(region, date);

    if (sessionToken != null) {
      postPolicy.policy['conditions']
          .push(['eq', r'$x-amz-security-token', sessionToken]);
    }

    final policyBase64 = jsonBase64(postPolicy.policy);
    postPolicy.formData['policy'] = policyBase64;

    final signature =
        postPresignSignatureV4(region, date, secretKey, policyBase64);

    postPolicy.formData['x-amz-signature'] = signature;
    final url = _client
        .getBaseRequest('POST', postPolicy.formData['bucket'], null, region,
            null, null, null)
        .url;
    var portStr = (port == 80 || port == 443 || port == null) ? '' : ':$port';
    var urlStr = '${url.scheme}://${url.host}${portStr}${url.path}';
    return PostPolicyResult(postURL: urlStr, formData: postPolicy.formData);
  }

  /// Generate a presigned URL for PUT.
  /// Using this URL, the browser can upload to S3 only with the specified object name.
  ///
  /// - [bucketName]: name of the bucket
  /// - [objectName]: name of the object
  /// - [expires]: expiry in seconds (optional, default 7 days)
  Future<String> presignedPutObject(
    String bucket,
    String object, {
    int expires,
  }) {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);
    return presignedUrl('PUT', bucket, object, expires: expires);
  }

  /// Generate a generic presigned URL which can be
  /// used for HTTP methods GET, PUT, HEAD and DELETE
  ///
  /// - [method]: name of the HTTP method
  /// - [bucketName]: name of the bucket
  /// - [objectName]: name of the object
  /// - [expires]: expiry in seconds (optional, default 7 days)
  /// - [reqParams]: request parameters (optional)
  /// - [requestDate]: A date object, the url will be issued at (optional)
  Future<String> presignedUrl(
    String method,
    String bucket,
    String object, {
    int expires,
    String resource,
    Map<String, String> reqParams,
    DateTime requestDate,
  }) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    assert(expires == null || expires >= 0);

    expires ??= expires = 24 * 60 * 60 * 7; // 7 days in seconds
    reqParams ??= {};
    requestDate ??= DateTime.now().toUtc();

    final region = await getBucketRegion(bucket);
    final request = _client.getBaseRequest(
      method,
      bucket,
      object,
      region,
      resource,
      reqParams,
      {},
    );
    return presignSignatureV4(this, request, region, requestDate, expires);
  }

  /// Uploads the object.
  Future<String> putObject(
    String bucket,
    String object,
    Stream<List<int>> data,
    int size, {
    Map<String, String> metadata,
  }) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    assert(data != null);
    assert(size >= 0 || size == null);

    metadata = prependXAMZMeta(metadata ?? <String, String>{});

    size ??= maxObjectSize;
    size = _calculatePartSize(size);

    final chunker = BlockStream(size);
    final uploader = MinioUploader(
      this,
      _client,
      bucket,
      object,
      size,
      metadata,
    );
    final etag = await data.transform(chunker).pipe(uploader);
    return etag.toString();
  }

  /// Remove all bucket notification
  Future<void> removeAllBucketNotification(bucket) => setBucketNotification(
      bucket, NotificationConfiguration(null, null, null));

  /// Remove a bucket.
  Future<void> removeBucket(String bucket) async {
    MinioInvalidBucketNameError.check(bucket);

    final resp = await _client.request(
      method: 'DELETE',
      bucket: bucket,
    );

    validate(resp, expect: 204);
    _regionMap.remove(bucket);
  }

  /// Remove the partially uploaded object.
  Future<void> removeIncompleteUpload(String bucket, String object) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    final uploadId = await findUploadId(bucket, object);
    if (uploadId == null) return;

    final resp = await _client.request(
      method: 'DELETE',
      bucket: bucket,
      object: object,
      queries: {'uploadId': uploadId},
    );

    validate(resp, expect: 204);
  }

  /// Remove the specified object.
  Future<void> removeObject(String bucket, String object) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    final resp = await _client.request(
      method: 'DELETE',
      bucket: bucket,
      object: object,
    );

    validate(resp, expect: 204);
  }

  /// Remove all the objects residing in the objectsList.
  Future<void> removeObjects(String bucket, List<String> objects) async {
    MinioInvalidBucketNameError.check(bucket);

    final bunches = groupList(objects, 1000);

    for (var bunch in bunches) {
      final payload = Delete(
        bunch.map((key) => ObjectIdentifier(key, null)).toList(),
        true,
      ).toXml().toString();

      final headers = {'Content-MD5': md5Base64(payload)};

      await _client.request(
        method: 'POST',
        bucket: bucket,
        resource: 'delete',
        headers: headers,
        payload: payload,
      );
    }
  }

  // Remove all the notification configurations in the S3 provider
  Future<void> setBucketNotification(
    String bucket,
    NotificationConfiguration config,
  ) async {
    MinioInvalidBucketNameError.check(bucket);
    assert(config != null);

    final resp = await _client.request(
      method: 'PUT',
      bucket: bucket,
      resource: 'notification',
      payload: config.toXml().toString(),
    );

    validate(resp, expect: 200);
  }

  /// Set the bucket policy on the specified bucket.
  ///
  /// [policy] is detailed [here](https://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies.html).
  Future<void> setBucketPolicy(
    String bucket, [
    Map<String, dynamic> policy,
  ]) async {
    MinioInvalidBucketNameError.check(bucket);

    final method = policy != null ? 'PUT' : 'DELETE';
    final payload = policy != null ? json.encode(policy) : '';

    final resp = await _client.request(
      method: method,
      bucket: bucket,
      resource: 'policy',
      payload: payload,
    );

    validate(resp, expect: 204);
  }

  Future<void> setObjectACL(String bucket, String object, String policy) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    final resp = await _client.request(
      method: 'PUT',
      bucket: bucket,
      object: object,
      queries: {'acl': policy},
    );
  }

  Future<AccessControlPolicy> getObjectACL(String bucket, String object) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      object: object,
      queries: {'acl': ''},
    );

    return AccessControlPolicy.fromXml(
      xml.XmlDocument.parse(resp.body).firstChild,
    );
  }

  /// Stat information of the object.
  Future<StatObjectResult> statObject(String bucket, String object) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    final resp = await _client.request(
      method: 'HEAD',
      bucket: bucket,
      object: object,
    );

    validate(resp, expect: 200);

    var etag = resp.headers['etag'];
    if (etag != null) {
      etag = trimDoubleQuote(etag);
    }

    return StatObjectResult(
      etag: etag,
      size: int.parse(resp.headers['content-length']),
      metaData: extractMetadata(resp.headers),
      lastModified: parseRfc7231Time(resp.headers['last-modified']),
      acl: await getObjectACL(bucket, object),
    );
  }
}
