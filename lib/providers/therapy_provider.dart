import 'package:flutter/foundation.dart';
import '../models/therapist.dart';
import '../models/wellness_dashboard.dart';
import '../services/therapy_service.dart';

class TherapyProvider extends ChangeNotifier {
  final TherapyService _therapyService = TherapyService();

  List<Therapist> _therapists = [];
  List<Therapist> _recommendedTherapists = [];
  List<TherapyAppointment> _appointments = [];
  List<TherapyAppointment> _upcomingAppointments = [];
  Therapist? _selectedTherapist;
  List<TherapistReview> _selectedTherapistReviews = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Therapist> get therapists => _therapists;
  List<Therapist> get recommendedTherapists => _recommendedTherapists;
  List<TherapyAppointment> get appointments => _appointments;
  List<TherapyAppointment> get upcomingAppointments => _upcomingAppointments;
  Therapist? get selectedTherapist => _selectedTherapist;
  List<TherapistReview> get selectedTherapistReviews => _selectedTherapistReviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Search therapists
  Future<void> searchTherapists({
    List<TherapistSpecialization>? specializations,
    List<TherapyApproach>? approaches,
    SessionFormat? sessionFormat,
    bool? acceptsInsurance,
    String? insuranceProvider,
    bool? offersOnlineTherapy,
    bool? offersInPersonTherapy,
    double? maxSessionRate,
    String? location,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _therapists = await _therapyService.findTherapists(
        specializations: specializations,
        approaches: approaches,
        sessionFormat: sessionFormat,
        acceptsInsurance: acceptsInsurance,
        insuranceProvider: insuranceProvider,
        offersOnlineTherapy: offersOnlineTherapy,
        offersInPersonTherapy: offersInPersonTherapy,
        maxSessionRate: maxSessionRate,
        location: location,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to search therapists: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error searching therapists: $e');
      }
    }
  }

  // Get personalized recommendations
  Future<void> getPersonalizedRecommendations({
    required String userId,
    required WellnessDashboard wellnessDashboard,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _recommendedTherapists = await _therapyService.getPersonalizedRecommendations(
        userId: userId,
        wellnessDashboard: wellnessDashboard,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to get recommendations: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error getting recommendations: $e');
      }
    }
  }

  // Select a therapist and load their details
  Future<void> selectTherapist(String therapistId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedTherapist = await _therapyService.getTherapist(therapistId);
      if (_selectedTherapist != null) {
        _selectedTherapistReviews = await _therapyService.getTherapistReviews(therapistId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load therapist details: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error selecting therapist: $e');
      }
    }
  }

  // Schedule an appointment
  Future<bool> scheduleAppointment({
    required String userId,
    required String therapistId,
    required DateTime scheduledDateTime,
    Duration duration = const Duration(minutes: 50),
    SessionFormat format = SessionFormat.individual,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final appointment = await _therapyService.scheduleAppointment(
        userId: userId,
        therapistId: therapistId,
        scheduledDateTime: scheduledDateTime,
        duration: duration,
        format: format,
        notes: notes,
      );

      // Add to local appointments list
      _appointments.insert(0, appointment);
      
      // Update upcoming appointments
      await loadUpcomingAppointments(userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to schedule appointment: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error scheduling appointment: $e');
      }
      return false;
    }
  }

