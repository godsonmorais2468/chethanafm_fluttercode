class ProgramSchedule {
  final int id;
  final String day;
  final String startTime;
  final String endTime;
  final String title;
  final String rj;

  ProgramSchedule({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.rj,
  });

  factory ProgramSchedule.fromJson(Map<String, dynamic> json) {
    return ProgramSchedule(
      id: json['id'] as int,
      day: json['day'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      title: json['title'] as String,
      rj: json['rj'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'title': title,
      'rj': rj,
    };
  }
}
