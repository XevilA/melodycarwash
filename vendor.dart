setState(() => _isLoading = false);
    }
  }

  int _getProgramDuration(String program) {
    switch (program) {
      case 'quick':
        return 30;
      case 'normal':
        return 45;
      case 'heavy':
        return 60;
      case 'delicate':
        return 40;
      default:
        return 45;
    }
  }

  double _getProgramPrice(String program) {
    // Get price from machine data or use defaults
    final prices = widget.machine['prices'] ?? {};
    switch (program) {
      case 'quick':
        return (prices['quick'] ?? 30).toDouble();
      case 'normal':
        return (prices['normal'] ?? 40).toDouble();
      case 'heavy':
        return (prices['heavy'] ?? 50).toDouble();
      case 'delicate':
        return (prices['delicate'] ?? 45).toDouble();
      default:
        return 40;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.machine['status'] ?? 'available';
    final type = widget.machine['type'] ?? 'washer';
    final machineNumber = widget.machine['machineNumber'] ?? 0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type == 'washer' ? Icons.local_laundry_service : Icons.dry_cleaning,
                    color: _getStatusColor(status),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เครื่องหมายเลข $machineNumber',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        type == 'washer' ? 'เครื่องซัก' : 'เครื่องอบ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status == 'available') ...[
                    const Text(
                      'เลือกโปรแกรม',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ProgramOption(
                      title: 'ซักด่วน',
                      duration: '30 นาที',
                      price: '฿${_getProgramPrice('quick').toStringAsFixed(0)}',
                      isSelected: _selectedProgram == 'quick',
                      onTap: () => setState(() => _selectedProgram = 'quick'),
                    ),
                    _ProgramOption(
                      title: 'ซักปกติ',
                      duration: '45 นาที',
                      price: '฿${_getProgramPrice('normal').toStringAsFixed(0)}',
                      isSelected: _selectedProgram == 'normal',
                      onTap: () => setState(() => _selectedProgram = 'normal'),
                    ),
                    _ProgramOption(
                      title: 'ซักหนัก',
                      duration: '60 นาที',
                      price: '฿${_getProgramPrice('heavy').toStringAsFixed(0)}',
                      isSelected: _selectedProgram == 'heavy',
                      onTap: () => setState(() => _selectedProgram = 'heavy'),
                    ),
                    _ProgramOption(
                      title: 'ผ้าบอบบาง',
                      duration: '40 นาที',
                      price: '฿${_getProgramPrice('delicate').toStringAsFixed(0)}',
                      isSelected: _selectedProgram == 'delicate',
                      onTap: () => setState(() => _selectedProgram = 'delicate'),
                    ),
                  ] else if (status == 'active') ...[
                    // Active Machine Info
                    _InfoCard(
                      title: 'โปรแกรมปัจจุบัน',
                      value: _getProgramName(widget.machine['currentProgram']),
                      icon: Icons.wash,
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'เวลาที่เหลือ',
                      value: '${widget.machine['remainingTime'] ?? 0} นาที',
                      icon: Icons.timer,
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'เวลาเริ่ม',
                      value: _formatTime(widget.machine['startTime']),
                      icon: Icons.access_time,
                    ),
                  ] else if (status == 'maintenance') ...[
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.build,
                            size: 64,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'เครื่องอยู่ในโหมดซ่อมบำรุง',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'กรุณารอจนกว่าการซ่อมบำรุงจะเสร็จสิ้น',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (status != 'active') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _toggleMaintenance,
                        icon: Icon(
                          status == 'maintenance' ? Icons.build_circle : Icons.build,
                        ),
                        label: Text(
                          status == 'maintenance' ? 'ยกเลิกซ่อมบำรุง' : 'ซ่อมบำรุง',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: status == 'maintenance' ? Colors.green : Colors.orange,
                          ),
                          foregroundColor: status == 'maintenance' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (status == 'available') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _startMachine,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('เริ่มการทำงาน'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B7BF5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else if (status == 'active') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _stopMachine,
                        icon: const Icon(Icons.stop),
                        label: const Text('หยุดการทำงาน'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'active':
        return Colors.orange;
      case 'maintenance':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'ว่าง';
      case 'active':
        return 'กำลังทำงาน';
      case 'maintenance':
        return 'ซ่อมบำรุง';
      default:
        return 'ไม่ทราบ';
    }
  }

  String _getProgramName(String? program) {
    switch (program) {
      case 'quick':
        return 'ซักด่วน';
      case 'normal':
        return 'ซักปกติ';
      case 'heavy':
        return 'ซักหนัก';
      case 'delicate':
        return 'ผ้าบอบบาง';
      default:
        return '-';
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return '-';
    }
  }
}

// Transaction History Screen
class _TransactionHistoryScreen extends StatefulWidget {
  final String userId;
  final String apiToken;

  const _TransactionHistoryScreen({
    required this.userId,
    required this.apiToken,
  });

  @override
  State<_TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<_TransactionHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // API: Get transactions
  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/transactions/vendor/${widget.userId}?date=$dateStr'),
        headers: ApiConfig.authHeaders(widget.apiToken),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _transactions = data['transactions'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate daily summary
    double totalRevenue = 0;
    for (var transaction in _transactions) {
      totalRevenue += (transaction['price'] ?? 0).toDouble();
    }

    return Column(
      children: [
        // Date Selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  });
                  _loadTransactions();
                },
                icon: const Icon(Icons.chevron_left),
              ),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                    _loadTransactions();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMMM yyyy', 'th').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: _selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                    ? () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
                        _loadTransactions();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),

        // Transaction List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ไม่มีรายการในวันนี้',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Daily Summary
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4B7BF5), Color(0xFF3A5FCD)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'รายได้ทั้งหมด',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '฿${NumberFormat('#,###').format(totalRevenue)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'จำนวนรายการ',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${_transactions.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Transaction List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _transactions[index];
                              return _TransactionCard(transaction: transaction);
                            },
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}

