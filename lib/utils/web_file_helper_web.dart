import 'dart:convert';
import 'dart:html' as html;

Future<void> downloadJsonFile(String filename, String content) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

Future<String?> pickJsonFile() async {
  final input = html.FileUploadInputElement()
    ..accept = '.json,application/json'
    ..style.display = 'none';
  html.document.body?.children.add(input);

  input.click();

  await input.onChange.first;
  final files = input.files;
  if (files == null || files.isEmpty) {
    html.document.body?.children.remove(input);
    return null;
  }

  final file = files[0];
  final reader = html.FileReader();
  reader.readAsText(file);
  await reader.onLoadEnd.first;

  html.document.body?.children.remove(input);
  return reader.result as String?;
}
