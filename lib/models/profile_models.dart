// ══════════════════════════════════════════════════════════════
//  SAVVY – PROFILE MODEL
//  lib/models/profile_models.dart
// ══════════════════════════════════════════════════════════════

enum Gender { male, female, other, notSpecified }

extension GenderExtension on Gender {
  String get label {
    switch (this) {
      case Gender.male:         return 'Homme';
      case Gender.female:       return 'Femme';
      case Gender.other:        return 'Autre';
      case Gender.notSpecified: return 'Non précisé';
    }
  }

  String get value {
    switch (this) {
      case Gender.male:         return 'male';
      case Gender.female:       return 'female';
      case Gender.other:        return 'other';
      case Gender.notSpecified: return 'not_specified';
    }
  }

  static Gender fromValue(String? value) {
    switch (value) {
      case 'male':   return Gender.male;
      case 'female': return Gender.female;
      case 'other':  return Gender.other;
      default:       return Gender.notSpecified;
    }
  }
}

// ─────────────────────────────────────────────────────────────

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? photoBase64;
  final Gender gender;
  final DateTime? birthDate;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoBase64,
    this.gender = Gender.notSpecified,
    this.birthDate,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  // ── Getters calculés ──────────────────────────────────────
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  String get formattedBirthDate {
    if (birthDate == null) return 'Non renseigné';
    return '${birthDate!.day.toString().padLeft(2, '0')}/'
        '${birthDate!.month.toString().padLeft(2, '0')}/'
        '${birthDate!.year}';
  }

  int? get age {
    if (birthDate == null) return null;
    final today = DateTime.now();
    int age = today.year - birthDate!.year;
    if (today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // ── Firestore ─────────────────────────────────────────────
  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoBase64: map['photoBase64'],
      gender: GenderExtension.fromValue(map['gender']),
      birthDate: map['birthDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['birthDate'])
          : null,
      phone: map['phone'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      if (photoBase64 != null) 'photoBase64': photoBase64,
      'gender': gender.value,
      if (birthDate != null) 'birthDate': birthDate!.millisecondsSinceEpoch,
      if (phone != null) 'phone': phone,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? photoBase64,
    Gender? gender,
    DateTime? birthDate,
    String? phone,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoBase64: photoBase64 ?? this.photoBase64,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class SecurityInfo {
  final bool hasPassword;     // false si connexion Google uniquement
  final DateTime? lastPasswordChange;
  final bool emailVerified;
  final List<String> providers; // ['password', 'google.com']

  const SecurityInfo({
    required this.hasPassword,
    required this.emailVerified,
    required this.providers,
    this.lastPasswordChange,
  });

  bool get isGoogleOnly =>
      providers.contains('google.com') && !providers.contains('password');

  String get lastChangeFormatted {
    if (lastPasswordChange == null) return 'Jamais modifié';
    final diff = DateTime.now().difference(lastPasswordChange!);
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 30) return 'Il y a ${diff.inDays} jours';
    return '${lastPasswordChange!.day}/${lastPasswordChange!.month}/${lastPasswordChange!.year}';
  }
}