import 'dart:io';

void main(List<String> args) {
  stdout.writeln('======================================================');
  stdout.writeln('🌱 Graft IDE Snippets Installer');
  stdout.writeln('======================================================');

  final currentDir = Directory.current.path;
  final vscodeDir = Directory('$currentDir/.vscode');
  if (!vscodeDir.existsSync()) {
    vscodeDir.createSync(recursive: true);
  }

  // 1. Install VS Code / Cursor snippets
  final vscodeTarget = File('${vscodeDir.path}/graft.code-snippets');
  final bundledVsCodeSnippets = _findSnippetFile('graft.code-snippets');

  if (bundledVsCodeSnippets != null && bundledVsCodeSnippets.existsSync()) {
    bundledVsCodeSnippets.copySync(vscodeTarget.path);
    stdout.writeln('✅ Installed VS Code & Cursor snippets:');
    stdout.writeln('   👉 ${vscodeTarget.path}');
  } else {
    stdout.writeln('⚠️  Could not locate bundled graft.code-snippets file.');
  }

  // 2. Install Android Studio / IntelliJ Live Templates
  final bundledJetBrainsTemplates = _findSnippetFile('graft_live_templates.xml');
  if (bundledJetBrainsTemplates != null &&
      bundledJetBrainsTemplates.existsSync()) {
    final installedJetBrainsPaths =
        _installJetBrainsTemplates(bundledJetBrainsTemplates);
    if (installedJetBrainsPaths.isNotEmpty) {
      stdout.writeln(
          '✅ Installed Android Studio / IntelliJ Live Templates into:');
      for (final p in installedJetBrainsPaths) {
        stdout.writeln('   👉 $p');
      }
    } else {
      stdout.writeln(
          'ℹ️  No active Android Studio or IntelliJ templates folder auto-detected.');
      stdout.writeln(
          '   You can manually import: ${bundledJetBrainsTemplates.path}');
    }
  }

  stdout.writeln('\n🎉 Available Snippets / Live Templates:');
  stdout.writeln('   - graft-controller : Scaffold Graft + GraftState pair');
  stdout.writeln('   - graft-value      : Scaffold lightweight ValueGraft');
  stdout.writeln('   - graft-slot       : Single-child isolated slot');
  stdout.writeln('   - graft-slots      : Multi-child isolated layout slot');
  stdout.writeln('   - graft-builder    : Zero-rebuild collection builder');
  stdout.writeln('   - graft-compute    : Pre-flight computed slot');
  stdout.writeln('   - graft-test       : Declarative unit test template');
  stdout.writeln('======================================================\n');
}

File? _findSnippetFile(String fileName) {
  final candidatePaths = [
    'tool/snippets/$fileName',
    '${Platform.script.resolve('../tool/snippets/$fileName').toFilePath()}',
    '${Directory.current.path}/tool/snippets/$fileName',
  ];

  for (final path in candidatePaths) {
    final file = File(path);
    if (file.existsSync()) {
      return file;
    }
  }
  return null;
}

List<String> _installJetBrainsTemplates(File templateFile) {
  final installed = <String>[];
  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (home == null) return installed;

  final searchRoots = <Directory>[];

  if (Platform.isMacOS) {
    searchRoots.add(Directory('$home/Library/Application Support/Google'));
    searchRoots.add(Directory('$home/Library/Application Support/JetBrains'));
  } else if (Platform.isLinux) {
    searchRoots.add(Directory('$home/.config/Google'));
    searchRoots.add(Directory('$home/.config/JetBrains'));
  } else if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    if (appData != null) {
      searchRoots.add(Directory('$appData/Google'));
      searchRoots.add(Directory('$appData/JetBrains'));
    }
  }

  for (final root in searchRoots) {
    if (!root.existsSync()) continue;
    try {
      final entities = root.listSync();
      for (final entity in entities) {
        if (entity is Directory) {
          final dirName = entity.uri.pathSegments
              .where((s) => s.isNotEmpty)
              .last
              .toLowerCase();
          if (dirName.contains('androidstudio') || dirName.contains('idea')) {
            final templatesDir = Directory('${entity.path}/templates');
            if (!templatesDir.existsSync()) {
              templatesDir.createSync(recursive: true);
            }
            final target = File('${templatesDir.path}/graft.xml');
            templateFile.copySync(target.path);
            installed.add(target.path);
          }
        }
      }
    } catch (_) {}
  }

  return installed;
}
