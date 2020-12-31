class Property {
  final String displayName;
  final String hintText;
  final double minValue;
  final double maxValue;
  final bool readonly;

  const Property(
      {this.displayName = "",
      this.hintText = "",
      this.minValue = -32768,
      this.maxValue = 32768,
      this.readonly = false});
}
