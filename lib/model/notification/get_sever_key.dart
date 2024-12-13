// import 'package:googleapis_auth/auth_io.dart';
//
// class GetSeverKey{
//   Future<String> getServerKeyToken() async{
//     final scopes = [
//       'https://www.googleapis.com/auth/userinfo.email',
//       'https://www.googleapis.com/auth/firebase.database'
//       'https://www.googleapis.com/auth/firebase.messaging'
//     ];
//
//     final client = await clientViaServiceAccount(
//         ServiceAccountCredentials.fromJson(
//             {
//               "type": "service_account",
//               "project_id": "maze-khana",
//               "private_key_id": "ec8ed2b6f2dd3c70e4e1147fab7efaf169d18a3d",
//               "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC2sB33C1MEVY7Q\n7JrIQQhpJN+xWBacyW2qgK6IRzh4VXC3tPmCTtUsLZfMkqILwUVJTd66HfoHL3li\nzv9OqmtRcQoNYJvUtL4GxNv8oCniKzJ4Lp1gl6w///+8lKjB5hFG97SNS5keeiQP\ngyU+/bCDcCVJwD2d+ms3nGfCMLDeNyoUfTEz6yywkHyi8pDl9MZCdBvXCvuVrZH9\neYWB3jEUWEFKMyuskmuuSw9zpq7kpezw9BRhGb5X5I2zunrgEMdA5uwFlh25rLxQ\nlMz1gUPMESNK+hwYohTkSQMfYK1QHU1eUZnhqfBk3+9smTeNgmAR0+gZIlYE4q6H\nnY1J+OQzAgMBAAECggEAAUfn1eEW8mtVJoLaLPhDwlT3Wot3ER9abP0c/CifrTxQ\nH4Gd1DuQRBCHxW/rwfBXd4Wbv6tRIvbCv54a7SbFvNrxipl4Tjv8Lxj3P+Sxlnve\nDTiqctBtbT9ywBQ8wKtHyLsY4Xq7tpp9oTw2qSPnNmy1XjiCVha45LlsgtCLlOtE\nDv8mSIwUerrxwX9/iiUiAGKn5ivrEXc59gnL3sIJGuWhOxL0sTd0w6Y+GZdWFWqC\n2nAAY7j8LSsIeOep0r5V3rwfrBhtL96Zb4VWv/Ceco+aCtrWYKh4b4GEqG2TvtjS\nuOUR8nC/UKfJOLU7fzvbRvCO3hRG6MNTgY1MnHv39QKBgQDlysf3kq1T/FbkcLg+\nNmXSo4iyKM6y1VkyteLCnsDjciuVcTYpt7JEOf6MfxLC21Y7d/q+NrTIZO8YWe0j\n4mHvQG1UCnqFZ8x7lbQAnzLSeWVwbeqrRVwAh8PcrSAIUdkFhMFZIj+8N2SX+xYZ\nV13il3N5phganYG6nz6XF8MihQKBgQDLhgpPP4q3GoAUMGo3BzW6yJ3QScaYw4IY\n7yQLSJBtJhUzZQB7CSDKokIQ1j/6GkA44hLIQHiENbKGYLDMmMEqauPHNvGnMoRv\ndjLS3gpB3ezTM3tk2XygNqlFrOYDv0Xp2jx+Te5hFKIhZ8nCTebr5xu70Ec+chyO\nBXM0twpVVwKBgGukrj+/KgqprlqcovIhsVkW2jX6/7iuUHZ81ZitnVXuaZQ70E+C\nibOEJ0XRUQyOirqY3ZC1N8KX5ZjWp0ukBJR67bvsnLBZi2RpIEUaTkhiLa6ZDtDk\nUNC+yHVbdCHxlWQMaDZE4O5eVHUNXbDJSGWY5LMbpzbwiZDOgBdvPi2xAoGAWxyP\novikReJkMiWWdzoQEKVdGPDeKmdj53uvXCnJFkP1O8Pcmjf06SIIh3cSvwlfdNeo\nZuON0EoluMiyfXVpDG87t2RefGY+KZP1nrbuSpxqOAaVGAnRI/w0fU+wzT6kstMT\nP8vtiqJtDp1jEkxDs5oLrWHJcygsplvEPnYu9xMCgYEA2JQb0UyveXZKn0hPmeqS\nJk7orHXeRL4Kr67XyTt6qYFGY24lOteVODmXX54XSR5c65k1gMA0fn7/01WcpABE\nrnmib9J7qFowv8wh6NZpdqhLElIsay1+1uI8BVana8ExLFZG8cY4v65CWqKs0Spm\ne0NvqlL/Lau2LUAMzQfUzw4=\n-----END PRIVATE KEY-----\n",
//               "client_email": "firebase-adminsdk-7c0og@maze-khana.iam.gserviceaccount.com",
//               "client_id": "105083687372790185526",
//               "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//               "token_uri": "https://oauth2.googleapis.com/token",
//               "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//               "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-7c0og%40maze-khana.iam.gserviceaccount.com",
//               "universe_domain": "googleapis.com"
//             }
//         ),
//         scopes
//     );
//     final accessServerKey = client.credentials.accessToken.data;
//     return accessServerKey;
//   }
// }