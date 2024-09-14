// ignore_for_file: require_trailing_commas
// ignore_for_file: deprecated_member_use
// ignore_for_file: empty_constructor_bodies

import 'package:xml/xml.dart';

XmlElement? getProp(XmlElement? xml, String name) {
  if (xml == null) return null;
  final result = xml.findElements(name);
  return result.isNotEmpty ? result.first : null;
}

T? getPropValueOrNull<T>(XmlElement? xml, String name) {
  final propValue = getProp(xml, name)?.value;
  if (propValue == null) return null;

  switch (T) {
    case const (String):
      return propValue as T?;
    case const (int):
      return int.tryParse(propValue) as T?;
    case const (bool):
      return (propValue.toUpperCase() == 'TRUE') as T?;
    case const (DateTime):
      return DateTime.parse(propValue) as T;
    default:
      return propValue as T;
  }
}

T getPropValue<T>(XmlElement? xml, String name) {
  final propValue = getPropValueOrNull<T>(xml, name);
  return propValue as T;
}

/// Specifies the days since the initiation of an incomplete multipart upload that Amazon S3 will wait before permanently removing all parts of the upload. For more information, see Aborting Incomplete Multipart Uploads Using a Bucket Lifecycle Configuration in the Amazon S3 User Guide.
class AbortIncompleteMultipartUpload {
  AbortIncompleteMultipartUpload(
    this.daysAfterInitiation,
  );

  AbortIncompleteMultipartUpload.fromXml(XmlElement? xml) {
    daysAfterInitiation = getPropValueOrNull<int>(xml, 'DaysAfterInitiation');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('AbortIncompleteMultipartUpload', nest: () {
      builder.element('DaysAfterInitiation',
          nest: daysAfterInitiation.toString());
    });
    return builder.buildDocument();
  }

  /// Specifies the number of days after which Amazon S3 aborts an incomplete multipart upload.
  int? daysAfterInitiation;
}

/// Configures the transfer acceleration state for an Amazon S3 bucket. For more information, see Amazon S3 Transfer Acceleration in the Amazon S3 User Guide.
class AccelerateConfiguration {
  AccelerateConfiguration(
    this.status,
  );

  AccelerateConfiguration.fromXml(XmlElement? xml) {
    status = getPropValueOrNull<String>(xml, 'Status');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('AccelerateConfiguration', nest: () {
      builder.element('Status', nest: status);
    });
    return builder.buildDocument();
  }

  /// Specifies the transfer acceleration status of the bucket.
  String? status;
}

/// Contains the elements that set the ACL permissions for an object per grantee.
class AccessControlPolicy {
  AccessControlPolicy(
    this.grants,
    this.owner,
  );

  AccessControlPolicy.fromXml(XmlElement? xml) {
    grants = getProp(xml, 'Grants')
        ?.children
        .map((c) => Grant.fromXml(c as XmlElement))
        .toList();
    owner = Owner.fromXml(getProp(xml, 'Owner'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('AccessControlPolicy', nest: () {
      builder.element('Grants', nest: grants?.map((e) => e.toXml()));
      builder.element('Owner', nest: owner?.toXml());
    });
    return builder.buildDocument();
  }

  /// A list of grants.
  List<Grant>? grants;

  /// Container for the bucket owner's display name and ID.
  Owner? owner;
}

/// A container for information about access control for replicas.
class AccessControlTranslation {
  AccessControlTranslation(
    this.owner,
  );

  AccessControlTranslation.fromXml(XmlElement? xml) {
    owner = getPropValue<String>(xml, 'Owner');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('AccessControlTranslation', nest: () {
      builder.element('Owner', nest: owner);
    });
    return builder.buildDocument();
  }

  /// Specifies the replica ownership. For default and valid values, see PUT bucket replication in the Amazon S3 API Reference.
  late String owner;
}

/// A conjunction (logical AND) of predicates, which is used in evaluating a metrics filter. The operator must have at least two predicates in any combination, and an object must match all of the predicates for the filter to apply.
class AnalyticsAndOperator {
  AnalyticsAndOperator(
    this.prefix,
    this.tags,
  );

  AnalyticsAndOperator.fromXml(XmlElement? xml) {
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    tags = getProp(xml, 'Tags')
        ?.children
        .map((c) => Tag.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('AnalyticsAndOperator', nest: () {
      builder.element('Prefix', nest: prefix);
      builder.element('Tags', nest: tags?.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// The prefix to use when evaluating an AND predicate: The prefix that an object must have to be included in the metrics results.
  String? prefix;

  /// The list of tags to use when evaluating an AND predicate.
  List<Tag>? tags;
}

/// Specifies the configuration and any analyses for the analytics filter of an Amazon S3 bucket.
class AnalyticsConfiguration {
  AnalyticsConfiguration(
    this.id,
    this.storageClassAnalysis,
    this.filter,
  );

  AnalyticsConfiguration.fromXml(XmlElement? xml) {
    id = getPropValue<String>(xml, 'Id');
    storageClassAnalysis =
        StorageClassAnalysis.fromXml(getProp(xml, 'StorageClassAnalysis'));
    filter = AnalyticsFilter.fromXml(getProp(xml, 'Filter'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('AnalyticsConfiguration', nest: () {
      builder.element('Id', nest: id);
      builder.element('StorageClassAnalysis',
          nest: storageClassAnalysis.toXml());
      builder.element('Filter', nest: filter?.toXml());
    });
    return builder.buildDocument();
  }

  /// The ID that identifies the analytics configuration.
  late String id;

  ///  Contains data related to access patterns to be collected and made available to analyze the tradeoffs between different storage classes.
  late StorageClassAnalysis storageClassAnalysis;

  /// The filter used to describe a set of objects for analyses. A filter must have exactly one prefix, one tag, or one conjunction (AnalyticsAndOperator). If no filter is provided, all objects will be considered in any analysis.
  AnalyticsFilter? filter;
}

/// Where to publish the analytics results.
class AnalyticsExportDestination {
  AnalyticsExportDestination(
    this.s3BucketDestination,
  );

  AnalyticsExportDestination.fromXml(XmlElement? xml) {
    s3BucketDestination = AnalyticsS3BucketDestination.fromXml(
        getProp(xml, 'S3BucketDestination'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('AnalyticsExportDestination', nest: () {
      builder.element('S3BucketDestination', nest: s3BucketDestination.toXml());
    });
    return builder.buildDocument();
  }

  /// A destination signifying output to an S3 bucket.
  late AnalyticsS3BucketDestination s3BucketDestination;
}

/// The filter used to describe a set of objects for analyses. A filter must have exactly one prefix, one tag, or one conjunction (AnalyticsAndOperator). If no filter is provided, all objects will be considered in any analysis.
class AnalyticsFilter {
  AnalyticsFilter(
    this.and,
    this.prefix,
    this.tag,
  );

  AnalyticsFilter.fromXml(XmlElement? xml) {
    and = AnalyticsAndOperator.fromXml(getProp(xml, 'And'));
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    tag = Tag.fromXml(getProp(xml, 'Tag'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('AnalyticsFilter', nest: () {
      builder.element('And', nest: and?.toXml());
      builder.element('Prefix', nest: prefix);
      builder.element('Tag', nest: tag?.toXml());
    });
    return builder.buildDocument();
  }

  /// A conjunction (logical AND) of predicates, which is used in evaluating an analytics filter. The operator must have at least two predicates.
  AnalyticsAndOperator? and;

  /// The prefix to use when evaluating an analytics filter.
  String? prefix;

  /// The tag to use when evaluating an analytics filter.
  Tag? tag;
}

/// Contains information about where to publish the analytics results.
class AnalyticsS3BucketDestination {
  AnalyticsS3BucketDestination(
    this.bucket,
    this.format,
    this.bucketAccountId,
    this.prefix,
  );

  AnalyticsS3BucketDestination.fromXml(XmlElement? xml) {
    bucket = getPropValue<String>(xml, 'Bucket');
    format = getPropValue<String>(xml, 'Format');
    bucketAccountId = getPropValueOrNull<String>(xml, 'BucketAccountId');
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('AnalyticsS3BucketDestination', nest: () {
      builder.element('Bucket', nest: bucket);
      builder.element('Format', nest: format);
      builder.element('BucketAccountId', nest: bucketAccountId);
      builder.element('Prefix', nest: prefix);
    });
    return builder.buildDocument();
  }

  /// The Amazon Resource Name (ARN) of the bucket to which data is exported.
  late String bucket;

  /// Specifies the file format used when exporting data to Amazon S3.
  late String format;

  /// The account ID that owns the destination S3 bucket. If no account ID is provided, the owner is not validated before exporting data.
  String? bucketAccountId;

  /// The prefix to use when exporting data. The prefix is prepended to all results.
  String? prefix;
}

///  In terms of implementation, a Bucket is a resource.
class Bucket {
  Bucket(
    this.creationDate,
    this.name,
  );

  Bucket.fromXml(XmlElement? xml) {
    creationDate = getPropValueOrNull<DateTime>(xml, 'CreationDate');
    name = getPropValueOrNull<String>(xml, 'Name');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Bucket', nest: () {
      builder.element('CreationDate', nest: creationDate?.toIso8601String());
      builder.element('Name', nest: name);
    });
    return builder.buildDocument();
  }

  /// Date the bucket was created. This date can change when making changes to your bucket, such as editing its bucket policy.
  DateTime? creationDate;

  /// The name of the bucket.
  String? name;
}

/// Specifies the information about the bucket that will be created. For more information about directory buckets, see Directory buckets in the Amazon S3 User Guide.
class BucketInfo {
  BucketInfo(
    this.dataRedundancy,
    this.type,
  );

  BucketInfo.fromXml(XmlElement? xml) {
    dataRedundancy = getPropValueOrNull<String>(xml, 'DataRedundancy');
    type = getPropValueOrNull<String>(xml, 'Type');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('BucketInfo', nest: () {
      builder.element('DataRedundancy', nest: dataRedundancy);
      builder.element('Type', nest: type);
    });
    return builder.buildDocument();
  }

  /// The number of Availability Zone that's used for redundancy for the bucket.
  String? dataRedundancy;

  /// The type of bucket.
  String? type;
}

/// Specifies the lifecycle configuration for objects in an Amazon S3 bucket. For more information, see Object Lifecycle Management in the Amazon S3 User Guide.
class BucketLifecycleConfiguration {
  BucketLifecycleConfiguration(
    this.rules,
  );

  BucketLifecycleConfiguration.fromXml(XmlElement? xml) {
    rules = getProp(xml, 'Rules')!
        .children
        .map((c) => LifecycleRule.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('BucketLifecycleConfiguration', nest: () {
      builder.element('Rules', nest: rules.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// A lifecycle rule for individual objects in an Amazon S3 bucket.
  late List<LifecycleRule> rules;
}

/// Container for logging status information.
class BucketLoggingStatus {
  BucketLoggingStatus(
    this.loggingEnabled,
  );

  BucketLoggingStatus.fromXml(XmlElement? xml) {
    loggingEnabled = LoggingEnabled.fromXml(getProp(xml, 'LoggingEnabled'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('BucketLoggingStatus', nest: () {
      builder.element('LoggingEnabled', nest: loggingEnabled?.toXml());
    });
    return builder.buildDocument();
  }

  /// Describes where logs are stored and the prefix that Amazon S3 assigns to all log object keys for a bucket. For more information, see PUT Bucket logging in the Amazon S3 API Reference.
  LoggingEnabled? loggingEnabled;
}

/// Contains all the possible checksum or digest values for an object.
class Checksum {
  Checksum(
    this.checksumCRC32,
    this.checksumCRC32C,
    this.checksumSHA1,
    this.checksumSHA256,
  );

  Checksum.fromXml(XmlElement? xml) {
    checksumCRC32 = getPropValueOrNull<String>(xml, 'ChecksumCRC32');
    checksumCRC32C = getPropValueOrNull<String>(xml, 'ChecksumCRC32C');
    checksumSHA1 = getPropValueOrNull<String>(xml, 'ChecksumSHA1');
    checksumSHA256 = getPropValueOrNull<String>(xml, 'ChecksumSHA256');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Checksum', nest: () {
      builder.element('ChecksumCRC32', nest: checksumCRC32);
      builder.element('ChecksumCRC32C', nest: checksumCRC32C);
      builder.element('ChecksumSHA1', nest: checksumSHA1);
      builder.element('ChecksumSHA256', nest: checksumSHA256);
    });
    return builder.buildDocument();
  }

  /// The base64-encoded, 32-bit CRC-32 checksum of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32;

  /// The base64-encoded, 32-bit CRC-32C checksum of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32C;

  /// The base64-encoded, 160-bit SHA-1 digest of the object. This will only be present if it was uploaded with the object. When you use the API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA1;

  /// The base64-encoded, 256-bit SHA-256 digest of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA256;
}

/// Container for specifying the AWS Lambda notification configuration.
class CloudFunctionConfiguration {
  CloudFunctionConfiguration(
    this.cloudFunction,
    this.event,
    this.events,
    this.id,
    this.invocationRole,
  );

  CloudFunctionConfiguration.fromXml(XmlElement? xml) {
    cloudFunction = getPropValueOrNull<String>(xml, 'CloudFunction');
    event = getPropValueOrNull<String>(xml, 'Event');
    events = getPropValueOrNull<List<String>>(xml, 'Events');
    id = getPropValueOrNull<String>(xml, 'Id');
    invocationRole = getPropValueOrNull<String>(xml, 'InvocationRole');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CloudFunctionConfiguration', nest: () {
      builder.element('CloudFunction', nest: cloudFunction);
      builder.element('Event', nest: event);
      builder.element('Events', nest: events);
      builder.element('Id', nest: id);
      builder.element('InvocationRole', nest: invocationRole);
    });
    return builder.buildDocument();
  }

  /// Lambda cloud function ARN that Amazon S3 can invoke when it detects events of the specified type.
  String? cloudFunction;

  ///  This member has been deprecated.
  String? event;

  /// Bucket events for which to send notifications.
  List<String>? events;

  /// An optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon S3 will assign an ID.
  String? id;

  /// The role supporting the invocation of the Lambda function
  String? invocationRole;
}

/// Container for all (if there are any) keys between Prefix and the next occurrence of the string specified by a delimiter. CommonPrefixes lists keys that act like subdirectories in the directory specified by Prefix. For example, if the prefix is notes/ and the delimiter is a slash (/) as in notes/summer/july, the common prefix is notes/summer/.
class CommonPrefix {
  CommonPrefix(
    this.prefix,
  );

  CommonPrefix.fromXml(XmlElement? xml) {
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CommonPrefix', nest: () {
      builder.element('Prefix', nest: prefix);
    });
    return builder.buildDocument();
  }

  /// Container for the specified common prefix.
  String? prefix;
}

/// The container for the completed multipart upload details.
class CompletedMultipartUpload {
  CompletedMultipartUpload(
    this.parts,
  );

  CompletedMultipartUpload.fromXml(XmlElement? xml) {
    parts = getProp(xml, 'Parts')
        ?.children
        .map((c) => CompletedPart.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CompletedMultipartUpload', nest: () {
      builder.element('Parts', nest: parts?.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// Array of CompletedPart data types.
  List<CompletedPart>? parts;
}

/// Details of the parts that were uploaded.
class CompletedPart {
  CompletedPart(
    this.checksumCRC32,
    this.checksumCRC32C,
    this.checksumSHA1,
    this.checksumSHA256,
    this.eTag,
    this.partNumber,
  );

  CompletedPart.fromXml(XmlElement? xml) {
    checksumCRC32 = getPropValueOrNull<String>(xml, 'ChecksumCRC32');
    checksumCRC32C = getPropValueOrNull<String>(xml, 'ChecksumCRC32C');
    checksumSHA1 = getPropValueOrNull<String>(xml, 'ChecksumSHA1');
    checksumSHA256 = getPropValueOrNull<String>(xml, 'ChecksumSHA256');
    eTag = getPropValueOrNull<String>(xml, 'ETag');
    partNumber = getPropValueOrNull<int>(xml, 'PartNumber');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CompletedPart', nest: () {
      builder.element('ChecksumCRC32', nest: checksumCRC32);
      builder.element('ChecksumCRC32C', nest: checksumCRC32C);
      builder.element('ChecksumSHA1', nest: checksumSHA1);
      builder.element('ChecksumSHA256', nest: checksumSHA256);
      builder.element('ETag', nest: eTag);
      builder.element('PartNumber', nest: partNumber.toString());
    });
    return builder.buildDocument();
  }

  /// The base64-encoded, 32-bit CRC-32 checksum of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32;

  /// The base64-encoded, 32-bit CRC-32C checksum of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32C;

  /// The base64-encoded, 160-bit SHA-1 digest of the object. This will only be present if it was uploaded with the object. When you use the API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA1;

  /// The base64-encoded, 256-bit SHA-256 digest of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA256;

  /// Entity tag returned when the part was uploaded.
  String? eTag;

  /// Part number that identifies the part. This is a positive integer between 1 and 10,000.
  int? partNumber;
}

/// A container for describing a condition that must be met for the specified redirect to apply. For example, 1. If request is for pages in the /docs folder, redirect to the /documents folder. 2. If request results in HTTP error 4xx, redirect request to another host where you might process the error.
class Condition {
  Condition(
    this.httpErrorCodeReturnedEquals,
    this.keyPrefixEquals,
  );

  Condition.fromXml(XmlElement? xml) {
    httpErrorCodeReturnedEquals =
        getPropValueOrNull<String>(xml, 'HttpErrorCodeReturnedEquals');
    keyPrefixEquals = getPropValueOrNull<String>(xml, 'KeyPrefixEquals');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Condition', nest: () {
      builder.element('HttpErrorCodeReturnedEquals',
          nest: httpErrorCodeReturnedEquals);
      builder.element('KeyPrefixEquals', nest: keyPrefixEquals);
    });
    return builder.buildDocument();
  }

  /// The HTTP error code when the redirect is applied. In the event of an error, if the error code equals this value, then the specified redirect is applied. Required when parent element Condition is specified and sibling KeyPrefixEquals is not specified. If both are specified, then both must be true for the redirect to be applied.
  String? httpErrorCodeReturnedEquals;

  /// The object key name prefix when the redirect is applied. For example, to redirect requests for ExamplePage.html, the key prefix will be ExamplePage.html. To redirect request for all pages with the prefix docs/, the key prefix will be /docs, which identifies all objects in the docs/ folder. Required when the parent element Condition is specified and sibling HttpErrorCodeReturnedEquals is not specified. If both conditions are specified, both must be true for the redirect to be applied.
  String? keyPrefixEquals;
}

///
class ContinuationEvent {
  ContinuationEvent();

  ContinuationEvent.fromXml(XmlElement? xml) {}

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ContinuationEvent', nest: () {});
    return builder.buildDocument();
  }
}

/// Container for all response elements.
class CopyObjectResult {
  CopyObjectResult(
    this.checksumCRC32,
    this.checksumCRC32C,
    this.checksumSHA1,
    this.checksumSHA256,
    this.eTag,
    this.lastModified,
  );

  CopyObjectResult.fromXml(XmlElement? xml) {
    checksumCRC32 = getPropValueOrNull<String>(xml, 'ChecksumCRC32');
    checksumCRC32C = getPropValueOrNull<String>(xml, 'ChecksumCRC32C');
    checksumSHA1 = getPropValueOrNull<String>(xml, 'ChecksumSHA1');
    checksumSHA256 = getPropValueOrNull<String>(xml, 'ChecksumSHA256');
    eTag = getPropValueOrNull<String>(xml, 'ETag');
    lastModified = getPropValueOrNull<DateTime>(xml, 'LastModified');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CopyObjectResult', nest: () {
      builder.element('ChecksumCRC32', nest: checksumCRC32);
      builder.element('ChecksumCRC32C', nest: checksumCRC32C);
      builder.element('ChecksumSHA1', nest: checksumSHA1);
      builder.element('ChecksumSHA256', nest: checksumSHA256);
      builder.element('ETag', nest: eTag);
      builder.element('LastModified', nest: lastModified?.toIso8601String());
    });
    return builder.buildDocument();
  }

  /// The base64-encoded, 32-bit CRC-32 checksum of the object. This will only be present if it was uploaded with the object. For more information, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32;

  /// The base64-encoded, 32-bit CRC-32C checksum of the object. This will only be present if it was uploaded with the object. For more information, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32C;

  /// The base64-encoded, 160-bit SHA-1 digest of the object. This will only be present if it was uploaded with the object. For more information, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA1;

  /// The base64-encoded, 256-bit SHA-256 digest of the object. This will only be present if it was uploaded with the object. For more information, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA256;

  /// Returns the ETag of the new object. The ETag reflects only changes to the contents of an object, not its metadata.
  String? eTag;

  /// Creation date of the object.
  DateTime? lastModified;
}

/// Container for all response elements.
class CopyPartResult {
  CopyPartResult(
    this.checksumCRC32,
    this.checksumCRC32C,
    this.checksumSHA1,
    this.checksumSHA256,
    this.eTag,
    this.lastModified,
  );

  CopyPartResult.fromXml(XmlElement? xml) {
    checksumCRC32 = getPropValueOrNull<String>(xml, 'ChecksumCRC32');
    checksumCRC32C = getPropValueOrNull<String>(xml, 'ChecksumCRC32C');
    checksumSHA1 = getPropValueOrNull<String>(xml, 'ChecksumSHA1');
    checksumSHA256 = getPropValueOrNull<String>(xml, 'ChecksumSHA256');
    eTag = getPropValueOrNull<String>(xml, 'ETag');
    lastModified = getPropValueOrNull<DateTime>(xml, 'LastModified');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CopyPartResult', nest: () {
      builder.element('ChecksumCRC32', nest: checksumCRC32);
      builder.element('ChecksumCRC32C', nest: checksumCRC32C);
      builder.element('ChecksumSHA1', nest: checksumSHA1);
      builder.element('ChecksumSHA256', nest: checksumSHA256);
      builder.element('ETag', nest: eTag);
      builder.element('LastModified', nest: lastModified?.toIso8601String());
    });
    return builder.buildDocument();
  }

  /// The base64-encoded, 32-bit CRC-32 checksum of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32;

  /// The base64-encoded, 32-bit CRC-32C checksum of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32C;

  /// The base64-encoded, 160-bit SHA-1 digest of the object. This will only be present if it was uploaded with the object. When you use the API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA1;

  /// The base64-encoded, 256-bit SHA-256 digest of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA256;

  /// Entity tag of the object.
  String? eTag;

  /// Date and time at which the object was uploaded.
  DateTime? lastModified;
}

/// Describes the cross-origin access configuration for objects in an Amazon S3 bucket. For more information, see Enabling Cross-Origin Resource Sharing in the Amazon S3 User Guide.
class CORSConfiguration {
  CORSConfiguration(
    this.cORSRules,
  );

  CORSConfiguration.fromXml(XmlElement? xml) {
    cORSRules = getProp(xml, 'CORSRules')!
        .children
        .map((c) => CORSRule.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CORSConfiguration', nest: () {
      builder.element('CORSRules', nest: cORSRules.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// A set of origins and methods (cross-origin access that you want to allow). You can add up to 100 rules to the configuration.
  late List<CORSRule> cORSRules;
}

/// Specifies a cross-origin access rule for an Amazon S3 bucket.
class CORSRule {
  CORSRule(
    this.allowedMethods,
    this.allowedOrigins,
    this.allowedHeaders,
    this.exposeHeaders,
    this.iD,
    this.maxAgeSeconds,
  );

  CORSRule.fromXml(XmlElement? xml) {
    allowedMethods = getPropValue<List<String>>(xml, 'AllowedMethods');
    allowedOrigins = getPropValue<List<String>>(xml, 'AllowedOrigins');
    allowedHeaders = getPropValueOrNull<List<String>>(xml, 'AllowedHeaders');
    exposeHeaders = getPropValueOrNull<List<String>>(xml, 'ExposeHeaders');
    iD = getPropValueOrNull<String>(xml, 'ID');
    maxAgeSeconds = getPropValueOrNull<int>(xml, 'MaxAgeSeconds');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CORSRule', nest: () {
      builder.element('AllowedMethods', nest: allowedMethods);
      builder.element('AllowedOrigins', nest: allowedOrigins);
      builder.element('AllowedHeaders', nest: allowedHeaders);
      builder.element('ExposeHeaders', nest: exposeHeaders);
      builder.element('ID', nest: iD);
      builder.element('MaxAgeSeconds', nest: maxAgeSeconds.toString());
    });
    return builder.buildDocument();
  }

  /// An HTTP method that you allow the origin to execute. Valid values are GET, PUT, HEAD, POST, and DELETE.
  late List<String> allowedMethods;

  /// One or more origins you want customers to be able to access the bucket from.
  late List<String> allowedOrigins;

  /// Headers that are specified in the Access-Control-Request-Headers header. These headers are allowed in a preflight OPTIONS request. In response to any preflight OPTIONS request, Amazon S3 returns any requested headers that are allowed.
  List<String>? allowedHeaders;

  /// One or more headers in the response that you want customers to be able to access from their applications (for example, from a JavaScript XMLHttpRequest object).
  List<String>? exposeHeaders;

  /// Unique identifier for the rule. The value cannot be longer than 255 characters.
  String? iD;

  /// The time in seconds that your browser is to cache the preflight response for the specified resource.
  int? maxAgeSeconds;
}

/// The configuration information for the bucket.
class CreateBucketConfiguration {
  CreateBucketConfiguration(
    this.bucket,
    this.location,
    this.locationConstraint,
  );

  CreateBucketConfiguration.fromXml(XmlElement? xml) {
    bucket = BucketInfo.fromXml(getProp(xml, 'Bucket'));
    location = LocationInfo.fromXml(getProp(xml, 'Location'));
    locationConstraint = getPropValueOrNull<String>(xml, 'LocationConstraint');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CreateBucketConfiguration', nest: () {
      builder.element('Bucket', nest: bucket?.toXml());
      builder.element('Location', nest: location?.toXml());
      builder.element('LocationConstraint', nest: locationConstraint);
    });
    return builder.buildDocument();
  }

  /// Specifies the information about the bucket that will be created.
  BucketInfo? bucket;

  /// Specifies the location where the bucket will be created.
  LocationInfo? location;

  /// Specifies the Region where the bucket will be created. You might choose a Region to optimize latency, minimize costs, or address regulatory requirements. For example, if you reside in Europe, you will probably find it advantageous to create buckets in the Europe (Ireland) Region. For more information, see Accessing a bucket in the Amazon S3 User Guide.
  String? locationConstraint;
}

/// Describes how an uncompressed comma-separated values (CSV)-formatted input object is formatted.
class CSVInput {
  CSVInput(
    this.allowQuotedRecordDelimiter,
    this.comments,
    this.fieldDelimiter,
    this.fileHeaderInfo,
    this.quoteCharacter,
    this.quoteEscapeCharacter,
    this.recordDelimiter,
  );

  CSVInput.fromXml(XmlElement? xml) {
    allowQuotedRecordDelimiter =
        getPropValueOrNull<bool>(xml, 'AllowQuotedRecordDelimiter');
    comments = getPropValueOrNull<String>(xml, 'Comments');
    fieldDelimiter = getPropValueOrNull<String>(xml, 'FieldDelimiter');
    fileHeaderInfo = getPropValueOrNull<String>(xml, 'FileHeaderInfo');
    quoteCharacter = getPropValueOrNull<String>(xml, 'QuoteCharacter');
    quoteEscapeCharacter =
        getPropValueOrNull<String>(xml, 'QuoteEscapeCharacter');
    recordDelimiter = getPropValueOrNull<String>(xml, 'RecordDelimiter');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CSVInput', nest: () {
      builder.element('AllowQuotedRecordDelimiter',
          nest: allowQuotedRecordDelimiter == true ? 'TRUE' : 'FALSE');
      builder.element('Comments', nest: comments);
      builder.element('FieldDelimiter', nest: fieldDelimiter);
      builder.element('FileHeaderInfo', nest: fileHeaderInfo);
      builder.element('QuoteCharacter', nest: quoteCharacter);
      builder.element('QuoteEscapeCharacter', nest: quoteEscapeCharacter);
      builder.element('RecordDelimiter', nest: recordDelimiter);
    });
    return builder.buildDocument();
  }

  /// Specifies that CSV field values may contain quoted record delimiters and such records should be allowed. Default value is FALSE. Setting this value to TRUE may lower performance.
  bool? allowQuotedRecordDelimiter;

  /// A single character used to indicate that a row should be ignored when the character is present at the start of that row. You can specify any character to indicate a comment line. The default character is #.
  String? comments;

  /// A single character used to separate individual fields in a record. You can specify an arbitrary delimiter.
  String? fieldDelimiter;

  /// Describes the first line of input. Valid values are:
  String? fileHeaderInfo;

  /// A single character used for escaping when the field delimiter is part of the value. For example, if the value is a, b, Amazon S3 wraps this field value in quotation marks, as follows: " a , b ".
  String? quoteCharacter;

  /// A single character used for escaping the quotation mark character inside an already escaped value. For example, the value """ a , b """ is parsed as " a , b ".
  String? quoteEscapeCharacter;

  /// A single character used to separate individual records in the input. Instead of the default value, you can specify an arbitrary delimiter.
  String? recordDelimiter;
}

/// Describes how uncompressed comma-separated values (CSV)-formatted results are formatted.
class CSVOutput {
  CSVOutput(
    this.fieldDelimiter,
    this.quoteCharacter,
    this.quoteEscapeCharacter,
    this.quoteFields,
    this.recordDelimiter,
  );

  CSVOutput.fromXml(XmlElement? xml) {
    fieldDelimiter = getPropValueOrNull<String>(xml, 'FieldDelimiter');
    quoteCharacter = getPropValueOrNull<String>(xml, 'QuoteCharacter');
    quoteEscapeCharacter =
        getPropValueOrNull<String>(xml, 'QuoteEscapeCharacter');
    quoteFields = getPropValueOrNull<String>(xml, 'QuoteFields');
    recordDelimiter = getPropValueOrNull<String>(xml, 'RecordDelimiter');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CSVOutput', nest: () {
      builder.element('FieldDelimiter', nest: fieldDelimiter);
      builder.element('QuoteCharacter', nest: quoteCharacter);
      builder.element('QuoteEscapeCharacter', nest: quoteEscapeCharacter);
      builder.element('QuoteFields', nest: quoteFields);
      builder.element('RecordDelimiter', nest: recordDelimiter);
    });
    return builder.buildDocument();
  }

  /// The value used to separate individual fields in a record. You can specify an arbitrary delimiter.
  String? fieldDelimiter;

  /// A single character used for escaping when the field delimiter is part of the value. For example, if the value is a, b, Amazon S3 wraps this field value in quotation marks, as follows: " a , b ".
  String? quoteCharacter;

  /// The single character used for escaping the quote character inside an already escaped value.
  String? quoteEscapeCharacter;

  /// Indicates whether to use quotation marks around output fields.
  String? quoteFields;

  /// A single character used to separate individual records in the output. Instead of the default value, you can specify an arbitrary delimiter.
  String? recordDelimiter;
}

/// The container element for optionally specifying the default Object Lock retention settings for new objects placed in the specified bucket.
class DefaultRetention {
  DefaultRetention(
    this.days,
    this.mode,
    this.years,
  );

