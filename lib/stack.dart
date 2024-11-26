class Stack<T> {
  final List<T> _stack = [];

  void push(T element) {
    _stack.add(element);
  }

  T pop() {
    if (_stack.isEmpty) {
      throw StateError('Stack is empty');
    }
    return _stack.removeLast();
  }

  T get(int i) {
    if (_stack.isEmpty) {
      throw StateError('Stack is empty');
    }
    return _stack[i];
  }

  T peek() {
    if (_stack.isEmpty) {
      throw StateError('Stack is empty');
    }
    return _stack.last;
  }

  bool get isEmpty => _stack.isEmpty;

  int get length => _stack.length;
}

