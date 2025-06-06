import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  late JsonArrayErrorResponseMapper jsonArrayErrorResponseMapper;

  setUp(() {
    jsonArrayErrorResponseMapper = const JsonArrayErrorResponseMapper();
  });

  group('test `map` function', () {
    test(
        'should return correct ServerError with code and message when using valid response',
        () {
      // arrange
      final response = {
        'errors': [
          {'code': 'error_code_1', 'message': 'error_message_1'},
          {'code': 'error_code_2', 'message': 'error_message_2'},
        ],
      };
      const expected = ServerError.general(
        errors: [
          ServerErrorDetail.detailed(
              field: 'error_code_1', detailMessage: 'error_message_1'),
          ServerErrorDetail.detailed(
              field: 'error_code_2', detailMessage: 'error_message_2'),
        ],
      );
      // act
      final result = jsonArrayErrorResponseMapper.map(response);
      // assert
      expect(result, expected);
    });

    test(
        'should return correct ServerError with code and message when using valid response with null message',
        () {
      // arrange
      final response = {
        'errors': [
          {'code': 'error_code_1'},
          {'code': 'error_code_2', 'message': 'error_message_2'},
        ],
      };
      const expected = ServerError.general(
        errors: [
          ServerErrorDetail.detailed(
              field: 'error_code_2', detailMessage: 'error_message_2'),
        ],
      );
      // act
      final result = jsonArrayErrorResponseMapper.map(response);
      // assert
      expect(result, expected);
    });

    test(
        'should return correct ServerError with code and message when using valid response with null code',
        () {
      // arrange
      final response = {
        'errors': [
          {'message': 'error_message_1'},
          {'code': 'error_code_2', 'message': 'error_message_2'},
        ],
      };
      const expected = ServerError.general(
        errors: [
          ServerErrorDetail.detailed(detailMessage: 'error_message_1'),
          ServerErrorDetail.detailed(
              field: 'error_code_2', detailMessage: 'error_message_2'),
        ],
      );
      // act
      final result = jsonArrayErrorResponseMapper.map(response);
      // assert
      expect(result, expected);
    });

    test('should return correct ServerError when some JSON keys are incorrect',
        () async {
      // arrange
      final errorResponse = {
        'errors': [
          {
            'code': 400, // correct key
            'error_message': 'The request is invalid', // incorrect key
          },
        ]
      };
      const expected = ServerError.general(
        errors: [ServerErrorDetail.detailed(serverStatusCode: 400)],
      );
      // act
      final result = jsonArrayErrorResponseMapper.map(errorResponse);
      // assert
      expect(result, expected);
    });

    test(
      'should return corresponding ServerError when all JSON keys are incorrect',
      () async {
        // arrange
        final errorResponse = {
          'errors': [
            {
              'er_code': 400, // incorrect key
              'error_message': 'The request is invalid', // incorrect key
            },
          ]
        };
        const expected =
            ServerError.general(errors: [ServerErrorDetail.detailed()]);
        final result = jsonArrayErrorResponseMapper.map(errorResponse);
        // assert
        expect(result, expected);
      },
    );

    test('should thow RemoteException.decodeError when using invalid data type',
        () async {
      // arrange
      final errorResponse = [
        {
          'code': '400',
          'message': true,
        },
      ];
      // assert
      expect(
        () => jsonArrayErrorResponseMapper.map(errorResponse),
        throwsA((e) =>
            e is RemoteException && e.kind == RemoteExceptionKind.decodeError),
      );
    });
  });
}
