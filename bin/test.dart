import  'dart:io';
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
}