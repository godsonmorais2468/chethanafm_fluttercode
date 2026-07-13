import 'dart:convert';
import 'dart:io';

import 'package:chethanafm/repo/api_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../utils/debug.dart';
import '../utils/helper.dart';
import 'package:http/http.dart' as http;

class RestClient {
  RestClient._privateConstructor();

  static final RestClient _instance = RestClient._privateConstructor();

  final _dio = Dio(
    BaseOptions(
      responseType: ResponseType.plain,
      baseUrl: ServerConfig.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      //Seconds
      receiveTimeout: const Duration(seconds: 90),
      //Seconds
      sendTimeout: const Duration(minutes: 5),
    ),
  );

  RestClient();

  static RestClient get instance => _instance;
  static const String _tag = "RestClient";
  static const String _token = "Bearer";
  Future<Map<String, dynamic>> _getHeaders(bool isToken, {Map<String, dynamic>? extraHeaders}) async {
    Map<String, dynamic> headers = {
      // "Content-Type": "application/x-www-form-urlencoded",
      "Content-Type": "application/json",
    };
    try {
      if (isToken) {
        final PrefHelper prefHelper = PrefHelper.instance;
        String token = prefHelper.getString(PrefHelper.token, "");

        headers["Authorization"] = "$_token $token";
      }

      if (extraHeaders != null) {
        headers.addAll(extraHeaders);
      }
    } catch (e) {
      print(e);
    }
    return headers;
  }

  Future<NetworkResult> post(String url, Map<String, dynamic>? requestBody, {bool isToken = true, BuildContext? context, Map<String, dynamic>? extraHeaders}) async {
    return _doRequest(context, url, _RequestMethod.post, requestBody: requestBody, isToken: isToken, extraHeaders: extraHeaders);
  }

  Future<NetworkResult> get(
    String url, {
    bool isToken = true,
    BuildContext? context,
    Map<String, dynamic>? requestBody,
  }) async {
    return _doRequest(context, url, _RequestMethod.get, isToken: isToken, requestBody: requestBody);
  }

  Future<NetworkResult> patch(
    String url,
    Map<String, dynamic> requestBody, {
    bool isToken = true,
    BuildContext? context,
  }) async {
    return _doRequest(context, url, _RequestMethod.patch, requestBody: requestBody, isToken: isToken);
  }

  Future<NetworkResult> postMultipart(String url, http.MultipartRequest? requestBody, {bool isToken = true, BuildContext? context, Map<String, dynamic>? extraHeaders}) async {
    return _doRequest1(context, url, requestBody, extraHeaders);
  }

