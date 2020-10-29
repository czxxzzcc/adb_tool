import 'package:flutter/material.dart';
// 仅仅用于MaterialApp上的更新

class ProcessState extends ChangeNotifier {
  String output = '';
  void clear() {
    output = '';
    notifyListeners();
  }

  void appendOut(String out) {
    output += out;
    notifyListeners();
  }
}
