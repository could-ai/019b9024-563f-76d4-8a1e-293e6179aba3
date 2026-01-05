import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pico Launchpad Config',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LaunchpadScreen(),
      },
    );
  }
}

class LaunchpadScreen extends StatefulWidget {
  const LaunchpadScreen({super.key});

  @override
  State<LaunchpadScreen> createState() => _LaunchpadScreenState();
}

class _LaunchpadScreenState extends State<LaunchpadScreen> {
  // Stores the name of the file assigned to each of the 10 buttons
  final List<String?> _assignedSounds = List.filled(10, null);
  bool _isUploading = false;

  Future<void> _pickSound(int index) async {
    try {
      // Using FileType.custom with specific extensions is often more reliable 
      // across different platforms and browsers than FileType.audio
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a', 'aac', 'flac', 'mid', 'midi'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _assignedSounds[index] = result.files.single.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _uploadToPico() async {
    // Check if any sounds are assigned
    if (_assignedSounds.every((sound) => sound == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign at least one sound before uploading.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Simulate upload process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isUploading = false;
      });
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upload Complete'),
          content: const Text('Sound configuration has been uploaded to the Pico Launchpad.'),
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pico Launchpad Setup'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Tap a button to assign a sound file',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // 2 columns x 5 rows = 10 buttons (5x2 grid)
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                final soundName = _assignedSounds[index];
                final isAssigned = soundName != null;
                
                return Material(
                  color: isAssigned 
                      ? Theme.of(context).colorScheme.primaryContainer 
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  elevation: isAssigned ? 2 : 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _pickSound(index),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isAssigned 
                              ? Theme.of(context).colorScheme.primary 
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAssigned ? Icons.audio_file : Icons.add_circle_outline,
                            color: isAssigned 
                                ? Theme.of(context).colorScheme.primary 
                                : Colors.grey.shade600,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              isAssigned ? soundName! : 'Button ${index + 1}',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isAssigned 
                                    ? Theme.of(context).colorScheme.onPrimaryContainer 
                                    : Colors.grey.shade700,
                                fontWeight: isAssigned ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadToPico,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isUploading 
                    ? Container(
                        width: 24, 
                        height: 24, 
                        padding: const EdgeInsets.all(2),
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary, 
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  _isUploading ? 'UPLOADING...' : 'UPLOAD TO PICO',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
