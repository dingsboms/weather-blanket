import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weather_blanket/components/location_and_coordinates/places_autocomplete/data/google_places_api.dart';
import 'package:weather_blanket/components/location_and_coordinates/places_autocomplete/model/prediction.dart';

class GooglePlacesAutoCompleteTextFormField extends StatefulWidget {
  const GooglePlacesAutoCompleteTextFormField({
    this.textEditingController,
    this.debounceTime = 600,
    this.onSuggestionClicked,
    this.fetchCoordinates = true,
    this.onPlaceDetailsWithCoordinatesReceived,
    this.predictionsStyle,
    this.overlayContainerBuilder,
    this.minInputLength = 0,
    this.sessionToken,
    this.initialValue,
    this.fetchSuggestionsForInitialValue = false,
    this.focusNode,
    this.style,
    this.maxHeight = 200,
    this.languageCode,
    this.onError,
    this.validator,
    super.key,
  });

  final String? initialValue;
  final bool fetchSuggestionsForInitialValue;
  final FocusNode? focusNode;
  final TextEditingController? textEditingController;
  final void Function(Prediction prediction)? onSuggestionClicked;
  final void Function(Prediction prediction)?
      onPlaceDetailsWithCoordinatesReceived;
  final bool fetchCoordinates;
  final int debounceTime;
  final String? languageCode;
  final TextStyle? predictionsStyle;
  final Widget Function(Widget overlayChild)? overlayContainerBuilder;
  final int minInputLength;
  final String? sessionToken;
  final double maxHeight;
  final Function? onError;
  final TextStyle? style;
  final String? Function(String?)? validator;

  @override
  State<GooglePlacesAutoCompleteTextFormField> createState() =>
      _GooglePlacesAutoCompleteTextFormFieldState();
}

class _GooglePlacesAutoCompleteTextFormFieldState
    extends State<GooglePlacesAutoCompleteTextFormField> {
  final GooglePlacesApi _api = GooglePlacesApi();
  final LayerLink _layerLink = LayerLink();

  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  late FocusNode _focus;
  List<Prediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();

    if (!kIsWeb && !Platform.isMacOS) {
      _focus.addListener(_onFocusChange);
    }

    if (widget.initialValue != null) {
      if (widget.textEditingController != null) {
        widget.textEditingController!.text = widget.initialValue!;
      }
      if (widget.fetchSuggestionsForInitialValue) {
        _onSearchChanged(widget.initialValue!);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focus.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focus.dispose();
    }
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      _removeOverlay();
    }
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceTime), () {
      _getLocation(text);
    });
  }

  Future<void> _getLocation(String text) async {
    if (text.isEmpty || text.length < widget.minInputLength) {
      _predictions.clear();
      _updateOverlay();
      return;
    }

    try {
      final result = await _api.getSuggestionsForInput(
        input: text,
        sessionToken: widget.sessionToken,
        languageCode: widget.languageCode,
      );

      if (result?.predictions == null) return;

      setState(() {
        _predictions = result!.predictions!;
        _updateOverlay();
      });
    } catch (e) {
      debugPrint('getLocation error: $e');
      widget.onError?.call(e);
    }
  }

  Future<void> _getPlaceDetails(Prediction prediction) async {
    try {
      final details = await _api.fetchCoordinatesForPrediction(
        prediction: prediction,
        sessionToken: widget.sessionToken,
      );

      if (details != null) {
        widget.onPlaceDetailsWithCoordinatesReceived?.call(details);
      }
    } catch (e) {
      debugPrint('getPlaceDetails error: $e');
      widget.onError?.call(e);
    }
  }

  void _updateOverlay() {
    _removeOverlay();
    if (_predictions.isNotEmpty) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child:
              widget.overlayContainerBuilder?.call(_buildPredictionsList()) ??
                  Material(
                    elevation: 1.0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: widget.maxHeight),
                      child: _buildPredictionsList(),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildPredictionsList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: _predictions.length,
      itemBuilder: (context, index) {
        final prediction = _predictions[index];
        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            widget.onSuggestionClicked?.call(prediction);
            if (widget.fetchCoordinates) {
              _getPlaceDetails(prediction);
            }
            _removeOverlay();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Text(
              prediction.description ?? '',
              style: widget.predictionsStyle ?? widget.style,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CupertinoTextFormFieldRow(
        controller: widget.textEditingController,
        initialValue:
            widget.textEditingController != null ? null : widget.initialValue,
        focusNode: _focus,
        style: widget.style ?? const TextStyle(color: CupertinoColors.black),
        onChanged: _onSearchChanged,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        ),
        validator: widget.validator,
      ),
    );
  }
}
