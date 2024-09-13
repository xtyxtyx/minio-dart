import 'package:minio/models.dart';
import 'package:minio/src/minio_client.dart';
import 'package:minio/src/minio_helpers.dart';

class MinioError implements Exception {
  MinioError(this.message);

  final String? message;

  @override
  String toString() {
    return 'MinioError: $message';
  }
}

class MinioAnonymousRequestError extends MinioError {
  MinioAnonymousRequestError(super.message);
}

class MinioInvalidArgumentError extends MinioError {
  MinioInvalidArgumentError(super.message);
}

class MinioInvalidPortError extends MinioError {
  MinioInvalidPortError(super.message);
}

class MinioInvalidEndpointError extends MinioError {
  MinioInvalidEndpointError(super.message);
}

class MinioInvalidBucketNameError extends MinioError {
  MinioInvalidBucketNameError(super.message);

  static void check(String bucket) {
    if (isValidBucketName(bucket)) return;
    throw MinioInvalidBucketNameError('Invalid bucket name: $bucket');
  }
}

class MinioInvalidObjectNameError extends MinioError {
  MinioInvalidObjectNameError(super.message);

  static void check(String object) {
    if (isValidObjectName(object)) return;
    throw MinioInvalidObjectNameError('Invalid object name: $object');
  }
}

class MinioAccessKeyRequiredError extends MinioError {
  MinioAccessKeyRequiredError(super.message);
}

class MinioSecretKeyRequiredError extends MinioError {
  MinioSecretKeyRequiredError(super.message);
}

class MinioExpiresParamError extends MinioError {
  MinioExpiresParamError(super.message);
}

class MinioInvalidDateError extends MinioError {
  MinioInvalidDateError(super.message);
}

class MinioInvalidPrefixError extends MinioError {
  MinioInvalidPrefixError(super.message);

  static void check(String prefix) {
    if (isValidPrefix(prefix)) return;
    throw MinioInvalidPrefixError('Invalid prefix: $prefix');
  }
}

class MinioInvalidBucketPolicyError extends MinioError {
  MinioInvalidBucketPolicyError(super.message);
}

class MinioIncorrectSizeError extends MinioError {
  MinioIncorrectSizeError(super.message);
}

class MinioInvalidXMLError extends MinioError {
  MinioInvalidXMLError(super.message);
}

class MinioS3Error extends MinioError {
  MinioS3Error(super.message, [this.error, this.response]);

  Error? error;

  MinioResponse? response;
}
