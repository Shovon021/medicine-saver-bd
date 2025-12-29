import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'cabinet_service.dart';

class BackupService {
  static final BackupService instance = BackupService._();
  BackupService._();

  // Export Cabinet to JSON File and Share
  Future<void> exportCabinet() async {
    try {
      // 1. Get Data
      await CabinetService.instance.init();
      final medicines = CabinetService.instance.medicines;
      
      if (medicines.isEmpty) throw Exception("Cabinet is empty");

      // 2. Convert to JSON
      final List<Map<String, dynamic>> jsonList = medicines.map((m) => {
        'brandName': m.brandName,
        'genericName': m.genericName,
        'manufacturer': m.manufacturer,
        'strength': m.strength,
        'dosageForm': m.dosageForm,
        'price': m.price,
        'savedAt': m.savedAt.toIso8601String(),
      }).toList();

      final jsonString = jsonEncode({
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'items': jsonList
      });

      // 3. Write to Temp File
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/medicine_cabinet_backup.json');
      await file.writeAsString(jsonString);

      // 4. Share File
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Medicine Cabinet Backup',
      );
      
    } catch (e) {
      rethrow;
    }
  }

  // Import Cabinet from JSON File
  Future<int> importCabinet() async {
    try {
      // 1. Pick File
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return 0; // Canceled

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // 2. Parse Items
      final List<dynamic> items = data['items'] ?? [];
      int count = 0;

      for (var item in items) {
        await CabinetService.instance.addMedicine(
          SavedMedicine(
            brandName: item['brandName'],
            genericName: item['genericName'],
            manufacturer: item['manufacturer'],
            strength: item['strength'],
            dosageForm: item['dosageForm'],
            price: (item['price'] ?? 0).toDouble(),
          ),
        );
        count++;
      }
      
      return count;

    } catch (e) {
      throw Exception("Invalid Backup File");
    }
  }
}
