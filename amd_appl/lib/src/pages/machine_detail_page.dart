import 'package:flutter/material.dart';
import 'package:amd_appl/src/service/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class MachineDetailsPage extends StatefulWidget {
  final String machineId;

  const MachineDetailsPage({Key? key, required this.machineId}) : super(key: key);

  @override
  _MachineDetailsPageState createState() => _MachineDetailsPageState();
}

class _MachineDetailsPageState extends State<MachineDetailsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> logs = [];
  bool isLoading = false;
  Timer? pollingTimer;

  @override
  void initState() {
    super.initState();
    fetchLogs(); // Initial fetch
    startPolling(); // Start polling every 2 seconds
  }

  @override
  void dispose() {
    pollingTimer?.cancel(); // Stop polling when the widget is disposed
    super.dispose();
  }

  void startPolling() {
    pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
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
        logs = newLogs; // Update the logs list
      });
    } catch (e) {
      debugPrint('Error fetching logs: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Machine ${widget.machineId} Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.security,
                      color: Color(0xFF00FF00),
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Machine ${widget.machineId}',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monitoring in progress...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Logs Section
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Activity Logs',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00FF00),
                          ),
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      Expanded(
                        child: logs.isEmpty
                            ? Center(
                                child: Text(
                                  'No logs available.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: logs.length,
                                itemBuilder: (context, index) {
                                  final log = logs[index];
                                  return ExpansionTile(
                                    collapsedBackgroundColor:
                                        const Color(0xFF1A1A1A),
                                    backgroundColor: const Color(0xFF1A1A1A),
                                    title: Text(
                                      'Log Entry: ${log['process_name'] ?? 'Unknown'}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Risk Level: ${log['risk_level'] ?? 'N/A'} - ${log['timestamp'] ?? ''}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    children: [
                                      ListTile(
                                        title: Text(
                                          'User: ${log['user'] ?? 'N/A'}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Command Line: ${log['command_line'] ?? 'N/A'}\nDescription: ${log['description'] ?? 'N/A'}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