  DefaultRetention.fromXml(XmlElement? xml) {
    days = getPropValueOrNull<int>(xml, 'Days');
    mode = getPropValueOrNull<String>(xml, 'Mode');
    years = getPropValueOrNull<int>(xml, 'Years');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('DefaultRetention', nest: () {
      builder.element('Days', nest: days.toString());
      builder.element('Mode', nest: mode);
      builder.element('Years', nest: years.toString());
    });
    return builder.buildDocument();
  }

  /// The number of days that you want to specify for the default retention period. Must be used with Mode.
  int? days;

  /// The default Object Lock retention mode you want to apply to new objects placed in the specified bucket. Must be used with either Days or Years.
  String? mode;

  /// The number of years that you want to specify for the default retention period. Must be used with Mode.
  int? years;
}

/// Container for the objects to delete.
class Delete {
  Delete(
    this.objects,
    this.quiet,
  );

  Delete.fromXml(XmlElement? xml) {
    objects = getProp(xml, 'Objects')!
        .children
        .map((c) => ObjectIdentifier.fromXml(c as XmlElement))
        .toList();
    quiet = getPropValueOrNull<bool>(xml, 'Quiet');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Delete', nest: () {
      builder.element('Objects', nest: objects.map((e) => e.toXml()));
      builder.element('Quiet', nest: quiet == true ? 'TRUE' : 'FALSE');
    });
    return builder.buildDocument();
  }

  /// The object to delete.
  late List<ObjectIdentifier> objects;

  /// Element to enable quiet mode for the request. When you add this element, you must set its value to true.
  bool? quiet;
}

/// Information about the deleted object.
class DeletedObject {
  DeletedObject(
    this.deleteMarker,
    this.deleteMarkerVersionId,
    this.key,
    this.versionId,
  );

  DeletedObject.fromXml(XmlElement? xml) {
    deleteMarker = getPropValueOrNull<bool>(xml, 'DeleteMarker');
    deleteMarkerVersionId =
        getPropValueOrNull<String>(xml, 'DeleteMarkerVersionId');
    key = getPropValueOrNull<String>(xml, 'Key');
    versionId = getPropValueOrNull<String>(xml, 'VersionId');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('DeletedObject', nest: () {
      builder.element('DeleteMarker',
          nest: deleteMarker == true ? 'TRUE' : 'FALSE');
      builder.element('DeleteMarkerVersionId', nest: deleteMarkerVersionId);
      builder.element('Key', nest: key);
      builder.element('VersionId', nest: versionId);
    });
    return builder.buildDocument();
  }

  /// Indicates whether the specified object version that was permanently deleted was (true) or was not (false) a delete marker before deletion. In a simple DELETE, this header indicates whether (true) or not (false) the current version of the object is a delete marker.
  bool? deleteMarker;

  /// The version ID of the delete marker created as a result of the DELETE operation. If you delete a specific object version, the value returned by this header is the version ID of the object version deleted.
  String? deleteMarkerVersionId;

  /// The name of the deleted object.
  String? key;

  /// The version ID of the deleted object.
  String? versionId;
}

/// Information about the delete marker.
class DeleteMarkerEntry {
  DeleteMarkerEntry(
    this.isLatest,
    this.key,
    this.lastModified,
    this.owner,
    this.versionId,
  );

  DeleteMarkerEntry.fromXml(XmlElement? xml) {
    isLatest = getPropValueOrNull<bool>(xml, 'IsLatest');
    key = getPropValueOrNull<String>(xml, 'Key');
    lastModified = getPropValueOrNull<DateTime>(xml, 'LastModified');
    owner = Owner.fromXml(getProp(xml, 'Owner'));
    versionId = getPropValueOrNull<String>(xml, 'VersionId');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('DeleteMarkerEntry', nest: () {
      builder.element('IsLatest', nest: isLatest == true ? 'TRUE' : 'FALSE');
      builder.element('Key', nest: key);
      builder.element('LastModified', nest: lastModified?.toIso8601String());
      builder.element('Owner', nest: owner?.toXml());
      builder.element('VersionId', nest: versionId);
    });
    return builder.buildDocument();
  }

  /// Specifies whether the object is (true) or is not (false) the latest version of an object.
  bool? isLatest;

  /// The object key.
  String? key;

  /// Date and time when the object was last modified.
  DateTime? lastModified;

  /// The account that created the delete marker.>
  Owner? owner;

  /// Version ID of an object.
  String? versionId;
}

/// Specifies whether Amazon S3 replicates delete markers. If you specify a Filter in your replication configuration, you must also include a DeleteMarkerReplication element. If your Filter includes a Tag element, the DeleteMarkerReplication Status must be set to Disabled, because Amazon S3 does not support replicating delete markers for tag-based rules. For an example configuration, see Basic Rule Configuration.
class DeleteMarkerReplication {
  DeleteMarkerReplication(
    this.status,
  );

  DeleteMarkerReplication.fromXml(XmlElement? xml) {
    status = getPropValueOrNull<String>(xml, 'Status');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('DeleteMarkerReplication', nest: () {
      builder.element('Status', nest: status);
    });
    return builder.buildDocument();
  }

  /// Indicates whether to replicate delete markers.
  String? status;
}

/// Specifies information about where to publish analysis or configuration results for an Amazon S3 bucket and S3 Replication Time Control (S3 RTC).
class Destination {
  Destination(
    this.bucket,
    this.accessControlTranslation,
    this.account,
    this.encryptionConfiguration,
    this.metrics,
    this.replicationTime,
    this.storageClass,
  );

  Destination.fromXml(XmlElement? xml) {
    bucket = getPropValue<String>(xml, 'Bucket');
    accessControlTranslation = AccessControlTranslation.fromXml(
        getProp(xml, 'AccessControlTranslation'));
    account = getPropValueOrNull<String>(xml, 'Account');
    encryptionConfiguration = EncryptionConfiguration.fromXml(
        getProp(xml, 'EncryptionConfiguration'));
    metrics = Metrics.fromXml(getProp(xml, 'Metrics'));
    replicationTime = ReplicationTime.fromXml(getProp(xml, 'ReplicationTime'));
    storageClass = getPropValueOrNull<String>(xml, 'StorageClass');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Destination', nest: () {
      builder.element('Bucket', nest: bucket);
      builder.element('AccessControlTranslation',
          nest: accessControlTranslation?.toXml());
      builder.element('Account', nest: account);
      builder.element('EncryptionConfiguration',
          nest: encryptionConfiguration?.toXml());
      builder.element('Metrics', nest: metrics?.toXml());
      builder.element('ReplicationTime', nest: replicationTime?.toXml());
      builder.element('StorageClass', nest: storageClass);
    });
    return builder.buildDocument();
  }

  ///  The Amazon Resource Name (ARN) of the bucket where you want Amazon S3 to store the results.
  late String bucket;

  /// Specify this only in a cross-account scenario (where source and destination bucket owners are not the same), and you want to change replica ownership to the AWS account that owns the destination bucket. If this is not specified in the replication configuration, the replicas are owned by same AWS account that owns the source object.
  AccessControlTranslation? accessControlTranslation;

  /// Destination bucket owner account ID. In a cross-account scenario, if you direct Amazon S3 to change replica ownership to the AWS account that owns the destination bucket by specifying the AccessControlTranslation property, this is the account ID of the destination bucket owner. For more information, see Replication Additional Configuration: Changing the Replica Owner in the Amazon S3 User Guide.
  String? account;

  /// A container that provides information about encryption. If SourceSelectionCriteria is specified, you must specify this element.
  EncryptionConfiguration? encryptionConfiguration;

  ///  A container specifying replication metrics-related settings enabling replication metrics and events.
  Metrics? metrics;

  ///  A container specifying S3 Replication Time Control (S3 RTC), including whether S3 RTC is enabled and the time when all objects and operations on objects must be replicated. Must be specified together with a Metrics block.
  ReplicationTime? replicationTime;

  ///  The storage class to use when replicating objects, such as S3 Standard or reduced redundancy. By default, Amazon S3 uses the storage class of the source object to create the object replica.
  String? storageClass;
}

/// Contains the type of server-side encryption used.
class Encryption {
  Encryption(
    this.encryptionType,
    this.kMSContext,
    this.kMSKeyId,
  );

  Encryption.fromXml(XmlElement? xml) {
    encryptionType = getPropValue<String>(xml, 'EncryptionType');
    kMSContext = getPropValueOrNull<String>(xml, 'KMSContext');
    kMSKeyId = getPropValueOrNull<String>(xml, 'KMSKeyId');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Encryption', nest: () {
      builder.element('EncryptionType', nest: encryptionType);
      builder.element('KMSContext', nest: kMSContext);
      builder.element('KMSKeyId', nest: kMSKeyId);
    });
    return builder.buildDocument();
  }

  /// The server-side encryption algorithm used when storing job results in Amazon S3 (for example, AES256, aws:kms).
  late String encryptionType;

  /// If the encryption type is aws:kms, this optional value can be used to specify the encryption context for the restore results.
  String? kMSContext;

  /// If the encryption type is aws:kms, this optional value specifies the ID of the symmetric encryption customer managed key to use for encryption of job results. Amazon S3 only supports symmetric encryption KMS keys. For more information, see Asymmetric keys in AWS KMS in the AWS Key Management Service Developer Guide.
  String? kMSKeyId;
}

