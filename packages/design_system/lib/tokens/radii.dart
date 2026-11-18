import 'package:flutter/material.dart';

abstract final class FitRadii {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 14;
  static const double xxl = 16;
  static const double card = 18;
  static const double cardLarge = 20;
  static const double section = 22;
  static const double pill = 18;
  static const double button = 12;
  static const double buttonLarge = 14;
  static const double buttonPill = 18;
  static const double input = 10;

  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get cardLargeBorder => BorderRadius.circular(cardLarge);
  static BorderRadius get sectionBorder => BorderRadius.circular(section);
  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static BorderRadius get buttonLargeBorder => BorderRadius.circular(buttonLarge);
  static BorderRadius get pillBorder => BorderRadius.circular(pill);
  static BorderRadius get inputBorder => BorderRadius.circular(input);
}
