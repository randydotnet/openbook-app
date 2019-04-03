import 'dart:collection';

import 'package:dcache/dcache.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

abstract class UpdatableModel<T> {
  final int id;

  Stream<T> get updateSubject => _updateChangeSubject.stream;
  final _updateChangeSubject = BehaviorSubject<T>();

  UpdatableModel({this.id}) {
    notifyUpdate();
  }

  void notifyUpdate() {
    _updateChangeSubject.add(this as T);
  }

  void update(Map json) {
    updateFromJson(json);
    notifyUpdate();
  }

  void updateFromJson(Map json);

  void dispose() {
    _updateChangeSubject.close();
  }
}

abstract class UpdatableModelFactory<T extends UpdatableModel> {
  SimpleCache<int, T> cache;

  UpdatableModelFactory({this.cache}) {
    if (this.cache == null)
      cache = SimpleCache(storage: UpdatableModelSimpleStorage(size: 10));
  }

  T fromJson(Map<String, dynamic> json) {
    int itemId = json['id'];

    UpdatableModel item = getItemWithIdFromCache(itemId);

    if (item != null) {
      item.update(json);
      return item;
    }

    item = makeFromJson(json);
    addToCache(item);
    return item;
  }

  T makeFromJson(Map json);

  T getItemWithIdFromCache(int itemId) {
    return cache.get(itemId);
  }

  void addToCache(T item) {
    cache.set(item.id, item);
  }

  void clearCache() {
    cache.clear();
  }
}

class UpdatableModelSimpleStorage<K, V extends UpdatableModel>
    implements Storage<K, V> {
  Map<K, CacheEntry<K, V>> _internalMap;
  int _size;

  UpdatableModelSimpleStorage({@required int size}) {
    this._size = size;
    this._internalMap = new LinkedHashMap();
  }

  @override
  CacheEntry<K, V> operator [](K key) {
    var ce = this._internalMap[key];
    return ce;
  }

  @override
  void operator []=(K key, CacheEntry<K, V> value) {
    this._internalMap[key] = value;
  }

  @override
  void clear() {
    this._internalMap.clear();
  }

  @override
  CacheEntry<K, V> get(K key) {
    return this[key];
  }

  @override
  Storage set(K key, CacheEntry<K, V> value) {
    this[key] = value;
    return this;
  }

  @override
  void remove(K key) {
    CacheEntry<K, UpdatableModel> item = get(key);
    item.value.dispose();
    this._internalMap.remove(key);
  }

  @override
  int get length => this._internalMap.length;

  @override
  bool containsKey(K key) {
    return this._internalMap.containsKey(key);
  }

  @override
  List<K> get keys => this._internalMap.keys.toList(growable: true);

  @override
  List<CacheEntry<K, V>> get values =>
      this._internalMap.values.toList(growable: true);

  @override
  int get capacity => this._size;
}