  Future<NetworkResult> _doRequest1(BuildContext? context, String url, http.MultipartRequest? request, Map<String, dynamic>? extraHeaders) async {
    try {
      var res = await request!.send();
      final respStr = await res.stream.bytesToString();
      return NetworkResult.success(respStr);
    } on DioException catch (e) {
      Debug.trace("$_tag POST_URL : $url");
      //  Debug.trace("$_tag REQUEST_BODY : $request");

      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        // _handleAppEvent(e.response);
        return NetworkResult.error(StringHelper.errorMsgEmptyData, data: e.response?.data, statusCode: e.response!.statusCode!);
      } else {
        // Error due to setting up or sending the request
        Debug.trace('$_tag Error sending request!');
        Debug.trace("$_tag ${e.message}");
      }
      return NetworkResult.error(StringHelper.errorMsgEmptyData);
    } catch (e) {
      return NetworkResult.error(StringHelper.errorMsgEmptyData);
    }
  }

  Future<NetworkResult> _doRequest(BuildContext? context, String url, _RequestMethod requestMethod,
      {bool isToken = true, Map<String, dynamic>? requestBody, List<File>? fileList, Map<String, dynamic>? extraHeaders}) async {
    Map<String, dynamic> headers = await _getHeaders(isToken, extraHeaders: extraHeaders);

    try {
      Response<String>? response;

      switch (requestMethod) {
        case _RequestMethod.delete:
          break;
        case _RequestMethod.get:
          {
            response = await _dio.get(url, data: requestBody, options: Options(headers: headers));
          }
          break;
        case _RequestMethod.post:
          {
            if (fileList != null && fileList.isNotEmpty) {
              //for upload files
              FormData formData = FormData();
              for (var element in fileList) {
                formData.files.add(MapEntry("files", await MultipartFile.fromFile(element.path, filename: element.path.split('/').last)));
              }
              response = await _dio.post(
                url,
                options: Options(headers: headers),
                data: formData,
              );
            } else {
              //for json post
              response = await _dio.post(
                url,
                options: Options(headers: headers),
                data: requestBody,
              );
            }
          }
          break;
        case _RequestMethod.patch:
          {
            response = await _dio.patch(
              url,
              options: Options(headers: headers),
              data: requestBody,
            );
          }
          break;
        case _RequestMethod.put:
          {
            response = await _dio.put(
              url,
              options: Options(headers: headers),
              data: requestBody,
            );
          }
          break;
      }

      int statusCode = response!.statusCode!;
      Debug.trace("$_tag POST_URL : $url");
      Debug.trace("$_tag REQUEST_BODY : ${jsonEncode(requestBody)}");
      Debug.trace("$_tag STATUS : $statusCode");
      Debug.trace("$_tag DATA : ${response.data}");

      return NetworkResult.success(response.data);
    } on DioException catch (e) {
      Debug.trace("$_tag POST_URL : $url");
      Debug.trace("$_tag REQUEST_BODY : $requestBody");
      Debug.trace("$_tag REQUEST_BODY : $e");

      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        Debug.trace('$_tag Dio error!');
        Debug.trace('$_tag STATUS : ${e.response?.statusCode}');
        Debug.trace('$_tag DATA : ${e.response?.data}');
        // _handleAppEvent(e.response);
        return NetworkResult.error(StringHelper.errorMsgEmptyData, data: e.response?.data, statusCode: e.response!.statusCode!);
      } else {
        // Error due to setting up or sending the request
        Debug.trace('$_tag Error sending request!');
        Debug.trace("$_tag ${e.message}");
      }
      return NetworkResult.error(StringHelper.errorMsgEmptyData);
    } catch (e) {
      return NetworkResult.error(StringHelper.errorMsgEmptyData);
    }
  }

  Future<NetworkResult> uploadFiles(String url, List<File> fileList, {bool isToken = true, BuildContext? context}) {
    return _doRequest(context, url, _RequestMethod.post, fileList: fileList, isToken: isToken);
  }
}

class ErrorCodes {
  static const int error403 = 403; //Session expired
  static const int error401 = 401; // Invalid access token
  static const int error409 = 409; //User is blocked by admin
  static const int error428 = 428; //No KYC or UPI Updated
  static const int error500 = 500; //Unknown error
}

enum _RequestMethod { get, post, patch, delete, put }

class ServerConfig {
  //LIVE Staging
  static const String baseUrl = "https://chethanafm.com";
  static const fm = "https://fm.chethanafm.com/chethana";

  static const String apiUrl = "$baseUrl/api";
}

class ApiList {
  static const String login = '/user/login';
  static const String signup = '/user/register';
  static const String registerOtpVerify = '/user/registerOtpVerify';
  static const String resendotp = '/user/resendotp';
  static const String loginOtpVerify = '/user/loginOtpVerify';
  static const String logout = '/user/logout';
  static const String prgramList = '/program/list';
  static const String commentList = '/comment/list';
  static const String commentSave = '/comment/save';
  static const String programStar = '/program/star';
  static const String programUserStar = '/program/userstar';
  static const String liveProgram = '/program/live';
  static const String programmeSchedule = '/schedule/';
  static const String liveRadio = '/live/';
}
