import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:AMD/src/pages/machine_detail_page.dart';
import 'package:AMD/src/service/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<String> machines = []; // Change to List<String> as we are getting a list of machine names
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMachines();
  }

  /// Polling function to fetch machines periodically
  void fetchMachines() async {
    try {
      final fetchedMachines = await _apiService.fetchMachines();
      setState(() {
        machines = fetchedMachines; // Assign the fetched list of machine names
        isLoading = false;
      });
      // Poll every 10 seconds
      Future.delayed(const Duration(seconds: 10), fetchMachines);
    } catch (e) {
      debugPrint('Error fetching machines: $e');
      // Retry after delay if an error occurs
      Future.delayed(const Duration(seconds: 10), fetchMachines);
    }
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            )
          : machines.isEmpty
              ? const Center(
                  child: Text(
                    'No Machines Found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: machines.length,
                    itemBuilder: (context, index) {
                      final machineName = machines[index]; // Directly access machine name
                      return MachineCard(
                        machineName: machineName,
                        onTap: () {
                          // You can pass machineName or a relevant machineId to the details page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MachineDetailsPage(machineId: machineName), // Pass an identifier like index for now
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
  final VoidCallback onTap;

  const MachineCard({
    Key? key,
    required this.machineName,
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
                backgroundColor: Colors.teal,
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
                  ],
                ),
              ),
              // Arrow Icon for navigation
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
