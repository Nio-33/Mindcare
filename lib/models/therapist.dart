import 'package:uuid/uuid.dart';

enum TherapistSpecialization {
  depression,
  anxiety,
  trauma,
  addiction,
  relationships,
  grief,
  eating_disorders,
  bipolar,
  adhd,
  general,
}

enum TherapyApproach {
  cognitive_behavioral_therapy,
  dialectical_behavior_therapy,
  psychodynamic,
  humanistic,
  mindfulness_based,
  acceptance_commitment_therapy,
  emdr,
  family_systems,
}

enum SessionFormat {
  individual,
  couples,
  family,
  group,
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  in_progress,
  completed,
  cancelled,
  no_show,
}

class Therapist {
  final String id;
  final String name;
  final String title;
  final String licenseNumber;
  final List<TherapistSpecialization> specializations;
  final List<TherapyApproach> approaches;
  final List<SessionFormat> sessionFormats;
  final String bio;
  final String? profileImageUrl;
  final double rating;
  final int reviewCount;
  final int yearsExperience;
  final List<String> languages;
  final Map<String, double> sessionRates; // Format -> rate per session
  final bool acceptsInsurance;
  final List<String> insuranceProviders;
  final Map<String, bool> availability; // Day -> available
  final String? officeAddress;
  final bool offersOnlineTherapy;
  final bool offersInPersonTherapy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isVerified;

  Therapist({
    String? id,
    required this.name,
    required this.title,
    required this.licenseNumber,
    required this.specializations,
    required this.approaches,
    required this.sessionFormats,
    required this.bio,
    this.profileImageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.yearsExperience,
    required this.languages,
    required this.sessionRates,
    this.acceptsInsurance = false,
    List<String>? insuranceProviders,
    Map<String, bool>? availability,
    this.officeAddress,
    this.offersOnlineTherapy = true,
    this.offersInPersonTherapy = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
    this.isVerified = false,
  })  : id = id ?? const Uuid().v4(),
        insuranceProviders = insuranceProviders ?? [],
        availability = availability ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'license_number': licenseNumber,
      'specializations': specializations.map((s) => s.toString().split('.').last).toList(),
      'approaches': approaches.map((a) => a.toString().split('.').last).toList(),
      'session_formats': sessionFormats.map((f) => f.toString().split('.').last).toList(),
      'bio': bio,
      'profile_image_url': profileImageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'years_experience': yearsExperience,
      'languages': languages,
      'session_rates': sessionRates,
      'accepts_insurance': acceptsInsurance,
      'insurance_providers': insuranceProviders,
      'availability': availability,
      'office_address': officeAddress,
      'offers_online_therapy': offersOnlineTherapy,
      'offers_in_person_therapy': offersInPersonTherapy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'is_verified': isVerified,
    };
  }

  factory Therapist.fromMap(Map<String, dynamic> map) {
    return Therapist(
      id: map['id'],
      name: map['name'],
      title: map['title'],
      licenseNumber: map['license_number'],
      specializations: (map['specializations'] as List)
          .map((s) => TherapistSpecialization.values
              .firstWhere((e) => e.toString().split('.').last == s))
          .toList(),
      approaches: (map['approaches'] as List)
          .map((a) => TherapyApproach.values
              .firstWhere((e) => e.toString().split('.').last == a))
          .toList(),
      sessionFormats: (map['session_formats'] as List)
          .map((f) => SessionFormat.values
              .firstWhere((e) => e.toString().split('.').last == f))
          .toList(),
      bio: map['bio'],
      profileImageUrl: map['profile_image_url'],
      rating: map['rating']?.toDouble() ?? 0.0,
      reviewCount: map['review_count'] ?? 0,
      yearsExperience: map['years_experience'],
      languages: List<String>.from(map['languages']),
      sessionRates: Map<String, double>.from(map['session_rates']),
      acceptsInsurance: map['accepts_insurance'] ?? false,
      insuranceProviders: List<String>.from(map['insurance_providers'] ?? []),
      availability: Map<String, bool>.from(map['availability'] ?? {}),
      officeAddress: map['office_address'],
      offersOnlineTherapy: map['offers_online_therapy'] ?? true,
      offersInPersonTherapy: map['offers_in_person_therapy'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isActive: map['is_active'] ?? true,
      isVerified: map['is_verified'] ?? false,
    );
  }
}

