import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'vocab_import_export.dart';

VocabImportExport getInstance() => VocabImportExportMobile();

class VocabImportExportMobile implements VocabImportExport {
  @override
  Future<List<dynamic>> importVocab() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["csv"],
      allowMultiple: false,
    );
    String csvStr = "";

    if (result != null) {
      File file = File(result.files.single.path!);
      csvStr = await file.readAsString();
    }
    List<List<dynamic>> csvList = const CsvToListConverter().convert(csvStr);

    return csvList;
  }

  @override
  Future<bool> exportVocab(List<dynamic> vocabList, String topicName) async {
    List<List<dynamic>> csvList = vocabList.map((e) => [e["en"], e["vi"]]).toList();

    String csvStr = const ListToCsvConverter().convert(csvList);
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
  }
}
