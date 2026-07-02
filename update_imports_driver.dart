import 'dart:io';

void main() {
  final dir = Directory('lib');
  
  final Map<String, String> replacements = {
    // Dashboard
    'features/driver/presentation/screens/driver_main_wrapper.dart': 'features/driver/dashboard/presentation/screens/driver_main_wrapper.dart',
    'features/driver/presentation/widgets/driver_drawer.dart': 'features/driver/dashboard/presentation/widgets/driver_drawer.dart',

    // Home
    'features/driver/presentation/screens/driver_home_screen.dart': 'features/driver/home/presentation/screens/driver_home_screen.dart',
    'features/driver/logic/driver_home_cubit': 'features/driver/home/logic/driver_home_cubit',
    'features/driver/presentation/widgets/active_trip_card.dart': 'features/driver/home/presentation/widgets/active_trip_card.dart',
    'features/driver/presentation/widgets/daily_stats_row.dart': 'features/driver/home/presentation/widgets/daily_stats_row.dart',
    'features/driver/presentation/widgets/online_status_card.dart': 'features/driver/home/presentation/widgets/online_status_card.dart',
    'features/driver/presentation/widgets/welcome_guide_card.dart': 'features/driver/home/presentation/widgets/welcome_guide_card.dart',

    // Vehicles
    'features/driver/presentation/screens/driver_primary_vehicle_screen.dart': 'features/driver/vehicles/presentation/screens/driver_primary_vehicle_screen.dart',
    'features/driver/presentation/screens/driver_backup_vehicle_screen.dart': 'features/driver/vehicles/presentation/screens/driver_backup_vehicle_screen.dart',
    'features/driver/presentation/widgets/editable_vehicle_field.dart': 'features/driver/vehicles/presentation/widgets/editable_vehicle_field.dart',

    // Profile
    'features/driver/data/models/driver_model.dart': 'features/driver/profile/data/models/driver_model.dart',
    'features/driver/presentation/screens/driver_profile_screen.dart': 'features/driver/profile/presentation/screens/driver_profile_screen.dart',

    // Requests
    'features/driver/presentation/widgets/new_requests_section.dart': 'features/driver/requests/presentation/widgets/new_requests_section.dart',

    // Work Areas
    'features/driver/presentation/widgets/work_areas_card.dart': 'features/driver/work_areas/presentation/widgets/work_areas_card.dart',

    // Documents
    'features/driver/presentation/widgets/vehicle_document_status.dart': 'features/driver/documents/presentation/widgets/vehicle_document_status.dart',
  };

  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      var newContent = content;

      // 1. Update absolute imports first
      replacements.forEach((oldPath, newPath) {
        newContent = newContent.replaceAll('package:kids_transport/$oldPath', 'package:kids_transport/$newPath');
      });

      // 2. Relative imports inside the driver feature
      if (entity.path.replaceAll('\\', '/').contains('lib/features/driver/')) {
         final relativeImportRegex = RegExp(r"""import\s+['"]((?:\.\./)+)(.*?)['"]\s*;""");
         
         String getAbsolutePath(String currentFilePath, String relativeImportPath) {
            final normalizedCurrent = currentFilePath.replaceAll('\\', '/');
            final parts = normalizedCurrent.split('/');
            // Remove filename
            parts.removeLast();
            
            final importParts = relativeImportPath.split('/');
            for (var p in importParts) {
               if (p == '..') {
                  if (parts.isNotEmpty) parts.removeLast();
               } else if (p != '.') {
                  parts.add(p);
               }
            }
            
            // Reconstruct path inside lib to make it absolute package:
            final idx = parts.indexOf('lib');
            if (idx != -1) {
               final packagePath = parts.sublist(idx + 1).join('/');
               return 'package:kids_transport/$packagePath';
            }
            return relativeImportPath; // fallback
         }

         newContent = newContent.replaceAllMapped(relativeImportRegex, (match) {
            final relativePath = match.group(1)! + match.group(2)!;
            final absPath = getAbsolutePath(entity.path, relativePath);
            return "import '$absPath';";
         });

         // Also replace again the absolute imports if we just converted them to old absolute paths!
         replacements.forEach((oldPath, newPath) {
           newContent = newContent.replaceAll('package:kids_transport/$oldPath', 'package:kids_transport/$newPath');
         });
      }

      if (content != newContent) {
        entity.writeAsStringSync(newContent);
        print('Updated imports in ${entity.path}');
      }
    }
  }
}
