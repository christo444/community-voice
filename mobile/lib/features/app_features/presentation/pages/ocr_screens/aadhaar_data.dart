class AadhaarData {
  String name = '';
  String dob = '';
  String age = '';
  String gender = '';
  String address = '';

  // ✅ ADD THESE
  String frontOcrText = '';
  String backOcrText = '';

  bool get hasFront =>
      name.isNotEmpty && dob.isNotEmpty && gender.isNotEmpty;

  bool get hasBack => address.isNotEmpty;
}