class AudioHashtagSystem {
  final Map<String, List<String>> _hashtagToFileIds = {};

  void addHashtag(String fileId, String hashtag) {
    if (!_hashtagToFileIds.containsKey(hashtag)) {
      _hashtagToFileIds[hashtag] = [];
    }
    if (!_hashtagToFileIds[hashtag]!.contains(fileId)) {
      _hashtagToFileIds[hashtag]!.add(fileId);
    }
  }

  List<String> getFilesByHashtag(String hashtag) {
    return _hashtagToFileIds[hashtag] ?? [];
  }

  List<String> getAllHashtags() {
    return _hashtagToFileIds.keys.toList();
  }
}
