import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{
  static ThemeData theme1 = ThemeData(primaryColor: Colors.black);
  static ThemeData theme2 = ThemeData(primaryColor: Colors.red);

  late ThemeData theme = theme1;

  setTheme(ThemeData value){
    theme = value;
    notifyListeners();
  }

  toggleTheme() {

    if(theme == theme1){
      theme = theme2;
    } else {
      theme = theme1;
    }

    notifyListeners();
  }
}