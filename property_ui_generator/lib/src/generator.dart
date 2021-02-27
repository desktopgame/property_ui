import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:property_ui_annotation/property_ui_annotation.dart';
import 'package:source_gen/source_gen.dart';

class PropertyInfo {
  final FieldElement field;
  final Property prop;

  const PropertyInfo(this.field, this.prop);
}

class PropertyUIGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    final lib = Library((b) =>
        b..body.addAll(library.classes.map((e) => Code(_codeForClass(e)))));
    final emitter = DartEmitter();
    return lib.accept(emitter).toString();
  }

  String classNameToFileName(String className) {
    var sb = StringBuffer();
    var regA = RegExp(r'[A-Z]');
    bool underscore = false;
    for (int i = 0; i < className.length; i++) {
      var ch = className.substring(i, i + 1);
      if (regA.hasMatch(ch)) {
        if (underscore) {
          sb.write("_");
          underscore = false;
        }
        sb.write(ch.toLowerCase());
      } else {
        sb.write(ch);
        underscore = true;
      }
    }
    return sb.toString();
  }

  List<PropertyInfo> _collectAnnotations(ClassElement e) {
    const checker = TypeChecker.fromRuntime(Property);
    List<PropertyInfo> ret = [];
    for (var field in e.fields) {
      if (checker.hasAnnotationOfExact(field)) {
        var a = checker.firstAnnotationOfExact(field);
        var dispName = a.getField("displayName").toStringValue();
        if (dispName == null || dispName.isEmpty) {
          dispName = field.name;
        }
        var prop = Property(
            displayName: dispName,
            hintText: a.getField("hintText").toStringValue(),
            minValue: a.getField("minValue").toDoubleValue(),
            maxValue: a.getField("maxValue").toDoubleValue(),
            readonly: a.getField("readonly").toBoolValue(),
            debug: a.getField("debug").toBoolValue());
        ret.add(PropertyInfo(field, prop));
      }
    }
    return ret;
  }

  String _generateCallback(FieldElement field, Property prop) {
    if (prop.readonly) {
      return "null";
    } else {
      const intChecker = TypeChecker.fromRuntime(int);
      const stringChecker = TypeChecker.fromRuntime(String);
      if (intChecker.isExactlyType(field.type)) {
        return '''
      (e) {
        this._target.${field.name} = int.parse(e);
        if(this._onChanged != null) {
          this._onChanged(_target, "${field.name}");
        }
      }
''';
      }
      if (stringChecker.isExactlyType(field.type)) {
        return '''
      (e) {
        this._target.${field.name} = e;
        if(this._onChanged != null) {
          this._onChanged(_target, "${field.name}");
        }
      }
''';
      }
      return '''
      (e) {
        setState(() {
          this._target.${field.name} = e;
          if(this._onChanged != null) {
            this._onChanged(_target, "${field.name}");
          }
        });
      }
''';
    }
  }

  String _codeForClass(ClassElement e) {
    if (e.fields.isEmpty) {
      return "";
    }
    var propInfos = _collectAnnotations(e);
    if (propInfos.isEmpty) {
      return "";
    }
    const stringChecker = TypeChecker.fromRuntime(String);
    const intChecker = TypeChecker.fromRuntime(int);
    const doubleChecker = TypeChecker.fromRuntime(double);
    const boolChecker = TypeChecker.fromRuntime(bool);
    var buffer = StringBuffer();
    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln("import 'package:flutter/services.dart';");
    buffer.writeln("import 'package:flutter/foundation.dart';");
    buffer.writeln("import './${classNameToFileName(e.name)}.dart';");
    buffer.writeln("");
    buffer.writeln('class ${e.name}UI extends StatefulWidget {');
    buffer.writeln("  ${e.name} _target;");
    buffer.writeln("  List<Widget> _header;");
    buffer.writeln("  List<Widget> _footer;");
    buffer.writeln("  void Function(${e.name}, String) _onChanged;");
    buffer.writeln(
        "  ${e.name}UI(this._target, {List<Widget> header, List<Widget> footer, void Function(${e.name}, String) onChanged}) {");
    buffer.writeln("    this._header = header == null ? [] : header;");
    buffer.writeln("    this._footer = footer == null ? [] : footer;");
    buffer.writeln("    this._onChanged = onChanged;");
    buffer.writeln("  }");
    buffer.writeln("");
    buffer.writeln("  @override");
    buffer.writeln("  State<StatefulWidget> createState() {");
    buffer.writeln(
        '    return ${e.name}UIState(this._target, header: _header, footer: _footer, onChanged: _onChanged);');
    buffer.writeln("  }");
    buffer.writeln("}");
    buffer.writeln("");
    buffer.writeln('class ${e.name}UIState extends State<${e.name}UI> {');
    buffer.writeln("  ${e.name} _target;");
    buffer.writeln("  List<Widget> _header;");
    buffer.writeln("  List<Widget> _footer;");
    buffer.writeln("  void Function(${e.name}, String) _onChanged;");
    for (var field in e.fields) {
      if (stringChecker.isExactlyType(field.type) ||
          intChecker.isExactlyType(field.type)) {
        buffer.writeln("  TextEditingController _${field.name}Controller;");
      }
    }
    buffer.writeln(
        "  ${e.name}UIState(this._target, {List<Widget> header, List<Widget> footer, void Function(${e.name}, String) onChanged}) {");
    buffer.writeln("    this._header = header == null ? [] : header;");
    buffer.writeln("    this._footer = footer == null ? [] : footer;");
    buffer.writeln("    this._onChanged = onChanged;");
    buffer.writeln("  }");
    buffer.writeln("");
    buffer.writeln("  @override");
    buffer.writeln("  void initState() {");
    buffer.writeln('    super.initState();');
    for (int i = 0; i < propInfos.length; i++) {
      var propInfo = propInfos[i];
      var field = propInfo.field;
      if (stringChecker.isExactlyType(field.type)) {
        buffer.writeln(
            '    _${field.name}Controller = TextEditingController()..text = _target.${field.name};');
      } else if (intChecker.isExactlyType(field.type)) {
        buffer.writeln(
            '    _${field.name}Controller = TextEditingController()..text = _target.${field.name}.toString();');
      }
    }
    buffer.writeln("  }");
    buffer.writeln("");
    buffer.writeln("  @override");
    buffer.writeln("  Widget build(BuildContext context) {");
    buffer.writeln('    var widgets = List<Widget>();');
    buffer.writeln('    widgets.addAll(_header);');
    for (int i = 0; i < propInfos.length; i++) {
      var propInfo = propInfos[i];
      var field = propInfo.field;
      var prop = propInfo.prop;
      var readonly = prop.readonly ? "true" : "false";
      var spaces = 4;
      if (prop.debug) {
        // デバッグビルドの時のみ有効になる場合ifで挟む
        buffer.writeln("    if(!kReleaseMode) {");
        spaces = 8;
      }
      var indent = "";
      for (int j = 0; j < spaces; j++) {
        indent += " ";
      }
      if (stringChecker.isExactlyType(field.type)) {
        buffer.write('${indent}widgets.add(');
        buffer.write(
            '_inputString("${prop.displayName}", "${prop.hintText}", $readonly, _${field.name}Controller,');
        buffer.write(_generateCallback(field, prop));
        buffer.writeln("));");
      } else if (intChecker.isExactlyType(field.type)) {
        buffer.write('${indent}widgets.add(');
        buffer.write(
            '_inputInt("${prop.displayName}", "${prop.hintText}", $readonly, _${field.name}Controller,');
        buffer.write(_generateCallback(field, prop));
        buffer.writeln("));");
      } else if (doubleChecker.isExactlyType(field.type)) {
        buffer.write('${indent}widgets.add(');
        buffer.write(
            '_inputDouble("${prop.displayName}", ${prop.minValue}, _target.${field.name}, ${prop.maxValue},');
        buffer.write(_generateCallback(field, prop));
        buffer.writeln("));");
      } else if (boolChecker.isExactlyType(field.type)) {
        buffer.write('${indent}widgets.add(');
        buffer
            .write('_inputBool("${prop.displayName}", _target.${field.name},');
        buffer.write(_generateCallback(field, prop));
        buffer.writeln("));");
      }
      buffer.writeln('${indent}widgets.add(Divider());');
      if (prop.debug) {
        // デバッグビルドの時のみ有効になる場合ifで挟む
        buffer.writeln("    }");
      }
    }
    buffer.writeln('    widgets.addAll(_footer);');
    buffer.writeln('    return _scrollableColumn(context, widgets);');
    buffer.writeln("  }");
    buffer.writeln("");
    buffer.writeln("  // helper methods");
    buffer.writeln("  Widget _labelWith(String label, Widget widget) {");
    buffer.writeln("    return Row(");
    buffer.writeln("      children: [");
    buffer.writeln("        SizedBox(");
    buffer.writeln("          width: 100,");
    buffer.writeln("          child: Text(");
    buffer.writeln("            label,");
    buffer.writeln("            textAlign: TextAlign.center,");
    buffer.writeln("          )),");
    //buffer.writeln("      Text(label,textAlign: TextAlign.center,),");
    buffer.writeln("      Expanded(child: widget)");
    buffer.writeln("      ],");
    buffer.writeln("    );");
    buffer.writeln("  }");
    buffer.writeln("");
    buffer.writeln(
        "  Widget _scrollableColumn(BuildContext context, List<Widget> children) {");
    buffer.writeln("    return SingleChildScrollView(");
    buffer.writeln("      child: ListView.builder(");
    buffer.writeln("        shrinkWrap: true,");
    buffer.writeln("        physics: NeverScrollableScrollPhysics(),");
    buffer.writeln(
        "        itemBuilder: (context, i) => SizedBox(height: 50, child: children[i]),");
    buffer.writeln("        itemCount: children.length,");
    buffer.writeln("    ),);");
    buffer.writeln("  }");
    buffer.writeln("");
    buffer.writeln(
        "  Widget _inputString(String name, String hint, bool readonly, TextEditingController controller, void Function(String) onChanged) {");
    buffer.writeln("    return _labelWith(name,TextField(");
    buffer.writeln("      readOnly: readonly,");
    buffer.writeln("      controller: controller,");
    buffer.writeln("      decoration: new InputDecoration(labelText: hint),");
    buffer.writeln("      onChanged: onChanged,");
    buffer.writeln("    ));");
    buffer.writeln("  }");
    buffer.writeln("");
    buffer.writeln(
        "  Widget _inputInt(String name, String hint, bool readonly, TextEditingController controller, void Function(String) onChanged) {");
    buffer.writeln("    return _labelWith(name, TextField(");
    buffer.writeln("      readOnly: readonly,");
    buffer.writeln("      controller: controller,");
    buffer.writeln("      decoration: new InputDecoration(labelText: hint),");
    buffer.writeln("      onChanged: onChanged,");
    buffer.writeln("      keyboardType: TextInputType.number,");
    buffer.writeln("      inputFormatters: <TextInputFormatter>[");
    buffer.writeln("        FilteringTextInputFormatter.digitsOnly");
    buffer.writeln("      ],");
    buffer.writeln("    ));");
    buffer.writeln("  }");
    buffer.writeln("");
    buffer.writeln(
        "  Widget _inputDouble(String name, double minValue, double value, double maxValue,void Function(double) onChanged) {");
    buffer.writeln("    return _labelWith(name, Slider(");
    buffer.writeln("      value: value,");
    buffer.writeln("      min: minValue,");
    buffer.writeln("      max: maxValue,");
    buffer.writeln("      onChanged: onChanged,");
    buffer.writeln("    ));");
    buffer.writeln("  }");
    buffer.writeln("");
    buffer.writeln(
        "  Widget _inputBool(String name, bool value, void Function(bool) onChanged) {");
    buffer.writeln("    return _labelWith(name, Switch(");
    buffer.writeln("      value: value,");
    buffer.writeln("      onChanged: onChanged,");
    buffer.writeln("    ));");
    buffer.writeln("  }");
    buffer.writeln("");
    buffer.writeln("}");
    return buffer.toString();
  }
}
