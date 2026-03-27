
import 'dart:developer';

class PrintLog{
  static final PrintLog _singleton = PrintLog._internal();
  factory PrintLog() {
    return _singleton;
  }

  PrintLog._internal();


  static void printLog(var value){
    log(value.toString());
  }
}
