class Property {
  final String displayName;
  final String hintText;
  final double minValue;
  final double maxValue;
  final bool readonly;
  final bool debug;

  const Property(
      {this.displayName = "",
      this.hintText = "",
      this.minValue = -32768,
      this.maxValue = 32768,
      this.readonly = false,
      this.debug = false});
}
