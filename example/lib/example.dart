import 'package:property_ui_annotation/property_ui_annotation.dart';

class Example {
  @Property(readonly: true, hintText: "enter your name.")
  String name;
  @Property()
  double height;
  @Property()
  int age;
  @Property()
  bool die;
  @Property(debug: true)
  bool debugParameter;

  Example() {
    this.name = "user";
    this.height = 180;
    this.age = 20;
    this.die = false;
  }
}
