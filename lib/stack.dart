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

// void main() {
//   var stack = Stack<int>();
//   stack.push(1);
//   stack.push(2);
//   stack.push(3);

//   print(stack.pop()); // 输出: 3
//   print(stack.peek()); // 输出: 2
//   print(stack.pop()); // 输出: 2
//   print(stack.isEmpty); // 输出: false
//   print(stack.size); // 输出: 1
// }