/// Specifies encryption-related information for an Amazon S3 bucket that is a destination for replicated objects.
class EncryptionConfiguration {
  EncryptionConfiguration(
    this.replicaKmsKeyID,
  );

  EncryptionConfiguration.fromXml(XmlElement? xml) {
    replicaKmsKeyID = getPropValueOrNull<String>(xml, 'ReplicaKmsKeyID');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('EncryptionConfiguration', nest: () {
      builder.element('ReplicaKmsKeyID', nest: replicaKmsKeyID);
    });
    return builder.buildDocument();
  }

  /// Specifies the ID (Key ARN or Alias ARN) of the customer managed AWS KMS key stored in AWS Key Management Service (KMS) for the destination bucket. Amazon S3 uses this key to encrypt replica objects. Amazon S3 only supports symmetric encryption KMS keys. For more information, see Asymmetric keys in AWS KMS in the AWS Key Management Service Developer Guide.
  String? replicaKmsKeyID;
}

/// A message that indicates the request is complete and no more messages will be sent. You should not assume that the request is complete until the client receives an EndEvent.
class EndEvent {
  EndEvent();

  EndEvent.fromXml(XmlElement? xml) {}

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('EndEvent', nest: () {});
    return builder.buildDocument();
  }
}

/// Container for all error elements.
class Error {
  Error(
    this.code,
    this.key,
    this.message,
    this.versionId,
  );

  Error.fromXml(XmlElement? xml) {
    code = getPropValueOrNull<String>(xml, 'Code');
    key = getPropValueOrNull<String>(xml, 'Key');
    message = getPropValueOrNull<String>(xml, 'Message');
    versionId = getPropValueOrNull<String>(xml, 'VersionId');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Error', nest: () {
      builder.element('Code', nest: code);
      builder.element('Key', nest: key);
      builder.element('Message', nest: message);
      builder.element('VersionId', nest: versionId);
    });
    return builder.buildDocument();
  }

  /// The error code is a string that uniquely identifies an error condition. It is meant to be read and understood by programs that detect and handle errors by type. The following is a list of Amazon S3 error codes. For more information, see Error responses.
  String? code;

  /// The error key.
  String? key;

  /// The error message contains a generic description of the error condition in English. It is intended for a human audience. Simple programs display the message directly to the end user if they encounter an error condition they don't know how or don't care to handle. Sophisticated programs with more exhaustive error handling and proper internationalization are more likely to ignore the error message.
  String? message;

  /// The version ID of the error.
  String? versionId;
}

/// The error information.
class ErrorDocument {
  ErrorDocument(
    this.key,
  );

  ErrorDocument.fromXml(XmlElement? xml) {
    key = getPropValue<String>(xml, 'Key');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ErrorDocument', nest: () {
      builder.element('Key', nest: key);
    });
    return builder.buildDocument();
  }

  /// The object key name to use when a 4XX class error occurs.
  late String key;
}

/// A container for specifying the configuration for Amazon EventBridge.
class EventBridgeConfiguration {
  EventBridgeConfiguration();

  EventBridgeConfiguration.fromXml(XmlElement? xml) {}

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('EventBridgeConfiguration', nest: () {});
    return builder.buildDocument();
  }
}

/// Optional configuration to replicate existing source bucket objects.
class ExistingObjectReplication {
  ExistingObjectReplication(
    this.status,
  );

  ExistingObjectReplication.fromXml(XmlElement? xml) {
    status = getPropValue<String>(xml, 'Status');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ExistingObjectReplication', nest: () {
      builder.element('Status', nest: status);
    });
    return builder.buildDocument();
  }

  /// Specifies whether Amazon S3 replicates existing source bucket objects.
  late String status;
}

/// Specifies the Amazon S3 object key name to filter on. An object key name is the name assigned to an object in your Amazon S3 bucket. You specify whether to filter on the suffix or prefix of the object key name. A prefix is a specific string of characters at the beginning of an object key name, which you can use to organize objects. For example, you can start the key names of related objects with a prefix, such as 2023- or engineering/. Then, you can use FilterRule to find objects in a bucket with key names that have the same prefix. A suffix is similar to a prefix, but it is at the end of the object key name instead of at the beginning.
class FilterRule {
  FilterRule(
    this.name,
    this.value,
  );

  FilterRule.fromXml(XmlElement? xml) {
    name = getPropValueOrNull<String>(xml, 'Name');
    value = getPropValueOrNull<String>(xml, 'Value');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('FilterRule', nest: () {
      builder.element('Name', nest: name);
      builder.element('Value', nest: value);
    });
    return builder.buildDocument();
  }

  /// The object key name prefix or suffix identifying one or more objects to which the filtering rule applies. The maximum length is 1,024 characters. Overlapping prefixes and suffixes are not supported. For more information, see Configuring Event Notifications in the Amazon S3 User Guide.
  String? name;

  /// The value that the filter searches for in object key names.
  String? value;
}

/// A collection of parts associated with a multipart upload.
class GetObjectAttributesParts {
  GetObjectAttributesParts(
    this.isTruncated,
    this.maxParts,
    this.nextPartNumberMarker,
    this.partNumberMarker,
    this.parts,
    this.totalPartsCount,
  );

  GetObjectAttributesParts.fromXml(XmlElement? xml) {
    isTruncated = getPropValueOrNull<bool>(xml, 'IsTruncated');
    maxParts = getPropValueOrNull<int>(xml, 'MaxParts');
    nextPartNumberMarker = getPropValueOrNull<int>(xml, 'NextPartNumberMarker');
    partNumberMarker = getPropValueOrNull<int>(xml, 'PartNumberMarker');
    parts = getProp(xml, 'Parts')
        ?.children
        .map((c) => ObjectPart.fromXml(c as XmlElement))
        .toList();
    totalPartsCount = getPropValueOrNull<int>(xml, 'TotalPartsCount');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('GetObjectAttributesParts', nest: () {
      builder.element('IsTruncated',
          nest: isTruncated == true ? 'TRUE' : 'FALSE');
      builder.element('MaxParts', nest: maxParts.toString());
      builder.element('NextPartNumberMarker',
          nest: nextPartNumberMarker.toString());
      builder.element('PartNumberMarker', nest: partNumberMarker.toString());
      builder.element('Parts', nest: parts?.map((e) => e.toXml()));
      builder.element('TotalPartsCount', nest: totalPartsCount.toString());
    });
    return builder.buildDocument();
  }

  /// Indicates whether the returned list of parts is truncated. A value of true indicates that the list was truncated. A list can be truncated if the number of parts exceeds the limit returned in the MaxParts element.
  bool? isTruncated;

  /// The maximum number of parts allowed in the response.
  int? maxParts;

  /// When a list is truncated, this element specifies the last part in the list, as well as the value to use for the PartNumberMarker request parameter in a subsequent request.
  int? nextPartNumberMarker;

  /// The marker for the current part.
  int? partNumberMarker;

  /// A container for elements related to a particular part. A response can contain zero or more Parts elements.
  List<ObjectPart>? parts;

  /// The total number of parts.
  int? totalPartsCount;
}

/// Container for S3 Glacier job parameters.
class GlacierJobParameters {
  GlacierJobParameters(
    this.tier,
  );

  GlacierJobParameters.fromXml(XmlElement? xml) {
    tier = getPropValue<String>(xml, 'Tier');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('GlacierJobParameters', nest: () {
      builder.element('Tier', nest: tier);
    });
    return builder.buildDocument();
  }

  /// Retrieval tier at which the restore will be processed.
  late String tier;
}

/// Container for grant information.
class Grant {
  Grant(
    this.grantee,
    this.permission,
  );

  Grant.fromXml(XmlElement? xml) {
    grantee = Grantee.fromXml(getProp(xml, 'Grantee'));
    permission = getPropValueOrNull<String>(xml, 'Permission');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Grant', nest: () {
      builder.element('Grantee', nest: grantee?.toXml());
      builder.element('Permission', nest: permission);
    });
    return builder.buildDocument();
  }

  /// The person being granted permissions.
  Grantee? grantee;

  /// Specifies the permission given to the grantee.
  String? permission;
}

/// Container for the person being granted permissions.
class Grantee {
  Grantee(
    this.type,
    this.displayName,
    this.emailAddress,
    this.iD,
    this.uRI,
  );

  Grantee.fromXml(XmlElement? xml) {
    type = getPropValue<String>(xml, 'Type');
    displayName = getPropValueOrNull<String>(xml, 'DisplayName');
    emailAddress = getPropValueOrNull<String>(xml, 'EmailAddress');
    iD = getPropValueOrNull<String>(xml, 'ID');
    uRI = getPropValueOrNull<String>(xml, 'URI');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Grantee', nest: () {
      builder.element('Type', nest: type);
      builder.element('DisplayName', nest: displayName);
      builder.element('EmailAddress', nest: emailAddress);
      builder.element('ID', nest: iD);
      builder.element('URI', nest: uRI);
    });
    return builder.buildDocument();
  }

  /// Type of grantee
  late String type;

  /// Screen name of the grantee.
  String? displayName;

  /// Email address of the grantee.
  String? emailAddress;

  /// The canonical user ID of the grantee.
  String? iD;

  /// URI of the grantee group.
  String? uRI;
}

/// Container for the Suffix element.
class IndexDocument {
  IndexDocument(
    this.suffix,
  );

  IndexDocument.fromXml(XmlElement? xml) {
    suffix = getPropValue<String>(xml, 'Suffix');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('IndexDocument', nest: () {
      builder.element('Suffix', nest: suffix);
    });
    return builder.buildDocument();
  }

  /// A suffix that is appended to a request that is for a directory on the website endpoint. (For example, if the suffix is index.html and you make a request to samplebucket/images/, the data that is returned will be for the object with the key name images/index.html.) The suffix must not be empty and must not include a slash character.
  late String suffix;
}

/// Container element that identifies who initiated the multipart upload.
class Initiator {
  Initiator(
    this.displayName,
    this.iD,
  );

  Initiator.fromXml(XmlElement? xml) {
    displayName = getPropValueOrNull<String>(xml, 'DisplayName');
    iD = getPropValueOrNull<String>(xml, 'ID');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Initiator', nest: () {
      builder.element('DisplayName', nest: displayName);
      builder.element('ID', nest: iD);
    });
    return builder.buildDocument();
  }

  /// Name of the Principal.
  String? displayName;

  /// If the principal is an AWS account, it provides the Canonical User ID. If the principal is an IAM User, it provides a user ARN value.
  String? iD;
}

/// Describes the serialization format of the object.
class InputSerialization {
  InputSerialization(
    this.compressionType,
    this.cSV,
    this.jSON,
    this.parquet,
  );

