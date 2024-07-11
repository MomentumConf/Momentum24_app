import 'package:flutter_sanity_client/flutter_sanity_client.dart';

final sanityClient = SanityClient(
  dataset: 'production',
  projectId: const String.fromEnvironment('SANITY_PROJECT_ID'),
  apiVersion: 'v2022-03-07',
);
