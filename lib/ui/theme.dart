import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



class ThemeProvider extends ChangeNotifier {
  static final ThemeData _general = ThemeData(
    fontFamily: "Poppins",
    textTheme: const TextTheme(
      headline6: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w600),
    ),
  );

  static ThemeData dark = _general.copyWith(
    colorScheme: const ColorScheme.dark(primary: Color(0xff001e2a), background: Colors.red),
  );
  static ThemeData theme2 = _general.copyWith(primaryColor: const Color(0x001C28FF));

  late ThemeData theme = dark;

  setTheme(ThemeData value) {
    theme = value;
    notifyListeners();
  }

  // toggleTheme() {
  //   if (theme == theme1) {
  //     theme = theme2;
  //   } else {
  //     theme = theme1;
  //   }
  //
  //   notifyListeners();
  // }
}
