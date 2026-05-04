import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';
import '../services/supabase_service.dart';
import '../errors/app_exceptions.dart';
import 'abstract_repositories.dart';

/// Concrete implementation of JobRepository using Supabase
class JobRepositoryImpl implements JobRepository {
  final SupabaseService _supabaseService;

  JobRepositoryImpl(this._supabaseService);

  @override
  Future<Job> createJob({required Map<String, dynamic> data}) async {
    try {
      final response = await _supabaseService.insert(
        table: 'jobs',
        data: data,
      );
      return Job.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create job: $e');
    }
  }

  @override
  Future<List<Job>> getJobs({String? status, String? category}) async {
    try {
      final filters = <String, dynamic>{};
      if (status != null) filters['status'] = status;
      if (category != null) filters['category'] = category;
      
      final results = await _supabaseService.query(
        table: 'jobs',
        filters: filters.isNotEmpty ? filters : null,
      );
      return results.map((e) => Job.fromJson(e)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch jobs: $e');
    }
  }

  @override
  Future<Job> getJobById({required String jobId}) async {
    try {
      final results = await _supabaseService.query(
        table: 'jobs',
        filters: {'id': jobId},
      );

      if (results.isEmpty) {
        throw ServerException('Job not found');
      }

      return Job.fromJson(results.first);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch job: $e');
    }
  }

  @override
  Future<void> updateJob({
    required String jobId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _supabaseService.update(
        table: 'jobs',
        id: jobId,
        data: data,
      );
    } catch (e) {
      throw ServerException('Failed to update job: $e');
    }
  }

  @override
  Future<void> deleteJob({required String jobId}) async {
    try {
      await _supabaseService.delete(
        table: 'jobs',
        id: jobId,
      );
    } catch (e) {
      throw ServerException('Failed to delete job: $e');
    }
  }

  @override
  Future<List<Job>> searchJobs({
    required String query,
    String? category,
    String? location,
  }) async {
    try {
      final results = await _supabaseService.query(
        table: 'jobs',
      );
      
      return results
          .map((e) => Job.fromJson(e))
          .where((j) => j.title.toLowerCase().contains(query.toLowerCase()) || 
                       j.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw ServerException('Search failed: $e');
    }
  }

  @override
  Future<List<Job>> getMyJobs() async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) {
      throw AuthenticationException('No user logged in');
    }

    try {
      final results = await _supabaseService.query(
        table: 'jobs',
        filters: {'client_id': currentUser.id},
      );
      return results.map((e) => Job.fromJson(e)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch your jobs: $e');
    }
  }
}

/// Provider for JobRepository
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return JobRepositoryImpl(supabaseService);
});
