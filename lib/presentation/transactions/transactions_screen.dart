import 'package:flutter/material.dart';

void main() => runApp(const TransactionsApp());

class TransactionsApp extends StatelessWidget {
  const TransactionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF111111),
      fontFamily: 'Roboto',
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF3F3F4),
        textTheme: baseTheme.textTheme.apply(
          bodyColor: const Color(0xFF1B1B1B),
          displayColor: const Color(0xFF1B1B1B),
        ),
      ),
      home: const TransactionsScreen(),
    );
  }
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  static const int _pageSize = 5;
  int _shown = _pageSize;
  bool _loadingMore = false;

  final List<Transaction> _transactions = [
    Transaction(
      id: 'TRX-001',
      transactionId: 'PAY-789456',
      status: TransactionStatus.paid,
      earnings: '\$1,234.56',
      purchasedOn: '10/10/2025',
    ),
    Transaction(
      id: 'TRX-002',
      transactionId: 'PAY-123456',
      status: TransactionStatus.onProcess,
      earnings: '\$987.65',
      purchasedOn: '09/10/2025',
    ),
    Transaction(
      id: 'TRX-003',
      transactionId: 'PAY-456789',
      status: TransactionStatus.paid,
      earnings: '\$2,345.67',
      purchasedOn: '08/10/2025',
    ),
    Transaction(
      id: 'TRX-004',
      transactionId: 'PAY-987654',
      status: TransactionStatus.failed,
      earnings: '\$543.21',
      purchasedOn: '07/10/2025',
    ),
    Transaction(
      id: 'TRX-005',
      transactionId: 'PAY-654321',
      status: TransactionStatus.paid,
      earnings: '\$1,876.54',
      purchasedOn: '06/10/2025',
    ),
    Transaction(
      id: 'TRX-006',
      transactionId: 'PAY-321654',
      status: TransactionStatus.onProcess,
      earnings: '\$765.43',
      purchasedOn: '05/10/2025',
    ),
  ];

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _shown = (_shown + _pageSize).clamp(0, _transactions.length);
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _transactions.take(_shown).toList();
    final canLoadMore = _shown < _transactions.length && !_loadingMore;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Payouts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),

            // Balance Overview Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Current Balance
                  _BalanceCard(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: Colors.green,
                    label: 'Current account balance',
                    amount: '\$5,432.10',
                  ),
                  const SizedBox(height: 16),

                  // Available for Withdrawal
                  _BalanceCard(
                    icon: Icons.monetization_on_rounded,
                    iconColor: Colors.orange,
                    label: 'Available for withdrawal',
                    amount: '\$3,210.50',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transaction History Header
            Row(
              children: [
                Text(
                  'Payout history',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.filter_list, size: 20),
                  onPressed: () {},
                  color: Colors.black54,
                ),
                const VerticalDivider(width: 16, thickness: 1),
                IconButton(
                  icon: const Icon(Icons.sort, size: 20),
                  onPressed: () {},
                  color: Colors.black54,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Transaction List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: visible.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0x11000000),
                ),
                itemBuilder: (context, i) => _TransactionRow(transaction: visible[i]),
              ),
            ),
            const SizedBox(height: 16),

            // Load More Button
            if (_transactions.isNotEmpty)
              Center(
                child: Opacity(
                  opacity: canLoadMore ? 1 : 0.6,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: canLoadMore ? _loadMore : null,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0x22000000)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_loadingMore)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              Image.asset(
                                'assets/icons/loading.png',
                                width: 18,
                                height: 18,
                              ),
                            const SizedBox(width: 10),
                            const Text(
                              'Load more',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEEEF)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.info_outline, color: Colors.black54),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final keyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Colors.black.withOpacity(.65));
    final valStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(
        fontWeight: FontWeight.w600, color: Colors.black.withOpacity(.85));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RowKVText(
                      k: 'ID',
                      vText: transaction.id,
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 8),
                    _RowKVText(
                      k: 'Transaction ID',
                      vText: transaction.transactionId,
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 8),
                    _RowKVText(
                      k: 'Status',
                      v: _StatusPill(status: transaction.status),
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                      isWidgetValue: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RowKVText(
                      k: 'Earnings',
                      vText: transaction.earnings,
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 8),
                    _RowKVText(
                      k: 'Purchased on',
                      vText: transaction.purchasedOn,
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RowKVText extends StatelessWidget {
  const _RowKVText({
    required this.k,
    this.vText,
    this.v,
    required this.keyStyle,
    required this.valStyle,
    this.isWidgetValue = false,
  }) : assert((vText != null) ^ (v != null), 'Provide either vText or v');

  final String k;
  final String? vText;
  final Widget? v;
  final TextStyle? keyStyle;
  final TextStyle? valStyle;
  final bool isWidgetValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(k, style: keyStyle)),
        const SizedBox(width: 8),
        if (isWidgetValue && v != null)
          v!
        else
          Text(vText ?? '', style: valStyle),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final TransactionStatus status;

  Color get _bg {
    switch (status) {
      case TransactionStatus.paid:
        return const Color(0xFFDFF7E3);
      case TransactionStatus.onProcess:
        return const Color(0xFFFFF4CC);
      case TransactionStatus.failed:
        return const Color(0xFFFFE0E0);
    }
  }

  Color get _textColor {
    switch (status) {
      case TransactionStatus.paid:
        return const Color(0xFF2E7D32);
      case TransactionStatus.onProcess:
        return const Color(0xFFF57F17);
      case TransactionStatus.failed:
        return const Color(0xFFC62828);
    }
  }

  String get _label {
    switch (status) {
      case TransactionStatus.paid:
        return 'Paid';
      case TransactionStatus.onProcess:
        return 'On process';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          _label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
      ),
    );
  }
}

enum TransactionStatus { paid, onProcess, failed }

class Transaction {
  Transaction({
    required this.id,
    required this.transactionId,
    required this.status,
    required this.earnings,
    required this.purchasedOn,
  });

  final String id;
  final String transactionId;
  final TransactionStatus status;
  final String earnings;
  final String purchasedOn;
}