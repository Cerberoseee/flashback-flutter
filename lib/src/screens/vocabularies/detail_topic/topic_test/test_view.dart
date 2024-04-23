import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_final/src/enums.dart';
import 'package:flutter_final/src/widgets/test_linear_progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class TestView extends StatefulWidget {
  final List<Map<String, dynamic>> vocabList;
  final TestType testType;
  final AnswerType answerType;

  static const routeName = '/vocab-test';

  const TestView({
    super.key,
    this.vocabList = const [
      {
        "en": "test",
        "vi": "thử",
      },
      {
        "en": "test1",
        "vi": "thử1",
      },
      {
        "en": "test2",
        "vi": "thử2",
      },
      {
        "en": "test3",
        "vi": "thử3",
      },
      {
        "en": "test4",
        "vi": "thử4",
      },
    ],
    this.testType = TestType.written,
    this.answerType = AnswerType.word,
  });

  @override
  State<StatefulWidget> createState() => _TestState();
}

class _TestState extends State<TestView> {
  int _questionNum = 0, _correctAns = 0, _wrongAns = 0;
  final List<Map<String, dynamic>> _listCard = [];
  late DateTime _timeStart, _timeEnd;
  String? _randomTFAns;
  late List<Map<String, dynamic>> _vocabList = [];
  bool _isFinished = false;
  late FocusNode focusNode;

  late TextEditingController _answerTextField;

  @override
  void initState() {
    _timeStart = DateTime.now();
    focusNode = FocusNode();
    _answerTextField = TextEditingController();
    _vocabList = List<Map<String, dynamic>>.from(widget.vocabList)..shuffle();
    _randomTFAns = _vocabList[Random().nextInt(_vocabList.length)]['vi'];
    super.initState();
  }

  void checkAnswerText(String value) {
    String answer, question;
    if (widget.answerType == AnswerType.definition) {
      question = _vocabList[_questionNum]['en'];
      answer = _vocabList[_questionNum]['vi'];
    } else {
      question = _vocabList[_questionNum]['vi'];
      answer = _vocabList[_questionNum]['en'];
    }
    if (answer.toLowerCase() == value.trim().toLowerCase()) {
      setState(() {
        _correctAns += 1;
        _answerTextField.text = "";
        _listCard.add({
          "question": question,
          "correctAnswer": answer,
          "answer": answer,
          "isCorrect": true,
        });
      });
    } else {
      setState(() {
        _wrongAns += 1;
        _answerTextField.text = "";
        _listCard.add({
          "question": question,
          "correctAnswer": answer,
          "answer": value,
          "isCorrect": false,
        });
      });
    }
  }

  void checkAnswerTrueFalse(bool value) {
    bool result;
    String question;
    if (widget.answerType == AnswerType.definition) {
      question = _vocabList[_questionNum]['en'];
      result = _vocabList[_questionNum]['vi'] == _randomTFAns;
    } else {
      question = _vocabList[_questionNum]['vi'];
      result = _vocabList[_questionNum]['en'] == _randomTFAns;
    }
    //XNOR Operation
    if (!(result ^ value)) {
      setState(() {
        _correctAns += 1;
        _listCard.add({
          "question": question,
          "answer": value,
          "isCorrect": true,
        });
      });
    } else {
      setState(() {
        _wrongAns += 1;
        _listCard.add({
          "question": question,
          "answer": value,
          "isCorrect": false,
        });
      });
    }
  }

