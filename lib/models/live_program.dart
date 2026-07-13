class LiveProgram {
  final int id;
  final String title;
  final String rj;
  final bool isLive;
  final String streamUrl;

  LiveProgram({
    required this.id,
    required this.title,
    required this.rj,
    required this.isLive,
    required this.streamUrl,
  });

  factory LiveProgram.fromJson(Map<String, dynamic> json) {
    return LiveProgram(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      rj: json['rj'] as String? ?? '',
      isLive: json['is_live'] as bool? ?? false,
      streamUrl: json['stream_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'rj': rj,
      'is_live': isLive,
      'stream_url': streamUrl,
    };
  }
}
