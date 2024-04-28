import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/enums.dart';
import 'package:flutter_final/src/widgets/test_linear_progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class TestView extends StatefulWidget {
  final List<Map<String, dynamic>> vocabList;
  final TestType testType;
  final AnswerType answerType;
  final bool instantAnswer;

  static const routeName = '/vocab-test';

  const TestView({
    super.key,
    this.vocabList = const [],
    this.instantAnswer = true,
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
  String? _randomTFAns, _currAnswer;
  late List<Map<String, dynamic>> _vocabList = [];
  bool _isFinished = false, _showAnswer = false, _showNextQuestionBtn = false, _isCurrCorrect = false;
  late FocusNode focusNode;
  late List<String> _multipleChoiceList;

  late TextEditingController _answerTextField;

  @override
  void initState() {
    _timeStart = DateTime.now();
    focusNode = FocusNode();
    _answerTextField = TextEditingController();
    _vocabList = List<Map<String, dynamic>>.from(widget.vocabList)..shuffle();
    _randomTFAns = _vocabList[Random().nextInt(_vocabList.length)]['en'];
    _multipleChoiceList = shuffleAnswer();
    super.initState();
  }

  List<String> shuffleAnswer() {
    String answer;

    if (widget.answerType == AnswerType.definition) {
      answer = _vocabList[_questionNum]['vi'];
    } else {
      answer = _vocabList[_questionNum]['en'];
    }

    List<String> answerList = [];
    List<int> addedList = [];
    answerList.add(answer);
    addedList.add(_questionNum);
    int loopIndex = 0;
    while (loopIndex < _vocabList.length - 1) {
      int tempAnsIndex = Random().nextInt(_vocabList.length);
      String tempAns = (widget.answerType == AnswerType.definition) ? _vocabList[tempAnsIndex]['vi'] : _vocabList[tempAnsIndex]['en'];
      if (addedList.firstWhereOrNull((element) => element == tempAnsIndex) != null) continue;
      answerList.add(tempAns);
      addedList.add(tempAnsIndex);
      loopIndex += 1;
    }
    answerList.shuffle();
    return answerList;
  }

  void checkMultipleAns(String value) {
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
        _isCurrCorrect = true;
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
        _isCurrCorrect = false;
      });
    }
    if (widget.instantAnswer) {
      setState(() {
        _currAnswer = answer;
        _showAnswer = true;
      });
    }
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
        _isCurrCorrect = false;
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
        _isCurrCorrect = false;
      });
    }

    if (widget.instantAnswer) {
      setState(() {
        _currAnswer = answer;
        _showAnswer = true;
      });
    }
  }

  void checkAnswerTrueFalse(bool value) {
    bool result;
    String question, answer;
    if (widget.answerType == AnswerType.definition) {
      question = _vocabList[_questionNum]['en'];
      result = _vocabList[_questionNum]['vi'] == _randomTFAns;
      answer = _vocabList[_questionNum]['vi'];
    } else {
      question = _vocabList[_questionNum]['vi'];
      result = _vocabList[_questionNum]['en'] == _randomTFAns;
      answer = _vocabList[_questionNum]['en'];
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
        _isCurrCorrect = true;
      });
    } else {
      setState(() {
        _wrongAns += 1;
        _listCard.add({
          "question": question,
          "answer": value,
          "isCorrect": false,
        });
        _isCurrCorrect = false;
      });
    }

    if (widget.instantAnswer) {
      setState(() {
        _currAnswer = answer;
        _showAnswer = true;
      });
    }
  }

  void nextQuestion() {
    if (widget.instantAnswer) {
      setState(() {
        _showAnswer = false;
        _showNextQuestionBtn = false;
      });
    }
    setState(() {
      _randomTFAns = (widget.answerType == AnswerType.definition) ? _vocabList[Random().nextInt(_vocabList.length)]['vi'] : _vocabList[Random().nextInt(_vocabList.length)]['en'];
      _multipleChoiceList = shuffleAnswer();

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
                        _showAnswer
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _isCurrCorrect
                                      ? Row(
                                          children: [
                                            Icon(
                                              Icons.done,
                                              color: Colors.green[400],
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Text(
                                              "Correct!",
                                              style: TextStyle(
                                                color: Colors.green[400],
                                              ),
                                            )
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Icon(
                                              Icons.done,
                                              color: Colors.red[400],
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Text(
                                              "Incorrect!",
                                              style: TextStyle(
                                                color: Colors.red[400],
                                              ),
                                            )
                                          ],
                                        ),
                                  Text(
                                    "Correct Answer: $_currAnswer",
                                    style: TextStyle(
                                      color: Colors.green[400],
                                      fontSize: 20,
                                    ),
                                  )
                                ],
                              )
                            : Container(),
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
      bottomNavigationBar: _showNextQuestionBtn
          ? Container(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
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
                    "Next question",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          : !_isFinished
              ? Container(
                  padding: const EdgeInsets.all(12),
                  child: widget.testType == TestType.multiple
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 128,
                          child: GridView.builder(
                            shrinkWrap: true,
                            itemCount: _vocabList.length < 4 ? _vocabList.length : 4,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemBuilder: (context, index) {
                              return ElevatedButton(
                                onPressed: () {
                                  checkMultipleAns(_multipleChoiceList[index]);
                                  if (widget.instantAnswer) {
                                    setState(() {
                                      _showNextQuestionBtn = true;
                                    });
                                  } else {
                                    nextQuestion();
                                  }
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
                                child: Text(
                                  _multipleChoiceList[index],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : widget.testType == TestType.trueFalse
                          ? Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      checkAnswerTrueFalse(false);
                                      if (widget.instantAnswer) {
                                        setState(() {
                                          _showNextQuestionBtn = true;
                                        });
                                      } else {
                                        nextQuestion();
                                      }
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
                                      if (widget.instantAnswer) {
                                        setState(() {
                                          _showNextQuestionBtn = true;
                                        });
                                      } else {
                                        nextQuestion();
                                      }
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
                                        if (widget.instantAnswer) {
                                          setState(() {
                                            _showNextQuestionBtn = true;
                                          });
                                        } else {
                                          nextQuestion();
                                        }
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    right: 56.0,
                                    top: 8.0,
                                    child: TextButton(
                                      onPressed: () {
                                        checkAnswerText(_answerTextField.text);
                                        if (widget.instantAnswer) {
                                          setState(() {
                                            _showNextQuestionBtn = true;
                                          });
                                        } else {
                                          nextQuestion();
                                        }
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
                                        if (widget.instantAnswer) {
                                          setState(() {
                                            _showNextQuestionBtn = true;
                                          });
                                        } else {
                                          nextQuestion();
                                        }
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