  void nextQuestion() {
    setState(() {
      _randomTFAns = (widget.answerType == AnswerType.definition) ? _vocabList[Random().nextInt(_vocabList.length)]['vi'] : _vocabList[Random().nextInt(_vocabList.length)]['en'];

      if (_questionNum == _vocabList.length - 1) {
        _isFinished = true;
        _timeEnd = DateTime.now();
        return;
      }
      _questionNum += 1;
    });
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${_questionNum + 1} / ${_vocabList.length}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        bottom: TestLinearProgressBar(
          backgroundColor: const Color(0xFF222831),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF76ABAE)),
          value: _isFinished ? 1.0 : (_questionNum * 1.0 / (_vocabList.isNotEmpty ? _vocabList.length : 1)),
        ),
      ),
      body: !_isFinished
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.answerType == AnswerType.definition ? _vocabList[_questionNum]['en'] : _vocabList[_questionNum]['vi']),
                        const Divider(
                          color: Color(0xFF2A2A2A),
                        ),
                        widget.testType == TestType.trueFalse ? Text(_randomTFAns!) : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Results",
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Correct: ${_correctAns.toString()}",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.green[400],
                              ),
                            ),
                            Text(
                              "Incorrect: ${_wrongAns.toString()}",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.red[400],
                              ),
                            ),
                            Text(
                              "Time Elapsed: ${(_timeEnd.difference(_timeStart).inMinutes).toString().padLeft(2, '0')}:${(_timeEnd.difference(_timeStart).inSeconds % 60).toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: Color(0xFF76ABAE),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                strokeWidth: 10.0,
                                value: (_correctAns * 1.0 / _vocabList.length),
                                backgroundColor: Colors.red[400],
                                valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 102, 187, 106)),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 5,
                              bottom: 0,
                              right: 0,
                              child: Center(
                                child: Text(
                                  "${((_correctAns * 1.0 / _vocabList.length) * 100).round()}% ",
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Your Answers",
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _listCard.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(
                            top: 12,
                            bottom: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  color: _listCard[index]['isCorrect'] ? Colors.green[400] : Colors.red[400],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(
                                      _listCard[index]['isCorrect'] ? Icons.done : Icons.close,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _listCard[index]['isCorrect'] ? "Correct" : "Incorrect",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top: 12,
                                ),
                                child: Text(_listCard[index]['question']),
                              ),
                              const SizedBox(height: 12),
                              !_listCard[index]['isCorrect']
                                  ? Container(
                                      padding: const EdgeInsets.only(left: 12, right: 12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.close,
                                            color: Colors.red[400],
                                          ),
                                          const SizedBox(width: 12),
                                          Text(_listCard[index]['answer'].toString()),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  bottom: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.done,
                                      color: Colors.green[400],
                                    ),
                                    const SizedBox(width: 12),
                                    Text(_listCard[index]['correctAnswer'].toString()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: !_isFinished
          ? Container(
              padding: const EdgeInsets.all(12),
              child: widget.testType == TestType.trueFalse
                  ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              checkAnswerTrueFalse(false);
                              nextQuestion();
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              padding: const MaterialStatePropertyAll(EdgeInsets.all(16)),
                              backgroundColor: const MaterialStatePropertyAll(
                                Color(0xFF76ABAE),
                              ),
                            ),
                            child: const Text(
                              "False",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              checkAnswerTrueFalse(true);
                              nextQuestion();
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              padding: const MaterialStatePropertyAll(EdgeInsets.all(16)),
                              backgroundColor: const MaterialStatePropertyAll(
                                Color(0xFF76ABAE),
                              ),
                            ),
                            child: const Text(
                              "True",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.all(12),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).size.width * 0.65 - 24),
                            child: TextField(
                              autofocus: true,
                              focusNode: focusNode,
                              controller: _answerTextField,
                              decoration: const InputDecoration(
                                hintText: "Enter answer",
                              ),
                              onSubmitted: (value) {
                                checkAnswerText(value);
                                nextQuestion();
                              },
                            ),
                          ),
                          Positioned(
                            right: 56.0,
                            top: 8.0,
                            child: TextButton(
                              onPressed: () {
                                checkAnswerText(_answerTextField.text);
                                nextQuestion();
                              },
                              child: const Text("Submit"),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 8.0,
                            child: TextButton(
                              onPressed: () {
                                checkAnswerText("");
                                nextQuestion();
                              },
                              child: const Text("Skip"),
                            ),
                          ),
                        ],
                      ),
                    ),
            )
          : const SizedBox(),
    );
  }
}
