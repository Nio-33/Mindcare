import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/therapist.dart';
import '../models/wellness_dashboard.dart';

class TherapyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Find therapists based on user preferences and needs
  Future<List<Therapist>> findTherapists({
    List<TherapistSpecialization>? specializations,
    List<TherapyApproach>? approaches,
    SessionFormat? sessionFormat,
    bool? acceptsInsurance,
    String? insuranceProvider,
    bool? offersOnlineTherapy,
    bool? offersInPersonTherapy,
    double? maxSessionRate,
    String? location,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('therapists')
          .where('is_active', isEqualTo: true)
          .where('is_verified', isEqualTo: true);

      if (specializations != null && specializations.isNotEmpty) {
        final specializationStrings = specializations
            .map((s) => s.toString().split('.').last)
            .toList();
        query = query.where('specializations', arrayContainsAny: specializationStrings);
      }

      if (acceptsInsurance == true) {
        query = query.where('accepts_insurance', isEqualTo: true);
      }

      if (insuranceProvider != null) {
        query = query.where('insurance_providers', arrayContains: insuranceProvider);
      }

      if (offersOnlineTherapy == true) {
        query = query.where('offers_online_therapy', isEqualTo: true);
      }

      if (offersInPersonTherapy == true) {
        query = query.where('offers_in_person_therapy', isEqualTo: true);
      }

      final querySnapshot = await query
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final therapists = querySnapshot.docs
          .map((doc) => Therapist.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Additional filtering for complex criteria
      return therapists.where((therapist) {
        if (approaches != null && approaches.isNotEmpty) {
          if (!therapist.approaches.any((approach) => approaches.contains(approach))) {
            return false;
          }
        }

        if (sessionFormat != null) {
          if (!therapist.sessionFormats.contains(sessionFormat)) {
            return false;
          }
        }

        if (maxSessionRate != null) {
          final rates = therapist.sessionRates.values;
          if (rates.isEmpty || rates.any((rate) => rate > maxSessionRate)) {
            return false;
          }
        }

        return true;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error finding therapists: $e');
      }
      return [];
    }
  }

  // Get therapist by ID
  Future<Therapist?> getTherapist(String therapistId) async {
    try {
      final doc = await _firestore
          .collection('therapists')
          .doc(therapistId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Therapist.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting therapist: $e');
      }
      return null;
    }
  }

  // Get personalized therapist recommendations
  Future<List<Therapist>> getPersonalizedRecommendations({
    required String userId,
    required WellnessDashboard wellnessDashboard,
  }) async {
    try {
      // Analyze user's wellness data to determine needs
      final recommendations = _analyzeTherapyNeeds(wellnessDashboard);
      
      // Find therapists matching the recommendations
      return await findTherapists(
        specializations: recommendations['specializations'],
        approaches: recommendations['approaches'],
        sessionFormat: recommendations['sessionFormat'],
        offersOnlineTherapy: true, // Default preference for accessibility
        limit: 10,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting personalized recommendations: $e');
      }
      return [];
    }
  }

  Map<String, dynamic> _analyzeTherapyNeeds(WellnessDashboard dashboard) {
    final currentScore = dashboard.currentScore;
    final insights = dashboard.insights;
    final riskAssessment = dashboard.predictiveModeling?['risk_assessment'];
    
    List<TherapistSpecialization> specializations = [];
    List<TherapyApproach> approaches = [];
    SessionFormat sessionFormat = SessionFormat.individual;

    // Analyze anxiety levels
    if (currentScore.anxiety > 60) {
      specializations.add(TherapistSpecialization.anxiety);
      approaches.addAll([
        TherapyApproach.cognitiveBehavioralTherapy,
        TherapyApproach.mindfulnessBased,
      ]);
    }

    // Analyze mood patterns
    if (currentScore.mood < 40) {
      specializations.add(TherapistSpecialization.depression);
      approaches.addAll([
        TherapyApproach.cognitiveBehavioralTherapy,
        TherapyApproach.dialecticalBehaviorTherapy,
      ]);
    }

    // Analyze insights for specific needs
    for (final insight in insights) {
      if (insight.category == 'risk' && insight.severity == 'high') {
        specializations.add(TherapistSpecialization.general);
        approaches.add(TherapyApproach.cognitiveBehavioralTherapy);
      }
      
      if (insight.title.toLowerCase().contains('trauma')) {
        specializations.add(TherapistSpecialization.trauma);
        approaches.add(TherapyApproach.emdr);
      }
    }

    // Check risk patterns
    if (riskAssessment != null) {
      final riskPatterns = riskAssessment['risk_patterns'] as List?;
      if (riskPatterns != null) {
        if (riskPatterns.contains('frequent_anxiety')) {
          specializations.add(TherapistSpecialization.anxiety);
        }
        if (riskPatterns.contains('persistent_low_mood')) {
          specializations.add(TherapistSpecialization.depression);
        }
      }
    }

    // Default to general if no specific needs identified
    if (specializations.isEmpty) {
      specializations.add(TherapistSpecialization.general);
      approaches.add(TherapyApproach.cognitiveBehavioralTherapy);
    }

    return {
      'specializations': specializations,
      'approaches': approaches,
      'sessionFormat': sessionFormat,
    };
  }

  // Schedule an appointment
  Future<TherapyAppointment> scheduleAppointment({
    required String userId,
    required String therapistId,
    required DateTime scheduledDateTime,
    Duration duration = const Duration(minutes: 50),
    SessionFormat format = SessionFormat.individual,
    String? notes,
  }) async {
    try {
      final appointment = TherapyAppointment(
        userId: userId,
        therapistId: therapistId,
        scheduledDateTime: scheduledDateTime,
        duration: duration,
        format: format,
        notes: notes,
      );

      await _firestore
          .collection('therapy_appointments')
          .doc(appointment.id)
          .set(appointment.toMap());

      return appointment;
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling appointment: $e');
      }
      throw Exception('Failed to schedule appointment');
    }
  }

  // Get user's appointments
  Future<List<TherapyAppointment>> getUserAppointments(
    String userId, {
    AppointmentStatus? status,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection('therapy_appointments')
          .where('user_id', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.toString().split('.').last);
      }

      final querySnapshot = await query
          .orderBy('scheduled_date_time', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => TherapyAppointment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user appointments: $e');
      }
      return [];
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await _firestore
          .collection('therapy_appointments')
          .doc(appointmentId)
          .update({
        'status': status.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating appointment status: $e');
      }
      throw Exception('Failed to update appointment status');
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      await _firestore
          .collection('therapy_appointments')
          .doc(appointmentId)
          .update({
        'status': AppointmentStatus.cancelled.toString().split('.').last,
        'cancellation_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling appointment: $e');
      }
      throw Exception('Failed to cancel appointment');
    }
  }

  // Submit therapist review
  Future<void> submitTherapistReview({
    required String userId,
    required String therapistId,
    required int rating,
    String? reviewText,
    List<String>? helpful,
    List<String>? improvements,
    bool isAnonymous = true,
  }) async {
    try {
      final review = TherapistReview(
        userId: userId,
        therapistId: therapistId,
        rating: rating,
        reviewText: reviewText,
        helpful: helpful,
        improvements: improvements,
        isAnonymous: isAnonymous,
      );

      await _firestore
          .collection('therapist_reviews')
          .doc(review.id)
          .set(review.toMap());

      // Update therapist's average rating
      await _updateTherapistRating(therapistId);
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting review: $e');
      }
      throw Exception('Failed to submit review');
    }
  }

  // Update therapist's average rating
  Future<void> _updateTherapistRating(String therapistId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('therapist_reviews')
          .where('therapist_id', isEqualTo: therapistId)
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        final reviews = reviewsSnapshot.docs
            .map((doc) => TherapistReview.fromMap(doc.data()))
            .toList();

        final totalRating = reviews.fold<int>(0, (total, review) => total + review.rating);
        final averageRating = totalRating / reviews.length;

        await _firestore
            .collection('therapists')
            .doc(therapistId)
            .update({
          'rating': averageRating,
          'review_count': reviews.length,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating therapist rating: $e');
      }
    }
  }

  // Get therapist reviews
  Future<List<TherapistReview>> getTherapistReviews(String therapistId) async {
    try {
      final querySnapshot = await _firestore
          .collection('therapist_reviews')
          .where('therapist_id', isEqualTo: therapistId)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => TherapistReview.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting therapist reviews: $e');
      }
      return [];
    }
  }

  // Get upcoming appointments for dashboard
  Future<List<TherapyAppointment>> getUpcomingAppointments(String userId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection('therapy_appointments')
          .where('user_id', isEqualTo: userId)
          .where('scheduled_date_time', isGreaterThan: now.toIso8601String())
          .where('status', whereIn: ['scheduled', 'confirmed'])
          .orderBy('scheduled_date_time')
          .limit(5)
          .get();

      return querySnapshot.docs
          .map((doc) => TherapyAppointment.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting upcoming appointments: $e');
      }
      return [];
    }
  }

  // Generate session outcome (post-session)
  Future<void> recordSessionOutcome({
    required String appointmentId,
    required Map<String, dynamic> outcome,
  }) async {
    try {
      await _firestore
          .collection('therapy_appointments')
          .doc(appointmentId)
          .update({
        'session_outcome': outcome,
        'status': AppointmentStatus.completed.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error recording session outcome: $e');
      }
      throw Exception('Failed to record session outcome');
    }
  }

  // Emergency crisis intervention
  Future<List<Map<String, dynamic>>> getCrisisResources() async {
    // This would typically come from a database, but for now return static data
    return [
      {
        'name': 'National Suicide Prevention Lifeline',
        'phone': '988',
        'description': '24/7 free and confidential support',
        'type': 'crisis',
      },
      {
        'name': 'Crisis Text Line',
        'phone': '741741',
        'text': 'HOME',
        'description': 'Text-based crisis support',
        'type': 'crisis',
      },
      {
        'name': 'Emergency Services',
        'phone': '911',
        'description': 'Immediate emergency response',
        'type': 'emergency',
      },
      {
        'name': 'SAMHSA National Helpline',
        'phone': '1-800-662-4357',
        'description': 'Mental health and substance abuse referrals',
        'type': 'referral',
      },
    ];
  }
}