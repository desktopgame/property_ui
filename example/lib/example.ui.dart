// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// PropertyUIGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './example.dart';

class ExampleUI extends StatefulWidget {
  Example _target;
  List<Widget> _header;
  List<Widget> _footer;
  void Function(Example, String) _onChanged;
  ExampleUI(this._target,
      {List<Widget> header,
      List<Widget> footer,
      void Function(Example, String) onChanged}) {
    this._header = header == null ? [] : header;
    this._footer = footer == null ? [] : footer;
    this._onChanged = onChanged;
  }

  @override
  State<StatefulWidget> createState() {
    return ExampleUIState(this._target,
        header: _header, footer: _footer, onChanged: _onChanged);
  }
}

class ExampleUIState extends State<ExampleUI> {
  Example _target;
  List<Widget> _header;
  List<Widget> _footer;
  void Function(Example, String) _onChanged;
  TextEditingController _nameController;
  TextEditingController _ageController;
  ExampleUIState(this._target,
      {List<Widget> header,
      List<Widget> footer,
      void Function(Example, String) onChanged}) {
    this._header = header == null ? [] : header;
    this._footer = footer == null ? [] : footer;
    this._onChanged = onChanged;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController()..text = _target.name;
    _ageController = TextEditingController()..text = _target.age.toString();
  }

  @override
  Widget build(BuildContext context) {
    return _scrollableColumn(context, [
      ..._header,
      _inputString("name", "enter your name.", true, _nameController, null),
      _inputDouble("height", -32768.0, _target.height, 32768.0, null),
      _inputInt("age", "", true, _ageController, null),
      _inputBool("die", _target.die, null),
      ..._footer,
    ]);
  }

  // helper methods
  Widget _labelWith(String label, Widget widget) {
    return Row(
      children: [
        SizedBox(
            width: 100,
            child: Text(
              label,
              textAlign: TextAlign.center,
            )),
        Expanded(child: widget)
      ],
    );
  }

  Widget _scrollableColumn(BuildContext context, List<Widget> children) {
    return SingleChildScrollView(
        child: Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: children,
      ),
    ));
  }

  Widget _inputString(String name, String hint, bool readonly,
      TextEditingController controller, void Function(String) onChanged) {
    return _labelWith(
        name,
        TextField(
          readOnly: readonly,
          controller: controller,
          decoration: new InputDecoration(labelText: hint),
          onChanged: onChanged,
        ));
  }

  Widget _inputInt(String name, String hint, bool readonly,
      TextEditingController controller, void Function(String) onChanged) {
    return _labelWith(
        name,
        TextField(
          readOnly: readonly,
          controller: controller,
          decoration: new InputDecoration(labelText: hint),
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
        ));
  }

  Widget _inputDouble(String name, double minValue, double value,
      double maxValue, void Function(double) onChanged) {
    return _labelWith(
        name,
        Slider(
          value: value,
          min: minValue,
          max: maxValue,
          onChanged: onChanged,
        ));
  }

  Widget _inputBool(String name, bool value, void Function(bool) onChanged) {
    return _labelWith(
        name,
        Switch(
          value: value,
          onChanged: onChanged,
        ));
  }
}
