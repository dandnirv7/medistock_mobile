const bool kUseDummyData =
    bool.fromEnvironment('USE_DUMMY', defaultValue: true);

const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);
