import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_crafter/model/question.dart';
import 'package:quiz_crafter/model/quiz.dart';
import 'package:quiz_crafter/theme/theme.dart';

class EditQuizScreen extends StatefulWidget {
  const EditQuizScreen({super.key, required this.quiz});

  final Quiz quiz;

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class QuestionFormItem {
  final TextEditingController questionController;
  final List<TextEditingController> optionsControllers;
  int correctOptionIndex;

  QuestionFormItem({
    required this.questionController,
    required this.optionsControllers,
    required this.correctOptionIndex,
  });

  void dispose() {
    questionController.dispose();
    for (var element in optionsControllers) {
      element.dispose();
    }
  }
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _timeLimitController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  late List<QuestionFormItem> _questionItems;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionItems) {
      item.dispose();
    }
  }

  void _initData() {
    _titleController = TextEditingController(text: widget.quiz.title);
    _timeLimitController =
        TextEditingController(text: widget.quiz.timeLimit.toString());

    _questionItems = widget.quiz.questions.map((question) {
      return QuestionFormItem(
        questionController: TextEditingController(
          text: question.text,
        ),
        optionsControllers: question.options
            .map((option) => TextEditingController(text: option))
            .toList(),
        correctOptionIndex: question.correctOptionIndex,
      );
    }).toList();
  }

  void _addQuestion() {
    setState(() {
      _questionItems.add(
        QuestionFormItem(
          questionController: TextEditingController(),
          optionsControllers: List.generate(4, (e) => TextEditingController()),
          correctOptionIndex: 0,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    if (_questionItems.length > 1) {
      setState(() {
        _questionItems[index].dispose();
        _questionItems.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Quiz must have at least one question",
          ),
        ),
      );
    }
  }

  Future<void> _updateQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final questions = _questionItems
          .map(
            (item) => Question(
              text: item.questionController.text.trim(),
              options:
                  item.optionsControllers.map((e) => e.text.trim()).toList(),
              correctOptionIndex: item.correctOptionIndex,
            ),
          )
          .toList();

      final updateQuiz = widget.quiz.copyWith(
        title: _titleController.text.trim(),
        timeLimit: int.parse(_timeLimitController.text),
        questions: questions,
        createdAt: widget.quiz.createdAt,
      );

      await _firestore.collection("quizzes").doc(widget.quiz.id).update(
            updateQuiz.toMap(isUpdate: true),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Quiz updated successfully",
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to update quiz",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryColor,
        title: Text(
          "Edit Quiz",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.backgroundColors,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateQuiz,
            icon: Icon(
              Icons.save,
              color: AppTheme.backgroundColors,
            ),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Text(
              "Quiz Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              cursorColor: AppTheme.primaryColor,
              controller: _titleController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 20),
                fillColor: Colors.white,
                labelText: "Title",
                hintText: "Enter quiz title",
                prefixIcon: Icon(
                  Icons.title,
                  color: AppTheme.primaryColor,
                ),
                labelStyle: TextStyle(color: AppTheme.primaryColor),
                floatingLabelStyle: TextStyle(
                  color: AppTheme.primaryColor,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter quiz title";
                }
                return null;
              },
            ),
            SizedBox(
              height: 16,
            ),
            TextFormField(
                cursorColor: AppTheme.primaryColor,
                controller: _timeLimitController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                  labelText: "Time Limit(in minutes)",
                  hintText: "Enter time limit",
                  prefixIcon: Icon(
                    Icons.timer,
                    color: AppTheme.primaryColor,
                  ),
                  labelStyle: TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter time limit";
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return "Please enter a valid time limit";
                  }
                  return null;
                }),
            SizedBox(
              height: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Questions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      label: Text(
                        "Add Question",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                ..._questionItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final QuestionFormItem question = entry.value;
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Question ${index + 1}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                              if (_questionItems.length > 1)
                                IconButton(
                                  onPressed: () {
                                    _removeQuestion(index);
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            cursorColor: AppTheme.primaryColor,
                            controller: question.questionController,
                            decoration: InputDecoration(
                              //fillColor: Colors.white,
                              labelText: "Question Title",
                              hintText: "Enter Question",
                              prefixIcon: Icon(
                                Icons.question_answer,
                                color: AppTheme.primaryColor,
                              ),
                              labelStyle:
                                  TextStyle(color: AppTheme.primaryColor),
                              floatingLabelStyle: TextStyle(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter question title";
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          ...question.optionsControllers
                              .asMap()
                              .entries
                              .map((entry) {
                            final optionIndex = entry.key;
                            final controller = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Radio<int>(
                                      activeColor: AppTheme.secondaryColor,
                                      value: optionIndex,
                                      groupValue: question.correctOptionIndex,
                                      onChanged: (value) {
                                        setState(() {
                                          question.correctOptionIndex = value!;
                                        });
                                      }),
                                  Expanded(
                                    child: TextFormField(
                                      cursorColor: AppTheme.primaryColor,
                                      controller: controller,
                                      decoration: InputDecoration(
                                        //fillColor: Colors.white,
                                        labelText: "Option ${optionIndex + 1}",
                                        hintText: "Enter option",
                                        labelStyle: TextStyle(
                                            color: AppTheme.primaryColor),
                                        floatingLabelStyle: TextStyle(
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter option";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(
                  height: 32,
                ),
                Center(
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateQuiz,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.secondaryColor,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Update Quiz",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
