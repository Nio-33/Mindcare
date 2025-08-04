import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthState _state = AuthState.initial;
  User? _user;
  UserProfile? _userProfile;
  String? _errorMessage;

  AuthState get state => _state;
  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Check initial auth state immediately
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _user = currentUser;
      _state = AuthState.authenticated;
      _loadUserProfile();
      if (kDebugMode) {
        print('AuthProvider: Initial user found: ${currentUser.uid}');
      }
    } else {
      _state = AuthState.unauthenticated;
      if (kDebugMode) {
        print('AuthProvider: No initial user found');
      }
    }
    
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (kDebugMode) {
        print('AuthProvider: Auth state changed - user = ${user?.uid}, previous state = $_state');
      }
      
      final previousState = _state;
      _user = user;
      
      if (user != null) {
        // Only clear error message if transitioning from error state
        if (_state == AuthState.error) {
          _errorMessage = null;
        }
        _state = AuthState.authenticated;
        _loadUserProfile();
        if (kDebugMode) {
          print('AuthProvider: State changed from $previousState to authenticated for user: ${user.uid}');
        }
      } else {
        _userProfile = null;
        // Only set to unauthenticated if not in an error state
        if (_state != AuthState.error) {
          _state = AuthState.unauthenticated;
        }
        if (kDebugMode) {
          print('AuthProvider: State changed from $previousState to $_state');
        }
      }
      
      // Always notify listeners to trigger UI updates
      notifyListeners();
      
      if (kDebugMode) {
        print('AuthProvider: Notified listeners, current state = $_state');
      }
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;

    try {
      final doc = await _firestore
          .collection('user_profiles')
          .doc(_user!.uid)
          .get();

      if (doc.exists) {
        _userProfile = UserProfile.fromMap(doc.data()!);
      } else {
        // Create default profile for new user
        _userProfile = UserProfile(
          id: _user!.uid,
          email: _user!.email!,
          fullName: _user!.displayName,
        );
        await _saveUserProfile();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user profile: $e');
      }
    }
  }

  Future<void> _saveUserProfile() async {
    if (_user == null || _userProfile == null) return;

    try {
      await _firestore
          .collection('user_profiles')
          .doc(_user!.uid)
          .set(_userProfile!.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user profile: $e');
      }
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      // Add timeout to prevent infinite loading
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Sign in timed out. Please check your internet connection and try again.');
        },
      );

      if (credential.user != null) {
        if (kDebugMode) {
          print('Sign in successful for user: ${credential.user!.uid}');
        }
        
        // Wait a moment for authStateChanges to update, then ensure state is correct
        await Future.delayed(const Duration(milliseconds: 500));
        
        // If still in loading state after delay, manually update
        if (_state == AuthState.loading) {
          _user = credential.user;
          _state = AuthState.authenticated;
          _loadUserProfile();
          notifyListeners();
          if (kDebugMode) {
            print('Manually updated state to authenticated after sign in');
          }
        }
        
        return true;
      } else {
        if (kDebugMode) {
          print('Sign in failed: credential.user is null');
        }
        _state = AuthState.error;
        _errorMessage = 'Sign in failed. Please try again.';
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
      }
      _errorMessage = _getErrorMessage(e.code);
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during sign in: $e');
      }
      _errorMessage = e.toString().contains('timed out') 
          ? 'Sign in timed out. Please check your internet connection and try again.'
          : 'An unexpected error occurred. Please check your internet connection and try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      if (kDebugMode) {
        print('Starting sign up process for email: $email');
      }
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      // Add timeout to prevent infinite loading
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Sign up timed out. Please check your internet connection and try again.');
        },
      );

      if (credential.user != null) {
        if (kDebugMode) {
          print('User created successfully: ${credential.user!.uid}');
        }
        try {
          // Update display name
          await credential.user!.updateDisplayName(fullName);

          // Create user profile
          _userProfile = UserProfile(
            id: credential.user!.uid,
            email: email,
            fullName: fullName,
            lastLogin: DateTime.now(),
          );
          await _saveUserProfile();
        } catch (e) {
          if (kDebugMode) {
            print('Warning: Profile creation failed, but user account was created: $e');
          }
          // Even if profile creation fails, authentication was successful
        }

        // Wait a moment for authStateChanges to update, then ensure state is correct
        await Future.delayed(const Duration(milliseconds: 500));
        
        // If still in loading state after delay, manually update
        if (_state == AuthState.loading) {
          _user = credential.user;
          _state = AuthState.authenticated;
          _userProfile ??= UserProfile(
            id: credential.user!.uid,
            email: email,
            fullName: fullName,
            lastLogin: DateTime.now(),
          );
          notifyListeners();
          if (kDebugMode) {
            print('Manually updated state to authenticated after sign up');
          }
        }

        if (kDebugMode) {
          print('Sign up successful, state = $_state');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('User creation failed: credential.user is null');
        }
        _state = AuthState.error;
        _errorMessage = 'Failed to create user account. Please try again.';
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException during sign up: ${e.code} - ${e.message}');
      }
      _errorMessage = _getErrorMessage(e.code);
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during sign up: $e');
      }
      _errorMessage = e.toString().contains('timed out') 
          ? 'Sign up timed out. Please check your internet connection and try again.'
          : 'An unexpected error occurred. Please check your internet connection and try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _userProfile = null;
      _state = AuthState.unauthenticated;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }

  Future<bool> updateUserProfile(UserProfile updatedProfile) async {
    try {
      _userProfile = updatedProfile;
      await _saveUserProfile();
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address. Please sign up first or check your email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address. Please sign in instead.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password (at least 6 characters).';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later or reset your password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please contact support.';
      case 'requires-recent-login':
        return 'Please sign out and sign back in to continue.';
      default:
        if (kDebugMode) {
          print('Unhandled Firebase Auth error: $errorCode');
        }
        return 'Authentication failed. Please check your email and password, or sign up if you don\'t have an account.';
    }
  }
}