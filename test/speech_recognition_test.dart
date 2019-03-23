import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:speech_recognition/speech_recognition.dart';

void main() {
	MockMethodChannel mockChannel;
	SpeechRecognition speechRecorder;

	group('speech recorder', () {
		setUp(() {
			mockChannel = new MockMethodChannel();
			speechRecorder = new SpeechRecognition.private(mockChannel);
		});

		test('initialize plugin', () async {
			speechRecorder.activate();
			verify(mockChannel.invokeMethod('speech.activate'));
		});
	});
}

	class MockMethodChannel extends Mock implements MethodChannel {}
