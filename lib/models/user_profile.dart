import 'package:uuid/uuid.dart';

class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final String? timezone;
  final EmergencyContact? emergencyContact;
  final PrivacySettings privacySettings;
  final SecuritySettings securitySettings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  UserProfile({
    String? id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.avatarUrl,
    this.timezone,
    this.emergencyContact,
    PrivacySettings? privacySettings,
    SecuritySettings? securitySettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastLogin,
  })  : id = id ?? const Uuid().v4(),
        privacySettings = privacySettings ?? PrivacySettings(),
        securitySettings = securitySettings ?? SecuritySettings(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'avatar_url': avatarUrl,
      'timezone': timezone,
      'emergency_contact': emergencyContact?.toMap(),
      'privacy_settings': privacySettings.toMap(),
      'security_settings': securitySettings.toMap(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      email: map['email'],
      fullName: map['full_name'],
      phoneNumber: map['phone_number'],
      dateOfBirth: map['date_of_birth'] != null 
          ? DateTime.parse(map['date_of_birth'])
          : null,
      avatarUrl: map['avatar_url'],
      timezone: map['timezone'],
      emergencyContact: map['emergency_contact'] != null
          ? EmergencyContact.fromMap(map['emergency_contact'])
          : null,
      privacySettings: PrivacySettings.fromMap(map['privacy_settings'] ?? {}),
      securitySettings: SecuritySettings.fromMap(map['security_settings'] ?? {}),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'])
          : null,
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? avatarUrl,
    String? timezone,
    EmergencyContact? emergencyContact,
    PrivacySettings? privacySettings,
    SecuritySettings? securitySettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      privacySettings: privacySettings ?? this.privacySettings,
      securitySettings: securitySettings ?? this.securitySettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String? relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    this.relationship,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: map['name'],
      phone: map['phone'],
      relationship: map['relationship'],
    );
  }
}

class PrivacySettings {
  final bool dataSharingConsent;
  final bool analyticsConsent;
  final bool marketingConsent;
  final bool researchParticipationConsent;
  final String profileVisibility; // 'private', 'friends', 'public'
  final bool moodDataSharing;
  final bool sessionDataSharing;

  PrivacySettings({
    this.dataSharingConsent = false,
    this.analyticsConsent = false,
    this.marketingConsent = false,
    this.researchParticipationConsent = false,
    this.profileVisibility = 'private',
    this.moodDataSharing = false,
    this.sessionDataSharing = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'data_sharing_consent': dataSharingConsent,
      'analytics_consent': analyticsConsent,
      'marketing_consent': marketingConsent,
      'research_participation_consent': researchParticipationConsent,
      'profile_visibility': profileVisibility,
      'mood_data_sharing': moodDataSharing,
      'session_data_sharing': sessionDataSharing,
    };
  }

  factory PrivacySettings.fromMap(Map<String, dynamic> map) {
    return PrivacySettings(
      dataSharingConsent: map['data_sharing_consent'] ?? false,
      analyticsConsent: map['analytics_consent'] ?? false,
      marketingConsent: map['marketing_consent'] ?? false,
      researchParticipationConsent: map['research_participation_consent'] ?? false,
      profileVisibility: map['profile_visibility'] ?? 'private',
      moodDataSharing: map['mood_data_sharing'] ?? false,
      sessionDataSharing: map['session_data_sharing'] ?? false,
    );
  }
}

class SecuritySettings {
  final bool twoFactorEnabled;
  final bool loginNotifications;
  final int sessionTimeoutMinutes;

  SecuritySettings({
    this.twoFactorEnabled = false,
    this.loginNotifications = true,
    this.sessionTimeoutMinutes = 30,
  });

  Map<String, dynamic> toMap() {
    return {
      'two_factor_enabled': twoFactorEnabled,
      'login_notifications': loginNotifications,
      'session_timeout_minutes': sessionTimeoutMinutes,
    };
  }

  factory SecuritySettings.fromMap(Map<String, dynamic> map) {
    return SecuritySettings(
      twoFactorEnabled: map['two_factor_enabled'] ?? false,
      loginNotifications: map['login_notifications'] ?? true,
      sessionTimeoutMinutes: map['session_timeout_minutes'] ?? 30,
    );
  }
}