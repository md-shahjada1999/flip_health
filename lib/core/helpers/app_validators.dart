class AppValidator {
  // Phone number validation
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    // Remove any spaces, dashes, or other formatting
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Check if it's exactly 10 digits
    if (cleanPhone.length != 10) return false;
    // Check if it contains only digits
    return RegExp(r'^[0-9]+$').hasMatch(cleanPhone);
  }
  
  // Email validation
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w.+\-]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email);
  }
  
  // Check if input is valid phone or email
  static bool isValidPhoneOrEmail(String input) {
    if (input.isEmpty) return false;
    return isValidPhoneNumber(input) || isValidEmail(input);
  }
  
  // Get input type
  static InputType getInputType(String input) {
    if (input.isEmpty) return InputType.unknown;
    if (isValidEmail(input)) return InputType.email;
    if (isValidPhoneNumber(input)) return InputType.phone;
    return InputType.unknown;
  }
  
  // Phone number error message
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhoneNumber(phone)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }
  
  // Email error message
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  // Phone or email error message
  static String? validatePhoneOrEmail(String? input) {
    if (input == null || input.isEmpty) {
      return 'Phone number or email is required';
    }
    if (!isValidPhoneOrEmail(input)) {
      return 'Please enter a valid phone number or email';
    }
    return null;
  }
  
  // Clean phone number (remove formatting)
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }
  
  // Format phone number for display (e.g., 1234567890 -> 123-456-7890)
  static String formatPhoneNumber(String phone) {
    String clean = cleanPhoneNumber(phone);
    if (clean.length == 10) {
      return '${clean.substring(0, 3)}-${clean.substring(3, 6)}-${clean.substring(6)}';
    }
    return phone;
  }
}

// Enum for input types
enum InputType {
  phone,
  email,
  unknown,
}