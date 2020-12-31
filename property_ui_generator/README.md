Generator for `property_ui_annotation`  
This is useful when you need to arrange a large number of widgets, such as in a configuration screen, and you want each value to be synchronized with the class.  
This package generates code that inspects the fields marked with annotations and places the appropriate editing widgets.  
For example, a TextField will be generated for a String type, and a Switch for a bool type.  
  
Below is the source code and the corresponding actual widget placement example.  

````.dart
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

  Example() {
    this.name = "user";
    this.height = 180;
    this.age = 20;
    this.die = false;
  }
}
````
![screenshot](https://user-images.githubusercontent.com/23698404/103415344-05084280-4bc5-11eb-98b0-0068fec0b0e0.png)

The code to place this widget itself looks like this
Although it is not excerpted here, the classes ExampleUI and ExampleUIState are actually generated.
````.dart
class _MyHomePageState extends State<MyHomePage> {
  Example _example;

  @override
  void initState() {
    super.initState();
    this._example = Example();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(children: [ExampleUI(_example), Spacer()]),
      ),
    );
  }
}
````

[example project is here.](https://github.com/desktopgame/property_ui/tree/main/example)

## Usage

Add packages to your pubspec.yaml.
````.yaml
dependencies:
  property_ui_annotation: ^1.0.0

dev_dependencies:
  build_runner: ^1.10.11
  property_ui_generator: ^1.0.2
````

Add @Property annotation to your class.
````.dart
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

  Example() {
    this.name = "user";
    this.height = 180;
    this.age = 20;
    this.die = false;
  }
}
````

Run build_runner on your project.
````.sh
flutter packages pub run build_runner build
````

## Supported data types
* String
* int
* double
* bool