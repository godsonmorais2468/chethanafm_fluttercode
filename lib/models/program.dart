class Program {
  final int id;
  final String name;
  final String day;
  final String week; // New field
  final String start;
  final String end;
  final String image;
  final String rj;
  final int odr;
  final int status;
  final int star;
  final String details; // Newly added field

  Program({
    required this.id,
    required this.name,
    required this.day,
    required this.week, // New field
    required this.start,
    required this.end,
    required this.image,
    required this.rj,
    required this.odr,
    required this.status,
    required this.star,
    required this.details, // New field
  });
  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] as int,
      name: json['name'] as String,
      day: json['day'] as String,
      week: json['week'] as String, // New field
      start: json['start'] as String,
      end: json['end'] as String,
      image: json['image'] as String,
      rj: json['rj'] as String,
      odr: json['odr'] as int,
      status: json['status'] as int,
      star: json['star'] ?? 0, // Assign 0 if null
      details: (json['details'] ?? '').toString(), // Explicitly cast to String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'day': day,
      'week': week, // New field serialization
      'start': start,
      'end': end,
      'image': image,
      'rj': rj,
      'odr': odr,
      'status': status,
      'star': star,
      'details': details, // New field serialization
    };
  }
}
