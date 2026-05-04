import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/repositories/transaction_repository_impl.dart';

/// Provider for wallet balance
final balanceProvider = FutureProvider<double>((ref) async {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  return transactionRepository.getWalletBalance();
});

/// Provider for transaction history
final transactionHistoryProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  return transactionRepository.getTransactionHistory();
});
