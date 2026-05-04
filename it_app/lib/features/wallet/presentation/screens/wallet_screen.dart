import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text('Wallet'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkBg,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'R 12,500.00',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBg,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBg,
                          ),
                          child: const Text(
                            'Withdraw',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBg,
                          ),
                          child: const Text(
                            'Add Funds',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatBox('Pending', 'R 2,500'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox('Escrow', 'R 0'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transaction History
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildTransactionItem(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(int index) {
    final transactions = [
      {
        'title': 'Payment from TechCorp',
        'amount': '+R 5,000',
        'date': '2 days ago',
        'icon': Icons.arrow_downward,
        'isIncome': true,
      },
      {
        'title': 'Withdrawal to Bank',
        'amount': '-R 8,000',
        'date': '1 week ago',
        'icon': Icons.arrow_upward,
        'isIncome': false,
      },
      {
        'title': 'Payment from Design Co',
        'amount': '+R 3,500',
        'date': '2 weeks ago',
        'icon': Icons.arrow_downward,
        'isIncome': true,
      },
      {
        'title': 'Platform Fee',
        'amount': '-R 150',
        'date': '2 weeks ago',
        'icon': Icons.credit_card,
        'isIncome': false,
      },
      {
        'title': 'Refund from Client',
        'amount': '+R 1,200',
        'date': '1 month ago',
        'icon': Icons.arrow_downward,
        'isIncome': true,
      },
    ];

    final tx = transactions[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (tx['isIncome'] as bool)
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              tx['icon'] as IconData,
              size: 20,
              color: (tx['isIncome'] as bool)
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx['date'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            tx['amount'] as String,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: (tx['isIncome'] as bool)
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
