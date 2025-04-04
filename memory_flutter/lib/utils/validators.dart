class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    return null;
  }
  
  // Event title validation
  static String? validateEventTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Event title is required';
    }
    
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    
    return null;
  }
  
  // Event type name validation
  static String? validateEventTypeName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 20) {
      return 'Name must be less than 20 characters';
    }
    
    final nameRegex = RegExp(r'^[a-zA-Z0-9 ]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, numbers, and spaces';
    }
    
    return null;
  }
}