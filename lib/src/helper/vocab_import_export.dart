import 'dart:convert';
import 'dart:io';
import 'package:universal_html/html.dart' as webFile;

import 'package:csv/csv.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class VocabImportExport {
  static Future<List<dynamic>> importVocab() async {
    FilePickerResult? result;
    if (kIsWeb) {
      result = await FilePickerWeb.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["csv"],
        allowMultiple: false,
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["csv"],
        allowMultiple: false,
      );
    }
    String csvStr = "";

    if (result != null) {
      if (kIsWeb) {
        csvStr = utf8.decode(result.files.single.bytes!);
      } else {
        File file = File(result.files.single.path!);
        csvStr = await file.readAsString();
      }
    }
    List<List<dynamic>> csvList = const CsvToListConverter().convert(csvStr);

    return csvList;
  }

  static Future<bool> exportVocab(List<dynamic> vocabList, String topicName) async {
    List<List<dynamic>> csvList = vocabList.map((e) => [e["en"], e["vi"]]).toList();

    String csvStr = const ListToCsvConverter().convert(csvList);
    if (!kIsWeb) {
      String dir = (await getTemporaryDirectory()).path;
      File temp = File('$dir/$topicName.csv');
      await temp.writeAsString(csvStr);
      final result = await Share.shareXFiles([XFile('$dir/$topicName.csv')], text: 'This is my csv file for my vocabulary topics');
      temp.delete();

      if (result.status == ShareResultStatus.success) {
        return true;
      } else {
        return false;
      }
    } else {
      var blob = webFile.Blob([csvStr], 'text/plain', 'native');
      webFile.AnchorElement(
        href: webFile.Url.createObjectUrlFromBlob(blob).toString(),
      )
        ..setAttribute("download", "$topicName.csv")
        ..click();
      return true;
    }
  }
}
