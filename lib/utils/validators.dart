class UtilValidators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해 주세요.';
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      return '유효한 이메일 주소를 입력해 주세요.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해 주세요.';
    }
    if (value.length < 8) {
      return '비밀번호는 8자 이상 입력해 주세요.';
    }
    if (value.length > 20) {
      return '비밀번호는 20자 이하로 입력해 주세요.';
    }
    return null;
  }

  static String? userId(String? value) {
    if (value == null || value.isEmpty) {
      return '아이디를 입력해 주세요.';
    }
    if (value.length < 4) {
      return '아이디는 4자 이상 입력해 주세요.';
    }
    // if (isDuplicate) {
    //   return '이미 사용중인 아이디입니다.';
    // }
    if (value.length > 20) {
      return '아이디는 20자 이하로 입력해 주세요.';
    }
    if (RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return null;
    } else {
      return '아이디는 영문자와 숫자만 입력 가능합니다.';
    }
  }
}
