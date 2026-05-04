/// Abstract repository for user operations
abstract class UserRepository {
  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUserProfile();

  /// Update user profile
  Future<void> updateUserProfile({required Map<String, dynamic> data});

  /// Get user by ID
  Future<Map<String, dynamic>> getUserById({required String userId});

  /// Search users
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    String? category,
  });

  /// Get user reviews
  Future<List<Map<String, dynamic>>> getUserReviews({required String userId});
}

/// Abstract repository for service operations
abstract class ServiceRepository {
  /// Create a new service
  Future<Map<String, dynamic>> createService({
    required Map<String, dynamic> data,
  });

  /// Get all services
  Future<List<Map<String, dynamic>>> getServices({
    String? category,
    String? sortBy,
  });

  /// Get service by ID
  Future<Map<String, dynamic>> getServiceById({required String serviceId});

  /// Update service
  Future<void> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
  });

  /// Delete service
  Future<void> deleteService({required String serviceId});

  /// Search services
  Future<List<Map<String, dynamic>>> searchServices({
    required String query,
    String? category,
    String? location,
  });
}

/// Abstract repository for job operations
abstract class JobRepository {
  /// Create a new job
  Future<Map<String, dynamic>> createJob({required Map<String, dynamic> data});

  /// Get all jobs
  Future<List<Map<String, dynamic>>> getJobs({String? status});

  /// Get job by ID
  Future<Map<String, dynamic>> getJobById({required String jobId});

  /// Update job
  Future<void> updateJob({
    required String jobId,
    required Map<String, dynamic> data,
  });

  /// Delete job
  Future<void> deleteJob({required String jobId});

  /// Search jobs
  Future<List<Map<String, dynamic>>> searchJobs({
    required String query,
    String? category,
    String? location,
  });
}

/// Abstract repository for message operations
abstract class MessageRepository {
  /// Send message
  Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String content,
    String? imageUrl,
  });

  /// Get conversations
  Future<List<Map<String, dynamic>>> getConversations();

  /// Get messages with user
  Future<List<Map<String, dynamic>>> getMessages({required String userId});

  /// Mark message as read
  Future<void> markAsRead({required String messageId});

  /// Stream messages
  Stream<Map<String, dynamic>> streamMessages({required String userId});
}

/// Abstract repository for transaction operations
abstract class TransactionRepository {
  /// Get transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory();

  /// Get wallet balance
  Future<Map<String, dynamic>> getWalletBalance();

  /// Withdraw funds
  Future<Map<String, dynamic>> withdrawFunds({
    required double amount,
    required String bankAccount,
  });

  /// Process payment
  Future<Map<String, dynamic>> processPayment({
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
