import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/supabase_service.dart';
import '../errors/app_exceptions.dart';
import 'abstract_repositories.dart';

/// Concrete implementation of TransactionRepository using Supabase
class TransactionRepositoryImpl implements TransactionRepository {
  final SupabaseService _supabaseService;

  TransactionRepositoryImpl(this._supabaseService);

  @override
  Future<List<Transaction>> getTransactionHistory() async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) {
      throw AuthenticationException('No user logged in');
    }

    try {
      // In a real app, you'd filter where current user is either sender or receiver
      // For this MVP, we'll fetch transactions where the user is either
      final results = await _supabaseService.query(
        table: 'transactions',
      );

      return results
          .map((e) => Transaction.fromJson(e))
          .where((t) => t.senderId == currentUser.id || t.receiverId == currentUser.id)
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch transaction history: $e');
    }
  }

  @override
  Future<double> getWalletBalance() async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) {
      throw AuthenticationException('No user logged in');
    }

    try {
      final transactions = await getTransactionHistory();
      double balance = 0.0;

      for (var tx in transactions) {
        if (tx.type == 'deposit' && tx.receiverId == currentUser.id) {
          balance += tx.amount;
        } else if (tx.type == 'withdrawal' && tx.senderId == currentUser.id) {
          balance -= tx.amount;
        } else if (tx.type == 'payment') {
          if (tx.receiverId == currentUser.id) {
            balance += tx.amount;
          } else if (tx.senderId == currentUser.id) {
            balance -= tx.amount;
          }
        }
      }
      return balance;
    } catch (e) {
      throw ServerException('Failed to calculate balance: $e');
    }
  }

  @override
  Future<Transaction> depositFunds({
    required double amount,
    required String reference,
  }) async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) {
      throw AuthenticationException('No user logged in');
    }

    try {
      final response = await _supabaseService.insert(
        table: 'transactions',
        data: {
          'sender_id': currentUser.id,
          'receiver_id': currentUser.id,
          'amount': amount,
          'type': 'deposit',
          'status': 'completed',
          'reference': reference,
        },
      );
      return Transaction.fromJson(response);
    } catch (e) {
      throw ServerException('Deposit failed: $e');
    }
  }

  @override
  Future<Transaction> withdrawFunds({
    required double amount,
    required String bankAccount,
  }) async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) {
      throw AuthenticationException('No user logged in');
    }

    final currentBalance = await getWalletBalance();
    if (amount > currentBalance) {
      throw InsufficientFundsException('Insufficient wallet balance for this withdrawal');
    }

    try {
      final response = await _supabaseService.insert(
        table: 'transactions',
        data: {
          'sender_id': currentUser.id,
          'receiver_id': currentUser.id,
          'amount': amount,
          'type': 'withdrawal',
          'status': 'pending',
          'reference': 'Withdrawal to $bankAccount',
        },
      );
      return Transaction.fromJson(response);
    } catch (e) {
      throw ServerException('Withdrawal failed: $e');
    }
  }

  @override
  Future<Transaction> processPayment({
    required double amount,
    required String receiverId,
    required String serviceId,
  }) async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) {
      throw AuthenticationException('No user logged in');
    }

    final currentBalance = await getWalletBalance();
    if (amount > currentBalance) {
      throw InsufficientFundsException('Insufficient wallet balance for this payment');
    }

    try {
      final response = await _supabaseService.insert(
        table: 'transactions',
        data: {
          'sender_id': currentUser.id,
          'receiver_id': receiverId,
          'amount': amount,
          'type': 'payment',
          'status': 'completed',
          'reference': 'Payment for service $serviceId',
        },
      );
      return Transaction.fromJson(response);
    } catch (e) {
      throw ServerException('Payment failed: $e');
    }
  }
}

/// Provider for TransactionRepository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return TransactionRepositoryImpl(supabaseService);
});