// Transaction Card Widget
class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final machineNumber = transaction['machineNumber'] ?? '-';
    final machineType = transaction['machineType'] ?? 'washer';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(transaction['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            machineType == 'washer' ? Icons.local_laundry_service : Icons.dry_cleaning,
            color: _getStatusColor(transaction['status']),
          ),
        ),
        title: Text(
          'เครื่องหมายเลข $machineNumber',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getProgramName(transaction['program'])),
            Text(
              _formatTime(transaction['startTime']),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '฿${transaction['price']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B7BF5),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(transaction['status']),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'active':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'completed':
        return 'เสร็จสิ้น';
      case 'active':
        return 'กำลังทำงาน';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return 'ไม่ทราบ';
    }
  }

  String _getProgramName(String? program) {
    switch (program) {
      case 'quick':
        return 'ซักด่วน';
      case 'normal':
        return 'ซักปกติ';
      case 'heavy':
        return 'ซักหนัก';
      case 'delicate':
        return 'ผ้าบอบบาง';
      default:
        return '-';
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return '-';
    }
  }
}

// Reports Screen
class _ReportsScreen extends StatefulWidget {
  final String userId;
  final String apiToken;

  const _ReportsScreen({
    required this.userId,
    required this.apiToken,
  });

  @override
  State<_ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<_ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'daily';
  Map<String, dynamic> _reportData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // API: Get report data
  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reports/vendor/${widget.userId}?period=$_selectedPeriod'),
        headers: ApiConfig.authHeaders(widget.apiToken),
      );

      if (response.statusCode == 200) {
        setState(() {
          _reportData = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reports: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Period Selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              _PeriodButton(
                label: 'รายวัน',
                isSelected: _selectedPeriod == 'daily',
                onTap: () {
                  setState(() => _selectedPeriod = 'daily');
                  _loadReports();
                },
              ),
              const SizedBox(width: 8),
              _PeriodButton(
                label: 'รายสัปดาห์',
                isSelected: _selectedPeriod == 'weekly',
                onTap: () {
                  setState(() => _selectedPeriod = 'weekly');
                  _loadReports();
                },
              ),
              const SizedBox(width: 8),
              _PeriodButton(
                label: 'รายเดือน',
                isSelected: _selectedPeriod == 'monthly',
                onTap: () {
                  setState(() => _selectedPeriod = 'monthly');
                  _loadReports();
                },
              ),
              const SizedBox(width: 8),
              _PeriodButton(
                label: 'รายปี',
                isSelected: _selectedPeriod == 'yearly',
                onTap: () {
                  setState(() => _selectedPeriod = 'yearly');
                  _loadReports();
                },
              ),
            ],
          ),
        ),

        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4B7BF5),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF4B7BF5),
            tabs: const [
              Tab(text: 'รายได้'),
              Tab(text: 'การใช้งาน'),
              Tab(text: 'ประสิทธิภาพ'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _RevenueReport(data: _reportData['revenue'] ?? {}),
                    _UsageReport(data: _reportData['usage'] ?? {}),
                    _PerformanceReport(data: _reportData['performance'] ?? {}),
                  ],
                ),
        ),
      ],
    );
  }
}

