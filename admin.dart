import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

// API Configuration
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

// Main Admin Dashboard Widget
class AdminDashboard extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String apiToken;

  const AdminDashboard({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.apiToken,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถออกจากระบบได้: $e')),
      );
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardScreen(
          adminId: widget.userId,
          apiToken: widget.apiToken,
        );
      case 1:
        return _VendorManagementScreen(
          adminId: widget.userId,
          apiToken: widget.apiToken,
        );
      case 2:
        return _FinancialScreen(
          adminId: widget.userId,
          apiToken: widget.apiToken,
        );
      case 3:
        return _SystemSettingsScreen(
          adminId: widget.userId,
          apiToken: widget.apiToken,
        );
      default:
        return _DashboardScreen(
          adminId: widget.userId,
          apiToken: widget.apiToken,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4B7BF5), Color(0xFF3A5FCD)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        'ระบบจัดการส่วนกลาง',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => _showNotifications(context),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'logout') {
                        _logout();
                      }
                    },
                    itemBuilder: (context) => [
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
            ),

            // Body Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildBody(),
              ),
            ),

            // Bottom Navigation
            Container(
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
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.dashboard, 'ภาพรวม', 0),
                      _buildNavItem(Icons.people, 'เจ้าของร้าน', 1),
                      _buildNavItem(Icons.account_balance_wallet, 'การเงิน', 2),
                      _buildNavItem(Icons.settings_applications, 'ตั้งค่า', 3),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4B7BF5).withOpacity(0.1)
              : Colors.transparent,
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

  // API: Show notifications
  void _showNotifications(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/notifications'),
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
              'การแจ้งเตือนระบบ',
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
                              size: 20,
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
      case 'new_vendor':
        return Colors.green;
      case 'payment':
        return Colors.blue;
      case 'alert':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'new_vendor':
        return Icons.person_add;
      case 'payment':
        return Icons.payment;
      case 'alert':
        return Icons.warning;
      case 'error':
        return Icons.error;
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

// Dashboard Screen (Tab 1)
class _DashboardScreen extends StatefulWidget {
  final String adminId;
  final String apiToken;

  const _DashboardScreen({
    required this.adminId,
    required this.apiToken,
  });

  @override
  State<_DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<_DashboardScreen> {
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/dashboard'),
        headers: ApiConfig.authHeaders(widget.apiToken),
      );

      if (mounted && response.statusCode == 200) {
        setState(() {
          _dashboardData = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final todayRevenue = (_dashboardData['todayRevenue'] ?? 0).toDouble();
    final vendorCount = _dashboardData['vendorCount'] ?? 0;
    final activeVendors = _dashboardData['activeVendors'] ?? 0;
    final machineCount = _dashboardData['machineCount'] ?? 0;
    final commission = todayRevenue * 0.15; // Example, should come from API
    final chartData = (_dashboardData['revenueChart'] as List?)
            ?.map((e) => e.toDouble())
            .toList() ??
        [];
    final activities = _dashboardData['recentActivities'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สวัสดี, Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ภาพรวมระบบวันที่ ${DateFormat('dd MMMM yyyy', 'th').format(DateTime.now())}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DashboardCard(
                        title: 'รายได้วันนี้',
                        value: '฿${NumberFormat('#,###').format(todayRevenue)}',
                        icon: Icons.attach_money,
                        color: Colors.green,
                        trend: '+12.5%', // Mock data
                        trendUp: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DashboardCard(
                        title: 'เจ้าของร้าน',
                        value: '$vendorCount',
                        subtitle: '$activeVendors active',
                        icon: Icons.store,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DashboardCard(
                        title: 'จำนวนเครื่อง',
                        value: '$machineCount',
                        icon: Icons.devices,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DashboardCard(
                        title: 'ค่าคอมมิชชั่น',
                        value: '฿${NumberFormat('#,###.00').format(commission)}',
                        icon: Icons.account_balance,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'แนวโน้มรายได้ 7 วันล่าสุด',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '+23.5%', // Mock data
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval:
                                chartData.reduce(math.max) > 0 ? chartData.reduce(math.max) / 4 : 1000,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey[200]!,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final day = DateTime.now()
                                      .subtract(Duration(days: 6 - value.toInt()));
                                  return Text(
                                    DateFormat('E', 'th').format(day),
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval:
                                    chartData.reduce(math.max) > 0 ? chartData.reduce(math.max) / 4 : 1000,
                                reservedSize: 50,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${(value / 1000).toStringAsFixed(0)}k',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 6,
                          minY: 0,
                          maxY: chartData.isEmpty
                              ? 50000
                              : chartData.reduce(math.max) * 1.2,
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
                                getDotPainter:
                                    (spot, percent, barData, index) {
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
            const SizedBox(height: 24),

            // Recent Activities
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
                    'กิจกรรมล่าสุด',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (activities.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('ไม่มีกิจกรรม'),
                      ),
                    )
                  else
                    ...activities.take(5).map((activity) {
                      return _ActivityItem(
                        icon: _getActivityIcon(activity['type']),
                        title: activity['title'] ?? '',
                        subtitle: activity['description'] ?? '',
                        time: _formatTimestamp(activity['timestamp']),
                        color: _getActivityColor(activity['type']),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots(List<double> data) {
    if (data.length != 7) {
      // Pad with zeros if data is not for 7 days
      final paddedData = List<double>.from(data);
      while (paddedData.length < 7) {
        paddedData.insert(0, 0);
      }
      data = paddedData.sublist(paddedData.length - 7);
    }
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }
    return spots;
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'new_vendor':
        return Icons.person_add;
      case 'machine_added':
        return Icons.add_box;
      case 'payment':
        return Icons.payment;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'new_vendor':
        return Colors.green;
      case 'machine_added':
        return Colors.blue;
      case 'payment':
        return Colors.purple;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
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
      } else if (difference.inDays < 7) {
        return '${difference.inDays} วันที่แล้ว';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return '';
    }
  }
}

// Vendor Management Screen (Tab 2)
class _VendorManagementScreen extends StatefulWidget {
  final String adminId;
  final String apiToken;

  const _VendorManagementScreen({
    required this.adminId,
    required this.apiToken,
  });

  @override
  State<_VendorManagementScreen> createState() =>
      _VendorManagementScreenState();
}

class _VendorManagementScreenState extends State<_VendorManagementScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  List<dynamic> _vendors = [];
  List<dynamic> _pendingApplications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final vendorsResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/vendors'),
        headers: ApiConfig.authHeaders(widget.apiToken),
      );

      final applicationsSnapshot = await FirebaseFirestore.instance
          .collection('vendor_applications')
          .where('status', isEqualTo: 'pending')
          .get();

      if (!mounted) return;

      if (vendorsResponse.statusCode == 200) {
        setState(() {
          _vendors = jsonDecode(vendorsResponse.body)['vendors'] ?? [];
          _pendingApplications = applicationsSnapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList();
          _isLoading = false;
        });
      } else {
         setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading vendors: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> _getFilteredVendors() {
    var filtered = _vendors;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((vendor) {
        final name = vendor['name']?.toString().toLowerCase() ?? '';
        final email = vendor['email']?.toString().toLowerCase() ?? '';
        final storeName = vendor['storeName']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            storeName.contains(query);
      }).toList();
    }

    if (_selectedFilter != 'all') {
      filtered = filtered.where((vendor) {
        switch (_selectedFilter) {
          case 'active':
            return vendor['status'] == 'active';
          case 'suspended':
            return vendor['status'] == 'suspended';
          case 'new':
            try {
              final createdAt = DateTime.parse(vendor['createdAt']);
              final daysSinceCreation =
                  DateTime.now().difference(createdAt).inDays;
              return daysSinceCreation <= 7;
            } catch (e) {
              return false;
            }
          default:
            return true;
        }
      }).toList();
    }
    return filtered;
  }

  Future<void> _approveApplication(Map<String, dynamic> application) async {
    try {
      await FirebaseFirestore.instance
          .collection('vendor_applications')
          .doc(application['id'])
          .update({'status': 'approved'});

      await FirebaseFirestore.instance
          .collection('users')
          .doc(application['id'])
          .update({
        'status': 'active',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': widget.adminId,
      });

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/vendors/approve'),
        headers: ApiConfig.authHeaders(widget.apiToken),
        body: jsonEncode({
          'vendorId': application['id'],
          'vendorData': application,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อนุมัติเจ้าของร้านสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        _loadVendors();
      } else {
        throw Exception('Failed to approve on backend');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการอนุมัติ: $e')),
      );
    }
  }

  Future<void> _rejectApplication(String applicationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('vendor_applications')
          .doc(applicationId)
          .update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': widget.adminId,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ปฏิเสธคำขอสมัครแล้ว'),
          backgroundColor: Colors.red,
        ),
      );
      _loadVendors();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการปฏิเสธ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredVendors = _getFilteredVendors();

    return Column(
      children: [
        // Pending Applications
        if (_pendingApplications.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pending_actions, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'คำขอสมัครรอการอนุมัติ (${_pendingApplications.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._pendingApplications.map((application) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(application['storeName'] ?? 'ไม่ระบุชื่อร้าน'),
                      subtitle: Text(
                          '${application['name']} - ${application['email']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green),
                            onPressed: () => _approveApplication(application),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () =>
                                _rejectApplication(application['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

        // Search and Filter
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'ค้นหาเจ้าของร้าน...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'ทั้งหมด',
                      isSelected: _selectedFilter == 'all',
                      onTap: () => setState(() => _selectedFilter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'ใช้งาน',
                      isSelected: _selectedFilter == 'active',
                      onTap: () => setState(() => _selectedFilter = 'active'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'ระงับ',
                      isSelected: _selectedFilter == 'suspended',
                      onTap: () =>
                          setState(() => _selectedFilter = 'suspended'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'ใหม่',
                      isSelected: _selectedFilter == 'new',
                      onTap: () => setState(() => _selectedFilter = 'new'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Vendor List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadVendors,
                  child: filteredVendors.isEmpty
                      ? const Center(child: Text('ไม่พบข้อมูลเจ้าของร้าน'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredVendors.length,
                          itemBuilder: (context, index) {
                            final vendor = filteredVendors[index];
                            return _VendorCard(
                              vendor: vendor,
                              apiToken: widget.apiToken,
                              onUpdate: _loadVendors,
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

// Vendor Card Widget for the list
class _VendorCard extends StatelessWidget {
  final Map<String, dynamic> vendor;
  final String apiToken;
  final VoidCallback onUpdate;

  const _VendorCard({
    required this.vendor,
    required this.apiToken,
    required this.onUpdate,
  });

  void _showVendorDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _VendorDetailScreen(
          vendor: vendor,
          apiToken: apiToken,
          onUpdate: onUpdate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showVendorDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF4B7BF5).withOpacity(0.1),
                child: Text(
                  vendor['name'] != null && vendor['name'].isNotEmpty
                      ? vendor['name'].substring(0, 1).toUpperCase()
                      : 'V',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B7BF5),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor['storeName'] ?? 'ไม่ระบุชื่อร้าน',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vendor['name'] ?? 'ไม่ระบุชื่อ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vendor['email'] ?? '-',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: vendor['status'] == 'active'
                          ? Colors.green
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vendor['status'] == 'active' ? 'ใช้งาน' : 'ระงับ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${vendor['machineCount'] ?? 0} เครื่อง',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Vendor Detail Screen
class _VendorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> vendor;
  final String apiToken;
  final VoidCallback onUpdate;

  const _VendorDetailScreen({
    required this.vendor,
    required this.apiToken,
    required this.onUpdate,
  });

  @override
  State<_VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<_VendorDetailScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _vendorDetails = {};
  List<dynamic> _machines = [];

  @override
  void initState() {
    super.initState();
    _vendorDetails = widget.vendor;
    _loadVendorDetails();
  }

  Future<void> _loadVendorDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/vendors/${widget.vendor['id']}'),
        headers: ApiConfig.authHeaders(widget.apiToken),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _vendorDetails = data['vendor'] ?? {};
          _machines = data['machines'] ?? [];
          _isLoading = false;
        });
      } else {
         setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading vendor details: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleVendorStatus() async {
    final currentStatus = _vendorDetails['status'];
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse(
            '${ApiConfig.baseUrl}/admin/vendors/${widget.vendor['id']}/status'),
        headers: ApiConfig.authHeaders(widget.apiToken),
        body: jsonEncode({
          'status': newStatus,
        }),
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.vendor['id'])
            .update({
          'status': newStatus,
          'statusUpdatedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _vendorDetails['status'] = newStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == 'active'
                ? 'เปิดใช้งานเจ้าของร้านแล้ว'
                : 'ระงับเจ้าของร้านแล้ว'),
            backgroundColor:
                newStatus == 'active' ? Colors.green : Colors.orange,
          ),
        );
        widget.onUpdate(); // Call the callback to refresh the previous screen
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _vendorDetails.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('รายละเอียดเจ้าของร้าน'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalRevenue = _vendorDetails['totalRevenue'] ?? 0;
    final transactionCount = _vendorDetails['transactionCount'] ?? 0;
    final name = _vendorDetails['name'] ?? 'V';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          _vendorDetails['storeName'] ?? 'รายละเอียดร้าน',
          style: const TextStyle(color: Color(0xFF2D3748)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit vendor logic
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadVendorDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          const Color(0xFF4B7BF5).withOpacity(0.1),
                      child: Text(
                        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'V',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B7BF5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _vendorDetails['name'] ?? 'ไม่ระบุชื่อ',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _vendorDetails['status'] == 'active'
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _vendorDetails['status'] == 'active'
                            ? 'ใช้งาน'
                            : 'ระงับ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _InfoRow(
                      icon: Icons.email,
                      label: 'อีเมล',
                      value: _vendorDetails['email'] ?? '-',
                    ),
                    _InfoRow(
                      icon: Icons.phone,
                      label: 'โทรศัพท์',
                      value: _vendorDetails['phone'] ?? '-',
                    ),
                    _InfoRow(
                      icon: Icons.store,
                      label: 'ชื่อร้าน',
                      value: _vendorDetails['storeName'] ?? '-',
                    ),
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'ที่อยู่',
                      value: _vendorDetails['address'] ?? '-',
                    ),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'วันที่สมัคร',
                      value: _formatDate(_vendorDetails['createdAt']),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'จำนวนเครื่อง',
                      value: '${_machines.length}',
                      icon: Icons.devices,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'รายการทั้งหมด',
                      value: NumberFormat('#,###').format(transactionCount),
                      icon: Icons.receipt,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'รายได้ทั้งหมด',
                value: '฿${NumberFormat('#,###').format(totalRevenue)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
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
                      'รายการเครื่อง',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_machines.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('ไม่มีเครื่อง'),
                        ),
                      )
                    else
                      ..._machines.map((machine) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getMachineStatusColor(
                                    machine['status'])
                                .withOpacity(0.1),
                            child: Icon(
                              machine['type'] == 'washer'
                                  ? Icons.local_laundry_service
                                  : Icons.dry_cleaning,
                              color: _getMachineStatusColor(machine['status']),
                            ),
                          ),
                          title: Text(
                              'เครื่องหมายเลข ${machine['machineNumber']}'),
                          subtitle: Text(machine['type'] == 'washer'
                              ? 'เครื่องซัก'
                              : 'เครื่องอบ'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getMachineStatusColor(machine['status']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getMachineStatusText(machine['status']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _toggleVendorStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _vendorDetails['status'] == 'active'
                        ? Colors.orange
                        : Colors.green,
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
                      : Text(
                          _vendorDetails['status'] == 'active'
                              ? 'ระงับการใช้งาน'
                              : 'เปิดใช้งาน',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '-';
    }
  }

  Color _getMachineStatusColor(String? status) {
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

  String _getMachineStatusText(String? status) {
    switch (status) {
      case 'available':
        return 'ว่าง';
      case 'active':
        return 'ทำงาน';
      case 'maintenance':
        return 'ซ่อม';
      default:
        return 'ไม่ทราบ';
    }
  }
}

// Financial Screen (Tab 3)
class _FinancialScreen extends StatefulWidget {
  final String adminId;
  final String apiToken;

  const _FinancialScreen({
    required this.adminId,
    required this.apiToken,
  });

  @override
  State<_FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<_FinancialScreen> {
  String _selectedPeriod = 'month';
  Map<String, dynamic> _financialData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/admin/financial?period=$_selectedPeriod'),
        headers: ApiConfig.authHeaders(widget.apiToken),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _financialData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
         setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading financial data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalRevenue = (_financialData['totalRevenue'] ?? 0).toDouble();
    final commission = (_financialData['commission'] ?? 0).toDouble();
    final vendorShare = (_financialData['vendorShare'] ?? 0).toDouble();
    final vendorRevenues =
        _financialData['vendorRevenues'] as Map<String, dynamic>? ?? {};
    final payments = _financialData['recentPayments'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: _loadFinancialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    'เลือกช่วงเวลา',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _PeriodChip(
                        label: 'รายวัน',
                        isSelected: _selectedPeriod == 'day',
                        onTap: () {
                          setState(() => _selectedPeriod = 'day');
                          _loadFinancialData();
                        },
                      ),
                      const SizedBox(width: 8),
                      _PeriodChip(
                        label: 'รายสัปดาห์',
                        isSelected: _selectedPeriod == 'week',
                        onTap: () {
                          setState(() => _selectedPeriod = 'week');
                          _loadFinancialData();
                        },
                      ),
                      const SizedBox(width: 8),
                      _PeriodChip(
                        label: 'รายเดือน',
                        isSelected: _selectedPeriod == 'month',
                        onTap: () {
                          setState(() => _selectedPeriod = 'month');
                          _loadFinancialData();
                        },
                      ),
                      const SizedBox(width: 8),
                      _PeriodChip(
                        label: 'รายปี',
                        isSelected: _selectedPeriod == 'year',
                        onTap: () {
                          setState(() => _selectedPeriod = 'year');
                          _loadFinancialData();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _FinancialCard(
                        title: 'รายได้รวม',
                        value:
                            '฿${NumberFormat('#,###.00').format(totalRevenue)}',
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FinancialCard(
                        title: 'ค่าคอมมิชชั่น', // (15%)
                        value: '฿${NumberFormat('#,###.00').format(commission)}',
                        icon: Icons.account_balance,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FinancialCard(
                  title: 'ส่วนแบ่งเจ้าของร้าน',
                  value: '฿${NumberFormat('#,###.00').format(vendorShare)}',
                  icon: Icons.store,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (vendorRevenues.isNotEmpty)
              Container(
                height: 350,
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
                      'สัดส่วนรายได้แต่ละสาขา',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: _getPieSections(vendorRevenues),
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                    // TODO: Handle touch
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  vendorRevenues.entries.take(6).map((entry) {
                                final index = vendorRevenues.keys
                                    .toList()
                                    .indexOf(entry.key);
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: _getChartColor(index),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          entry.key,
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ประวัติการชำระเงิน',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Navigate to all payments screen
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('ดูทั้งหมด'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (payments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('ไม่มีประวัติการชำระเงิน'),
                      ),
                    )
                  else
                    ...payments.take(5).map((payment) {
                      return _PaymentItem(
                        vendorName: payment['vendorName'] ?? 'ไม่ระบุ',
                        amount: (payment['amount'] ?? 0).toDouble(),
                        date: payment['createdAt'],
                        status: payment['status'] ?? 'pending',
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieSections(
      Map<String, dynamic> vendorRevenues) {
    if (vendorRevenues.isEmpty) return [];

    final total =
        vendorRevenues.values.fold(0.0, (sum, value) => sum + (value ?? 0.0));
    if (total == 0.0) return [];

    return vendorRevenues.entries.take(6).map((entry) {
      final index = vendorRevenues.keys.toList().indexOf(entry.key);
      final value = (entry.value ?? 0.0).toDouble();
      final percentage = (value / total * 100);

      return PieChartSectionData(
        color: _getChartColor(index),
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getChartColor(int index) {
    final colors = [
      const Color(0xFF4B7BF5),
      const Color(0xFF00C49F),
      const Color(0xFFFFBB28),
      const Color(0xFFFF8042),
      const Color(0xFF8884D8),
      const Color(0xFF82CA9D),
    ];
    return colors[index % colors.length];
  }
}

// System Settings Screen (Tab 4)
class _SystemSettingsScreen extends StatefulWidget {
  final String adminId;
  final String apiToken;

  const _SystemSettingsScreen({
    required this.adminId,
    required this.apiToken,
  });

  @override
  State<_SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<_SystemSettingsScreen> {
  final _commissionController = TextEditingController(text: '15.0');
  bool _autoBackup = true;
  String _backupFrequency = 'daily';
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _commissionController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/settings'),
        headers: ApiConfig.authHeaders(widget.apiToken),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _commissionController.text =
              data['commissionRate']?.toString() ?? '15.0';
          _autoBackup = data['autoBackup'] ?? true;
          _backupFrequency = data['backupFrequency'] ?? 'daily';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading settings: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/admin/settings'),
        headers: ApiConfig.authHeaders(widget.apiToken),
        body: jsonEncode({
          'commissionRate': double.tryParse(_commissionController.text) ?? 15.0,
          'autoBackup': _autoBackup,
          'backupFrequency': _backupFrequency,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกการตั้งค่าแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to save settings');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _exportData() async {
    // Implement data export logic
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กำลังดำเนินการส่งออกข้อมูล...')));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadSettings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Commission Settings
            _buildSettingsCard(
              title: 'ตั้งค่าค่าคอมมิชชั่น',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _commissionController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'อัตราค่าคอมมิชชั่น (%)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: const Icon(Icons.percent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B7BF5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('บันทึก',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ค่าคอมมิชชั่นจะถูกหักจากรายได้ของเจ้าของร้านโดยอัตโนมัติ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Backup Settings
            _buildSettingsCard(
              title: 'การสำรองข้อมูลอัตโนมัติ',
              children: [
                SwitchListTile(
                  title: const Text('เปิดใช้งานการสำรองข้อมูลอัตโนมัติ'),
                  subtitle: const Text('ระบบจะสำรองข้อมูลตามความถี่ที่กำหนด'),
                  value: _autoBackup,
                  onChanged: (value) {
                    setState(() => _autoBackup = value);
                    _saveSettings();
                  },
                  activeColor: const Color(0xFF4B7BF5),
                ),
                if (_autoBackup) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'ความถี่ในการสำรองข้อมูล',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _FrequencyOption(
                        label: 'รายวัน',
                        value: 'daily',
                        groupValue: _backupFrequency,
                        onChanged: (value) {
                          setState(() => _backupFrequency = value!);
                          _saveSettings();
                        },
                      ),
                      _FrequencyOption(
                        label: 'รายสัปดาห์',
                        value: 'weekly',
                        groupValue: _backupFrequency,
                        onChanged: (value) {
                          setState(() => _backupFrequency = value!);
                          _saveSettings();
                        },
                      ),
                      _FrequencyOption(
                        label: 'รายเดือน',
                        value: 'monthly',
                        groupValue: _backupFrequency,
                        onChanged: (value) {
                          setState(() => _backupFrequency = value!);
                          _saveSettings();
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Data Management
            _buildSettingsCard(
              title: 'จัดการข้อมูล',
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload,
                      color: Color(0xFF4B7BF5)),
                  title: const Text('สำรองข้อมูลทันที'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: API Call for Manual backup
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.file_download, color: Colors.green),
                  title: const Text('ส่งออกข้อมูล'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _exportData,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Security Settings
            _buildSettingsCard(
              title: 'ความปลอดภัย',
              children: [
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.red),
                  title: const Text('เปลี่ยนรหัสผ่าน'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show change password dialog
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: const Text('ประวัติการเข้าใช้งาน'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                     // TODO: Navigate to login history screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
      {required String title, required List<Widget> children}) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// Helper Widgets
class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendUp;

  const _DashboardCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (trend != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trendUp ?? false)
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        (trendUp ?? false)
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: (trendUp ?? false) ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: TextStyle(
                          color:
                              (trendUp ?? false) ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
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
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4B7BF5) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF4B7BF5) : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _FinancialCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentItem extends StatelessWidget {
  final String vendorName;
  final double amount;
  final String? date;
  final String status;

  const _PaymentItem({
    required this.vendorName,
    required this.amount,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.payment,
              color: _getStatusColor(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '฿${NumberFormat('#,###.00').format(amount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'completed':
        return 'สำเร็จ';
      case 'pending':
        return 'รอดำเนินการ';
      case 'failed':
        return 'ล้มเหลว';
      default:
        return 'ไม่ทราบ';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yy').format(date);
    } catch (e) {
      return '-';
    }
  }
}

class _FrequencyOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _FrequencyOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(value),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFF4B7BF5),
            ),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
