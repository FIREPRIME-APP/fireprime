class SelectedOptions {
  static final SelectedOptions _options = SelectedOptions._internal();
  late Map<String, String?> selectedOptions;

  factory SelectedOptions() {
    return _options;
  }

  SelectedOptions._internal();
}
