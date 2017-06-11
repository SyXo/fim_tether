class JSONCoder {
  Map<String, dynamic> data = new Map();

  JSONCoder();

  Map<String, dynamic> toJson() {
    return data;
  }

  dynamic objectify(dynamic data) {
    if (data == null) return null;
    if (data is num || data is bool || data is String) {
      return data;
    } else if (data is Set || data is List) {
      // for some weird reason, lists need to be re-created
      List objectified = new List();
      for (dynamic item in data) {
        objectified.add(objectify(item));
      }
      return objectified;
    } else if (data is Map) {
      Map<String, dynamic> objectified = new Map();
      for (dynamic key in data.keys) {
        objectified[key.toString()] = objectify(data[key]);
      }
      return objectified;
    } else if (data is DateTime) {
      return data.toIso8601String();
    } else if (data is JSONCoding) {
      JSONCoder coder = new JSONCoder();
      data.encode(coder);
      return coder.toJson();
    }
    print('Warning: Tried to encode non-encodable');
    return data;
  }

  encode(dynamic data, {String forKey}) {
    this.data[forKey] = objectify(data);
  }

  dynamic _decodeSafe(String key, dynamic defaultValue) {
    if (!data.containsKey(key)) return defaultValue;
    if (data[key] == null) return defaultValue;
    return data[key];
  }

  bool decodeBool({String forKey}) {
    return _decodeSafe(forKey, false);
  }

  num decodeNum({String forKey}) {
    return _decodeSafe(forKey, 0);
  }

  String decodeString({String forKey}) {
    return _decodeSafe(forKey, '');
  }

  DateTime decodeDateTime({String forKey}) {
    return DateTime.parse(_decodeSafe(forKey, '1970-01-01T00:00:00Z'));
  }

  // only top-level deserialization!
  List<T> decodeList<T>({String forKey, dynamic decodeItem(dynamic item)}) {
    Iterable decoded = _decodeSafe(forKey, new List<T>());
    List<T> result = new List();
    if (decodeItem != null) {
      for (dynamic item in decoded) {
        result.add(decodeItem(item));
      }
    } else {
      for (dynamic item in decoded) result.add(item);
    }
    return result;
  }

  // only top-level deserialization!
  Map decodeMap({String forKey}) {
    return _decodeSafe(forKey, new Map());
  }

  JSONCoding decodeObject({String forKey, JSONCoding template}) {
    JSONCoder coder = new JSONCoder();
    coder.data = _decodeSafe(forKey, new Map());
    template.decode(coder);
    return template;
  }
}

// mixin
abstract class JSONCoding {
  void encode(JSONCoder coder);
  void decode(JSONCoder coder);
}
