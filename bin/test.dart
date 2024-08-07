void main() {
  try {
    // 调用一个可能抛出异常的方法
    doSomething();
  } on CustomException catch (e) {
    // 捕获自定义异常
    print('Caught custom exception: $e');
  } catch (e) {
    // 捕获其他类型的异常
    print('Caught exception: $e');
  } finally {
    // 无论是否发生异常，都会执行的代码
    print('Finally block executed');
  }
}

void doSomething() {
  // 抛出一个自定义异常
  throw CustomException('Something went wrong');
}

// 定义一个自定义异常类
class CustomException implements Exception {
  final String message;

  CustomException(this.message);

  @override
  String toString() => 'CustomException: $message';
}
