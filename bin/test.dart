import  'dart:io';
import 'package:collection/collection.dart';

void main(List<String> args) {
  List arr = [
    1,
    2,
    if(2>4) 3 else 4,
    4
  ];
  print(arr);
  print(Directory('/etc/file/file1').parent.path);
  print(Directory('http://www.google.com/dir/dir2/file').parent.path);
  print(Uri.parse('/etc/file/file1').resolve('../file2'));
  print(Uri.parse('/etc/file/file1').resolve('../file2').path);
  print(Uri.parse('http://www.google.com/dir/dir2/file').resolve('file2'));
  print(Uri.parse('http://www.google.com/dir/dir2/file').resolve('../file2'));
  print(Uri.parse('http://www.google.com/dir/dir2/file').resolve('../file2').path);
  var equals = const ListEquality();
  print(equals.equals([1,2,3,4,5], [1,2,3,4,5]));
  print([1,2,3,4,[1,2]].toString() == [1,2,3,4,[1,2]].toString());
  var a = {'a': 1, 'b': 2, 'c': (){}};
  var b = {'a': 1, 'b': 2, 'c': (){}};
  var c = {};
  var d = {};
  print(c.values.toString() == d.values.toString());
  print(a.values.toString());
  print(b.values.toString());
  print(b.values.toString() == a.values.toString());
  print(equals.equals(a.values.toList(), b.values.toList()));
}