// Revenue Report Widget
class _RevenueReport extends StatelessWidget {
  final Map<String, dynamic> data;

  const _RevenueReport({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = (data['total'] ?? 0).toDouble();
    final transactionCount = data['transactionCount'] ?? 0;
    final chartData = (data['chartData'] as List?)?.map((e) => e.toDouble()).toList() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _ReportCard(
                  title: 'รายได้รวม',
                  value: '฿${NumberFormat('#,###').format(total)}',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReportCard(
                  title: 'รายการทั้งหมด',
                  value: '$transactionCount',
                  icon: Icons.receipt,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Revenue Chart
          if (chartData.isNotEmpty)
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'กราฟรายได้',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1000,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[200]!,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  'Day ${value.toInt() + 1}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1000,
                              reservedSize: 42,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: chartData.length.toDouble() - 1,
                        minY: 0,
                        maxY: chartData.isEmpty ? 1000 : chartData.reduce(math.max) * 1.2,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getSpots(chartData),
                            isCurved: true,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4B7BF5), Color(0xFF3A5FCD)],
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: const Color(0xFF4B7BF5),
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF4B7BF5).withOpacity(0.3),
                                  const Color(0xFF3A5FCD).withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots(List<double> data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }
    return spots;
  }
}

// Usage Report Widget
class _UsageReport extends StatelessWidget {
  final Map<String, dynamic> data;

  const _UsageReport({required this.data});

