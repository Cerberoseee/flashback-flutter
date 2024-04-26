import 'package:flutter/material.dart';
import 'package:flutter_final/src/enums.dart';
import 'package:google_fonts/google_fonts.dart';

class TestSetupView extends StatefulWidget {
  final int? lastScore;
  final List<Map<String, dynamic>> vocabList;

  static const routeName = '/vocab-test-setup';

  const TestSetupView({
    super.key,
    this.lastScore = 10,
    this.vocabList = const [],
  });

  @override
  State<StatefulWidget> createState() => _TestSetupState();
}

class _TestSetupState extends State<TestSetupView> {
  bool _instantAnswer = false;
  TestType _testType = TestType.trueFalse;
  AnswerType _answerType = AnswerType.word;

  void showAnswerTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: const Text("Word"),
                    onTap: () {
                      setState(() {
                        _answerType = AnswerType.word;
                      });
                      Navigator.pop(context);
                    },
                    trailing: (_answerType == AnswerType.word) ? const Icon(Icons.done) : const SizedBox(),
                  ),
                  ListTile(
                    title: const Text("Definition"),
                    onTap: () {
                      setState(() {
                        _answerType = AnswerType.definition;
                      });
                      Navigator.pop(context);
                    },
                    trailing: (_answerType == AnswerType.definition) ? const Icon(Icons.done) : const SizedBox(),
                  )
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Test Setup",
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Vocab topic",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.lastScore != null
                    ? Text(
                        "Your last score: ${widget.lastScore}/${widget.vocabList.length}",
                        style: const TextStyle(
                          color: Color(0xFF6cf590),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Container(),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Test Settings",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(),
            SwitchListTile(
              activeColor: const Color(0xFF76ABAE),
              value: _instantAnswer,
              onChanged: (value) {
                setState(() {
                  _instantAnswer = value;
                });
              },
              title: const Text("Instant Correct Answer"),
            ),
            ListTile(
              onTap: () {
                showAnswerTypeBottomSheet();
              },
              title: Text("Answer with: ${(_answerType == AnswerType.word) ? "Word" : "Definition"}"),
              trailing: const Icon(
                Icons.arrow_forward_ios_sharp,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Test Type",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(),
            RadioListTile(
              activeColor: const Color(0xFF76ABAE),
              value: TestType.trueFalse,
              groupValue: _testType,
              onChanged: (TestType? value) {
                setState(() {
                  _testType = value!;
                });
              },
              title: const Text("True/False"),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            RadioListTile(
              activeColor: const Color(0xFF76ABAE),
              value: TestType.written,
              groupValue: _testType,
              onChanged: (TestType? value) {
                setState(() {
                  _testType = value!;
                });
              },
              title: const Text("Written"),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            RadioListTile(
              activeColor: const Color(0xFF76ABAE),
              value: TestType.multiple,
              groupValue: _testType,
              onChanged: (TestType? value) {
                setState(() {
                  _testType = value!;
                });
              },
              title: const Text("Multiple Choices"),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () {
            Navigator.popAndPushNamed(context, "/vocab-test", arguments: {
              "vocabList": widget.vocabList,
              "testType": _testType,
              "answerType": _answerType,
            });
          },
          style: const ButtonStyle(
            padding: MaterialStatePropertyAll(EdgeInsets.all(16)),
            backgroundColor: MaterialStatePropertyAll(
              Color(0xFF76ABAE),
            ),
          ),
          child: const Text(
            "Enter Test",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
