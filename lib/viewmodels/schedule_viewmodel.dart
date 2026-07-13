import 'package:flutter/material.dart';
import 'package:chethanafm/models/program.dart';
import 'package:chethanafm/models/program_schedule.dart';
import 'package:chethanafm/repo/api_client.dart';
import 'package:chethanafm/repo/api_state.dart';
import 'package:chethanafm/repo/repository.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ApiClient _apiClient;

  // Existing programs list for Home Screen (Today's Line-Up)
  List<Program> _allPrograms = [];
  bool _isLoadingPrograms = false;

  // New schedule items list for Schedule Screen (Module 3)
  List<ProgramSchedule> _allSchedules = [];
  List<ProgramSchedule> _filteredSchedules = [];
  bool _isLoading = false;
  String _errorMessage = "";
  String _selectedDay = "Mon"; // default tab day filter
  String _searchQuery = "";

  ScheduleViewModel({ApiClient? apiClient}) : _apiClient = apiClient ?? Repository.instance;

  List<Program> get allPrograms => _allPrograms;
  List<ProgramSchedule> get allSchedules => _allSchedules;
  List<ProgramSchedule> get filteredSchedules => _filteredSchedules;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedDay => _selectedDay;
  String get searchQuery => _searchQuery;

  // Group schedules by week day (returns ProgramSchedule)
  List<ProgramSchedule> getProgramListForDay(String day) {
    final query = _searchQuery.toLowerCase();
    return _allSchedules.where((p) {
      final dayMatches = p.day.toLowerCase() == day.toLowerCase();
      if (query.isEmpty) return dayMatches;
      final titleMatches = p.title.toLowerCase().contains(query);
      final rjMatches = p.rj.toLowerCase().contains(query);
      return dayMatches && (titleMatches || rjMatches);
    }).toList();
  }

  // Fetch the legacy programs list (keeps Home Screen intact!)
  Future<void> fetchPrograms(int userId) async {
    _isLoadingPrograms = true;
    notifyListeners();

    final result = await _apiClient.programList(userId);
    _isLoadingPrograms = false;

    if (result.status == Status.success && result.data != null) {
      _allPrograms = result.data!;
    }
    notifyListeners();
  }

  // Fetch the program schedule API for Schedule Screen
  Future<void> fetchSchedule() async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    final result = await _apiClient.getProgrammeSchedule();
    _isLoading = false;

    if (result.status == Status.success && result.data != null) {
      _allSchedules = result.data!;
      _filterSchedules();
    } else {
      _errorMessage = result.error.isNotEmpty ? result.error : "Failed to fetch programme schedule";
    }
    notifyListeners();
  }

  void selectDay(String day) {
    _selectedDay = day;
    _filterSchedules();
    notifyListeners();
  }

  void searchPrograms(String query) {
    _searchQuery = query;
    _filterSchedules();
    notifyListeners();
  }

  void _filterSchedules() {
    final query = _searchQuery.toLowerCase();
    _filteredSchedules = _allSchedules.where((p) {
      final matchesDay = p.day.toLowerCase() == _selectedDay.toLowerCase();
      if (query.isEmpty) return matchesDay;
      final titleMatches = p.title.toLowerCase().contains(query);
      final rjMatches = p.rj.toLowerCase().contains(query);
      return matchesDay && (titleMatches || rjMatches);
    }).toList();
  }

  // Retain existing toggleStar signature to avoid compilation errors in other files
  Future<void> toggleStar(int userId, int programId, Function(NetworkResult) callback) async {
    final result = await _apiClient.programStar(userId, programId);
    if (result.status == Status.success) {
      final idx = _allPrograms.indexWhere((p) => p.id == programId);
      if (idx != -1) {
        final current = _allPrograms[idx];
        _allPrograms[idx] = Program(
          id: current.id,
          name: current.name,
          day: current.day,
          week: current.week,
          start: current.start,
          end: current.end,
          image: current.image,
          rj: current.rj,
          odr: current.odr,
          status: current.status,
          star: current.star == 1 ? 0 : 1,
          details: current.details,
        );
        notifyListeners();
      }
    }
    callback(result);
  }
}
