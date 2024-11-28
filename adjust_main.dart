import 'dart:io';
import 'package:yaml/yaml.dart';

void main() async {
  // Load pubspec.yaml
  File pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('pubspec.yaml not found!');
    return;
  }

  String pubspecContent = pubspecFile.readAsStringSync();
  var doc = loadYaml(pubspecContent);

  // Check if the app name exists and adjust main.dart accordingly
  String? appName = doc['name'];
  if (appName != null) {
    // Path to the main.dart file
    File mainFile = File('lib/main.dart');
    if (mainFile.existsSync()) {
      String mainContent = mainFile.readAsStringSync();

      // Replace the app name in main.dart (customize this if needed)
      mainContent = mainContent.replaceAll('MyApp', appName);

      // Save the modified content
      mainFile.writeAsStringSync(mainContent);
      print('App name adjusted in main.dart to: $appName');
    } else {
      print('main.dart not found!');
    }
  } else {
    print('App name not found in pubspec.yaml!');
  }

  // Check if additional dependencies need to be added to the project
  var dependencies = doc['dependencies'];
  if (dependencies != null) {
    for (var dep in dependencies.keys) {
      print('Dependency found: $dep');
      // You can handle specific dependencies here (e.g., adding to main.dart or showing messages)
    }
  } else {
    print('No dependencies found in pubspec.yaml!');
  }
}
