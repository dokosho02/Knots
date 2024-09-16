// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

Future<String> getRelativeTime({required String utcTimeStr}) =>
    RustLib.instance.api.crateApiSimpleGetRelativeTime(utcTimeStr: utcTimeStr);

Future<bool> checkIfFileExists({required String filePath}) =>
    RustLib.instance.api.crateApiSimpleCheckIfFileExists(filePath: filePath);

Future<List<(String, String)>> fetchFeedsFromDatabaseAsync(
        {required String dbPath}) =>
    RustLib.instance.api
        .crateApiSimpleFetchFeedsFromDatabaseAsync(dbPath: dbPath);

Future<void> addFeedToDatabaseAsync(
        {required String dbPath,
        required String title,
        required String link}) =>
    RustLib.instance.api.crateApiSimpleAddFeedToDatabaseAsync(
        dbPath: dbPath, title: title, link: link);

Future<List<(String, String, String)>> fetchItemsByFeedLinkAsync(
        {required String dbPath, required String feedLink}) =>
    RustLib.instance.api.crateApiSimpleFetchItemsByFeedLinkAsync(
        dbPath: dbPath, feedLink: feedLink);

Future<String> fetchContentsByItemLinkAsync(
        {required String dbPath, required String itemLink}) =>
    RustLib.instance.api.crateApiSimpleFetchContentsByItemLinkAsync(
        dbPath: dbPath, itemLink: itemLink);

Future<String> fetchCurrentFeedLinkAsync({required String dbPath}) =>
    RustLib.instance.api
        .crateApiSimpleFetchCurrentFeedLinkAsync(dbPath: dbPath);

Future<void> updateCurrentFeedLinkAsync(
        {required String dbPath, required String link}) =>
    RustLib.instance.api
        .crateApiSimpleUpdateCurrentFeedLinkAsync(dbPath: dbPath, link: link);

Future<String> fetchCurrentItemLinkAsync({required String dbPath}) =>
    RustLib.instance.api
        .crateApiSimpleFetchCurrentItemLinkAsync(dbPath: dbPath);

Future<void> updateCurrentItemLinkAsync(
        {required String dbPath, required String link}) =>
    RustLib.instance.api
        .crateApiSimpleUpdateCurrentItemLinkAsync(dbPath: dbPath, link: link);

Future<String> fetchFeedTitleAsync(
        {required String dbPath, required String link}) =>
    RustLib.instance.api
        .crateApiSimpleFetchFeedTitleAsync(dbPath: dbPath, link: link);

Future<String> fetchItemTitleAsync(
        {required String dbPath, required String link}) =>
    RustLib.instance.api
        .crateApiSimpleFetchItemTitleAsync(dbPath: dbPath, link: link);

Future<String> fetchPublishedAtAsync(
        {required String dbPath, required String link}) =>
    RustLib.instance.api
        .crateApiSimpleFetchPublishedAtAsync(dbPath: dbPath, link: link);

Future<int> fetchIsStarredByItemLinkAsync(
        {required String dbPath, required String link}) =>
    RustLib.instance.api.crateApiSimpleFetchIsStarredByItemLinkAsync(
        dbPath: dbPath, link: link);

Future<int> fetchIsReadByItemLinkAsync(
        {required String dbPath, required String link}) =>
    RustLib.instance.api
        .crateApiSimpleFetchIsReadByItemLinkAsync(dbPath: dbPath, link: link);

Future<void> createCurrentSettingsDbAsync({required String dbPath}) =>
    RustLib.instance.api
        .crateApiSimpleCreateCurrentSettingsDbAsync(dbPath: dbPath);

Future<FileProcessor> createProcessor({required String fileType}) =>
    RustLib.instance.api.crateApiSimpleCreateProcessor(fileType: fileType);

Future<FileProcessor> processChunk(
        {required FileProcessor processor, required List<int> chunk}) =>
    RustLib.instance.api
        .crateApiSimpleProcessChunk(processor: processor, chunk: chunk);

Future<List<String>> finalizeProcessing({required FileProcessor processor}) =>
    RustLib.instance.api.crateApiSimpleFinalizeProcessing(processor: processor);

String greet({required String name}) =>
    RustLib.instance.api.crateApiSimpleGreet(name: name);

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<FileProcessor>>
abstract class FileProcessor implements RustOpaqueInterface {
  Future<List<String>> finalize();

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<FileProcessor> newInstance({required String fileType}) =>
      RustLib.instance.api.crateApiSimpleFileProcessorNew(fileType: fileType);

  Future<void> processChunk({required List<int> chunk});
}
