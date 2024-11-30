import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading assets
import 'package:google_fonts/google_fonts.dart';

class MachineDetailsPage extends StatefulWidget {
  final int machineId;

  const MachineDetailsPage({Key? key, required this.machineId}) : super(key: key);

  @override
  _MachineDetailsPageState createState() => _MachineDetailsPageState();
}

class _MachineDetailsPageState extends State<MachineDetailsPage> {
  List<dynamic> logs = []; // To store logs fetched from assets

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  // Function to load logs from the assets folder
  Future<void> loadLogs() async {
    // Load the JSON file from assets
    final String response = await rootBundle.loadString('assets/Data/logs.json');
    final data = json.decode(response);

    setState(() {
      logs = data;
    });
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
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Icon(
                      Icons.security,
                      color: const Color(0xFF00FF00),
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
                            fontWeight: FontWeight.w400,
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
                        child: ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF00FF00),
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.black,
                                ),
                              ),
                              title: Text(
                                'Log Entry #${log['log_id']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                'Risk: ${log['risk']}% - Time: ${log['time']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[400],
                                ),
                              ),
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