class TherapyAppointment {
  final String id;
  final String userId;
  final String therapistId;
  final DateTime scheduledDateTime;
  final Duration duration;
  final SessionFormat format;
  final AppointmentStatus status;
  final String? sessionLink; // For online sessions
  final String? location; // For in-person sessions
  final double? sessionFee;
  final String? notes;
  final String? cancellationReason;
  final Map<String, dynamic>? sessionOutcome;
  final DateTime createdAt;
  final DateTime updatedAt;

  TherapyAppointment({
    String? id,
    required this.userId,
    required this.therapistId,
    required this.scheduledDateTime,
    this.duration = const Duration(minutes: 50),
    required this.format,
    this.status = AppointmentStatus.scheduled,
    this.sessionLink,
    this.location,
    this.sessionFee,
    this.notes,
    this.cancellationReason,
    this.sessionOutcome,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'therapist_id': therapistId,
      'scheduled_date_time': scheduledDateTime.toIso8601String(),
      'duration_minutes': duration.inMinutes,
      'format': format.toString().split('.').last,
      'status': status.toString().split('.').last,
      'session_link': sessionLink,
      'location': location,
      'session_fee': sessionFee,
      'notes': notes,
      'cancellation_reason': cancellationReason,
      'session_outcome': sessionOutcome,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TherapyAppointment.fromMap(Map<String, dynamic> map) {
    return TherapyAppointment(
      id: map['id'],
      userId: map['user_id'],
      therapistId: map['therapist_id'],
      scheduledDateTime: DateTime.parse(map['scheduled_date_time']),
      duration: Duration(minutes: map['duration_minutes'] ?? 50),
      format: SessionFormat.values
          .firstWhere((e) => e.toString().split('.').last == map['format']),
      status: AppointmentStatus.values
          .firstWhere((e) => e.toString().split('.').last == map['status']),
      sessionLink: map['session_link'],
      location: map['location'],
      sessionFee: map['session_fee']?.toDouble(),
      notes: map['notes'],
      cancellationReason: map['cancellation_reason'],
      sessionOutcome: map['session_outcome'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

class TherapistReview {
  final String id;
  final String userId;
  final String therapistId;
  final int rating; // 1-5 stars
  final String? reviewText;
  final List<String> helpful; // What was helpful
  final List<String> improvements; // What could be improved
  final bool isAnonymous;
  final DateTime createdAt;
  final bool isVerified;

  TherapistReview({
    String? id,
    required this.userId,
    required this.therapistId,
    required this.rating,
    this.reviewText,
    List<String>? helpful,
    List<String>? improvements,
    this.isAnonymous = true,
    DateTime? createdAt,
    this.isVerified = false,
  })  : id = id ?? const Uuid().v4(),
        helpful = helpful ?? [],
        improvements = improvements ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'therapist_id': therapistId,
      'rating': rating,
      'review_text': reviewText,
      'helpful': helpful,
      'improvements': improvements,
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
      'is_verified': isVerified,
    };
  }

  factory TherapistReview.fromMap(Map<String, dynamic> map) {
    return TherapistReview(
      id: map['id'],
      userId: map['user_id'],
      therapistId: map['therapist_id'],
      rating: map['rating'],
      reviewText: map['review_text'],
      helpful: List<String>.from(map['helpful'] ?? []),
      improvements: List<String>.from(map['improvements'] ?? []),
      isAnonymous: map['is_anonymous'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      isVerified: map['is_verified'] ?? false,
    );
  }
}