// ignore_for_file: avoid_print

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import '../common/index.dart';
import 'conf_skeleton.dart';

final List<String> flutterCommands = ['run', 'release', 'profile'];
final List<String> makefileCommands = [
  'gen_env',
  'sync',
  'dart_code_metrics',
  'update_app_icon',
  'update_splash',
  'remove_splash'
];

class AndroidStudioEnvGenerator {
  final Map<FlavorsEnum, Map<String, String>> allDartDefinesByEnv;

  AndroidStudioEnvGenerator({
    required this.allDartDefinesByEnv,
  });

  void call() {
    try {
      final settingsFile = File(workspaceXmlPath);
      if (!settingsFile.existsSync()) {
        settingsFile.createSync(recursive: true);
        settingsFile.writeAsStringSync(workspaceSkeleton);
      }
      ConfigXmlWriter(
        filePath: workspaceXmlPath,
        allDartDefinesByEnv: allDartDefinesByEnv,
      ).call();
    } on XmlException catch (e) {
      print(
          'Error: Failed to parse $workspaceXmlPath. It is not a valid XML file.\n$e');
    } on FormatException catch (e) {
      print(
          'Error: The content of $workspaceXmlPath has an invalid structure.\n$e');
    } on FileSystemException catch (e) {
      print('Error: $workspaceXmlPath does not exist!\n$e');
    }
  }
}

class ConfigXmlWriter {
  final String filePath;
  final Map<FlavorsEnum, Map<String, String>> allDartDefinesByEnv;

  ConfigXmlWriter({
    required this.filePath,
    required this.allDartDefinesByEnv,
  });

  void call() {
    final mandatoryFile = File(filePath);
    mandatoryFile
        .writeAsStringSync(_writeConfig(mandatoryFile.readAsStringSync()));
  }

  String _writeConfig(String fileContent) {
    final XmlDocument document = XmlDocument.parse(fileContent);
    _validateConfFile(document);
    final runConfRootElement = _findRunManagerComponent(document);

    if (runConfRootElement == null) {
      throw StateError(
          'Could not find or create <component name="RunManager">. This should not happen.');
    }

    flutterCommands.forEach((String command) {
      flavorsList.forEach((element) {
        _addOrReplaceConf(
            runConfRootElement,
            _createRunConf(
                config: command,
                flavor: element.name,
                dartDefines: allDartDefinesByEnv[element.flavorEnum]));
      });
    });

    makefileCommands.forEach((String command) {
      _addOrReplaceConf(runConfRootElement, _createMakeConf(target: command));
    });

    return document.toXmlString(pretty: true, indent: '\t');
  }

  XmlElement? _findRunManagerComponent(XmlDocument document) {
    return document.findAllElements('component').firstWhereOrNull(
        (element) => element.getAttribute('name') == 'RunManager');
  }

  void _validateConfFile(XmlDocument document) {
    if (_findRunManagerComponent(document) == null) {
      final projectRootElements = document.findAllElements('project');
      if (projectRootElements.isEmpty) {
        throw FormatException(
            'Could not find <project> element in $workspaceXmlPath');
      }
      final XmlNode runManagerElement =
          _createElementFromSkeleton(runManagerSkeleton);
      projectRootElements.first.children.add(runManagerElement);
    }
  }

  XmlNode _createRunConf(
      {required String config,
      required String flavor,
      Map<String, String>? dartDefines}) {
    final XmlNode newRunConfElement =
        _createElementFromSkeleton(runConfigSkeletonXml);
    newRunConfElement.setAttribute('name', '$config $flavor');
    final buildFlavorElement = newRunConfElement.childElements
        .firstWhere((element) => element.getAttribute('name') == 'buildFlavor');
    buildFlavorElement.setAttribute('value', flavor);
    final dartDefinesElement = newRunConfElement.childElements.firstWhere(
        (element) => element.getAttribute('name') == 'additionalArgs');
    dartDefinesElement.setAttribute(
        'value',
        _getAdditionalArgs(
            command: config, flavor: flavor, dartDefines: dartDefines));
    return newRunConfElement;
  }

  XmlNode _createMakeConf({required String target}) {
    final XmlNode newMakeConfElement =
        _createElementFromSkeleton(makeConfigSkeletonXml);
    newMakeConfElement.setAttribute('name', 'make $target');
    final targetElement = newMakeConfElement.findAllElements('makefile').first;
    targetElement.setAttribute('target', target);
    return newMakeConfElement;
  }

  XmlNode _createElementFromSkeleton(String skeleton) {
    try {
      final XmlNode? element = XmlDocument.parse(skeleton).firstChild?.copy();
      if (element == null) {
        throw FormatException(
            'Failed to create element from skeleton because it parsed to null: $skeleton');
      }
      return element;
    } on XmlException catch (e) {
      throw FormatException(
          'Failed to parse skeleton XML: $e\nSkeleton: $skeleton');
    }
  }

  String _getAdditionalArgs({
    required String flavor,
    String? command,
    Map<String, String>? dartDefines,
  }) {
    final StringBuffer buffer = StringBuffer();
    if (command != null && !command.contains('run')) {
      buffer.write('--$command ');
    }
    buffer.write('--flavor $flavor ');
    buffer.write(convertEnvToDartDefineString(dartDefines));
    return buffer.toString();
  }

  void _addOrReplaceConf(XmlElement rootElement, XmlNode newConf) {
    final XmlNode? existingElement = rootElement.children.firstWhereOrNull(
        (element) =>
            element.getAttribute('name') == newConf.getAttribute('name'));
    if (existingElement != null) {
      rootElement.children.remove(existingElement);
    }
    rootElement.children.add(newConf);
  }
}
