import 'package:chethanafm/repo/rest_client.dart';

class NetworkResult<T> {
  Status status;
  String error;
  T? data;
  int statusCode;

  NetworkResult({this.status = Status.none, this.error = "", this.data, this.statusCode = ErrorCodes.error500});

  factory NetworkResult.initial() {
    return NetworkResult();
  }

  factory NetworkResult.error(String error, {T? data, int statusCode = ErrorCodes.error500}) {
    return NetworkResult(status: Status.error, error: error, statusCode: statusCode, data: data);
  }

  factory NetworkResult.success(T? data, {int statusCode = 200}) {
    return NetworkResult(data: data, status: Status.success, statusCode: statusCode);
  }

  factory NetworkResult.loading() {
    return NetworkResult(status: Status.loading);
  }

  NetworkResult copyWith({status, error, data}) {
    return NetworkResult(status: status ?? this.status, error: error ?? this.error, data: data ?? this.data);
  }
}

enum Status { none, loading, success, error }

typedef NetworkCallback<T> = void Function(NetworkResult<T> result);
