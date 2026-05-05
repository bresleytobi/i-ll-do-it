import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/withdrawal_request.dart';
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
    if (currentUser == null) throw AuthenticationException('No user logged in');

    try {
      final results = await _supabaseService.query(
        table: 'transactions',
        // In a real app, we'd use a complex filter or RPC to get where user is sender OR receiver
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
    if (currentUser == null) throw AuthenticationException('No user logged in');

    try {
      final response = await _supabaseService.query(
        table: 'users',
        select: 'id, email, display_name, created_at, updated_at', // Mocking user fetch
        filters: {'id': currentUser.id},
      );
      
      // In a real app, we'd just get the balance column
      // For this MVP calculation logic:
      final transactions = await getTransactionHistory();
      double balance = 0.0;

      for (var tx in transactions) {
        if (tx.status != 'completed') continue;
        
        if (tx.type == 'deposit' && tx.receiverId == currentUser.id) {
          balance += tx.amount;
        } else if (tx.type == 'withdrawal' && tx.senderId == currentUser.id) {
          balance -= tx.amount;
        } else if (tx.type == 'payment' || tx.type == 'escrow_release') {
          if (tx.receiverId == currentUser.id) {
            balance += tx.amount;
          } else if (tx.senderId == currentUser.id) {
            balance -= tx.amount;
          }
        } else if (tx.type == 'escrow' && tx.senderId == currentUser.id) {
          balance -= tx.amount;
        }
      }
      return balance;
    } catch (e) {
      throw ServerException('Failed to calculate balance: $e');
    }
  }

  @override
  Future<double> getEscrowBalance() async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) throw AuthenticationException('No user logged in');

    try {
      final transactions = await getTransactionHistory();
      double escrow = 0.0;

      for (var tx in transactions) {
        if (tx.type == 'escrow' && tx.status == 'pending') {
          if (tx.senderId == currentUser.id || tx.receiverId == currentUser.id) {
            escrow += tx.amount;
          }
        }
      }
      return escrow;
    } catch (e) {
      throw ServerException('Failed to calculate escrow: $e');
    }
  }

  @override
  Future<Transaction> depositFunds({
    required double amount,
    required String reference,
    required String gateway,
  }) async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) throw AuthenticationException('No user logged in');

    try {
      // Simulate gateway success
      final response = await _supabaseService.insert(
        table: 'transactions',
        data: {
          'sender_id': currentUser.id,
          'receiver_id': currentUser.id,
          'amount': amount,
          'type': 'deposit',
          'status': 'completed',
          'reference': '$gateway: $reference',
        },
      );
      return Transaction.fromJson(response);
    } catch (e) {
      throw ServerException('Deposit failed: $e');
    }
  }

  @override
  Future<void> requestWithdrawal({
    required double amount,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
    required String branchCode,
    required String accountType,
  }) async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) throw AuthenticationException('No user logged in');

    final balance = await getWalletBalance();
    if (amount > balance) throw InsufficientFundsException('Insufficient funds');

    try {
      await _supabaseService.insert(
        table: 'withdrawal_requests',
        data: {
          'user_id': currentUser.id,
          'amount': amount,
          'bank_name': bankName,
          'account_holder': accountHolder,
          'account_number': accountNumber,
          'branch_code': branchCode,
          'account_type': accountType,
          'status': 'pending',
        },
      );
      
      // Also record as a pending transaction to deduct from viewable balance
      await _supabaseService.insert(
        table: 'transactions',
        data: {
          'sender_id': currentUser.id,
          'receiver_id': currentUser.id,
          'amount': amount,
          'type': 'withdrawal',
          'status': 'completed', // We deduct it immediately for the user's view
          'reference': 'Withdrawal to $bankName',
        },
      );
    } catch (e) {
      throw ServerException('Withdrawal request failed: $e');
    }
  }

  @override
  Future<Transaction> createEscrowPayment({
    required double amount,
    required String receiverId,
    required String orderId,
  }) async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) throw AuthenticationException('No user logged in');

    try {
      final response = await _supabaseService.insert(
        table: 'transactions',
        data: {
          'sender_id': currentUser.id,
          'receiver_id': receiverId,
          'amount': amount,
          'type': 'escrow',
          'status': 'pending',
          'order_id': orderId,
          'reference': 'Escrow for order $orderId',
        },
      );
      return Transaction.fromJson(response);
    } catch (e) {
      throw ServerException('Escrow creation failed: $e');
    }
  }

  @override
  Future<void> releaseEscrow({required String orderId}) async {
    try {
      // Find the escrow transaction
      final results = await _supabaseService.query(
        table: 'transactions',
        filters: {'order_id': orderId, 'type': 'escrow'},
      );

      if (results.isEmpty) throw ServerException('Escrow transaction not found');
      
      final txId = results.first['id'];

      // Mark as completed
      await _supabaseService.update(
        table: 'transactions',
        id: txId,
        data: {'status': 'completed', 'type': 'escrow_release'},
      );
    } catch (e) {
      throw ServerException('Failed to release escrow: $e');
    }
  }

  @override
  Future<void> refundEscrow({required String orderId}) async {
    try {
      final results = await _supabaseService.query(
        table: 'transactions',
        filters: {'order_id': orderId, 'type': 'escrow'},
      );

      if (results.isEmpty) throw ServerException('Escrow transaction not found');
      
      final txId = results.first['id'];

      // Mark as cancelled
      await _supabaseService.update(
        table: 'transactions',
        id: txId,
        data: {'status': 'cancelled'},
      );
    } catch (e) {
      throw ServerException('Failed to refund escrow: $e');
    }
  }

  @override
  Future<List<WithdrawalRequest>> getMyWithdrawalRequests() async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) throw AuthenticationException('No user logged in');

    try {
      final results = await _supabaseService.query(
        table: 'withdrawal_requests',
        filters: {'user_id': currentUser.id},
      );

      return results.map((e) => WithdrawalRequest.fromJson(e)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch withdrawal requests: $e');
    }
  }

  @override
  Future<Transaction> processPayment({
    required double amount,
    required String receiverId,
    required String serviceId,
  }) async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) throw AuthenticationException('No user logged in');

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
