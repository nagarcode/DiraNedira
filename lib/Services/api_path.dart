class APIPath {
  static String investment(
          String apartmentId, String investmentId, String yearMonth) =>
      'apartments/$apartmentId/investments/investments/$yearMonth/$investmentId';

  static String investments(String apartmentId, String yearMonth) =>
      'apartments/$apartmentId/investments/investments/$yearMonth';
  static String months(String apartmentId) =>
      'apartments/$apartmentId/investments/investments/';

  static String apartments() => 'apartments';

  static String user(String uid) => 'users/$uid';

  static String users() => 'users';

  static String apartment(String apartmentId) => 'apartments/$apartmentId';

  static String apartmentUsers(String apartmentId) =>
      'apartments/$apartmentId/users';

  static String userInApartment({String apartmentId, String uid}) =>
      'apartments/$apartmentId/users/$uid';
}