  // Load user's appointments
  Future<void> loadUserAppointments(String userId, {AppointmentStatus? status}) async {
    try {
      _appointments = await _therapyService.getUserAppointments(userId, status: status);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load appointments: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error loading appointments: $e');
      }
    }
  }

  // Load upcoming appointments
  Future<void> loadUpcomingAppointments(String userId) async {
    try {
      _upcomingAppointments = await _therapyService.getUpcomingAppointments(userId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading upcoming appointments: $e');
      }
    }
  }

  // Cancel an appointment
  Future<bool> cancelAppointment(String appointmentId, String reason) async {
    try {
      await _therapyService.cancelAppointment(appointmentId, reason);
      
      // Update local appointment status
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        // Create updated appointment with cancelled status
        // Note: In a real implementation, you'd want to reload from the service
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel appointment: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error cancelling appointment: $e');
      }
      return false;
    }
  }

  // Submit a review for a therapist
  Future<bool> submitTherapistReview({
    required String userId,
    required String therapistId,
    required int rating,
    String? reviewText,
    List<String>? helpful,
    List<String>? improvements,
    bool isAnonymous = true,
  }) async {
    try {
      await _therapyService.submitTherapistReview(
        userId: userId,
        therapistId: therapistId,
        rating: rating,
        reviewText: reviewText,
        helpful: helpful,
        improvements: improvements,
        isAnonymous: isAnonymous,
      );

      // Reload reviews if this is for the selected therapist
      if (_selectedTherapist?.id == therapistId) {
        _selectedTherapistReviews = await _therapyService.getTherapistReviews(therapistId);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit review: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error submitting review: $e');
      }
      return false;
    }
  }

  // Get crisis resources
  Future<List<Map<String, dynamic>>> getCrisisResources() async {
    return await _therapyService.getCrisisResources();
  }

  // Filter therapists by criteria
  void filterTherapists({
    List<TherapistSpecialization>? specializations,
    List<TherapyApproach>? approaches,
    double? minRating,
    double? maxSessionRate,
    bool? acceptsInsurance,
  }) {
    List<Therapist> filtered = List.from(_therapists);

    if (specializations != null && specializations.isNotEmpty) {
      filtered = filtered.where((therapist) {
        return therapist.specializations.any((spec) => specializations.contains(spec));
      }).toList();
    }

    if (approaches != null && approaches.isNotEmpty) {
      filtered = filtered.where((therapist) {
        return therapist.approaches.any((approach) => approaches.contains(approach));
      }).toList();
    }

    if (minRating != null) {
      filtered = filtered.where((therapist) => therapist.rating >= minRating).toList();
    }

    if (maxSessionRate != null) {
      filtered = filtered.where((therapist) {
        return therapist.sessionRates.values.every((rate) => rate <= maxSessionRate);
      }).toList();
    }

    if (acceptsInsurance != null) {
      filtered = filtered.where((therapist) => therapist.acceptsInsurance == acceptsInsurance).toList();
    }

    _therapists = filtered;
    notifyListeners();
  }

  // Sort therapists
  void sortTherapists(String criteria) {
    switch (criteria) {
      case 'rating':
        _therapists.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'experience':
        _therapists.sort((a, b) => b.yearsExperience.compareTo(a.yearsExperience));
        break;
      case 'price_low':
        _therapists.sort((a, b) {
          final aMinRate = a.sessionRates.values.isEmpty ? double.infinity : a.sessionRates.values.reduce((a, b) => a < b ? a : b);
          final bMinRate = b.sessionRates.values.isEmpty ? double.infinity : b.sessionRates.values.reduce((a, b) => a < b ? a : b);
          return aMinRate.compareTo(bMinRate);
        });
        break;
      case 'price_high':
        _therapists.sort((a, b) {
          final aMinRate = a.sessionRates.values.isEmpty ? 0.0 : a.sessionRates.values.reduce((a, b) => a < b ? a : b);
          final bMinRate = b.sessionRates.values.isEmpty ? 0.0 : b.sessionRates.values.reduce((a, b) => a < b ? a : b);
          return bMinRate.compareTo(aMinRate);
        });
        break;
      case 'reviews':
        _therapists.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }
    notifyListeners();
  }

  // Get next appointment
  TherapyAppointment? get nextAppointment {
    if (_upcomingAppointments.isNotEmpty) {
      return _upcomingAppointments.first;
    }
    return null;
  }

  // Check if user has upcoming appointments
  bool get hasUpcomingAppointments => _upcomingAppointments.isNotEmpty;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear selected therapist
  void clearSelectedTherapist() {
    _selectedTherapist = null;
    _selectedTherapistReviews = [];
    notifyListeners();
  }

  // Load mock data for testing
  void loadMockData() {
    _recommendedTherapists = [
      Therapist(
        name: 'Dr. Sarah Johnson',
        title: 'Licensed Clinical Psychologist',
        licenseNumber: 'PSY123456',
        specializations: [TherapistSpecialization.anxiety, TherapistSpecialization.depression],
        approaches: [TherapyApproach.cognitiveBehavioralTherapy, TherapyApproach.mindfulnessBased],
        sessionFormats: [SessionFormat.individual],
        bio: 'Dr. Johnson specializes in anxiety and depression treatment with over 10 years of experience. She uses evidence-based approaches to help clients develop coping strategies.',
        rating: 4.8,
        reviewCount: 127,
        yearsExperience: 10,
        languages: ['English', 'Spanish'],
        sessionRates: {'individual': 150.0},
        acceptsInsurance: true,
        insuranceProviders: ['Blue Cross', 'Aetna', 'United Healthcare'],
        offersOnlineTherapy: true,
        offersInPersonTherapy: true,
      ),
      Therapist(
        name: 'Dr. Michael Chen',
        title: 'Licensed Marriage and Family Therapist',
        licenseNumber: 'LMFT789012',
        specializations: [TherapistSpecialization.relationships, TherapistSpecialization.trauma],
        approaches: [TherapyApproach.humanistic, TherapyApproach.emdr],
        sessionFormats: [SessionFormat.individual, SessionFormat.couples],
        bio: 'Dr. Chen has extensive experience in relationship counseling and trauma therapy. He helps individuals and couples build stronger connections and heal from past experiences.',
        rating: 4.9,
        reviewCount: 89,
        yearsExperience: 8,
        languages: ['English', 'Mandarin'],
        sessionRates: {'individual': 140.0, 'couples': 180.0},
        acceptsInsurance: false,
        offersOnlineTherapy: true,
        offersInPersonTherapy: false,
      ),
    ];

    _upcomingAppointments = [
      TherapyAppointment(
        userId: 'mock_user',
        therapistId: _recommendedTherapists.first.id,
        scheduledDateTime: DateTime.now().add(const Duration(days: 2)),
        format: SessionFormat.individual,
        status: AppointmentStatus.confirmed,
        sessionLink: 'https://therapy-session.com/room/123',
      ),
    ];

    notifyListeners();
  }
}