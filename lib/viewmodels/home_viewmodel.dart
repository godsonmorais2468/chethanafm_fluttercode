import 'package:flutter/material.dart';
import 'package:chethanafm/models/live_program.dart';
import 'package:chethanafm/repo/api_client.dart';
import 'package:chethanafm/repo/repository.dart';
import 'package:chethanafm/repo/api_state.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  
  LiveProgram? _liveProgram;
  bool _isLoading = false;
  String? _errorMessage;

  HomeViewModel({ApiClient? apiClient}) : _apiClient = apiClient ?? Repository.instance;

  LiveProgram? get liveProgram => _liveProgram;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLiveProgram() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiClient.getLiveProgram();
      if (result.status == Status.success && result.data != null) {
        _liveProgram = result.data;
      } else {
        _errorMessage = result.error.isNotEmpty ? result.error : 'Failed to load live programme';
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
