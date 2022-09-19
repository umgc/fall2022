class ApplicationFunction {
  String methodName;
  String message;
  List<String>? parameters;

  // Constructor
  ApplicationFunction({ this.methodName = '', this.message = '', this.parameters = null });

  String get getMethodName {
    return methodName;
  }

  String get getMessage {
    return message;
  }

  List<String>? get getParameters {
    return parameters;
  }
}