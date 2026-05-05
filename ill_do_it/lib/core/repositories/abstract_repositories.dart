import '../models/user.dart';
import '../models/service.dart';
import '../models/job.dart';
import '../models/transaction.dart';

/// Abstract repository for user operations
abstract class UserRepository {
  /// Get current user profile
  Future<User> getCurrentUserProfile();

  /// Update user profile
  Future<void> updateUserProfile({required Map<String, dynamic> data});

  /// Upload user avatar
  Future<String> uploadAvatar({required List<int> bytes});

  /// Get user by ID
  Future<User> getUserById({required String userId});

  /// Search users
  Future<List<User>> searchUsers({
    required String query,
    String? category,
  });

  /// Get user reviews
  Future<List<Map<String, dynamic>>> getUserReviews({required String userId});

  /// Request user verification
  Future<void> requestVerification();
}

/// Abstract repository for service operations
abstract class ServiceRepository {
  /// Create a new service
  Future<Service> createService({
    required Map<String, dynamic> data,
  });

  /// Upload service image
  Future<String> uploadServiceImage({required List<int> bytes});

  /// Get all services
  Future<List<Service>> getServices({
    String? category,
    String? sortBy,
  });

  /// Get service by ID
  Future<Service> getServiceById({required String serviceId});

  /// Update service
  Future<void> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
  });

  /// Delete service
  Future<void> deleteService({required String serviceId});

  /// Search services
  Future<List<Service>> searchServices({
    required String query,
    String? category,
    String? location,
  });

  /// Get user's own services
  Future<List<Service>> getMyServices();
}

/// Abstract repository for job operations
abstract class JobRepository {
  /// Create a new job
  Future<Job> createJob({required Map<String, dynamic> data});

  /// Upload job image
  Future<String> uploadJobImage({required List<int> bytes});

  /// Get all jobs
  Future<List<Job>> getJobs({String? status, String? category});

  /// Get job by ID
  Future<Job> getJobById({required String jobId});

  /// Update job
  Future<void> updateJob({
    required String jobId,
    required Map<String, dynamic> data,
  });

  /// Delete job
  Future<void> deleteJob({required String jobId});

  /// Search jobs
  Future<List<Job>> searchJobs({
    required String query,
    String? category,
    String? location,
  });

  /// Get jobs posted by the current user
  Future<List<Job>> getMyJobs();
}

/// Abstract repository for transaction operations
abstract class TransactionRepository {
  /// Get transaction history
  Future<List<Transaction>> getTransactionHistory();

  /// Get wallet balance
  Future<double> getWalletBalance();

  /// Deposit funds into wallet
  Future<Transaction> depositFunds({
    required double amount,
    required String reference,
  });

  /// Withdraw funds
  Future<Transaction> withdrawFunds({
    required double amount,
    required String bankAccount,
  });

  /// Process payment
  Future<Transaction> processPayment({
    required double amount,
    required String receiverId,
    required String serviceId,
  });
}

/// Abstract repository for review operations
abstract class ReviewRepository {
  /// Create review
  Future<Map<String, dynamic>> createReview({
    required String targetUserId,
    required int rating,
    required String comment,
    String? serviceId,
  });

  /// Get reviews for user
  Future<List<Map<String, dynamic>>> getUserReviews({required String userId});

  /// Update review
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  });

  /// Delete review
  Future<void> deleteReview({required String reviewId});
}
