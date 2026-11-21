import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const BaggageCalculatorApp());
}

// The main application.
class BaggageCalculatorApp extends StatelessWidget {
  const BaggageCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baggage Fee Calculator',

      theme: ThemeData(
        useMaterial3: true,

        // Main purple theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7),
        ),

        // Light purple background
        scaffoldBackgroundColor: const Color(0xFFF7F2FC),

        // Application title bar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF673AB7),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      home: const MainPage(),
    );
  }
}

// Holds the Home and About pages.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedPage = 0;

  final List<Widget> pages = const [
    HomePage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedPage == 0 ? 'Baggage Fee Calculator' : 'About',
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF3949AB)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.flight_takeoff, color: Colors.white, size: 42),
                  SizedBox(height: 10),
                  Text(
                    'Baggage Fee Calculator',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: selectedPage == 0,
              onTap: () {
                setState(() => selectedPage = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              selected: selectedPage == 1,
              onTap: () {
                setState(() => selectedPage = 1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: pages[selectedPage],
    );
  }
}

// Home page: accepts baggage details and calculates the fee.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  String selectedClass = 'Economy';

  double? excessWeight;
  double? excessCharge;
  double? totalPayable;

  @override
  void dispose() {
    weightController.dispose();
    rateController.dispose();
    super.dispose();
  }

  void calculateFee() {
    // Read the text and convert it into numbers.
    final double? baggageWeight = double.tryParse(weightController.text);
    final double? rate = double.tryParse(rateController.text);

    // Check whether the user entered valid values.
    if (baggageWeight == null || rate == null ||
        baggageWeight < 0 || rate < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers (zero or above).'),
        ),
      );
      return;
    }

    if (baggageWeight>100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum baggage weight is 100kg!')),
      );
      return;
    }

    // Economy allows 20 kg. Business allows 40 kg.
    final double allowance = selectedClass == 'Economy' ? 20 : 40;

    // Excess baggage cannot be a negative number.
    final double excess = (baggageWeight - allowance)
        .clamp(0.0, double.infinity)
        .toDouble();

    // Calculate the fee and add the 8% service tax.
    final double charge = excess * rate;
    final double total = charge + (charge * 0.08);

    // Update the screen with the calculation results.
    setState(() {
      excessWeight = excess;
      excessCharge = charge;
      totalPayable = total;
    });
  }

  void clearForm() {
    weightController.clear();
    rateController.clear();

    setState(() {
      selectedClass = 'Economy';
      excessWeight = null;
      excessCharge = null;
      totalPayable = null;
    });
  }

  Widget resultRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3949AB)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          const Icon(
            Icons.flight_takeoff,
            size: 55,
            color: Color(0xFF673AB7),
          ),

          const SizedBox(height: 8),
          const Text(
            'Calculate Your Excess Baggage Fee',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your baggage details below.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 22),

          // Input 1: baggage weight.
          TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Baggage weight (kg)',
              hintText: 'Example: 25',
              prefixIcon: Icon(Icons.scale),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 15),

          // Input 2: ticket class.
          DropdownButtonFormField<String>(
            initialValue: selectedClass,
            decoration: const InputDecoration(
              labelText: 'Ticket class',
              prefixIcon: Icon(Icons.airline_seat_recline_extra),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: const [
              DropdownMenuItem(value: 'Economy', child: Text('Economy (20 kg)')),
              DropdownMenuItem(value: 'Business', child: Text('Business (40 kg)')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedClass = value);
              }
            },
          ),
          const SizedBox(height: 15),

          // Input 3: excess baggage rate.
          TextField(
            controller: rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Excess baggage rate (RM per kg)',
              hintText: 'Example: 15',
              prefixIcon: Icon(Icons.payments_outlined),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Calculate and Reset buttons.
          ElevatedButton.icon(
            onPressed: calculateFee,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Fee'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3949AB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
          const SizedBox(height: 9),
          OutlinedButton.icon(
            onPressed: clearForm,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
          const SizedBox(height: 20),

          // Show the results only after the Calculate button is pressed.
          if (totalPayable != null)
            Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calculation Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    resultRow(
                      'Excess baggage weight',
                      '${excessWeight!.toStringAsFixed(2)} kg',
                      Icons.luggage,
                    ),
                    resultRow(
                      'Excess baggage charge',
                      'RM ${excessCharge!.toStringAsFixed(2)}',
                      Icons.receipt_long,
                    ),
                    resultRow(
                      'Service tax (8%)',
                      'RM ${(excessCharge! * 0.08).toStringAsFixed(2)}',
                      Icons.percent,
                    ),
                    const Divider(),
                    resultRow(
                      'Total amount payable',
                      'RM ${totalPayable!.toStringAsFixed(2)}',
                      Icons.account_balance_wallet,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Economy: 20 kg allowance  •  Business: 40 kg allowance',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// About page: edit the author details and GitHub link before presenting.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // TODO: Replace these three values with your own information.
  static const String authorName = 'LUQMAN HAQIM BIN TUBARI';
  static const String matricNumber = '2025235888';
  static const String course = 'CS2515B';

  // TODO: Replace this with your actual GitHub repository URL.
  static const String githubUrl = 'https://github.com/Man21-hub/MobileAssignment.git';

  Future<void> openGithub() async {
    final Uri url = Uri.parse(githubUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SizedBox(height: 25),

          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFF673AB7),
            child: Icon(
              Icons.flight_takeoff,
              size: 55,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Baggage Fee Calculator',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'A simple application to estimate excess baggage fees for air travel.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Author Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Text('Name: $authorName'),
                  const SizedBox(height: 10),
                  Text('Matric No: $matricNumber'),
                  const SizedBox(height: 10),
                  Text('Course: $course'),
                  const SizedBox(height: 18),
                  const Text(
                    'GitHub Repository',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: openGithub,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open GitHub Repository'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '© 2026 Baggage Fee Calculator. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
