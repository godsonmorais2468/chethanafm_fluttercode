class CountryCode {
  final String code;
  final String country;

  CountryCode({
    required this.code,
    required this.country,
  });

  String get flagEmoji {
    switch (code) {
      case '+91': return '🇮🇳';
      case '+1': return '🇺🇸';
      case '+44': return '🇬🇧';
      case '+61': return '🇦🇺';
      case '+971': return '🇦🇪';
      case '+966': return '🇸🇦';
      case '+65': return '🇸🇬';
      default: return '🌐';
    }
  }

  factory CountryCode.fromJson(Map<String, dynamic> json) {
    return CountryCode(
      code: json['code'] as String? ?? '',
      country: json['country'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'country': country,
    };
  }

  CountryCode copyWith({
    String? code,
    String? country,
  }) {
    return CountryCode(
      code: code ?? this.code,
      country: country ?? this.country,
    );
  }
}

class LoginRequest {
  final String countryCode;
  final String phoneNumber;
  final String password;

  LoginRequest({
    required this.countryCode,
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'country_code': countryCode,
      'phone_number': phoneNumber,
      'password': password,
    };
  }
}

class User {
  final int id;
  final String name;
  final String countryCode;
  final String phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_code': countryCode,
      'phone_number': phoneNumber,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? countryCode,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String? ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

class RegisterResponse {
  final String token;
  final User user;

  RegisterResponse({
    required this.token,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      token: json['token'] as String? ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

class ProfileResponse {
  final User user;

  ProfileResponse({
    required this.user,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
    };
  }
}
