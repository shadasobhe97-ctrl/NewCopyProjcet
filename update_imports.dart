import 'dart:io';

void main() {
  final dir = Directory('lib');
  
  final Map<String, String> replacements = {
    // Dashboard
    'features/parent/presentation/screens/parent_main_wrapper.dart': 'features/parent/dashboard/presentation/screens/parent_main_wrapper.dart',
    'features/parent/presentation/widgets/parent_drawer.dart': 'features/parent/dashboard/presentation/widgets/parent_drawer.dart',

    // Home
    'features/parent/presentation/screens/parent_home_screen.dart': 'features/parent/home/presentation/screens/parent_home_screen.dart',
    'features/parent/logic/home_cubit': 'features/parent/home/logic/home_cubit',

    // Children
    'features/parent/presentation/screens/my_children_screen.dart': 'features/parent/children/presentation/screens/my_children_screen.dart',
    'features/parent/presentation/screens/add_child_screen.dart': 'features/parent/children/presentation/screens/add_child_screen.dart',
    'features/parent/presentation/screens/child_detail_screen.dart': 'features/parent/children/presentation/screens/child_detail_screen.dart',
    'features/parent/data/models/child_model.dart': 'features/parent/children/data/models/child_model.dart',
    'features/parent/logic/child_cubit': 'features/parent/children/logic/child_cubit',
    'features/parent/presentation/widgets/child_card.dart': 'features/parent/children/presentation/widgets/child_card.dart',
    'features/parent/presentation/widgets/child_detail_header.dart': 'features/parent/children/presentation/widgets/child_detail_header.dart',
    'features/parent/presentation/widgets/child_photo_uploader.dart': 'features/parent/children/presentation/widgets/child_photo_uploader.dart',
    'features/parent/presentation/widgets/gender_selector.dart': 'features/parent/children/presentation/widgets/gender_selector.dart',
    'features/parent/presentation/widgets/time_picker_card.dart': 'features/parent/children/presentation/widgets/time_picker_card.dart',
    'features/parent/presentation/widgets/time_slot_selector.dart': 'features/parent/children/presentation/widgets/time_slot_selector.dart',

    // Search
    'features/parent/presentation/screens/parent_search_screen.dart': 'features/parent/search/presentation/screens/parent_search_screen.dart',
    'features/parent/presentation/screens/driver_profile_view.dart': 'features/parent/search/presentation/screens/driver_profile_view.dart',
    'features/parent/data/models/driver_search_model.dart': 'features/parent/search/data/models/driver_search_model.dart',
    'features/parent/presentation/widgets/custom_search_dropdown.dart': 'features/parent/search/presentation/widgets/custom_search_dropdown.dart',

    // Profile
    'features/parent/presentation/screens/parent_profile_screen.dart': 'features/parent/profile/presentation/screens/parent_profile_screen.dart',
    'features/parent/presentation/widgets/profile_email_field.dart': 'features/parent/profile/presentation/widgets/profile_email_field.dart',
    'features/parent/presentation/widgets/profile_avatar_editor.dart': 'features/parent/profile/presentation/widgets/profile_avatar_editor.dart',

    // Addresses
    'features/parent/presentation/screens/saved_addresses_screen.dart': 'features/parent/addresses/presentation/screens/saved_addresses_screen.dart',
    'features/parent/data/models/address_model.dart': 'features/parent/addresses/data/models/address_model.dart',
    'features/parent/logic/address_cubit': 'features/parent/addresses/logic/address_cubit',
    'features/parent/presentation/widgets/address_card.dart': 'features/parent/addresses/presentation/widgets/address_card.dart',
    'features/parent/presentation/widgets/add_address_sheet.dart': 'features/parent/addresses/presentation/widgets/add_address_sheet.dart',

    // Shared
    'features/parent/data/repositories/parent_repository.dart': 'features/parent/shared/data/repositories/parent_repository.dart',
    'features/parent/presentation/widgets/info_card.dart': 'features/parent/shared/presentation/widgets/info_card.dart',
    'features/parent/presentation/widgets/state_widgets': 'features/parent/shared/presentation/widgets/state_widgets',
  };

  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      var newContent = content;

      // 1. Update absolute imports first
      replacements.forEach((oldPath, newPath) {
        newContent = newContent.replaceAll('package:kids_transport/$oldPath', 'package:kids_transport/$newPath');
      });

      // 2. Relative imports inside the parent feature
      // Since relative paths can be like '../../data/models/child_model.dart' or '../../../presentation/widgets/child_card.dart'
      // It's tricky with basic string replacement. 
      // The safest way is to change all relative imports matching `../` inside the `parent` directory into absolute imports!
      if (entity.path.replaceAll('\\', '/').contains('lib/features/parent/')) {
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
