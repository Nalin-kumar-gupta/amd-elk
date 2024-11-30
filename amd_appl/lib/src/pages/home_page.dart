import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:amd_appl/src/pages/machine_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> machines = [];

  @override
  void initState() {
    super.initState();
    loadMachines();
  }

  Future<void> loadMachines() async {
    final String data =
        await rootBundle.loadString('assets/Data/machines.json');
    setState(() {
      machines = json.decode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Automated Malware Detector',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Placeholder for settings action
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: machines.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: machines.length,
                itemBuilder: (context, index) {
                  final machine = machines[index];
                  return MachineCard(
                    machineName: machine['name'],
                    machineStatus: machine['status'], // e.g., "Active", "Inactive"
                    riskLevel: machine['riskLevel'], // e.g., 45%
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MachineDetailsPage(machineId: machine['id']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class MachineCard extends StatelessWidget {
  final String machineName;
  final String machineStatus;
  final int riskLevel;
  final VoidCallback onTap;

  const MachineCard({
    Key? key,
    required this.machineName,
    required this.machineStatus,
    required this.riskLevel,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Machine Icon
              CircleAvatar(
                radius: 30,
                backgroundColor: riskLevel > 70 ? Colors.red : Colors.teal,
                child: const Icon(Icons.computer, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              // Machine Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      machineName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: $machineStatus',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              // Risk Indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$riskLevel% Risk',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: riskLevel > 70 ? Colors.red : Colors.greenAccent,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
