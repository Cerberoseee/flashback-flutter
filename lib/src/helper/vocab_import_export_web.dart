import 'dart:convert';
import 'package:flutter_final/src/helper/vocab_import_export.dart';
import 'package:universal_html/html.dart' as webFile;

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker/_internal/file_picker_web.dart';

VocabImportExport getInstance() => VocabImportExportWeb();

class VocabImportExportWeb implements VocabImportExport {
  @override
  Future<List<dynamic>> importVocab() async {
    FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["csv"],
      allowMultiple: false,
    );

    String csvStr = "";

    if (result != null) {
      csvStr = utf8.decode(result.files.single.bytes!);
    }
    List<List<dynamic>> csvList = const CsvToListConverter().convert(csvStr);

    return csvList;
  }

  @override
  Future<bool> exportVocab(List<dynamic> vocabList, String topicName) async {
    List<List<dynamic>> csvList = vocabList.map((e) => [e["en"], e["vi"]]).toList();

    String csvStr = const ListToCsvConverter().convert(csvList);

    var blob = webFile.Blob([csvStr], 'text/plain', 'native');
    webFile.AnchorElement(
      href: webFile.Url.createObjectUrlFromBlob(blob).toString(),
    )
      ..setAttribute("download", "$topicName.csv")
      ..click();
    return true;
  }
}
