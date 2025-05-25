import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:AMD/src/service/api_service.dart';

class MachineDetailsPage extends StatefulWidget {
  final String machineId;

  const MachineDetailsPage({Key? key, required this.machineId}) : super(key: key);

  @override
  _MachineDetailsPageState createState() => _MachineDetailsPageState();
}

class _MachineDetailsPageState extends State<MachineDetailsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> logs = [];
  Map<String, int> riskLevelCount = {"Low": 0, "Medium": 0, "High": 0};
  bool isLoading = false;
  Timer? pollingTimer;

  @override
  void initState() {
    super.initState();
    fetchLogs();
    startPolling();
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    super.dispose();
  }

  void startPolling() {
    pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchLogs(isPolling: true);
    });
  }

  Future<void> fetchLogs({bool isPolling = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final newLogs = await _apiService.fetchLogs(widget.machineId);
      setState(() {
        logs = newLogs;
        updateRiskLevelCount();
      });
    } catch (e) {
      debugPrint('Error fetching logs: \$e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateRiskLevelCount() {
    riskLevelCount = {"Low": 0, "Medium": 0, "High": 0};
    for (var log in logs) {
      final riskLevel = log['risk_level'] ?? 'Low';
      if (riskLevelCount.containsKey(riskLevel)) {
        riskLevelCount[riskLevel] = riskLevelCount[riskLevel]! + 1;
      }
    }
  }

  void showLogDetails(dynamic log) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: log.entries.map<Widget>((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${entry.key}: ",
                        style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text("${entry.value}", style: const TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<FlSpot> _generateRiskTrendData() {
    List<FlSpot> data = [];
    final sorted = List.from(logs)..sort((a, b) => (a['timestamp'] ?? '').compareTo(b['timestamp'] ?? ''));
    for (int i = 0; i < sorted.length; i++) {
      double y = 0;
      switch (sorted[i]['risk_level']) {
        case 'Low':
          y = 1;
          break;
        case 'Medium':
          y = 2;
          break;
        case 'High':
          y = 3;
          break;
      }
      data.add(FlSpot(i.toDouble(), y));
    }
    return data;
  }

  List<PieChartSectionData> _buildPieChartData() {
    return [
      PieChartSectionData(value: riskLevelCount['Low']!.toDouble(), color: Colors.green, title: 'Low'),
      PieChartSectionData(value: riskLevelCount['Medium']!.toDouble(), color: Colors.orange, title: 'Medium'),
      PieChartSectionData(value: riskLevelCount['High']!.toDouble(), color: Colors.red, title: 'High'),
    ];
  }

  List<Widget> _buildSummaryInsights() {
    final Map<String, int> processCount = {};
    final Map<String, int> userCount = {};
    for (var log in logs) {
      final proc = log['process_name'] ?? 'Unknown';
      final user = log['user'] ?? 'Unknown';
      processCount[proc] = (processCount[proc] ?? 0) + 1;
      userCount[user] = (userCount[user] ?? 0) + 1;
    }

    String mostCommonProcess = processCount.entries.fold('', (p, e) => e.value > (processCount[p] ?? 0) ? e.key : p);
    String topUser = userCount.entries.fold('', (p, e) => e.value > (userCount[p] ?? 0) ? e.key : p);

    return [
      Text("High Risk Logs: ${riskLevelCount["High"]}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      Text("Most Frequent Process: \$mostCommonProcess", style: const TextStyle(color: Colors.white)),
      Text("Top User: \$topUser", style: const TextStyle(color: Colors.white)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(146, 84, 81, 81),
      appBar: AppBar(
        title: Text('Machine ${widget.machineId} Details',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              title: "Summary Insights",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildSummaryInsights(),
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: "Risk Trend Over Time",
              child: SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 4,
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 1:
                                return const Text('Low', style: TextStyle(color: Colors.white, fontSize: 10));
                              case 2:
                                return const Text('Medium', style: TextStyle(color: Colors.white, fontSize: 10));
                              case 3:
                                return const Text('High', style: TextStyle(color: Colors.white, fontSize: 10));
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generateRiskTrendData(),
                        isCurved: true,
                        color: Colors.orangeAccent,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: "Risk Level Distribution",
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartData(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: "Activity Logs",
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[850]!),
                  columns: const [
                    DataColumn(label: Text("Time", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("User", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("Process", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("Risk", style: TextStyle(color: Colors.white))),
                  ],
                  rows: logs.map((log) {
                    Color bgColor;
                    switch (log['risk_level']) {
                      case 'High':
                        bgColor = Colors.red[900]!;
                        break;
                      case 'Medium':
                        bgColor = Colors.orange[800]!;
                        break;
                      default:
                        bgColor = Colors.green[700]!;
                    }
                    return DataRow(
                      color: MaterialStateColor.resolveWith((states) => bgColor),
                      cells: [
                        DataCell(Text(log['timestamp'] ?? 'N/A', style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis)),
                        DataCell(Text(log['user'] ?? 'N/A', style: const TextStyle(color: Colors.white))),
                        DataCell(Text(log['process_name'] ?? 'N/A', style: const TextStyle(color: Colors.white))),
                        DataCell(Text(log['risk_level'] ?? 'N/A', style: const TextStyle(color: Colors.white))),
                      ],
                      onSelectChanged: (_) => showLogDetails(log),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: "Pinned Alerts",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: logs.where((log) => log['risk_level'] == 'High').take(5).map((log) {
                  return Text("⚠️ ${log['process_name']} - ${log['description']}",
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF00FF00))),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}