  InputSerialization.fromXml(XmlElement? xml) {
    compressionType = getPropValueOrNull<String>(xml, 'CompressionType');
    cSV = CSVInput.fromXml(getProp(xml, 'CSV'));
    jSON = JSONInput.fromXml(getProp(xml, 'JSON'));
    parquet = ParquetInput.fromXml(getProp(xml, 'Parquet'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('InputSerialization', nest: () {
      builder.element('CompressionType', nest: compressionType);
      builder.element('CSV', nest: cSV?.toXml());
      builder.element('JSON', nest: jSON?.toXml());
      builder.element('Parquet', nest: parquet?.toXml());
    });
    return builder.buildDocument();
  }

  /// Specifies object's compression format. Valid values: NONE, GZIP, BZIP2. Default Value: NONE.
  String? compressionType;

  /// Describes the serialization of a CSV-encoded object.
  CSVInput? cSV;

  /// Specifies JSON as object's input serialization format.
  JSONInput? jSON;

  /// Specifies Parquet as object's input serialization format.
  ParquetInput? parquet;
}

/// A container for specifying S3 Intelligent-Tiering filters. The filters determine the subset of objects to which the rule applies.
class IntelligentTieringAndOperator {
  IntelligentTieringAndOperator(
    this.prefix,
    this.tags,
  );

  IntelligentTieringAndOperator.fromXml(XmlElement? xml) {
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    tags = getProp(xml, 'Tags')
        ?.children
        .map((c) => Tag.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('IntelligentTieringAndOperator', nest: () {
      builder.element('Prefix', nest: prefix);
      builder.element('Tags', nest: tags?.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// An object key name prefix that identifies the subset of objects to which the configuration applies.
  String? prefix;

  /// All of these tags must exist in the object's tag set in order for the configuration to apply.
  List<Tag>? tags;
}

/// Specifies the S3 Intelligent-Tiering configuration for an Amazon S3 bucket.
class IntelligentTieringConfiguration {
  IntelligentTieringConfiguration(
    this.id,
    this.status,
    this.tierings,
    this.filter,
  );

  IntelligentTieringConfiguration.fromXml(XmlElement? xml) {
    id = getPropValue<String>(xml, 'Id');
    status = getPropValue<String>(xml, 'Status');
    tierings = getProp(xml, 'Tierings')!
        .children
        .map((c) => Tiering.fromXml(c as XmlElement))
        .toList();
    filter = IntelligentTieringFilter.fromXml(getProp(xml, 'Filter'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('IntelligentTieringConfiguration', nest: () {
      builder.element('Id', nest: id);
      builder.element('Status', nest: status);
      builder.element('Tierings', nest: tierings.map((e) => e.toXml()));
      builder.element('Filter', nest: filter?.toXml());
    });
    return builder.buildDocument();
  }

  /// The ID used to identify the S3 Intelligent-Tiering configuration.
  late String id;

  /// Specifies the status of the configuration.
  late String status;

  /// Specifies the S3 Intelligent-Tiering storage class tier of the configuration.
  late List<Tiering> tierings;

  /// Specifies a bucket filter. The configuration only includes objects that meet the filter's criteria.
  IntelligentTieringFilter? filter;
}

/// The Filter is used to identify objects that the S3 Intelligent-Tiering configuration applies to.
class IntelligentTieringFilter {
  IntelligentTieringFilter(
    this.and,
    this.prefix,
    this.tag,
  );

  IntelligentTieringFilter.fromXml(XmlElement? xml) {
    and = IntelligentTieringAndOperator.fromXml(getProp(xml, 'And'));
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    tag = Tag.fromXml(getProp(xml, 'Tag'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('IntelligentTieringFilter', nest: () {
      builder.element('And', nest: and?.toXml());
      builder.element('Prefix', nest: prefix);
      builder.element('Tag', nest: tag?.toXml());
    });
    return builder.buildDocument();
  }

  /// A conjunction (logical AND) of predicates, which is used in evaluating a metrics filter. The operator must have at least two predicates, and an object must match all of the predicates in order for the filter to apply.
  IntelligentTieringAndOperator? and;

  /// An object key name prefix that identifies the subset of objects to which the rule applies.
  String? prefix;

  /// A container of a key value name pair.
  Tag? tag;
}

/// Specifies the inventory configuration for an Amazon S3 bucket. For more information, see GET Bucket inventory in the Amazon S3 API Reference.
class InventoryConfiguration {
  InventoryConfiguration(
    this.destination,
    this.id,
    this.includedObjectVersions,
    this.isEnabled,
    this.schedule,
    this.filter,
    this.optionalFields,
  );

  InventoryConfiguration.fromXml(XmlElement? xml) {
    destination = InventoryDestination.fromXml(getProp(xml, 'Destination'));
    id = getPropValue<String>(xml, 'Id');
    includedObjectVersions =
        getPropValue<String>(xml, 'IncludedObjectVersions');
    isEnabled = getPropValue<bool>(xml, 'IsEnabled');
    schedule = InventorySchedule.fromXml(getProp(xml, 'Schedule'));
    filter = InventoryFilter.fromXml(getProp(xml, 'Filter'));
    optionalFields = getPropValueOrNull<List<String>>(xml, 'OptionalFields');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('InventoryConfiguration', nest: () {
      builder.element('Destination', nest: destination.toXml());
      builder.element('Id', nest: id);
      builder.element('IncludedObjectVersions', nest: includedObjectVersions);
      builder.element('IsEnabled', nest: isEnabled == true ? 'TRUE' : 'FALSE');
      builder.element('Schedule', nest: schedule.toXml());
      builder.element('Filter', nest: filter?.toXml());
      builder.element('OptionalFields', nest: optionalFields);
    });
    return builder.buildDocument();
  }

  /// Contains information about where to publish the inventory results.
  late InventoryDestination destination;

  /// The ID used to identify the inventory configuration.
  late String id;

  /// Object versions to include in the inventory list. If set to All, the list includes all the object versions, which adds the version-related fields VersionId, IsLatest, and DeleteMarker to the list. If set to Current, the list does not contain these version-related fields.
  late String includedObjectVersions;

  /// Specifies whether the inventory is enabled or disabled. If set to True, an inventory list is generated. If set to False, no inventory list is generated.
  late bool isEnabled;

  /// Specifies the schedule for generating inventory results.
  late InventorySchedule schedule;

  /// Specifies an inventory filter. The inventory only includes objects that meet the filter's criteria.
  InventoryFilter? filter;

  /// Contains the optional fields that are included in the inventory results.
  List<String>? optionalFields;
}

/// Specifies the inventory configuration for an Amazon S3 bucket.
class InventoryDestination {
  InventoryDestination(
    this.s3BucketDestination,
  );

  InventoryDestination.fromXml(XmlElement? xml) {
    s3BucketDestination = InventoryS3BucketDestination.fromXml(
        getProp(xml, 'S3BucketDestination'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('InventoryDestination', nest: () {
      builder.element('S3BucketDestination', nest: s3BucketDestination.toXml());
    });
    return builder.buildDocument();
  }

  /// Contains the bucket name, file format, bucket owner (optional), and prefix (optional) where inventory results are published.
  late InventoryS3BucketDestination s3BucketDestination;
}

/// Contains the type of server-side encryption used to encrypt the inventory results.
class InventoryEncryption {
  InventoryEncryption(
    this.sSEKMS,
    this.sSES3,
  );

  InventoryEncryption.fromXml(XmlElement? xml) {
    sSEKMS = SSEKMS.fromXml(getProp(xml, 'SSEKMS'));
    sSES3 = SSES3.fromXml(getProp(xml, 'SSES3'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('InventoryEncryption', nest: () {
      builder.element('SSEKMS', nest: sSEKMS?.toXml());
      builder.element('SSES3', nest: sSES3?.toXml());
    });
    return builder.buildDocument();
  }

  /// Specifies the use of SSE-KMS to encrypt delivered inventory reports.
  SSEKMS? sSEKMS;

  /// Specifies the use of SSE-S3 to encrypt delivered inventory reports.
  SSES3? sSES3;
}

/// Specifies an inventory filter. The inventory only includes objects that meet the filter's criteria.
class InventoryFilter {
  InventoryFilter(
    this.prefix,
  );

  InventoryFilter.fromXml(XmlElement? xml) {
    prefix = getPropValue<String>(xml, 'Prefix');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('InventoryFilter', nest: () {
      builder.element('Prefix', nest: prefix);
    });
    return builder.buildDocument();
  }

  /// The prefix that an object must have to be included in the inventory results.
  late String prefix;
}

/// Contains the bucket name, file format, bucket owner (optional), and prefix (optional) where inventory results are published.
class InventoryS3BucketDestination {
  InventoryS3BucketDestination(
    this.bucket,
    this.format,
    this.accountId,
    this.encryption,
    this.prefix,
  );

  InventoryS3BucketDestination.fromXml(XmlElement? xml) {
    bucket = getPropValue<String>(xml, 'Bucket');
    format = getPropValue<String>(xml, 'Format');
    accountId = getPropValueOrNull<String>(xml, 'AccountId');
    encryption = InventoryEncryption.fromXml(getProp(xml, 'Encryption'));
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('InventoryS3BucketDestination', nest: () {
      builder.element('Bucket', nest: bucket);
      builder.element('Format', nest: format);
      builder.element('AccountId', nest: accountId);
      builder.element('Encryption', nest: encryption?.toXml());
      builder.element('Prefix', nest: prefix);
    });
    return builder.buildDocument();
  }

  /// The Amazon Resource Name (ARN) of the bucket where inventory results will be published.
  late String bucket;

  /// Specifies the output format of the inventory results.
  late String format;

  /// The account ID that owns the destination S3 bucket. If no account ID is provided, the owner is not validated before exporting data.
  String? accountId;

  /// Contains the type of server-side encryption used to encrypt the inventory results.
  InventoryEncryption? encryption;

  /// The prefix that is prepended to all inventory results.
  String? prefix;
}

/// Specifies the schedule for generating inventory results.
class InventorySchedule {
  InventorySchedule(
    this.frequency,
  );

  InventorySchedule.fromXml(XmlElement? xml) {
    frequency = getPropValue<String>(xml, 'Frequency');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('InventorySchedule', nest: () {
      builder.element('Frequency', nest: frequency);
    });
    return builder.buildDocument();
  }

  /// Specifies how frequently inventory results are produced.
  late String frequency;
}

/// Specifies JSON as object's input serialization format.
class JSONInput {
  JSONInput(
    this.type,
  );

  JSONInput.fromXml(XmlElement? xml) {
    type = getPropValueOrNull<String>(xml, 'Type');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('JSONInput', nest: () {
      builder.element('Type', nest: type);
    });
    return builder.buildDocument();
  }

  /// The type of JSON. Valid values: Document, Lines.
  String? type;
}

/// Specifies JSON as request's output serialization format.
class JSONOutput {
  JSONOutput(
    this.recordDelimiter,
  );

  JSONOutput.fromXml(XmlElement? xml) {
    recordDelimiter = getPropValueOrNull<String>(xml, 'RecordDelimiter');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('JSONOutput', nest: () {
      builder.element('RecordDelimiter', nest: recordDelimiter);
    });
    return builder.buildDocument();
  }

  /// The value used to separate individual records in the output. If no value is specified, Amazon S3 uses a newline character ('\n').
  String? recordDelimiter;
}

/// A container for specifying the configuration for AWS Lambda notifications.
class LambdaFunctionConfiguration {
  LambdaFunctionConfiguration(
    this.events,
    this.lambdaFunctionArn,
    this.filter,
    this.id,
  );

  LambdaFunctionConfiguration.fromXml(XmlElement? xml) {
    events = getPropValue<List<String>>(xml, 'Events');
    lambdaFunctionArn = getPropValue<String>(xml, 'LambdaFunctionArn');
    filter = NotificationConfigurationFilter.fromXml(getProp(xml, 'Filter'));
    id = getPropValueOrNull<String>(xml, 'Id');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('LambdaFunctionConfiguration', nest: () {
      builder.element('Events', nest: events);
      builder.element('LambdaFunctionArn', nest: lambdaFunctionArn);
      builder.element('Filter', nest: filter?.toXml());
      builder.element('Id', nest: id);
    });
    return builder.buildDocument();
  }

  /// The Amazon S3 bucket event for which to invoke the AWS Lambda function. For more information, see Supported Event Types in the Amazon S3 User Guide.
  late List<String> events;

  /// The Amazon Resource Name (ARN) of the AWS Lambda function that Amazon S3 invokes when the specified event type occurs.
  late String lambdaFunctionArn;

  /// Specifies object key name filtering rules. For information about key name filtering, see Configuring event notifications using object key name filtering in the Amazon S3 User Guide.
  NotificationConfigurationFilter? filter;

  /// An optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon S3 will assign an ID.
  String? id;
}

/// Container for lifecycle rules. You can add as many as 1000 rules.
class LifecycleConfiguration {
  LifecycleConfiguration(
    this.rules,
  );

  LifecycleConfiguration.fromXml(XmlElement? xml) {
    rules = getProp(xml, 'Rules')!
        .children
        .map((c) => Rule.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('LifecycleConfiguration', nest: () {
      builder.element('Rules', nest: rules.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// Specifies lifecycle configuration rules for an Amazon S3 bucket.
  late List<Rule> rules;
}

/// Container for the expiration for the lifecycle of the object.
class LifecycleExpiration {
  LifecycleExpiration(
    this.date,
    this.days,
    this.expiredObjectDeleteMarker,
  );

  LifecycleExpiration.fromXml(XmlElement? xml) {
    date = getPropValueOrNull<DateTime>(xml, 'Date');
    days = getPropValueOrNull<int>(xml, 'Days');
    expiredObjectDeleteMarker =
        getPropValueOrNull<bool>(xml, 'ExpiredObjectDeleteMarker');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('LifecycleExpiration', nest: () {
      builder.element('Date', nest: date?.toIso8601String());
      builder.element('Days', nest: days.toString());
      builder.element('ExpiredObjectDeleteMarker',
          nest: expiredObjectDeleteMarker == true ? 'TRUE' : 'FALSE');
    });
    return builder.buildDocument();
  }

  /// Indicates at what date the object is to be moved or deleted. The date value must conform to the ISO 8601 format. The time is always midnight UTC.
  DateTime? date;

  /// Indicates the lifetime, in days, of the objects that are subject to the rule. The value must be a non-zero positive integer.
  int? days;

  /// Indicates whether Amazon S3 will remove a delete marker with no noncurrent versions. If set to true, the delete marker will be expired; if set to false the policy takes no action. This cannot be specified with Days or Date in a Lifecycle Expiration Policy.
  bool? expiredObjectDeleteMarker;
}

/// A lifecycle rule for individual objects in an Amazon S3 bucket.
class LifecycleRule {
  LifecycleRule(
    this.status,
    this.abortIncompleteMultipartUpload,
    this.expiration,
    this.filter,
    this.iD,
    this.noncurrentVersionExpiration,
    this.noncurrentVersionTransitions,
    this.prefix,
    this.transitions,
  );

  LifecycleRule.fromXml(XmlElement? xml) {
    status = getPropValue<String>(xml, 'Status');
    abortIncompleteMultipartUpload = AbortIncompleteMultipartUpload.fromXml(
        getProp(xml, 'AbortIncompleteMultipartUpload'));
    expiration = LifecycleExpiration.fromXml(getProp(xml, 'Expiration'));
    filter = LifecycleRuleFilter.fromXml(getProp(xml, 'Filter'));
    iD = getPropValueOrNull<String>(xml, 'ID');
    noncurrentVersionExpiration = NoncurrentVersionExpiration.fromXml(
        getProp(xml, 'NoncurrentVersionExpiration'));
    noncurrentVersionTransitions = getProp(xml, 'NoncurrentVersionTransitions')
        ?.children
        .map((c) => NoncurrentVersionTransition.fromXml(c as XmlElement))
        .toList();
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    transitions = getProp(xml, 'Transitions')
        ?.children
        .map((c) => Transition.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('LifecycleRule', nest: () {
      builder.element('Status', nest: status);
      builder.element('AbortIncompleteMultipartUpload',
          nest: abortIncompleteMultipartUpload?.toXml());
      builder.element('Expiration', nest: expiration?.toXml());
      builder.element('Filter', nest: filter?.toXml());
      builder.element('ID', nest: iD);
      builder.element('NoncurrentVersionExpiration',
          nest: noncurrentVersionExpiration?.toXml());
      builder.element('NoncurrentVersionTransitions',
          nest: noncurrentVersionTransitions?.map((e) => e.toXml()));
      builder.element('Prefix', nest: prefix);
      builder.element('Transitions', nest: transitions?.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// If 'Enabled', the rule is currently being applied. If 'Disabled', the rule is not currently being applied.
  late String status;

  /// Specifies the days since the initiation of an incomplete multipart upload that Amazon S3 will wait before permanently removing all parts of the upload. For more information, see Aborting Incomplete Multipart Uploads Using a Bucket Lifecycle Configuration in the Amazon S3 User Guide.
  AbortIncompleteMultipartUpload? abortIncompleteMultipartUpload;

  /// Specifies the expiration for the lifecycle of the object in the form of date, days and, whether the object has a delete marker.
  LifecycleExpiration? expiration;

  /// The Filter is used to identify objects that a Lifecycle Rule applies to. A Filter must have exactly one of Prefix, Tag, or And specified. Filter is required if the LifecycleRule does not contain a Prefix element.
  LifecycleRuleFilter? filter;

  /// Unique identifier for the rule. The value cannot be longer than 255 characters.
  String? iD;

  /// Specifies when noncurrent object versions expire. Upon expiration, Amazon S3 permanently deletes the noncurrent object versions. You set this lifecycle configuration action on a bucket that has versioning enabled (or suspended) to request that Amazon S3 delete noncurrent object versions at a specific period in the object's lifetime.
  NoncurrentVersionExpiration? noncurrentVersionExpiration;

  ///  Specifies the transition rule for the lifecycle rule that describes when noncurrent objects transition to a specific storage class. If your bucket is versioning-enabled (or versioning is suspended), you can set this action to request that Amazon S3 transition noncurrent object versions to a specific storage class at a set period in the object's lifetime.
  List<NoncurrentVersionTransition>? noncurrentVersionTransitions;

  ///  This member has been deprecated.
  String? prefix;

  /// Specifies when an Amazon S3 object transitions to a specified storage class.
  List<Transition>? transitions;
}

/// This is used in a Lifecycle Rule Filter to apply a logical AND to two or more predicates. The Lifecycle Rule will apply to any object matching all of the predicates configured inside the And operator.
class LifecycleRuleAndOperator {
  LifecycleRuleAndOperator(
    this.objectSizeGreaterThan,
    this.objectSizeLessThan,
    this.prefix,
    this.tags,
  );

  LifecycleRuleAndOperator.fromXml(XmlElement? xml) {
    objectSizeGreaterThan =
        getPropValueOrNull<int>(xml, 'ObjectSizeGreaterThan');
    objectSizeLessThan = getPropValueOrNull<int>(xml, 'ObjectSizeLessThan');
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    tags = getProp(xml, 'Tags')
        ?.children
        .map((c) => Tag.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('LifecycleRuleAndOperator', nest: () {
      builder.element('ObjectSizeGreaterThan',
          nest: objectSizeGreaterThan.toString());
      builder.element('ObjectSizeLessThan',
          nest: objectSizeLessThan.toString());
      builder.element('Prefix', nest: prefix);
      builder.element('Tags', nest: tags?.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// Minimum object size to which the rule applies.
  int? objectSizeGreaterThan;

  /// Maximum object size to which the rule applies.
  int? objectSizeLessThan;

  /// Prefix identifying one or more objects to which the rule applies.
  String? prefix;

  /// All of these tags must exist in the object's tag set in order for the rule to apply.
  List<Tag>? tags;
}

/// The Filter is used to identify objects that a Lifecycle Rule applies to. A Filter can have exactly one of Prefix, Tag, ObjectSizeGreaterThan, ObjectSizeLessThan, or And specified. If the Filter element is left empty, the Lifecycle Rule applies to all objects in the bucket.
class LifecycleRuleFilter {
  LifecycleRuleFilter(
    this.and,
    this.objectSizeGreaterThan,
    this.objectSizeLessThan,
    this.prefix,
    this.tag,
  );

  LifecycleRuleFilter.fromXml(XmlElement? xml) {
    and = LifecycleRuleAndOperator.fromXml(getProp(xml, 'And'));
    objectSizeGreaterThan =
        getPropValueOrNull<int>(xml, 'ObjectSizeGreaterThan');
    objectSizeLessThan = getPropValueOrNull<int>(xml, 'ObjectSizeLessThan');
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    tag = Tag.fromXml(getProp(xml, 'Tag'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('LifecycleRuleFilter', nest: () {
      builder.element('And', nest: and?.toXml());
      builder.element('ObjectSizeGreaterThan',
          nest: objectSizeGreaterThan.toString());
      builder.element('ObjectSizeLessThan',
          nest: objectSizeLessThan.toString());
      builder.element('Prefix', nest: prefix);
      builder.element('Tag', nest: tag?.toXml());
    });
    return builder.buildDocument();
  }

  /// This is used in a Lifecycle Rule Filter to apply a logical AND to two or more predicates. The Lifecycle Rule will apply to any object matching all of the predicates configured inside the And operator.
  LifecycleRuleAndOperator? and;

  /// Minimum object size to which the rule applies.
  int? objectSizeGreaterThan;

  /// Maximum object size to which the rule applies.
  int? objectSizeLessThan;

  /// Prefix identifying one or more objects to which the rule applies.
  String? prefix;

  /// This tag must exist in the object's tag set in order for the rule to apply.
  Tag? tag;
}

/// Specifies the location where the bucket will be created.
class LocationInfo {
  LocationInfo(
    this.name,
    this.type,
  );

  LocationInfo.fromXml(XmlElement? xml) {
    name = getPropValueOrNull<String>(xml, 'Name');
    type = getPropValueOrNull<String>(xml, 'Type');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('LocationInfo', nest: () {
      builder.element('Name', nest: name);
      builder.element('Type', nest: type);
    });
    return builder.buildDocument();
  }

  /// The name of the location where the bucket will be created.
  String? name;

  /// The type of location where the bucket will be created.
  String? type;
}

/// Describes where logs are stored and the prefix that Amazon S3 assigns to all log object keys for a bucket. For more information, see PUT Bucket logging in the Amazon S3 API Reference.
class LoggingEnabled {
  LoggingEnabled(
    this.targetBucket,
    this.targetPrefix,
    this.targetGrants,
    this.targetObjectKeyFormat,
  );

  LoggingEnabled.fromXml(XmlElement? xml) {
    targetBucket = getPropValue<String>(xml, 'TargetBucket');
    targetPrefix = getPropValue<String>(xml, 'TargetPrefix');
    targetGrants = getProp(xml, 'TargetGrants')
        ?.children
        .map((c) => TargetGrant.fromXml(c as XmlElement))
        .toList();
    targetObjectKeyFormat =
        TargetObjectKeyFormat.fromXml(getProp(xml, 'TargetObjectKeyFormat'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('LoggingEnabled', nest: () {
      builder.element('TargetBucket', nest: targetBucket);
      builder.element('TargetPrefix', nest: targetPrefix);
      builder.element('TargetGrants',
          nest: targetGrants?.map((e) => e.toXml()));
      builder.element('TargetObjectKeyFormat',
          nest: targetObjectKeyFormat?.toXml());
    });
    return builder.buildDocument();
  }

  /// Specifies the bucket where you want Amazon S3 to store server access logs. You can have your logs delivered to any bucket that you own, including the same bucket that is being logged. You can also configure multiple buckets to deliver their logs to the same target bucket. In this case, you should choose a different TargetPrefix for each source bucket so that the delivered log files can be distinguished by key.
  late String targetBucket;

  /// A prefix for all log object keys. If you store log files from multiple Amazon S3 buckets in a single bucket, you can use a prefix to distinguish which log files came from which bucket.
  late String targetPrefix;

  /// Container for granting information.
  List<TargetGrant>? targetGrants;

  /// Amazon S3 key format for log objects.
  TargetObjectKeyFormat? targetObjectKeyFormat;
}

/// A metadata key-value pair to store with an object.
class MetadataEntry {
  MetadataEntry(
    this.name,
    this.value,
  );

  MetadataEntry.fromXml(XmlElement? xml) {
    name = getPropValueOrNull<String>(xml, 'Name');
    value = getPropValueOrNull<String>(xml, 'Value');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('MetadataEntry', nest: () {
      builder.element('Name', nest: name);
      builder.element('Value', nest: value);
    });
    return builder.buildDocument();
  }

  /// Name of the object.
  String? name;

  /// Value of the object.
  String? value;
}

///  A container specifying replication metrics-related settings enabling replication metrics and events.
class Metrics {
  Metrics(
    this.status,
    this.eventThreshold,
  );

  Metrics.fromXml(XmlElement? xml) {
    status = getPropValue<String>(xml, 'Status');
    eventThreshold =
        ReplicationTimeValue.fromXml(getProp(xml, 'EventThreshold'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Metrics', nest: () {
      builder.element('Status', nest: status);
      builder.element('EventThreshold', nest: eventThreshold?.toXml());
    });
    return builder.buildDocument();
  }

  ///  Specifies whether the replication metrics are enabled.
  late String status;

  ///  A container specifying the time threshold for emitting the s3:Replication:OperationMissedThreshold event.
  ReplicationTimeValue? eventThreshold;
}

/// A conjunction (logical AND) of predicates, which is used in evaluating a metrics filter. The operator must have at least two predicates, and an object must match all of the predicates in order for the filter to apply.
class MetricsAndOperator {
  MetricsAndOperator(
    this.accessPointArn,
    this.prefix,
    this.tags,
  );

  MetricsAndOperator.fromXml(XmlElement? xml) {
    accessPointArn = getPropValueOrNull<String>(xml, 'AccessPointArn');
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    tags = getProp(xml, 'Tags')
        ?.children
        .map((c) => Tag.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('MetricsAndOperator', nest: () {
      builder.element('AccessPointArn', nest: accessPointArn);
      builder.element('Prefix', nest: prefix);
      builder.element('Tags', nest: tags?.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// The access point ARN used when evaluating an AND predicate.
  String? accessPointArn;

  /// The prefix used when evaluating an AND predicate.
  String? prefix;

  /// The list of tags used when evaluating an AND predicate.
  List<Tag>? tags;
}

/// Specifies a metrics configuration for the CloudWatch request metrics (specified by the metrics configuration ID) from an Amazon S3 bucket. If you're updating an existing metrics configuration, note that this is a full replacement of the existing metrics configuration. If you don't include the elements you want to keep, they are erased. For more information, see PutBucketMetricsConfiguration.
class MetricsConfiguration {
  MetricsConfiguration(
    this.id,
    this.filter,
  );

  MetricsConfiguration.fromXml(XmlElement? xml) {
    id = getPropValue<String>(xml, 'Id');
    filter = MetricsFilter.fromXml(getProp(xml, 'Filter'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('MetricsConfiguration', nest: () {
      builder.element('Id', nest: id);
      builder.element('Filter', nest: filter?.toXml());
    });
    return builder.buildDocument();
  }

  /// The ID used to identify the metrics configuration. The ID has a 64 character limit and can only contain letters, numbers, periods, dashes, and underscores.
  late String id;

  /// Specifies a metrics configuration filter. The metrics configuration will only include objects that meet the filter's criteria. A filter must be a prefix, an object tag, an access point ARN, or a conjunction (MetricsAndOperator).
  MetricsFilter? filter;
}

/// Specifies a metrics configuration filter. The metrics configuration only includes objects that meet the filter's criteria. A filter must be a prefix, an object tag, an access point ARN, or a conjunction (MetricsAndOperator). For more information, see PutBucketMetricsConfiguration.
class MetricsFilter {
  MetricsFilter(
    this.accessPointArn,
    this.and,
    this.prefix,
    this.tag,
  );

  MetricsFilter.fromXml(XmlElement? xml) {
    accessPointArn = getPropValueOrNull<String>(xml, 'AccessPointArn');
    and = MetricsAndOperator.fromXml(getProp(xml, 'And'));
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    tag = Tag.fromXml(getProp(xml, 'Tag'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('MetricsFilter', nest: () {
      builder.element('AccessPointArn', nest: accessPointArn);
      builder.element('And', nest: and?.toXml());
      builder.element('Prefix', nest: prefix);
      builder.element('Tag', nest: tag?.toXml());
    });
    return builder.buildDocument();
  }

  /// The access point ARN used when evaluating a metrics filter.
  String? accessPointArn;

  /// A conjunction (logical AND) of predicates, which is used in evaluating a metrics filter. The operator must have at least two predicates, and an object must match all of the predicates in order for the filter to apply.
  MetricsAndOperator? and;

  /// The prefix used when evaluating a metrics filter.
  String? prefix;

  /// The tag used when evaluating a metrics filter.
  Tag? tag;
}

/// Container for the MultipartUpload for the Amazon S3 object.
class MultipartUpload {
  MultipartUpload(
    this.checksumAlgorithm,
    this.initiated,
    this.initiator,
    this.key,
    this.owner,
    this.storageClass,
    this.uploadId,
  );

  MultipartUpload.fromXml(XmlElement? xml) {
    checksumAlgorithm = getPropValueOrNull<String>(xml, 'ChecksumAlgorithm');
    initiated = getPropValueOrNull<DateTime>(xml, 'Initiated');
    initiator = Initiator.fromXml(getProp(xml, 'Initiator'));
    key = getPropValueOrNull<String>(xml, 'Key');
    owner = Owner.fromXml(getProp(xml, 'Owner'));
    storageClass = getPropValueOrNull<String>(xml, 'StorageClass');
    uploadId = getPropValueOrNull<String>(xml, 'UploadId');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('MultipartUpload', nest: () {
      builder.element('ChecksumAlgorithm', nest: checksumAlgorithm);
      builder.element('Initiated', nest: initiated?.toIso8601String());
      builder.element('Initiator', nest: initiator?.toXml());
      builder.element('Key', nest: key);
      builder.element('Owner', nest: owner?.toXml());
      builder.element('StorageClass', nest: storageClass);
      builder.element('UploadId', nest: uploadId);
    });
    return builder.buildDocument();
  }

  /// The algorithm that was used to create a checksum of the object.
  String? checksumAlgorithm;

  /// Date and time at which the multipart upload was initiated.
  DateTime? initiated;

  /// Identifies who initiated the multipart upload.
  Initiator? initiator;

  /// Key of the object for which the multipart upload was initiated.
  String? key;

  /// Specifies the owner of the object that is part of the multipart upload.
  Owner? owner;

  /// The class of storage used to store the object.
  String? storageClass;

  /// Upload ID that identifies the multipart upload.
  String? uploadId;
}

/// Specifies when noncurrent object versions expire. Upon expiration, Amazon S3 permanently deletes the noncurrent object versions. You set this lifecycle configuration action on a bucket that has versioning enabled (or suspended) to request that Amazon S3 delete noncurrent object versions at a specific period in the object's lifetime.
class NoncurrentVersionExpiration {
  NoncurrentVersionExpiration(
    this.newerNoncurrentVersions,
    this.noncurrentDays,
  );

  NoncurrentVersionExpiration.fromXml(XmlElement? xml) {
    newerNoncurrentVersions =
        getPropValueOrNull<int>(xml, 'NewerNoncurrentVersions');
    noncurrentDays = getPropValueOrNull<int>(xml, 'NoncurrentDays');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('NoncurrentVersionExpiration', nest: () {
      builder.element('NewerNoncurrentVersions',
          nest: newerNoncurrentVersions.toString());
      builder.element('NoncurrentDays', nest: noncurrentDays.toString());
    });
    return builder.buildDocument();
  }

  /// Specifies how many noncurrent versions Amazon S3 will retain. You can specify up to 100 noncurrent versions to retain. Amazon S3 will permanently delete any additional noncurrent versions beyond the specified number to retain. For more information about noncurrent versions, see Lifecycle configuration elements in the Amazon S3 User Guide.
  int? newerNoncurrentVersions;

  /// Specifies the number of days an object is noncurrent before Amazon S3 can perform the associated action. The value must be a non-zero positive integer. For information about the noncurrent days calculations, see How Amazon S3 Calculates When an Object Became Noncurrent in the Amazon S3 User Guide.
  int? noncurrentDays;
}

/// Container for the transition rule that describes when noncurrent objects transition to the STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER_IR, GLACIER, or DEEP_ARCHIVE storage class. If your bucket is versioning-enabled (or versioning is suspended), you can set this action to request that Amazon S3 transition noncurrent object versions to the STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER_IR, GLACIER, or DEEP_ARCHIVE storage class at a specific period in the object's lifetime.
class NoncurrentVersionTransition {
  NoncurrentVersionTransition(
    this.newerNoncurrentVersions,
    this.noncurrentDays,
    this.storageClass,
  );

  NoncurrentVersionTransition.fromXml(XmlElement? xml) {
    newerNoncurrentVersions =
        getPropValueOrNull<int>(xml, 'NewerNoncurrentVersions');
    noncurrentDays = getPropValueOrNull<int>(xml, 'NoncurrentDays');
    storageClass = getPropValueOrNull<String>(xml, 'StorageClass');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('NoncurrentVersionTransition', nest: () {
      builder.element('NewerNoncurrentVersions',
          nest: newerNoncurrentVersions.toString());
      builder.element('NoncurrentDays', nest: noncurrentDays.toString());
      builder.element('StorageClass', nest: storageClass);
    });
    return builder.buildDocument();
  }

  /// Specifies how many noncurrent versions Amazon S3 will retain in the same storage class before transitioning objects. You can specify up to 100 noncurrent versions to retain. Amazon S3 will transition any additional noncurrent versions beyond the specified number to retain. For more information about noncurrent versions, see Lifecycle configuration elements in the Amazon S3 User Guide.
  int? newerNoncurrentVersions;

  /// Specifies the number of days an object is noncurrent before Amazon S3 can perform the associated action. For information about the noncurrent days calculations, see How Amazon S3 Calculates How Long an Object Has Been Noncurrent in the Amazon S3 User Guide.
  int? noncurrentDays;

  /// The class of storage used to store the object.
  String? storageClass;
}

/// A container for specifying the notification configuration of the bucket. If this element is empty, notifications are turned off for the bucket.
class NotificationConfiguration {
  NotificationConfiguration(
    this.eventBridgeConfiguration,
    this.lambdaFunctionConfigurations,
    this.queueConfigurations,
    this.topicConfigurations,
  );

  NotificationConfiguration.fromXml(XmlElement? xml) {
    eventBridgeConfiguration = EventBridgeConfiguration.fromXml(
        getProp(xml, 'EventBridgeConfiguration'));
    lambdaFunctionConfigurations = getProp(xml, 'LambdaFunctionConfigurations')
        ?.children
        .map((c) => LambdaFunctionConfiguration.fromXml(c as XmlElement))
        .toList();
    queueConfigurations = getProp(xml, 'QueueConfigurations')
        ?.children
        .map((c) => QueueConfiguration.fromXml(c as XmlElement))
        .toList();
    topicConfigurations = getProp(xml, 'TopicConfigurations')
        ?.children
        .map((c) => TopicConfiguration.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('NotificationConfiguration', nest: () {
      builder.element('EventBridgeConfiguration',
          nest: eventBridgeConfiguration?.toXml());
      builder.element('LambdaFunctionConfigurations',
          nest: lambdaFunctionConfigurations?.map((e) => e.toXml()));
      builder.element('QueueConfigurations',
          nest: queueConfigurations?.map((e) => e.toXml()));
      builder.element('TopicConfigurations',
          nest: topicConfigurations?.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// Enables delivery of events to Amazon EventBridge.
  EventBridgeConfiguration? eventBridgeConfiguration;

  /// Describes the AWS Lambda functions to invoke and the events for which to invoke them.
  List<LambdaFunctionConfiguration>? lambdaFunctionConfigurations;

  /// The Amazon Simple Queue Service queues to publish messages to and the events for which to publish messages.
  List<QueueConfiguration>? queueConfigurations;

  /// The topic to which notifications are sent and the events for which notifications are generated.
  List<TopicConfiguration>? topicConfigurations;
}

/// Container for specifying the AWS Lambda notification configuration.
class NotificationConfigurationDeprecated {
  NotificationConfigurationDeprecated(
    this.cloudFunctionConfiguration,
    this.queueConfiguration,
    this.topicConfiguration,
  );

  NotificationConfigurationDeprecated.fromXml(XmlElement? xml) {
    cloudFunctionConfiguration = CloudFunctionConfiguration.fromXml(
        getProp(xml, 'CloudFunctionConfiguration'));
    queueConfiguration = QueueConfigurationDeprecated.fromXml(
        getProp(xml, 'QueueConfiguration'));
    topicConfiguration = TopicConfigurationDeprecated.fromXml(
        getProp(xml, 'TopicConfiguration'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('NotificationConfigurationDeprecated', nest: () {
      builder.element('CloudFunctionConfiguration',
          nest: cloudFunctionConfiguration?.toXml());
      builder.element('QueueConfiguration', nest: queueConfiguration?.toXml());
      builder.element('TopicConfiguration', nest: topicConfiguration?.toXml());
    });
    return builder.buildDocument();
  }

  /// Container for specifying the AWS Lambda notification configuration.
  CloudFunctionConfiguration? cloudFunctionConfiguration;

  /// This data type is deprecated. This data type specifies the configuration for publishing messages to an Amazon Simple Queue Service (Amazon SQS) queue when Amazon S3 detects specified events.
  QueueConfigurationDeprecated? queueConfiguration;

  /// This data type is deprecated. A container for specifying the configuration for publication of messages to an Amazon Simple Notification Service (Amazon SNS) topic when Amazon S3 detects specified events.
  TopicConfigurationDeprecated? topicConfiguration;
}

/// Specifies object key name filtering rules. For information about key name filtering, see Configuring event notifications using object key name filtering in the Amazon S3 User Guide.
class NotificationConfigurationFilter {
  NotificationConfigurationFilter(
    this.key,
  );

  NotificationConfigurationFilter.fromXml(XmlElement? xml) {
    key = S3KeyFilter.fromXml(getProp(xml, 'Key'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('NotificationConfigurationFilter', nest: () {
      builder.element('Key', nest: key?.toXml());
    });
    return builder.buildDocument();
  }

  /// A container for object key name prefix and suffix filtering rules.
  S3KeyFilter? key;
}

/// An object consists of data and its descriptive metadata.
class Object {
  Object(
    this.checksumAlgorithm,
    this.eTag,
    this.key,
    this.lastModified,
    this.owner,
    this.restoreStatus,
    this.size,
    this.storageClass,
  );

  Object.fromXml(XmlElement? xml) {
    checksumAlgorithm =
        getPropValueOrNull<List<String>>(xml, 'ChecksumAlgorithm');
    eTag = getPropValueOrNull<String>(xml, 'ETag');
    key = getPropValueOrNull<String>(xml, 'Key');
    lastModified = getPropValueOrNull<DateTime>(xml, 'LastModified');
    owner = Owner.fromXml(getProp(xml, 'Owner'));
    restoreStatus = RestoreStatus.fromXml(getProp(xml, 'RestoreStatus'));
    size = getPropValueOrNull<int>(xml, 'Size');
    storageClass = getPropValueOrNull<String>(xml, 'StorageClass');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Object', nest: () {
      builder.element('ChecksumAlgorithm', nest: checksumAlgorithm);
      builder.element('ETag', nest: eTag);
      builder.element('Key', nest: key);
      builder.element('LastModified', nest: lastModified?.toIso8601String());
      builder.element('Owner', nest: owner?.toXml());
      builder.element('RestoreStatus', nest: restoreStatus?.toXml());
      builder.element('Size', nest: size.toString());
      builder.element('StorageClass', nest: storageClass);
    });
    return builder.buildDocument();
  }

  /// The algorithm that was used to create a checksum of the object.
  List<String>? checksumAlgorithm;

  /// The entity tag is a hash of the object. The ETag reflects changes only to the contents of an object, not its metadata. The ETag may or may not be an MD5 digest of the object data. Whether or not it is depends on how the object was created and how it is encrypted as described below:
  String? eTag;

  /// The name that you assign to an object. You use the object key to retrieve the object.
  String? key;

  /// Creation date of the object.
  DateTime? lastModified;

  /// The owner of the object
  Owner? owner;

  /// Specifies the restoration status of an object. Objects in certain storage classes must be restored before they can be retrieved. For more information about these storage classes and how to work with archived objects, see Working with archived objects in the Amazon S3 User Guide.
  RestoreStatus? restoreStatus;

  /// Size in bytes of the object
  int? size;

  /// The class of storage used to store the object.
  String? storageClass;
}

/// Object Identifier is unique value to identify objects.
class ObjectIdentifier {
  ObjectIdentifier(
    this.key,
    this.versionId,
  );

  ObjectIdentifier.fromXml(XmlElement? xml) {
    key = getPropValue<String>(xml, 'Key');
    versionId = getPropValueOrNull<String>(xml, 'VersionId');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ObjectIdentifier', nest: () {
      builder.element('Key', nest: key);
      builder.element('VersionId', nest: versionId);
    });
    return builder.buildDocument();
  }

  /// Key name of the object.
  late String key;

  /// Version ID for the specific version of the object to delete.
  String? versionId;
}

/// The container element for Object Lock configuration parameters.
class ObjectLockConfiguration {
  ObjectLockConfiguration(
    this.objectLockEnabled,
    this.rule,
  );

  ObjectLockConfiguration.fromXml(XmlElement? xml) {
    objectLockEnabled = getPropValueOrNull<String>(xml, 'ObjectLockEnabled');
    rule = ObjectLockRule.fromXml(getProp(xml, 'Rule'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ObjectLockConfiguration', nest: () {
      builder.element('ObjectLockEnabled', nest: objectLockEnabled);
      builder.element('Rule', nest: rule?.toXml());
    });
    return builder.buildDocument();
  }

  /// Indicates whether this bucket has an Object Lock configuration enabled. Enable ObjectLockEnabled when you apply ObjectLockConfiguration to a bucket.
  String? objectLockEnabled;

  /// Specifies the Object Lock rule for the specified object. Enable the this rule when you apply ObjectLockConfiguration to a bucket. Bucket settings require both a mode and a period. The period can be either Days or Years but you must select one. You cannot specify Days and Years at the same time.
  ObjectLockRule? rule;
}

/// A legal hold configuration for an object.
class ObjectLockLegalHold {
  ObjectLockLegalHold(
    this.status,
  );

  ObjectLockLegalHold.fromXml(XmlElement? xml) {
    status = getPropValueOrNull<String>(xml, 'Status');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ObjectLockLegalHold', nest: () {
      builder.element('Status', nest: status);
    });
    return builder.buildDocument();
  }

  /// Indicates whether the specified object has a legal hold in place.
  String? status;
}

/// A Retention configuration for an object.
class ObjectLockRetention {
  ObjectLockRetention(
    this.mode,
    this.retainUntilDate,
  );

  ObjectLockRetention.fromXml(XmlElement? xml) {
    mode = getPropValueOrNull<String>(xml, 'Mode');
    retainUntilDate = getPropValueOrNull<DateTime>(xml, 'RetainUntilDate');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ObjectLockRetention', nest: () {
      builder.element('Mode', nest: mode);
      builder.element('RetainUntilDate',
          nest: retainUntilDate?.toIso8601String());
    });
    return builder.buildDocument();
  }

  /// Indicates the Retention mode for the specified object.
  String? mode;

  /// The date on which this Object Lock Retention will expire.
  DateTime? retainUntilDate;
}

/// The container element for an Object Lock rule.
class ObjectLockRule {
  ObjectLockRule(
    this.defaultRetention,
  );

  ObjectLockRule.fromXml(XmlElement? xml) {
    defaultRetention =
        DefaultRetention.fromXml(getProp(xml, 'DefaultRetention'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ObjectLockRule', nest: () {
      builder.element('DefaultRetention', nest: defaultRetention?.toXml());
    });
    return builder.buildDocument();
  }

  /// The default Object Lock retention mode and period that you want to apply to new objects placed in the specified bucket. Bucket settings require both a mode and a period. The period can be either Days or Years but you must select one. You cannot specify Days and Years at the same time.
  DefaultRetention? defaultRetention;
}

/// A container for elements related to an individual part.
class ObjectPart {
  ObjectPart(
    this.checksumCRC32,
    this.checksumCRC32C,
    this.checksumSHA1,
    this.checksumSHA256,
    this.partNumber,
    this.size,
  );

  ObjectPart.fromXml(XmlElement? xml) {
    checksumCRC32 = getPropValueOrNull<String>(xml, 'ChecksumCRC32');
    checksumCRC32C = getPropValueOrNull<String>(xml, 'ChecksumCRC32C');
    checksumSHA1 = getPropValueOrNull<String>(xml, 'ChecksumSHA1');
    checksumSHA256 = getPropValueOrNull<String>(xml, 'ChecksumSHA256');
    partNumber = getPropValueOrNull<int>(xml, 'PartNumber');
    size = getPropValueOrNull<int>(xml, 'Size');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ObjectPart', nest: () {
      builder.element('ChecksumCRC32', nest: checksumCRC32);
      builder.element('ChecksumCRC32C', nest: checksumCRC32C);
      builder.element('ChecksumSHA1', nest: checksumSHA1);
      builder.element('ChecksumSHA256', nest: checksumSHA256);
      builder.element('PartNumber', nest: partNumber.toString());
      builder.element('Size', nest: size.toString());
    });
    return builder.buildDocument();
  }

  /// This header can be used as a data integrity check to verify that the data received is the same data that was originally sent. This header specifies the base64-encoded, 32-bit CRC-32 checksum of the object. For more information, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32;

  /// The base64-encoded, 32-bit CRC-32C checksum of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32C;

  /// The base64-encoded, 160-bit SHA-1 digest of the object. This will only be present if it was uploaded with the object. When you use the API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA1;

  /// The base64-encoded, 256-bit SHA-256 digest of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA256;

  /// The part number identifying the part. This value is a positive integer between 1 and 10,000.
  int? partNumber;

  /// The size of the uploaded part in bytes.
  int? size;
}

/// The version of an object.
class ObjectVersion {
  ObjectVersion(
    this.checksumAlgorithm,
    this.eTag,
    this.isLatest,
    this.key,
    this.lastModified,
    this.owner,
    this.restoreStatus,
    this.size,
    this.storageClass,
    this.versionId,
  );

  ObjectVersion.fromXml(XmlElement? xml) {
    checksumAlgorithm =
        getPropValueOrNull<List<String>>(xml, 'ChecksumAlgorithm');
    eTag = getPropValueOrNull<String>(xml, 'ETag');
    isLatest = getPropValueOrNull<bool>(xml, 'IsLatest');
    key = getPropValueOrNull<String>(xml, 'Key');
    lastModified = getPropValueOrNull<DateTime>(xml, 'LastModified');
    owner = Owner.fromXml(getProp(xml, 'Owner'));
    restoreStatus = RestoreStatus.fromXml(getProp(xml, 'RestoreStatus'));
    size = getPropValueOrNull<int>(xml, 'Size');
    storageClass = getPropValueOrNull<String>(xml, 'StorageClass');
    versionId = getPropValueOrNull<String>(xml, 'VersionId');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ObjectVersion', nest: () {
      builder.element('ChecksumAlgorithm', nest: checksumAlgorithm);
      builder.element('ETag', nest: eTag);
      builder.element('IsLatest', nest: isLatest == true ? 'TRUE' : 'FALSE');
      builder.element('Key', nest: key);
      builder.element('LastModified', nest: lastModified?.toIso8601String());
      builder.element('Owner', nest: owner?.toXml());
      builder.element('RestoreStatus', nest: restoreStatus?.toXml());
      builder.element('Size', nest: size.toString());
      builder.element('StorageClass', nest: storageClass);
      builder.element('VersionId', nest: versionId);
    });
    return builder.buildDocument();
  }

  /// The algorithm that was used to create a checksum of the object.
  List<String>? checksumAlgorithm;

  /// The entity tag is an MD5 hash of that version of the object.
  String? eTag;

  /// Specifies whether the object is (true) or is not (false) the latest version of an object.
  bool? isLatest;

  /// The object key.
  String? key;

  /// Date and time when the object was last modified.
  DateTime? lastModified;

  /// Specifies the owner of the object.
  Owner? owner;

  /// Specifies the restoration status of an object. Objects in certain storage classes must be restored before they can be retrieved. For more information about these storage classes and how to work with archived objects, see Working with archived objects in the Amazon S3 User Guide.
  RestoreStatus? restoreStatus;

  /// Size in bytes of the object.
  int? size;

  /// The class of storage used to store the object.
  String? storageClass;

  /// Version ID of an object.
  String? versionId;
}

/// Describes the location where the restore job's output is stored.
class OutputLocation {
  OutputLocation(
    this.s3,
  );

  OutputLocation.fromXml(XmlElement? xml) {
    s3 = S3Location.fromXml(getProp(xml, 'S3'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('OutputLocation', nest: () {
      builder.element('S3', nest: s3?.toXml());
    });
    return builder.buildDocument();
  }

  /// Describes an S3 location that will receive the results of the restore request.
  S3Location? s3;
}

/// Describes how results of the Select job are serialized.
class OutputSerialization {
  OutputSerialization(
    this.cSV,
    this.jSON,
  );

  OutputSerialization.fromXml(XmlElement? xml) {
    cSV = CSVOutput.fromXml(getProp(xml, 'CSV'));
    jSON = JSONOutput.fromXml(getProp(xml, 'JSON'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('OutputSerialization', nest: () {
      builder.element('CSV', nest: cSV?.toXml());
      builder.element('JSON', nest: jSON?.toXml());
    });
    return builder.buildDocument();
  }

  /// Describes the serialization of CSV-encoded Select results.
  CSVOutput? cSV;

  /// Specifies JSON as request's output serialization format.
  JSONOutput? jSON;
}

/// Container for the owner's display name and ID.
class Owner {
  Owner(
    this.displayName,
    this.iD,
  );

  Owner.fromXml(XmlElement? xml) {
    displayName = getPropValueOrNull<String>(xml, 'DisplayName');
    iD = getPropValueOrNull<String>(xml, 'ID');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Owner', nest: () {
      builder.element('DisplayName', nest: displayName);
      builder.element('ID', nest: iD);
    });
    return builder.buildDocument();
  }

  /// Container for the display name of the owner. This value is only supported in the following AWS Regions:
  String? displayName;

  /// Container for the ID of the owner.
  String? iD;
}

/// The container element for a bucket's ownership controls.
class OwnershipControls {
  OwnershipControls(
    this.rules,
  );

  OwnershipControls.fromXml(XmlElement? xml) {
    rules = getProp(xml, 'Rules')!
        .children
        .map((c) => OwnershipControlsRule.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('OwnershipControls', nest: () {
      builder.element('Rules', nest: rules.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// The container element for an ownership control rule.
  late List<OwnershipControlsRule> rules;
}

/// The container element for an ownership control rule.
class OwnershipControlsRule {
  OwnershipControlsRule(
    this.objectOwnership,
  );

  OwnershipControlsRule.fromXml(XmlElement? xml) {
    objectOwnership = getPropValue<String>(xml, 'ObjectOwnership');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('OwnershipControlsRule', nest: () {
      builder.element('ObjectOwnership', nest: objectOwnership);
    });
    return builder.buildDocument();
  }

  /// The container element for object ownership for a bucket's ownership controls.
  late String objectOwnership;
}

/// Container for Parquet.
class ParquetInput {
  ParquetInput();

  ParquetInput.fromXml(XmlElement? xml) {}

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ParquetInput', nest: () {});
    return builder.buildDocument();
  }
}

/// Container for elements related to a part.
class Part {
  Part(
    this.checksumCRC32,
    this.checksumCRC32C,
    this.checksumSHA1,
    this.checksumSHA256,
    this.eTag,
    this.lastModified,
    this.partNumber,
    this.size,
  );

  Part.fromXml(XmlElement? xml) {
    checksumCRC32 = getPropValueOrNull<String>(xml, 'ChecksumCRC32');
    checksumCRC32C = getPropValueOrNull<String>(xml, 'ChecksumCRC32C');
    checksumSHA1 = getPropValueOrNull<String>(xml, 'ChecksumSHA1');
    checksumSHA256 = getPropValueOrNull<String>(xml, 'ChecksumSHA256');
    eTag = getPropValueOrNull<String>(xml, 'ETag');
    lastModified = getPropValueOrNull<DateTime>(xml, 'LastModified');
    partNumber = getPropValueOrNull<int>(xml, 'PartNumber');
    size = getPropValueOrNull<int>(xml, 'Size');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Part', nest: () {
      builder.element('ChecksumCRC32', nest: checksumCRC32);
      builder.element('ChecksumCRC32C', nest: checksumCRC32C);
      builder.element('ChecksumSHA1', nest: checksumSHA1);
      builder.element('ChecksumSHA256', nest: checksumSHA256);
      builder.element('ETag', nest: eTag);
      builder.element('LastModified', nest: lastModified?.toIso8601String());
      builder.element('PartNumber', nest: partNumber.toString());
      builder.element('Size', nest: size.toString());
    });
    return builder.buildDocument();
  }

  /// This header can be used as a data integrity check to verify that the data received is the same data that was originally sent. This header specifies the base64-encoded, 32-bit CRC-32 checksum of the object. For more information, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32;

  /// The base64-encoded, 32-bit CRC-32C checksum of the object. This will only be present if it was uploaded with the object. When you use an API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumCRC32C;

  /// The base64-encoded, 160-bit SHA-1 digest of the object. This will only be present if it was uploaded with the object. When you use the API operation on an object that was uploaded using multipart uploads, this value may not be a direct checksum value of the full object. Instead, it's a calculation based on the checksum values of each individual part. For more information about how checksums are calculated with multipart uploads, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA1;

  /// This header can be used as a data integrity check to verify that the data received is the same data that was originally sent. This header specifies the base64-encoded, 256-bit SHA-256 digest of the object. For more information, see Checking object integrity in the Amazon S3 User Guide.
  String? checksumSHA256;

  /// Entity tag returned when the part was uploaded.
  String? eTag;

  /// Date and time at which the part was uploaded.
  DateTime? lastModified;

  /// Part number identifying the part. This is a positive integer between 1 and 10,000.
  int? partNumber;

  /// Size in bytes of the uploaded part data.
  int? size;
}

/// Amazon S3 keys for log objects are partitioned in the following format:
class PartitionedPrefix {
  PartitionedPrefix(
    this.partitionDateSource,
  );

  PartitionedPrefix.fromXml(XmlElement? xml) {
    partitionDateSource =
        getPropValueOrNull<String>(xml, 'PartitionDateSource');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('PartitionedPrefix', nest: () {
      builder.element('PartitionDateSource', nest: partitionDateSource);
    });
    return builder.buildDocument();
  }

  /// Specifies the partition date source for the partitioned prefix. PartitionDateSource can be EventTime or DeliveryTime.
  String? partitionDateSource;
}

/// The container element for a bucket's policy status.
class PolicyStatus {
  PolicyStatus(
    this.isPublic,
  );

  PolicyStatus.fromXml(XmlElement? xml) {
    isPublic = getPropValueOrNull<bool>(xml, 'IsPublic');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('PolicyStatus', nest: () {
      builder.element('IsPublic', nest: isPublic == true ? 'TRUE' : 'FALSE');
    });
    return builder.buildDocument();
  }

  /// The policy status for this bucket. TRUE indicates that this bucket is public. FALSE indicates that the bucket is not public.
  bool? isPublic;
}

/// This data type contains information about progress of an operation.
class Progress {
  Progress(
    this.bytesProcessed,
    this.bytesReturned,
    this.bytesScanned,
  );

  Progress.fromXml(XmlElement? xml) {
    bytesProcessed = getPropValueOrNull<int>(xml, 'BytesProcessed');
    bytesReturned = getPropValueOrNull<int>(xml, 'BytesReturned');
    bytesScanned = getPropValueOrNull<int>(xml, 'BytesScanned');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Progress', nest: () {
      builder.element('BytesProcessed', nest: bytesProcessed.toString());
      builder.element('BytesReturned', nest: bytesReturned.toString());
      builder.element('BytesScanned', nest: bytesScanned.toString());
    });
    return builder.buildDocument();
  }

  /// The current number of uncompressed object bytes processed.
  int? bytesProcessed;

  /// The current number of bytes of records payload data returned.
  int? bytesReturned;

  /// The current number of object bytes scanned.
  int? bytesScanned;
}

/// This data type contains information about the progress event of an operation.
class ProgressEvent {
  ProgressEvent(
    this.details,
  );

  ProgressEvent.fromXml(XmlElement? xml) {
    details = Progress.fromXml(getProp(xml, 'Details'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ProgressEvent', nest: () {
      builder.element('Details', nest: details?.toXml());
    });
    return builder.buildDocument();
  }

  /// The Progress event details.
  Progress? details;
}

/// The PublicAccessBlock configuration that you want to apply to this Amazon S3 bucket. You can enable the configuration options in any combination. For more information about when Amazon S3 considers a bucket or object public, see The Meaning of "Public" in the Amazon S3 User Guide.
class PublicAccessBlockConfiguration {
  PublicAccessBlockConfiguration(
    this.blockPublicAcls,
    this.blockPublicPolicy,
    this.ignorePublicAcls,
    this.restrictPublicBuckets,
  );

  PublicAccessBlockConfiguration.fromXml(XmlElement? xml) {
    blockPublicAcls = getPropValueOrNull<bool>(xml, 'BlockPublicAcls');
    blockPublicPolicy = getPropValueOrNull<bool>(xml, 'BlockPublicPolicy');
    ignorePublicAcls = getPropValueOrNull<bool>(xml, 'IgnorePublicAcls');
    restrictPublicBuckets =
        getPropValueOrNull<bool>(xml, 'RestrictPublicBuckets');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('PublicAccessBlockConfiguration', nest: () {
      builder.element('BlockPublicAcls',
          nest: blockPublicAcls == true ? 'TRUE' : 'FALSE');
      builder.element('BlockPublicPolicy',
          nest: blockPublicPolicy == true ? 'TRUE' : 'FALSE');
      builder.element('IgnorePublicAcls',
          nest: ignorePublicAcls == true ? 'TRUE' : 'FALSE');
      builder.element('RestrictPublicBuckets',
          nest: restrictPublicBuckets == true ? 'TRUE' : 'FALSE');
    });
    return builder.buildDocument();
  }

  /// Specifies whether Amazon S3 should block public access control lists (ACLs) for this bucket and objects in this bucket. Setting this element to TRUE causes the following behavior:
  bool? blockPublicAcls;

  /// Specifies whether Amazon S3 should block public bucket policies for this bucket. Setting this element to TRUE causes Amazon S3 to reject calls to PUT Bucket policy if the specified bucket policy allows public access.
  bool? blockPublicPolicy;

  /// Specifies whether Amazon S3 should ignore public ACLs for this bucket and objects in this bucket. Setting this element to TRUE causes Amazon S3 to ignore all public ACLs on this bucket and objects in this bucket.
  bool? ignorePublicAcls;

  /// Specifies whether Amazon S3 should restrict public bucket policies for this bucket. Setting this element to TRUE restricts access to this bucket to only AWS service principals and authorized users within this account if the bucket has a public policy.
  bool? restrictPublicBuckets;
}

/// Specifies the configuration for publishing messages to an Amazon Simple Queue Service (Amazon SQS) queue when Amazon S3 detects specified events.
class QueueConfiguration {
  QueueConfiguration(
    this.events,
    this.queueArn,
    this.filter,
    this.id,
  );

  QueueConfiguration.fromXml(XmlElement? xml) {
    events = getPropValue<List<String>>(xml, 'Events');
    queueArn = getPropValue<String>(xml, 'QueueArn');
    filter = NotificationConfigurationFilter.fromXml(getProp(xml, 'Filter'));
    id = getPropValueOrNull<String>(xml, 'Id');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('QueueConfiguration', nest: () {
      builder.element('Events', nest: events);
      builder.element('QueueArn', nest: queueArn);
      builder.element('Filter', nest: filter?.toXml());
      builder.element('Id', nest: id);
    });
    return builder.buildDocument();
  }

  /// A collection of bucket events for which to send notifications
  late List<String> events;

  /// The Amazon Resource Name (ARN) of the Amazon SQS queue to which Amazon S3 publishes a message when it detects events of the specified type.
  late String queueArn;

  /// Specifies object key name filtering rules. For information about key name filtering, see Configuring event notifications using object key name filtering in the Amazon S3 User Guide.
  NotificationConfigurationFilter? filter;

  /// An optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon S3 will assign an ID.
  String? id;
}

/// This data type is deprecated. Use QueueConfiguration for the same purposes. This data type specifies the configuration for publishing messages to an Amazon Simple Queue Service (Amazon SQS) queue when Amazon S3 detects specified events.
class QueueConfigurationDeprecated {
  QueueConfigurationDeprecated(
    this.event,
    this.events,
    this.id,
    this.queue,
  );

  QueueConfigurationDeprecated.fromXml(XmlElement? xml) {
    event = getPropValueOrNull<String>(xml, 'Event');
    events = getPropValueOrNull<List<String>>(xml, 'Events');
    id = getPropValueOrNull<String>(xml, 'Id');
    queue = getPropValueOrNull<String>(xml, 'Queue');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('QueueConfigurationDeprecated', nest: () {
      builder.element('Event', nest: event);
      builder.element('Events', nest: events);
      builder.element('Id', nest: id);
      builder.element('Queue', nest: queue);
    });
    return builder.buildDocument();
  }

  ///  This member has been deprecated.
  String? event;

  /// A collection of bucket events for which to send notifications.
  List<String>? events;

  /// An optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon S3 will assign an ID.
  String? id;

  /// The Amazon Resource Name (ARN) of the Amazon SQS queue to which Amazon S3 publishes a message when it detects events of the specified type.
  String? queue;
}

/// The container for the records event.
class RecordsEvent {
  RecordsEvent(
    this.payload,
  );

  RecordsEvent.fromXml(XmlElement? xml) {
    payload = getPropValueOrNull<String>(xml, 'Payload');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('RecordsEvent', nest: () {
      builder.element('Payload', nest: payload);
    });
    return builder.buildDocument();
  }

  /// The byte array of partial, one or more result records. S3 Select doesn't guarantee that a record will be self-contained in one record frame. To ensure continuous streaming of data, S3 Select might split the same record across multiple record frames instead of aggregating the results in memory. Some S3 clients (for example, the AWS SDK for Java) handle this behavior by creating a ByteStream out of the response by default. Other clients might not handle this behavior by default. In those cases, you must aggregate the results on the client side and parse the response.
  String? payload;
}

/// Specifies how requests are redirected. In the event of an error, you can specify a different error code to return.
class Redirect {
  Redirect(
    this.hostName,
    this.httpRedirectCode,
    this.protocol,
    this.replaceKeyPrefixWith,
    this.replaceKeyWith,
  );

  Redirect.fromXml(XmlElement? xml) {
    hostName = getPropValueOrNull<String>(xml, 'HostName');
    httpRedirectCode = getPropValueOrNull<String>(xml, 'HttpRedirectCode');
    protocol = getPropValueOrNull<String>(xml, 'Protocol');
    replaceKeyPrefixWith =
        getPropValueOrNull<String>(xml, 'ReplaceKeyPrefixWith');
    replaceKeyWith = getPropValueOrNull<String>(xml, 'ReplaceKeyWith');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Redirect', nest: () {
      builder.element('HostName', nest: hostName);
      builder.element('HttpRedirectCode', nest: httpRedirectCode);
      builder.element('Protocol', nest: protocol);
      builder.element('ReplaceKeyPrefixWith', nest: replaceKeyPrefixWith);
      builder.element('ReplaceKeyWith', nest: replaceKeyWith);
    });
    return builder.buildDocument();
  }

  /// The host name to use in the redirect request.
  String? hostName;

  /// The HTTP redirect code to use on the response. Not required if one of the siblings is present.
  String? httpRedirectCode;

  /// Protocol to use when redirecting requests. The default is the protocol that is used in the original request.
  String? protocol;

  /// The object key prefix to use in the redirect request. For example, to redirect requests for all pages with prefix docs/ (objects in the docs/ folder) to documents/, you can set a condition block with KeyPrefixEquals set to docs/ and in the Redirect set ReplaceKeyPrefixWith to /documents. Not required if one of the siblings is present. Can be present only if ReplaceKeyWith is not provided.
  String? replaceKeyPrefixWith;

  /// The specific object key to use in the redirect request. For example, redirect request to error.html. Not required if one of the siblings is present. Can be present only if ReplaceKeyPrefixWith is not provided.
  String? replaceKeyWith;
}

/// Specifies the redirect behavior of all requests to a website endpoint of an Amazon S3 bucket.
class RedirectAllRequestsTo {
  RedirectAllRequestsTo(
    this.hostName,
    this.protocol,
  );

  RedirectAllRequestsTo.fromXml(XmlElement? xml) {
    hostName = getPropValue<String>(xml, 'HostName');
    protocol = getPropValueOrNull<String>(xml, 'Protocol');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('RedirectAllRequestsTo', nest: () {
      builder.element('HostName', nest: hostName);
      builder.element('Protocol', nest: protocol);
    });
    return builder.buildDocument();
  }

  /// Name of the host where requests are redirected.
  late String hostName;

  /// Protocol to use when redirecting requests. The default is the protocol that is used in the original request.
  String? protocol;
}

/// A filter that you can specify for selection for modifications on replicas. Amazon S3 doesn't replicate replica modifications by default. In the latest version of replication configuration (when Filter is specified), you can specify this element and set the status to Enabled to replicate modifications on replicas.
class ReplicaModifications {
  ReplicaModifications(
    this.status,
  );

  ReplicaModifications.fromXml(XmlElement? xml) {
    status = getPropValue<String>(xml, 'Status');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ReplicaModifications', nest: () {
      builder.element('Status', nest: status);
    });
    return builder.buildDocument();
  }

  /// Specifies whether Amazon S3 replicates modifications on replicas.
  late String status;
}

/// A container for replication rules. You can add up to 1,000 rules. The maximum size of a replication configuration is 2 MB.
class ReplicationConfiguration {
  ReplicationConfiguration(
    this.role,
    this.rules,
  );

  ReplicationConfiguration.fromXml(XmlElement? xml) {
    role = getPropValue<String>(xml, 'Role');
    rules = getProp(xml, 'Rules')!
        .children
        .map((c) => ReplicationRule.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ReplicationConfiguration', nest: () {
      builder.element('Role', nest: role);
      builder.element('Rules', nest: rules.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// The Amazon Resource Name (ARN) of the AWS Identity and Access Management (IAM) role that Amazon S3 assumes when replicating objects. For more information, see How to Set Up Replication in the Amazon S3 User Guide.
  late String role;

  /// A container for one or more replication rules. A replication configuration must have at least one rule and can contain a maximum of 1,000 rules.
  late List<ReplicationRule> rules;
}

/// Specifies which Amazon S3 objects to replicate and where to store the replicas.
class ReplicationRule {
  ReplicationRule(
    this.destination,
    this.status,
    this.deleteMarkerReplication,
    this.existingObjectReplication,
    this.filter,
    this.iD,
    this.prefix,
    this.priority,
    this.sourceSelectionCriteria,
  );

  ReplicationRule.fromXml(XmlElement? xml) {
    destination = Destination.fromXml(getProp(xml, 'Destination'));
    status = getPropValue<String>(xml, 'Status');
    deleteMarkerReplication = DeleteMarkerReplication.fromXml(
        getProp(xml, 'DeleteMarkerReplication'));
    existingObjectReplication = ExistingObjectReplication.fromXml(
        getProp(xml, 'ExistingObjectReplication'));
    filter = ReplicationRuleFilter.fromXml(getProp(xml, 'Filter'));
    iD = getPropValueOrNull<String>(xml, 'ID');
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    priority = getPropValueOrNull<int>(xml, 'Priority');
    sourceSelectionCriteria = SourceSelectionCriteria.fromXml(
        getProp(xml, 'SourceSelectionCriteria'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ReplicationRule', nest: () {
      builder.element('Destination', nest: destination.toXml());
      builder.element('Status', nest: status);
      builder.element('DeleteMarkerReplication',
          nest: deleteMarkerReplication?.toXml());
      builder.element('ExistingObjectReplication',
          nest: existingObjectReplication?.toXml());
      builder.element('Filter', nest: filter?.toXml());
      builder.element('ID', nest: iD);
      builder.element('Prefix', nest: prefix);
      builder.element('Priority', nest: priority.toString());
      builder.element('SourceSelectionCriteria',
          nest: sourceSelectionCriteria?.toXml());
    });
    return builder.buildDocument();
  }

  /// A container for information about the replication destination and its configurations including enabling the S3 Replication Time Control (S3 RTC).
  late Destination destination;

  /// Specifies whether the rule is enabled.
  late String status;

  /// Specifies whether Amazon S3 replicates delete markers. If you specify a Filter in your replication configuration, you must also include a DeleteMarkerReplication element. If your Filter includes a Tag element, the DeleteMarkerReplication Status must be set to Disabled, because Amazon S3 does not support replicating delete markers for tag-based rules. For an example configuration, see Basic Rule Configuration.
  DeleteMarkerReplication? deleteMarkerReplication;

  /// Optional configuration to replicate existing source bucket objects.
  ExistingObjectReplication? existingObjectReplication;

  /// A filter that identifies the subset of objects to which the replication rule applies. A Filter must specify exactly one Prefix, Tag, or an And child element.
  ReplicationRuleFilter? filter;

  /// A unique identifier for the rule. The maximum value is 255 characters.
  String? iD;

  ///  This member has been deprecated.
  String? prefix;

  /// The priority indicates which rule has precedence whenever two or more replication rules conflict. Amazon S3 will attempt to replicate objects according to all replication rules. However, if there are two or more rules with the same destination bucket, then objects will be replicated according to the rule with the highest priority. The higher the number, the higher the priority.
  int? priority;

  /// A container that describes additional filters for identifying the source objects that you want to replicate. You can choose to enable or disable the replication of these objects. Currently, Amazon S3 supports only the filter that you can specify for objects created with server-side encryption using a customer managed key stored in AWS Key Management Service (SSE-KMS).
  SourceSelectionCriteria? sourceSelectionCriteria;
}

/// A container for specifying rule filters. The filters determine the subset of objects to which the rule applies. This element is required only if you specify more than one filter.
class ReplicationRuleAndOperator {
  ReplicationRuleAndOperator(
    this.prefix,
    this.tags,
  );

  ReplicationRuleAndOperator.fromXml(XmlElement? xml) {
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    tags = getProp(xml, 'Tags')
        ?.children
        .map((c) => Tag.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ReplicationRuleAndOperator', nest: () {
      builder.element('Prefix', nest: prefix);
      builder.element('Tags', nest: tags?.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// An object key name prefix that identifies the subset of objects to which the rule applies.
  String? prefix;

  /// An array of tags containing key and value pairs.
  List<Tag>? tags;
}

/// A filter that identifies the subset of objects to which the replication rule applies. A Filter must specify exactly one Prefix, Tag, or an And child element.
class ReplicationRuleFilter {
  ReplicationRuleFilter(
    this.and,
    this.prefix,
    this.tag,
  );

  ReplicationRuleFilter.fromXml(XmlElement? xml) {
    and = ReplicationRuleAndOperator.fromXml(getProp(xml, 'And'));
    prefix = getPropValueOrNull<String>(xml, 'Prefix');
    tag = Tag.fromXml(getProp(xml, 'Tag'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ReplicationRuleFilter', nest: () {
      builder.element('And', nest: and?.toXml());
      builder.element('Prefix', nest: prefix);
      builder.element('Tag', nest: tag?.toXml());
    });
    return builder.buildDocument();
  }

  /// A container for specifying rule filters. The filters determine the subset of objects to which the rule applies. This element is required only if you specify more than one filter. For example:
  ReplicationRuleAndOperator? and;

  /// An object key name prefix that identifies the subset of objects to which the rule applies.
  String? prefix;

  /// A container for specifying a tag key and value.
  Tag? tag;
}

///  A container specifying S3 Replication Time Control (S3 RTC) related information, including whether S3 RTC is enabled and the time when all objects and operations on objects must be replicated. Must be specified together with a Metrics block.
class ReplicationTime {
  ReplicationTime(
    this.status,
    this.time,
  );

  ReplicationTime.fromXml(XmlElement? xml) {
    status = getPropValue<String>(xml, 'Status');
    time = ReplicationTimeValue.fromXml(getProp(xml, 'Time'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ReplicationTime', nest: () {
      builder.element('Status', nest: status);
      builder.element('Time', nest: time.toXml());
    });
    return builder.buildDocument();
  }

  ///  Specifies whether the replication time is enabled.
  late String status;

  ///  A container specifying the time by which replication should be complete for all objects and operations on objects.
  late ReplicationTimeValue time;
}

///  A container specifying the time value for S3 Replication Time Control (S3 RTC) and replication metrics EventThreshold.
class ReplicationTimeValue {
  ReplicationTimeValue(
    this.minutes,
  );

  ReplicationTimeValue.fromXml(XmlElement? xml) {
    minutes = getPropValueOrNull<int>(xml, 'Minutes');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ReplicationTimeValue', nest: () {
      builder.element('Minutes', nest: minutes.toString());
    });
    return builder.buildDocument();
  }

  ///  Contains an integer specifying time in minutes.
  int? minutes;
}

/// Container for Payer.
class RequestPaymentConfiguration {
  RequestPaymentConfiguration(
    this.payer,
  );

  RequestPaymentConfiguration.fromXml(XmlElement? xml) {
    payer = getPropValue<String>(xml, 'Payer');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('RequestPaymentConfiguration', nest: () {
      builder.element('Payer', nest: payer);
    });
    return builder.buildDocument();
  }

  /// Specifies who pays for the download and request fees.
  late String payer;
}

/// Container for specifying if periodic QueryProgress messages should be sent.
class RequestProgress {
  RequestProgress(
    this.enabled,
  );

  RequestProgress.fromXml(XmlElement? xml) {
    enabled = getPropValueOrNull<bool>(xml, 'Enabled');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('RequestProgress', nest: () {
      builder.element('Enabled', nest: enabled == true ? 'TRUE' : 'FALSE');
    });
    return builder.buildDocument();
  }

  /// Specifies whether periodic QueryProgress frames should be sent. Valid values: TRUE, FALSE. Default value: FALSE.
  bool? enabled;
}

/// Container for restore job parameters.
class RestoreRequest {
  RestoreRequest(
    this.days,
    this.description,
    this.glacierJobParameters,
    this.outputLocation,
    this.selectParameters,
    this.tier,
    this.type,
  );

  RestoreRequest.fromXml(XmlElement? xml) {
    days = getPropValueOrNull<int>(xml, 'Days');
    description = getPropValueOrNull<String>(xml, 'Description');
    glacierJobParameters =
        GlacierJobParameters.fromXml(getProp(xml, 'GlacierJobParameters'));
    outputLocation = OutputLocation.fromXml(getProp(xml, 'OutputLocation'));
    selectParameters =
        SelectParameters.fromXml(getProp(xml, 'SelectParameters'));
    tier = getPropValueOrNull<String>(xml, 'Tier');
    type = getPropValueOrNull<String>(xml, 'Type');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('RestoreRequest', nest: () {
      builder.element('Days', nest: days.toString());
      builder.element('Description', nest: description);
      builder.element('GlacierJobParameters',
          nest: glacierJobParameters?.toXml());
      builder.element('OutputLocation', nest: outputLocation?.toXml());
      builder.element('SelectParameters', nest: selectParameters?.toXml());
      builder.element('Tier', nest: tier);
      builder.element('Type', nest: type);
    });
    return builder.buildDocument();
  }

  /// Lifetime of the active copy in days. Do not use with restores that specify OutputLocation.
  int? days;

  /// The optional description for the job.
  String? description;

  /// S3 Glacier related parameters pertaining to this job. Do not use with restores that specify OutputLocation.
  GlacierJobParameters? glacierJobParameters;

  /// Describes the location where the restore job's output is stored.
  OutputLocation? outputLocation;

  /// Amazon S3 Select is no longer available to new customers. Existing customers of Amazon S3 Select can continue to use the feature as usual. Learn more
  SelectParameters? selectParameters;

  /// Retrieval tier at which the restore will be processed.
  String? tier;

  /// Amazon S3 Select is no longer available to new customers. Existing customers of Amazon S3 Select can continue to use the feature as usual. Learn more
  String? type;
}

/// Specifies the restoration status of an object. Objects in certain storage classes must be restored before they can be retrieved. For more information about these storage classes and how to work with archived objects, see Working with archived objects in the Amazon S3 User Guide.
class RestoreStatus {
  RestoreStatus(
    this.isRestoreInProgress,
    this.restoreExpiryDate,
  );

  RestoreStatus.fromXml(XmlElement? xml) {
    isRestoreInProgress = getPropValueOrNull<bool>(xml, 'IsRestoreInProgress');
    restoreExpiryDate = getPropValueOrNull<DateTime>(xml, 'RestoreExpiryDate');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('RestoreStatus', nest: () {
      builder.element('IsRestoreInProgress',
          nest: isRestoreInProgress == true ? 'TRUE' : 'FALSE');
      builder.element('RestoreExpiryDate',
          nest: restoreExpiryDate?.toIso8601String());
    });
    return builder.buildDocument();
  }

  /// Specifies whether the object is currently being restored. If the object restoration is in progress, the header returns the value TRUE. For example:
  bool? isRestoreInProgress;

  /// Indicates when the restored copy will expire. This value is populated only if the object has already been restored. For example:
  DateTime? restoreExpiryDate;
}

/// Specifies the redirect behavior and when a redirect is applied. For more information about routing rules, see Configuring advanced conditional redirects in the Amazon S3 User Guide.
class RoutingRule {
  RoutingRule(
    this.redirect,
    this.condition,
  );

  RoutingRule.fromXml(XmlElement? xml) {
    redirect = Redirect.fromXml(getProp(xml, 'Redirect'));
    condition = Condition.fromXml(getProp(xml, 'Condition'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('RoutingRule', nest: () {
      builder.element('Redirect', nest: redirect.toXml());
      builder.element('Condition', nest: condition?.toXml());
    });
    return builder.buildDocument();
  }

  /// Container for redirect information. You can redirect requests to another host, to another page, or with another protocol. In the event of an error, you can specify a different error code to return.
  late Redirect redirect;

  /// A container for describing a condition that must be met for the specified redirect to apply. For example, 1. If request is for pages in the /docs folder, redirect to the /documents folder. 2. If request results in HTTP error 4xx, redirect request to another host where you might process the error.
  Condition? condition;
}

/// Specifies lifecycle rules for an Amazon S3 bucket. For more information, see Put Bucket Lifecycle Configuration in the Amazon S3 API Reference. For examples, see Put Bucket Lifecycle Configuration Examples.
class Rule {
  Rule(
    this.prefix,
    this.status,
    this.abortIncompleteMultipartUpload,
    this.expiration,
    this.iD,
    this.noncurrentVersionExpiration,
    this.noncurrentVersionTransition,
    this.transition,
  );

  Rule.fromXml(XmlElement? xml) {
    prefix = getPropValue<String>(xml, 'Prefix');
    status = getPropValue<String>(xml, 'Status');
    abortIncompleteMultipartUpload = AbortIncompleteMultipartUpload.fromXml(
        getProp(xml, 'AbortIncompleteMultipartUpload'));
    expiration = LifecycleExpiration.fromXml(getProp(xml, 'Expiration'));
    iD = getPropValueOrNull<String>(xml, 'ID');
    noncurrentVersionExpiration = NoncurrentVersionExpiration.fromXml(
        getProp(xml, 'NoncurrentVersionExpiration'));
    noncurrentVersionTransition = NoncurrentVersionTransition.fromXml(
        getProp(xml, 'NoncurrentVersionTransition'));
    transition = Transition.fromXml(getProp(xml, 'Transition'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Rule', nest: () {
      builder.element('Prefix', nest: prefix);
      builder.element('Status', nest: status);
      builder.element('AbortIncompleteMultipartUpload',
          nest: abortIncompleteMultipartUpload?.toXml());
      builder.element('Expiration', nest: expiration?.toXml());
      builder.element('ID', nest: iD);
      builder.element('NoncurrentVersionExpiration',
          nest: noncurrentVersionExpiration?.toXml());
      builder.element('NoncurrentVersionTransition',
          nest: noncurrentVersionTransition?.toXml());
      builder.element('Transition', nest: transition?.toXml());
    });
    return builder.buildDocument();
  }

  /// Object key prefix that identifies one or more objects to which this rule applies.
  late String prefix;

  /// If Enabled, the rule is currently being applied. If Disabled, the rule is not currently being applied.
  late String status;

  /// Specifies the days since the initiation of an incomplete multipart upload that Amazon S3 will wait before permanently removing all parts of the upload. For more information, see Aborting Incomplete Multipart Uploads Using a Bucket Lifecycle Configuration in the Amazon S3 User Guide.
  AbortIncompleteMultipartUpload? abortIncompleteMultipartUpload;

  /// Specifies the expiration for the lifecycle of the object.
  LifecycleExpiration? expiration;

  /// Unique identifier for the rule. The value can't be longer than 255 characters.
  String? iD;

  /// Specifies when noncurrent object versions expire. Upon expiration, Amazon S3 permanently deletes the noncurrent object versions. You set this lifecycle configuration action on a bucket that has versioning enabled (or suspended) to request that Amazon S3 delete noncurrent object versions at a specific period in the object's lifetime.
  NoncurrentVersionExpiration? noncurrentVersionExpiration;

  /// Container for the transition rule that describes when noncurrent objects transition to the STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER_IR, GLACIER, or DEEP_ARCHIVE storage class. If your bucket is versioning-enabled (or versioning is suspended), you can set this action to request that Amazon S3 transition noncurrent object versions to the STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER_IR, GLACIER, or DEEP_ARCHIVE storage class at a specific period in the object's lifetime.
  NoncurrentVersionTransition? noncurrentVersionTransition;

  /// Specifies when an object transitions to a specified storage class. For more information about Amazon S3 lifecycle configuration rules, see Transitioning Objects Using Amazon S3 Lifecycle in the Amazon S3 User Guide.
  Transition? transition;
}

/// A container for object key name prefix and suffix filtering rules.
class S3KeyFilter {
  S3KeyFilter(
    this.filterRules,
  );

  S3KeyFilter.fromXml(XmlElement? xml) {
    filterRules = getProp(xml, 'FilterRules')
        ?.children
        .map((c) => FilterRule.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('S3KeyFilter', nest: () {
      builder.element('FilterRules', nest: filterRules?.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// A list of containers for the key-value pair that defines the criteria for the filter rule.
  List<FilterRule>? filterRules;
}

/// Describes an Amazon S3 location that will receive the results of the restore request.
class S3Location {
  S3Location(
    this.bucketName,
    this.prefix,
    this.accessControlList,
    this.cannedACL,
    this.encryption,
    this.storageClass,
    this.tagging,
    this.userMetadata,
  );

  S3Location.fromXml(XmlElement? xml) {
    bucketName = getPropValue<String>(xml, 'BucketName');
    prefix = getPropValue<String>(xml, 'Prefix');
    accessControlList = getProp(xml, 'AccessControlList')
        ?.children
        .map((c) => Grant.fromXml(c as XmlElement))
        .toList();
    cannedACL = getPropValueOrNull<String>(xml, 'CannedACL');
    encryption = Encryption.fromXml(getProp(xml, 'Encryption'));
    storageClass = getPropValueOrNull<String>(xml, 'StorageClass');
    tagging = Tagging.fromXml(getProp(xml, 'Tagging'));
    userMetadata = getProp(xml, 'UserMetadata')
        ?.children
        .map((c) => MetadataEntry.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('S3Location', nest: () {
      builder.element('BucketName', nest: bucketName);
      builder.element('Prefix', nest: prefix);
      builder.element('AccessControlList',
          nest: accessControlList?.map((e) => e.toXml()));
      builder.element('CannedACL', nest: cannedACL);
      builder.element('Encryption', nest: encryption?.toXml());
      builder.element('StorageClass', nest: storageClass);
      builder.element('Tagging', nest: tagging?.toXml());
      builder.element('UserMetadata',
          nest: userMetadata?.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// The name of the bucket where the restore results will be placed.
  late String bucketName;

  /// The prefix that is prepended to the restore results for this request.
  late String prefix;

  /// A list of grants that control access to the staged results.
  List<Grant>? accessControlList;

  /// The canned ACL to apply to the restore results.
  String? cannedACL;

  /// Contains the type of server-side encryption used.
  Encryption? encryption;

  /// The class of storage used to store the restore results.
  String? storageClass;

  /// The tag-set that is applied to the restore results.
  Tagging? tagging;

  /// A list of metadata to store with the restore results in S3.
  List<MetadataEntry>? userMetadata;
}

/// Specifies the byte range of the object to get the records from. A record is processed when its first byte is contained by the range. This parameter is optional, but when specified, it must not be empty. See RFC 2616, Section 14.35.1 about how to specify the start and end of the range.
class ScanRange {
  ScanRange(
    this.end,
    this.start,
  );

  ScanRange.fromXml(XmlElement? xml) {
    end = getPropValueOrNull<int>(xml, 'End');
    start = getPropValueOrNull<int>(xml, 'Start');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ScanRange', nest: () {
      builder.element('End', nest: end.toString());
      builder.element('Start', nest: start.toString());
    });
    return builder.buildDocument();
  }

  /// Specifies the end of the byte range. This parameter is optional. Valid values: non-negative integers. The default value is one less than the size of the object being queried. If only the End parameter is supplied, it is interpreted to mean scan the last N bytes of the file. For example, <scanrange><end>50</end></scanrange> means scan the last 50 bytes.
  int? end;

  /// Specifies the start of the byte range. This parameter is optional. Valid values: non-negative integers. The default value is 0. If only start is supplied, it means scan from that point to the end of the file. For example, <scanrange><start>50</start></scanrange> means scan from byte 50 until the end of the file.
  int? start;
}

/// The container for selecting objects from a content event stream.
class SelectObjectContentEventStream {
  SelectObjectContentEventStream(
    this.cont,
    this.end,
    this.progress,
    this.records,
    this.stats,
  );

  SelectObjectContentEventStream.fromXml(XmlElement? xml) {
    cont = ContinuationEvent.fromXml(getProp(xml, 'Cont'));
    end = EndEvent.fromXml(getProp(xml, 'End'));
    progress = ProgressEvent.fromXml(getProp(xml, 'Progress'));
    records = RecordsEvent.fromXml(getProp(xml, 'Records'));
    stats = StatsEvent.fromXml(getProp(xml, 'Stats'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('SelectObjectContentEventStream', nest: () {
      builder.element('Cont', nest: cont?.toXml());
      builder.element('End', nest: end?.toXml());
      builder.element('Progress', nest: progress?.toXml());
      builder.element('Records', nest: records?.toXml());
      builder.element('Stats', nest: stats?.toXml());
    });
    return builder.buildDocument();
  }

  /// The Continuation Event.
  ContinuationEvent? cont;

  /// The End Event.
  EndEvent? end;

  /// The Progress Event.
  ProgressEvent? progress;

  /// The Records Event.
  RecordsEvent? records;

  /// The Stats Event.
  StatsEvent? stats;
}

/// Amazon S3 Select is no longer available to new customers. Existing customers of Amazon S3 Select can continue to use the feature as usual. Learn more
class SelectParameters {
  SelectParameters(
    this.expression,
    this.expressionType,
    this.inputSerialization,
    this.outputSerialization,
  );

  SelectParameters.fromXml(XmlElement? xml) {
    expression = getPropValue<String>(xml, 'Expression');
    expressionType = getPropValue<String>(xml, 'ExpressionType');
    inputSerialization =
        InputSerialization.fromXml(getProp(xml, 'InputSerialization'));
    outputSerialization =
        OutputSerialization.fromXml(getProp(xml, 'OutputSerialization'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('SelectParameters', nest: () {
      builder.element('Expression', nest: expression);
      builder.element('ExpressionType', nest: expressionType);
      builder.element('InputSerialization', nest: inputSerialization.toXml());
      builder.element('OutputSerialization', nest: outputSerialization.toXml());
    });
    return builder.buildDocument();
  }

  /// Amazon S3 Select is no longer available to new customers. Existing customers of Amazon S3 Select can continue to use the feature as usual. Learn more
  late String expression;

  /// The type of the provided expression (for example, SQL).
  late String expressionType;

  /// Describes the serialization format of the object.
  late InputSerialization inputSerialization;

  /// Describes how the results of the Select job are serialized.
  late OutputSerialization outputSerialization;
}

/// Describes the default server-side encryption to apply to new objects in the bucket. If a PUT Object request doesn't specify any server-side encryption, this default encryption will be applied. If you don't specify a customer managed key at configuration, Amazon S3 automatically creates an AWS KMS key in your AWS account the first time that you add an object encrypted with SSE-KMS to a bucket. By default, Amazon S3 uses this KMS key for SSE-KMS. For more information, see PUT Bucket encryption in the Amazon S3 API Reference.
class ServerSideEncryptionByDefault {
  ServerSideEncryptionByDefault(
    this.sSEAlgorithm,
    this.kMSMasterKeyID,
  );

  ServerSideEncryptionByDefault.fromXml(XmlElement? xml) {
    sSEAlgorithm = getPropValue<String>(xml, 'SSEAlgorithm');
    kMSMasterKeyID = getPropValueOrNull<String>(xml, 'KMSMasterKeyID');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ServerSideEncryptionByDefault', nest: () {
      builder.element('SSEAlgorithm', nest: sSEAlgorithm);
      builder.element('KMSMasterKeyID', nest: kMSMasterKeyID);
    });
    return builder.buildDocument();
  }

  /// Server-side encryption algorithm to use for the default encryption.
  late String sSEAlgorithm;

  ///  AWS Key Management Service (KMS) customer AWS KMS key ID to use for the default encryption. This parameter is allowed if and only if SSEAlgorithm is set to aws:kms or aws:kms:dsse.
  String? kMSMasterKeyID;
}

/// Specifies the default server-side-encryption configuration.
class ServerSideEncryptionConfiguration {
  ServerSideEncryptionConfiguration(
    this.rules,
  );

  ServerSideEncryptionConfiguration.fromXml(XmlElement? xml) {
    rules = getProp(xml, 'Rules')!
        .children
        .map((c) => ServerSideEncryptionRule.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ServerSideEncryptionConfiguration', nest: () {
      builder.element('Rules', nest: rules.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// Container for information about a particular server-side encryption configuration rule.
  late List<ServerSideEncryptionRule> rules;
}

/// Specifies the default server-side encryption configuration.
class ServerSideEncryptionRule {
  ServerSideEncryptionRule(
    this.applyServerSideEncryptionByDefault,
    this.bucketKeyEnabled,
  );

  ServerSideEncryptionRule.fromXml(XmlElement? xml) {
    applyServerSideEncryptionByDefault = ServerSideEncryptionByDefault.fromXml(
        getProp(xml, 'ApplyServerSideEncryptionByDefault'));
    bucketKeyEnabled = getPropValueOrNull<bool>(xml, 'BucketKeyEnabled');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('ServerSideEncryptionRule', nest: () {
      builder.element('ApplyServerSideEncryptionByDefault',
          nest: applyServerSideEncryptionByDefault?.toXml());
      builder.element('BucketKeyEnabled',
          nest: bucketKeyEnabled == true ? 'TRUE' : 'FALSE');
    });
    return builder.buildDocument();
  }

  /// Specifies the default server-side encryption to apply to new objects in the bucket. If a PUT Object request doesn't specify any server-side encryption, this default encryption will be applied.
  ServerSideEncryptionByDefault? applyServerSideEncryptionByDefault;

  /// Specifies whether Amazon S3 should use an S3 Bucket Key with server-side encryption using KMS (SSE-KMS) for new objects in the bucket. Existing objects are not affected. Setting the BucketKeyEnabled element to true causes Amazon S3 to use an S3 Bucket Key. By default, S3 Bucket Key is not enabled.
  bool? bucketKeyEnabled;
}

/// The established temporary security credentials of the session.
class SessionCredentials {
  SessionCredentials(
    this.accessKeyId,
    this.expiration,
    this.secretAccessKey,
    this.sessionToken,
  );

  SessionCredentials.fromXml(XmlElement? xml) {
    accessKeyId = getPropValue<String>(xml, 'AccessKeyId');
    expiration = getPropValue<DateTime>(xml, 'Expiration');
    secretAccessKey = getPropValue<String>(xml, 'SecretAccessKey');
    sessionToken = getPropValue<String>(xml, 'SessionToken');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('SessionCredentials', nest: () {
      builder.element('AccessKeyId', nest: accessKeyId);
      builder.element('Expiration', nest: expiration.toIso8601String());
      builder.element('SecretAccessKey', nest: secretAccessKey);
      builder.element('SessionToken', nest: sessionToken);
    });
    return builder.buildDocument();
  }

  /// A unique identifier that's associated with a secret access key. The access key ID and the secret access key are used together to sign programmatic AWS requests cryptographically.
  late String accessKeyId;

  /// Temporary security credentials expire after a specified interval. After temporary credentials expire, any calls that you make with those credentials will fail. So you must generate a new set of temporary credentials. Temporary credentials cannot be extended or refreshed beyond the original specified interval.
  late DateTime expiration;

  /// A key that's used with the access key ID to cryptographically sign programmatic AWS requests. Signing a request identifies the sender and prevents the request from being altered.
  late String secretAccessKey;

  /// A part of the temporary security credentials. The session token is used to validate the temporary security credentials.
  late String sessionToken;
}

/// To use simple format for S3 keys for log objects, set SimplePrefix to an empty object.
class SimplePrefix {
  SimplePrefix();

  SimplePrefix.fromXml(XmlElement? xml) {}

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('SimplePrefix', nest: () {});
    return builder.buildDocument();
  }
}

/// A container that describes additional filters for identifying the source objects that you want to replicate. You can choose to enable or disable the replication of these objects. Currently, Amazon S3 supports only the filter that you can specify for objects created with server-side encryption using a customer managed key stored in AWS Key Management Service (SSE-KMS).
class SourceSelectionCriteria {
  SourceSelectionCriteria(
    this.replicaModifications,
    this.sseKmsEncryptedObjects,
  );

  SourceSelectionCriteria.fromXml(XmlElement? xml) {
    replicaModifications =
        ReplicaModifications.fromXml(getProp(xml, 'ReplicaModifications'));
    sseKmsEncryptedObjects =
        SseKmsEncryptedObjects.fromXml(getProp(xml, 'SseKmsEncryptedObjects'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('SourceSelectionCriteria', nest: () {
      builder.element('ReplicaModifications',
          nest: replicaModifications?.toXml());
      builder.element('SseKmsEncryptedObjects',
          nest: sseKmsEncryptedObjects?.toXml());
    });
    return builder.buildDocument();
  }

  /// A filter that you can specify for selections for modifications on replicas. Amazon S3 doesn't replicate replica modifications by default. In the latest version of replication configuration (when Filter is specified), you can specify this element and set the status to Enabled to replicate modifications on replicas.
  ReplicaModifications? replicaModifications;

  ///  A container for filter information for the selection of Amazon S3 objects encrypted with AWS KMS. If you include SourceSelectionCriteria in the replication configuration, this element is required.
  SseKmsEncryptedObjects? sseKmsEncryptedObjects;
}

/// Specifies the use of SSE-KMS to encrypt delivered inventory reports.
class SSEKMS {
  SSEKMS(
    this.keyId,
  );

  SSEKMS.fromXml(XmlElement? xml) {
    keyId = getPropValue<String>(xml, 'KeyId');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('SSEKMS', nest: () {
      builder.element('KeyId', nest: keyId);
    });
    return builder.buildDocument();
  }

  /// Specifies the ID of the AWS Key Management Service (AWS KMS) symmetric encryption customer managed key to use for encrypting inventory reports.
  late String keyId;
}

/// A container for filter information for the selection of S3 objects encrypted with AWS KMS.
class SseKmsEncryptedObjects {
  SseKmsEncryptedObjects(
    this.status,
  );

  SseKmsEncryptedObjects.fromXml(XmlElement? xml) {
    status = getPropValue<String>(xml, 'Status');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('SseKmsEncryptedObjects', nest: () {
      builder.element('Status', nest: status);
    });
    return builder.buildDocument();
  }

  /// Specifies whether Amazon S3 replicates objects created with server-side encryption using an AWS KMS key stored in AWS Key Management Service.
  late String status;
}

/// Specifies the use of SSE-S3 to encrypt delivered inventory reports.
class SSES3 {
  SSES3();

  SSES3.fromXml(XmlElement? xml) {}

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('SSES3', nest: () {});
    return builder.buildDocument();
  }
}

/// Container for the stats details.
class Stats {
  Stats(
    this.bytesProcessed,
    this.bytesReturned,
    this.bytesScanned,
  );

  Stats.fromXml(XmlElement? xml) {
    bytesProcessed = getPropValueOrNull<int>(xml, 'BytesProcessed');
    bytesReturned = getPropValueOrNull<int>(xml, 'BytesReturned');
    bytesScanned = getPropValueOrNull<int>(xml, 'BytesScanned');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Stats', nest: () {
      builder.element('BytesProcessed', nest: bytesProcessed.toString());
      builder.element('BytesReturned', nest: bytesReturned.toString());
      builder.element('BytesScanned', nest: bytesScanned.toString());
    });
    return builder.buildDocument();
  }

  /// The total number of uncompressed object bytes processed.
  int? bytesProcessed;

  /// The total number of bytes of records payload data returned.
  int? bytesReturned;

  /// The total number of object bytes scanned.
  int? bytesScanned;
}

/// Container for the Stats Event.
class StatsEvent {
  StatsEvent(
    this.details,
  );

  StatsEvent.fromXml(XmlElement? xml) {
    details = Stats.fromXml(getProp(xml, 'Details'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('StatsEvent', nest: () {
      builder.element('Details', nest: details?.toXml());
    });
    return builder.buildDocument();
  }

  /// The Stats event details.
  Stats? details;
}

/// Specifies data related to access patterns to be collected and made available to analyze the tradeoffs between different storage classes for an Amazon S3 bucket.
class StorageClassAnalysis {
  StorageClassAnalysis(
    this.dataExport,
  );

  StorageClassAnalysis.fromXml(XmlElement? xml) {
    dataExport =
        StorageClassAnalysisDataExport.fromXml(getProp(xml, 'DataExport'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('StorageClassAnalysis', nest: () {
      builder.element('DataExport', nest: dataExport?.toXml());
    });
    return builder.buildDocument();
  }

  /// Specifies how data related to the storage class analysis for an Amazon S3 bucket should be exported.
  StorageClassAnalysisDataExport? dataExport;
}

/// Container for data related to the storage class analysis for an Amazon S3 bucket for export.
class StorageClassAnalysisDataExport {
  StorageClassAnalysisDataExport(
    this.destination,
    this.outputSchemaVersion,
  );

  StorageClassAnalysisDataExport.fromXml(XmlElement? xml) {
    destination =
        AnalyticsExportDestination.fromXml(getProp(xml, 'Destination'));
    outputSchemaVersion = getPropValue<String>(xml, 'OutputSchemaVersion');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('StorageClassAnalysisDataExport', nest: () {
      builder.element('Destination', nest: destination.toXml());
      builder.element('OutputSchemaVersion', nest: outputSchemaVersion);
    });
    return builder.buildDocument();
  }

  /// The place to store the data for an analysis.
  late AnalyticsExportDestination destination;

  /// The version of the output schema to use when exporting data. Must be V_1.
  late String outputSchemaVersion;
}

/// A container of a key value name pair.
class Tag {
  Tag(
    this.key,
    this.value,
  );

  Tag.fromXml(XmlElement? xml) {
    key = getPropValue<String>(xml, 'Key');
    value = getPropValue<String>(xml, 'Value');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Tag', nest: () {
      builder.element('Key', nest: key);
      builder.element('Value', nest: value);
    });
    return builder.buildDocument();
  }

  /// Name of the object key.
  late String key;

  /// Value of the tag.
  late String value;
}

/// Container for TagSet elements.
class Tagging {
  Tagging(
    this.tagSet,
  );

  Tagging.fromXml(XmlElement? xml) {
    tagSet = getProp(xml, 'TagSet')!
        .children
        .map((c) => Tag.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Tagging', nest: () {
      builder.element('TagSet', nest: tagSet.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// A collection for a set of tags
  late List<Tag> tagSet;
}

/// Container for granting information.
class TargetGrant {
  TargetGrant(
    this.grantee,
    this.permission,
  );

  TargetGrant.fromXml(XmlElement? xml) {
    grantee = Grantee.fromXml(getProp(xml, 'Grantee'));
    permission = getPropValueOrNull<String>(xml, 'Permission');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('TargetGrant', nest: () {
      builder.element('Grantee', nest: grantee?.toXml());
      builder.element('Permission', nest: permission);
    });
    return builder.buildDocument();
  }

  /// Container for the person being granted permissions.
  Grantee? grantee;

  /// Logging permissions assigned to the grantee for the bucket.
  String? permission;
}

/// Amazon S3 key format for log objects. Only one format, PartitionedPrefix or SimplePrefix, is allowed.
class TargetObjectKeyFormat {
  TargetObjectKeyFormat(
    this.partitionedPrefix,
    this.simplePrefix,
  );

  TargetObjectKeyFormat.fromXml(XmlElement? xml) {
    partitionedPrefix =
        PartitionedPrefix.fromXml(getProp(xml, 'PartitionedPrefix'));
    simplePrefix = SimplePrefix.fromXml(getProp(xml, 'SimplePrefix'));
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('TargetObjectKeyFormat', nest: () {
      builder.element('PartitionedPrefix', nest: partitionedPrefix?.toXml());
      builder.element('SimplePrefix', nest: simplePrefix?.toXml());
    });
    return builder.buildDocument();
  }

  /// Partitioned S3 key for log objects.
  PartitionedPrefix? partitionedPrefix;

  /// To use the simple format for S3 keys for log objects. To specify SimplePrefix format, set SimplePrefix to {}.
  SimplePrefix? simplePrefix;
}

/// The S3 Intelligent-Tiering storage class is designed to optimize storage costs by automatically moving data to the most cost-effective storage access tier, without additional operational overhead.
class Tiering {
  Tiering(
    this.accessTier,
    this.days,
  );

  Tiering.fromXml(XmlElement? xml) {
    accessTier = getPropValue<String>(xml, 'AccessTier');
    days = getPropValue<int>(xml, 'Days');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Tiering', nest: () {
      builder.element('AccessTier', nest: accessTier);
      builder.element('Days', nest: days.toString());
    });
    return builder.buildDocument();
  }

  /// S3 Intelligent-Tiering access tier. See Storage class for automatically optimizing frequently and infrequently accessed objects for a list of access tiers in the S3 Intelligent-Tiering storage class.
  late String accessTier;

  /// The number of consecutive days of no access after which an object will be eligible to be transitioned to the corresponding tier. The minimum number of days specified for Archive Access tier must be at least 90 days and Deep Archive Access tier must be at least 180 days. The maximum can be up to 2 years (730 days).
  late int days;
}

/// A container for specifying the configuration for publication of messages to an Amazon Simple Notification Service (Amazon SNS) topic when Amazon S3 detects specified events.
class TopicConfiguration {
  TopicConfiguration(
    this.events,
    this.topicArn,
    this.filter,
    this.id,
  );

  TopicConfiguration.fromXml(XmlElement? xml) {
    events = getPropValue<List<String>>(xml, 'Events');
    topicArn = getPropValue<String>(xml, 'TopicArn');
    filter = NotificationConfigurationFilter.fromXml(getProp(xml, 'Filter'));
    id = getPropValueOrNull<String>(xml, 'Id');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('TopicConfiguration', nest: () {
      builder.element('Events', nest: events);
      builder.element('TopicArn', nest: topicArn);
      builder.element('Filter', nest: filter?.toXml());
      builder.element('Id', nest: id);
    });
    return builder.buildDocument();
  }

  /// The Amazon S3 bucket event about which to send notifications. For more information, see Supported Event Types in the Amazon S3 User Guide.
  late List<String> events;

  /// The Amazon Resource Name (ARN) of the Amazon SNS topic to which Amazon S3 publishes a message when it detects events of the specified type.
  late String topicArn;

  /// Specifies object key name filtering rules. For information about key name filtering, see Configuring event notifications using object key name filtering in the Amazon S3 User Guide.
  NotificationConfigurationFilter? filter;

  /// An optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon S3 will assign an ID.
  String? id;
}

/// A container for specifying the configuration for publication of messages to an Amazon Simple Notification Service (Amazon SNS) topic when Amazon S3 detects specified events. This data type is deprecated. Use TopicConfiguration instead.
class TopicConfigurationDeprecated {
  TopicConfigurationDeprecated(
    this.event,
    this.events,
    this.id,
    this.topic,
  );

  TopicConfigurationDeprecated.fromXml(XmlElement? xml) {
    event = getPropValueOrNull<String>(xml, 'Event');
    events = getPropValueOrNull<List<String>>(xml, 'Events');
    id = getPropValueOrNull<String>(xml, 'Id');
    topic = getPropValueOrNull<String>(xml, 'Topic');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('TopicConfigurationDeprecated', nest: () {
      builder.element('Event', nest: event);
      builder.element('Events', nest: events);
      builder.element('Id', nest: id);
      builder.element('Topic', nest: topic);
    });
    return builder.buildDocument();
  }

  ///  This member has been deprecated.
  String? event;

  /// A collection of events related to objects
  List<String>? events;

  /// An optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon S3 will assign an ID.
  String? id;

  /// Amazon SNS topic to which Amazon S3 will publish a message to report the specified events for the bucket.
  String? topic;
}

/// Specifies when an object transitions to a specified storage class. For more information about Amazon S3 lifecycle configuration rules, see Transitioning Objects Using Amazon S3 Lifecycle in the Amazon S3 User Guide.
class Transition {
  Transition(
    this.date,
    this.days,
    this.storageClass,
  );

  Transition.fromXml(XmlElement? xml) {
    date = getPropValueOrNull<DateTime>(xml, 'Date');
    days = getPropValueOrNull<int>(xml, 'Days');
    storageClass = getPropValueOrNull<String>(xml, 'StorageClass');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('Transition', nest: () {
      builder.element('Date', nest: date?.toIso8601String());
      builder.element('Days', nest: days.toString());
      builder.element('StorageClass', nest: storageClass);
    });
    return builder.buildDocument();
  }

  /// Indicates when objects are transitioned to the specified storage class. The date value must be in ISO 8601 format. The time is always midnight UTC.
  DateTime? date;

  /// Indicates the number of days after creation when objects are transitioned to the specified storage class. The value must be a positive integer.
  int? days;

  /// The storage class to which you want the object to transition.
  String? storageClass;
}

/// Describes the versioning state of an Amazon S3 bucket. For more information, see PUT Bucket versioning in the Amazon S3 API Reference.
class VersioningConfiguration {
  VersioningConfiguration(
    this.mFADelete,
    this.status,
  );

  VersioningConfiguration.fromXml(XmlElement? xml) {
    mFADelete = getPropValueOrNull<String>(xml, 'MFADelete');
    status = getPropValueOrNull<String>(xml, 'Status');
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('VersioningConfiguration', nest: () {
      builder.element('MFADelete', nest: mFADelete);
      builder.element('Status', nest: status);
    });
    return builder.buildDocument();
  }

  /// Specifies whether MFA delete is enabled in the bucket versioning configuration. This element is only returned if the bucket has been configured with MFA delete. If the bucket has never been so configured, this element is not returned.
  String? mFADelete;

  /// The versioning state of the bucket.
  String? status;
}

/// Specifies website configuration parameters for an Amazon S3 bucket.
class WebsiteConfiguration {
  WebsiteConfiguration(
    this.errorDocument,
    this.indexDocument,
    this.redirectAllRequestsTo,
    this.routingRules,
  );

  WebsiteConfiguration.fromXml(XmlElement? xml) {
    errorDocument = ErrorDocument.fromXml(getProp(xml, 'ErrorDocument'));
    indexDocument = IndexDocument.fromXml(getProp(xml, 'IndexDocument'));
    redirectAllRequestsTo =
        RedirectAllRequestsTo.fromXml(getProp(xml, 'RedirectAllRequestsTo'));
    routingRules = getProp(xml, 'RoutingRules')
        ?.children
        .map((c) => RoutingRule.fromXml(c as XmlElement))
        .toList();
  }

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('WebsiteConfiguration', nest: () {
      builder.element('ErrorDocument', nest: errorDocument?.toXml());
      builder.element('IndexDocument', nest: indexDocument?.toXml());
      builder.element('RedirectAllRequestsTo',
          nest: redirectAllRequestsTo?.toXml());
      builder.element('RoutingRules',
          nest: routingRules?.map((e) => e.toXml()));
    });
    return builder.buildDocument();
  }

  /// The name of the error document for the website.
  ErrorDocument? errorDocument;

  /// The name of the index document for the website.
  IndexDocument? indexDocument;

  /// The redirect behavior for every request to this bucket's website endpoint.
  RedirectAllRequestsTo? redirectAllRequestsTo;

  /// Rules that define when a redirect is applied and the redirect behavior.
  List<RoutingRule>? routingRules;
}