  @override
  Widget build(BuildContext context) {
    final hourlyData = data['hourlyData'] as Map<String, dynamic>? ?? {};
    final programData = data['programData'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hourly Usage Chart
          if (hourlyData.isNotEmpty)
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ชั่วโมงที่มีการใช้บริการ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: hourlyData.values.fold<double>(0, (a, b) => math.max(a, (b as num).toDouble())) * 1.2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.black87,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.toInt()} ครั้ง',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() % 3 == 0) {
                                  return Text(
                                    '${value.toInt()}:00',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 5,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _getBarGroups(hourlyData),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Program Usage
          if (programData.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'โปรแกรมที่ใช้บ่อย',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...programData.entries.map((entry) {
                    final total = programData.values.fold(0, (a, b) => a + b);
                    final percentage = ((entry.value / total) * 100).toStringAsFixed(1);
                    return _ProgramUsageItem(
                      program: entry.key,
                      count: entry.value,
                      percentage: percentage,
                      total: total,
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups(Map<String, dynamic> data) {
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < 24; i++) {
      final value = (data[i.toString()] ?? 0).toDouble();
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              gradient: const LinearGradient(
                colors: [Color(0xFF4B7BF5), Color(0xFF3A5FCD)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 8,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }
    return groups;
  }
}

// Performance Report Widget
class _PerformanceReport extends StatelessWidget {
  final Map<String, dynamic> data;

  const _PerformanceReport({required this.data});

  @override
  Widget build(BuildContext context) {
    final utilizationRate = data['utilizationRate'] ?? '0';
    final avgRuntime = data['avgRuntime'] ?? '0';
    final machinePerformance = data['machinePerformance'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overall Performance
          Row(
            children: [
              Expanded(
                child: _ReportCard(
                  title: 'อัตราการใช้งาน',
                  value: '$utilizationRate%',
                  icon: Icons.speed,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReportCard(
                  title: 'เวลาทำงานเฉลี่ย',
                  value: '$avgRuntime นาที',
                  icon: Icons.timer,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Machine Performance List
          if (machinePerformance.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ประสิทธิภาพแต่ละเครื่อง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...machinePerformance.map((machine) {
                    return _MachinePerformanceItem(
                      machineNumber: machine['machineNumber'] ?? 0,
                      type: machine['type'] ?? 'washer',
                      transactionCount: machine['transactionCount'] ?? 0,
                      revenue: (machine['revenue'] ?? 0).toDouble(),
                      status: machine['status'] ?? 'available',
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Settings Screen
class _SettingsScreen extends StatefulWidget {
  final String userId;
  final String apiToken;

  const _SettingsScreen({
    required this.userId,
    required this.apiToken,
  });

  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  final _priceControllers = {
    'quick': TextEditingController(),
    'normal': TextEditingController(),
    'heavy': TextEditingController(),
    'delicate': TextEditingController(),
  };

  TimeOfDay? _promotionStartTime;
  TimeOfDay? _promotionEndTime;
  int _promotionDiscount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // API: Load settings
  Future<void> _loadSettings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/settings/vendor/${widget.userId}'),
        headers: ApiConfig.authHeaders(widget.apiToken),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prices = data['prices'] ?? {};
        final promotion = data['promotion'] ?? {};
        
        setState(() {
          _priceControllers['quick']!.text = prices['quick']?.toString() ?? '30';
          _priceControllers['normal']!.text = prices['normal']?.toString() ?? '40';
          _priceControllers['heavy']!.text = prices['heavy']?.toString() ?? '50';
          _priceControllers['delicate']!.text = prices['delicate']?.toString() ?? '45';

          if (promotion['startTime'] != null) {
            final parts = promotion['startTime'].split(':');
            _promotionStartTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
          
          if (promotion['endTime'] != null) {
            final parts = promotion['endTime'].split(':');
            _promotionEndTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
          
          _promotionDiscount = promotion['discount'] ?? 0;
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // API: Save settings
  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/settings/vendor/${widget.userId}'),
        headers: ApiConfig.authHeaders(widget.apiToken),
        body: jsonEncode({
          'prices': {
            'quick': double.parse(_priceControllers['quick']!.text),
            'normal': double.parse(_priceControllers['normal']!.text),
            'heavy': double.parse(_priceControllers['heavy']!.text),
            'delicate': double.parse(_priceControllers['delicate']!.text),
          },
          'promotion': _promotionStartTime != null && _promotionEndTime != null
              ? {
                  'startTime': '${_promotionStartTime!.hour}:${_promotionStartTime!.minute}',
                  'endTime': '${_promotionEndTime!.hour}:${_promotionEndTime!.minute}',
                  'discount': _promotionDiscount,
                }
              : null,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกการตั้งค่าแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // API: Export data
  Future<void> _exportData() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/export/vendor/${widget.userId}'),
        headers: ApiConfig.authHeaders(widget.apiToken),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final downloadUrl = data['downloadUrl'];
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ส่งออกข้อมูลสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        
        // In a real app, open the download URL
        // For demo, we just show success message
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Settings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ตั้งค่าราคา',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _PriceInput(
                  label: 'ซักด่วน (30 นาที)',
                  controller: _priceControllers['quick']!,
                ),
                _PriceInput(
                  label: 'ซักปกติ (45 นาที)',
                  controller: _priceControllers['normal']!,
                ),
                _PriceInput(
                  label: 'ซักหนัก (60 นาที)',
                  controller: _priceControllers['heavy']!,
                ),
                _PriceInput(
                  label: 'ผ้าบอบบาง (40 นาที)',
                  controller: _priceControllers['delicate']!,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Promotion Settings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ตั้งค่าโปรโมชั่น',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TimeSelector(
                        label: 'เวลาเริ่ม',
                        time: _promotionStartTime,
                        onSelect: (time) => setState(() => _promotionStartTime = time),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeSelector(
                        label: 'เวลาสิ้นสุด',
                        time: _promotionEndTime,
                        onSelect: (time) => setState(() => _promotionEndTime = time),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'ส่วนลด: $_promotionDiscount%',
                  style: const TextStyle(fontSize: 16),
                ),
                Slider(
                  value: _promotionDiscount.toDouble(),
                  min: 0,
                  max: 50,
                  divisions: 10,
                  activeColor: const Color(0xFF4B7BF5),
                  onChanged: (value) => setState(() => _promotionDiscount = value.toInt()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data Management
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'จัดการข้อมูล',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.cloud_upload, color: Color(0xFF4B7BF5)),
                  title: const Text('สำรองข้อมูล'),
                  subtitle: const Text('อัปโหลดข้อมูลไปยังคลาวด์'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // API: Backup data
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('กำลังสำรองข้อมูล...')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download, color: Colors.green),
                  title: const Text('ดึงข้อมูล'),
                  subtitle: const Text('ดาวน์โหลดข้อมูลจากคลาวด์'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // API: Restore data
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('กำลังดึงข้อมูล...')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_download, color: Colors.orange),
                  title: const Text('ส่งออกข้อมูล'),
                  subtitle: const Text('ส่งออกเป็นไฟล์ Excel'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _exportData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B7BF5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'บันทึกการตั้งค่า',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

// Helper Widgets
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B7BF5) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ProgramOption extends StatelessWidget {
  final String title;
  final String duration;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProgramOption({
    required this.title,
    required this.duration,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B7BF5).withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4B7BF5) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF4B7BF5) : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Color(0xFF4B7BF5),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

// API Configuration (same as main.dart)
class ApiConfig {
  static const String baseUrl = 'https://api.laundry-system.com/v1'; // Change to your API URL
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) {
    return {
      ...headers,
      'Authorization': 'Bearer $token',
    };
  }
}

class VendorDashboard extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String apiToken;
  final Map<String, dynamic> vendorData;

  const VendorDashboard({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.apiToken,
    required this.vendorData,
  });

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Firebase Auth Logout + API Logout
  Future<void> _logout() async {
    try {
      // API: Call logout endpoint
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
        headers: ApiConfig.authHeaders(widget.apiToken),
        body: jsonEncode({
          'userId': widget.userId,
        }),
      );

      // Firebase: Sign out
      await FirebaseAuth.instance.signOut();
      
      if (!mounted) return;
      
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถออกจากระบบได้: $e')),
      );
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _MachineControlScreen(
          userId: widget.userId,
          apiToken: widget.apiToken,
        );
      case 1:
        return _TransactionHistoryScreen(
          userId: widget.userId,
          apiToken: widget.apiToken,
        );
      case 2:
        return _ReportsScreen(
          userId: widget.userId,
          apiToken: widget.apiToken,
        );
      case 3:
        return _SettingsScreen(
          userId: widget.userId,
          apiToken: widget.apiToken,
        );
      default:
        return _MachineControlScreen(
          userId: widget.userId,
          apiToken: widget.apiToken,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4B7BF5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_laundry_service,
                color: Color(0xFF4B7BF5),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Melody Wash&Dry',
                  style: TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.vendorData['storeName'] ?? 'ระบบเจ้าของร้าน',
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF718096)),
            onPressed: () => _showNotifications(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF718096)),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 12),
                    Text('โปรไฟล์'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('ออกจากระบบ'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ScaleTransition(
        scale: _scaleAnimation,
        child: _buildBody(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.devices, 'เครื่อง', 0),
                _buildNavItem(Icons.history, 'ประวัติ', 1),
                _buildNavItem(Icons.bar_chart, 'รายงาน', 2),
                _buildNavItem(Icons.settings, 'ตั้งค่า', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        _animationController.reset();
        _animationController.forward();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B7BF5).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4B7BF5) : const Color(0xFF718096),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4B7BF5) : const Color(0xFF718096),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // API: Get notifications
  void _showNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications/${widget.userId}'),
        headers: ApiConfig.authHeaders(widget.apiToken),
      );

      if (response.statusCode == 200) {
        final notifications = jsonDecode(response.body)['notifications'] as List;
        
        if (!mounted) return;
        
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _NotificationsSheet(
            notifications: notifications,
            apiToken: widget.apiToken,
          ),
        );
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }
}

// Notifications Sheet
class _NotificationsSheet extends StatelessWidget {
  final List<dynamic> notifications;
  final String apiToken;

  const _NotificationsSheet({
    required this.notifications,
    required this.apiToken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'การแจ้งเตือน',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(child: Text('ไม่มีการแจ้งเตือน'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getNotificationColor(notification['type']),
                            child: Icon(
                              _getNotificationIcon(notification['type']),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(notification['title'] ?? ''),
                          subtitle: Text(notification['message'] ?? ''),
                          trailing: Text(
                            _formatTimestamp(notification['createdAt']),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} นาทีที่แล้ว';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ชั่วโมงที่แล้ว';
      } else {
        return DateFormat('dd/MM/yyyy HH:mm').format(date);
      }
    } catch (e) {
      return '';
    }
  }
}

// Machine Control Screen
class _MachineControlScreen extends StatefulWidget {
  final String userId;
  final String apiToken;

  const _MachineControlScreen({
    required this.userId,
    required this.apiToken,
  });

  @override
  State<_MachineControlScreen> createState() => _MachineControlScreenState();
}

class _MachineControlScreenState extends State<_MachineControlScreen> {
  String _selectedFilter = 'all';
  List<dynamic> _machines = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadMachines();
    // Refresh every 10 seconds for real-time updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadMachines();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // API: Get machines list
  Future<void> _loadMachines() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/machines/vendor/${widget.userId}'),
        headers: ApiConfig.authHeaders(widget.apiToken),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _machines = data['machines'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading machines: $e');
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getFilteredMachines() {
    if (_selectedFilter == 'all') return _machines;
    
    return _machines.where((machine) {
      switch (_selectedFilter) {
        case 'available':
          return machine['status'] == 'available';
        case 'active':
          return machine['status'] == 'active';
        case 'maintenance':
          return machine['status'] == 'maintenance';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMachines = _getFilteredMachines();
    final activeMachines = _machines.where((m) => m['status'] == 'active').length;
    final totalRevenue = _machines.fold<double>(
      0,
      (sum, m) => sum + (m['todayRevenue'] ?? 0).toDouble(),
    );

    return Column(
      children: [
        // Summary Cards
        Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _SummaryCard(
                title: 'รายได้วันนี้',
                value: '฿${NumberFormat('#,###').format(totalRevenue)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                title: 'เครื่องทำงาน',
                value: '$activeMachines/${_machines.length}',
                icon: Icons.devices,
                color: Colors.blue,
              ),
            ],
          ),
        ),

        // Filter Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _FilterChip(
                label: 'ทั้งหมด',
                isSelected: _selectedFilter == 'all',
                onTap: () => setState(() => _selectedFilter = 'all'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'ว่าง',
                isSelected: _selectedFilter == 'available',
                onTap: () => setState(() => _selectedFilter = 'available'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'กำลังทำงาน',
                isSelected: _selectedFilter == 'active',
                onTap: () => setState(() => _selectedFilter = 'active'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'ซ่อมบำรุง',
                isSelected: _selectedFilter == 'maintenance',
                onTap: () => setState(() => _selectedFilter = 'maintenance'),
              ),
            ],
          ),
        ),

        // Machine List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadMachines,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredMachines.length,
                    itemBuilder: (context, index) {
                      final machine = filteredMachines[index];
                      return _MachineCard(
                        machine: machine,
                        apiToken: widget.apiToken,
                        onUpdate: _loadMachines,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

// Machine Card Widget
class _MachineCard extends StatelessWidget {
  final Map<String, dynamic> machine;
  final String apiToken;
  final VoidCallback onUpdate;

  const _MachineCard({
    required this.machine,
    required this.apiToken,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final status = machine['status'] ?? 'available';
    final type = machine['type'] ?? 'washer';
    final machineNumber = machine['machineNumber'] ?? 0;
    final remainingTime = machine['remainingTime'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showMachineDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Machine Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  type == 'washer' ? Icons.local_laundry_service : Icons.dry_cleaning,
                  color: _getStatusColor(status),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              
              // Machine Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เครื่องหมายเลข $machineNumber',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type == 'washer' ? 'เครื่องซัก' : 'เครื่องอบ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (status == 'active' && remainingTime > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'เหลือเวลา $remainingTime นาที',
                            style: TextStyle(
                              color: Colors.orange[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'active':
        return Colors.orange;
      case 'maintenance':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'ว่าง';
      case 'active':
        return 'กำลังทำงาน';
      case 'maintenance':
        return 'ซ่อมบำรุง';
      default:
        return 'ไม่ทราบ';
    }
  }

  void _showMachineDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MachineDetailSheet(
        machine: machine,
        apiToken: apiToken,
        onUpdate: onUpdate,
      ),
    );
  }
}

// Machine Detail Sheet
class _MachineDetailSheet extends StatefulWidget {
  final Map<String, dynamic> machine;
  final String apiToken;
  final VoidCallback onUpdate;

  const _MachineDetailSheet({
    required this.machine,
    required this.apiToken,
    required this.onUpdate,
  });

  @override
  State<_MachineDetailSheet> createState() => _MachineDetailSheetState();
}

class _MachineDetailSheetState extends State<_MachineDetailSheet> {
  bool _isLoading = false;
  String? _selectedProgram;
  
  // API: Start Machine
  Future<void> _startMachine() async {
    if (_selectedProgram == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกโปรแกรม')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/machines/${widget.machine['id']}/start'),
        headers: ApiConfig.authHeaders(widget.apiToken),
        body: jsonEncode({
          'program': _selectedProgram,
          'userId': widget.machine['vendorId'],
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        widget.onUpdate();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เครื่องเริ่มทำงานแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw 'Failed to start machine';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // API: Stop Machine
  Future<void> _stopMachine() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/machines/${widget.machine['id']}/stop'),
        headers: ApiConfig.authHeaders(widget.apiToken),
        body: jsonEncode({
          'userId': widget.machine['vendorId'],
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        widget.onUpdate();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('หยุดเครื่องแล้ว'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw 'Failed to stop machine';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // API: Toggle Maintenance
  Future<void> _toggleMaintenance() async {
    final currentStatus = widget.machine['status'];
    final newStatus = currentStatus == 'maintenance' ? 'available' : 'maintenance';

    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/machines/${widget.machine['id']}/status'),
        headers: ApiConfig.authHeaders(widget.apiToken),
        body: jsonEncode({
          'status': newStatus,
          'userId': widget.machine['vendorId'],
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        widget.onUpdate();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'maintenance' 
                  ? 'เครื่องเข้าสู่โหมดซ่อมบำรุง' 
                  : 'ยกเลิกโหมดซ่อมบำรุงแล้ว'
            ),
            backgroundColor: newStatus == 'maintenance' ? Colors.red : Colors.green,
          ),
        );
      } else {
        throw 'Failed to update machine status';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
