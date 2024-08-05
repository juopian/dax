
import 'package:dax/token.dart';

class RuntimeError extends Error {
  final Token token;
  final String message;
  RuntimeError(this.token, this.message);
}