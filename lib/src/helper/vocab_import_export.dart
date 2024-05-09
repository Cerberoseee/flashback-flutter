import 'vocab_ie_stub.dart' 
  if (dart.library.js) 'vocab_import_export_web.dart' 
  if (dart.library.io) 'vocab_import_export_mobile.dart';

abstract class VocabImportExport {
  static VocabImportExport? _instance;

  static VocabImportExport? get instance {
    _instance = getInstance();
    return _instance;
  }

  Future<List<dynamic>> importVocab();
  Future<bool> exportVocab(List<dynamic> vocabList, String topicName);
}
