import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

typedef void AvailabilityHandler(bool result);
typedef void StringResultHandler(String text);

/// the channel to control the speech recognition
class SpeechRecognition {
	bool _canRecord = false;
	final MethodChannel _channel;

	factory SpeechRecognition() => _instance;

	@visibleForTesting
	SpeechRecognition.private(MethodChannel channel) : _channel = channel {
		_channel.setMethodCallHandler(_platformCallHandler);
	}

	static final SpeechRecognition _instance = SpeechRecognition.private(
		const MethodChannel('speech_recognition')
	);

	AvailabilityHandler availabilityHandler;

	StringResultHandler currentLocaleHandler;
	StringResultHandler recognitionResultHandler;

	VoidCallback recognitionError;

	VoidCallback recognitionStartedHandler;

	StringResultHandler recognitionCompleteHandler;

	/// ask for speech recognizer permission
	Future activate() => _channel.invokeMethod("speech.activate");

	/// start listening
	Future listen({String locale = "en_US"}) {
		assert(locale != null);
		if (_canRecord) {
			_channel.invokeMethod("speech.listen", locale);
		}
	}

	Future cancel() => _channel.invokeMethod("speech.cancel");

	Future stop() => _channel.invokeMethod("speech.stop");

	Future _platformCallHandler(MethodCall call) async {
		// print("_platformCallHandler call ${call.method} ${call.arguments}");

		switch (call.method) {
			case "speech.onSpeechAvailability":
				availabilityHandler(call.arguments);
				break;

			case "speech.onCurrentLocale":
				currentLocaleHandler(call.arguments);
				break;

			case "speech.onSpeech":
				recognitionResultHandler(call.arguments);
				break;

			case "speech.onRecognitionStarted":
				recognitionStartedHandler();
				break;

			case "speech.onRecognitionComplete":
				recognitionCompleteHandler(call.arguments);
				break;

			case "speech.onError":
				recognitionError();
				break;

			case "speech.onPermissionGranted":
				_canRecord = true;
				break;

			case "speech.onPermissionDenied":
				_canRecord = false;
				break;

			default:
				print('Unknowm method ${call.method} ');
		}
	}

	// define a method to handle availability / permission result
	void setAvailabilityHandler(AvailabilityHandler handler) =>
		availabilityHandler = handler;

	// define a method to handle recognition result
	void setRecognitionResultHandler(StringResultHandler handler) =>
		recognitionResultHandler = handler;

	// define a method to handle native call
	void setRecognitionStartedHandler(VoidCallback handler) =>
		recognitionStartedHandler = handler;

	// define a method to handle native call
	void setRecognitionCompleteHandler(StringResultHandler handler) =>
		recognitionCompleteHandler = handler;

	void setCurrentLocaleHandler(StringResultHandler handler) =>
		currentLocaleHandler = handler;

	void setRecognitionErrorHandler(VoidCallback handler) =>
		recognitionError = handler;
}
