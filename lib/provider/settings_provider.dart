import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _deepseekApiKey = '';
  String _openaiApiKey = '';
  String _geminiApiKey = '';
  String _grokApiKey = '';
  String _doubaoApiKey = '';
  String _claudeApiKey = '';
  bool _useCustomEndpoints = false;

  bool get isDarkMode => _isDarkMode;
  String get deepseekApiKey => _deepseekApiKey;
  String get openaiApiKey => _openaiApiKey;
  String get geminiApiKey => _geminiApiKey;
  String get grokApiKey => _grokApiKey;
  String get doubaoApiKey => _doubaoApiKey;
  String get claudeApiKey => _claudeApiKey;
  bool get useCustomEndpoints => _useCustomEndpoints;

  // 获取有效的API密钥（用户自定义或默认）
  String getEffectiveDeepSeekKey() {
    return APIConfig.getEffectiveKey(_deepseekApiKey, APIConfig.defaultDeepSeekKey);
  }

  String getEffectiveOpenAIKey() {
    return APIConfig.getEffectiveKey(_openaiApiKey, APIConfig.defaultOpenAIKey);
  }

  String getEffectiveGeminiKey() {
    return APIConfig.getEffectiveKey(_geminiApiKey, APIConfig.defaultGeminiKey);
  }

  String getEffectiveGrokKey() {
    return APIConfig.getEffectiveKey(_grokApiKey, APIConfig.defaultGrokKey);
  }

  String getEffectiveDoubaoKey() {
    return APIConfig.getEffectiveKey(_doubaoApiKey, APIConfig.defaultDoubaoKey);
  }

  String getEffectiveClaudeKey() {
    return APIConfig.getEffectiveKey(_claudeApiKey, APIConfig.defaultClaudeKey);
  }

  // 检查是否使用默认密钥
  bool isUsingDefaultDeepSeek() {
    return APIConfig.isUsingDefaultKey(_deepseekApiKey, APIConfig.defaultDeepSeekKey);
  }

  bool isUsingDefaultOpenAI() {
    return APIConfig.isUsingDefaultKey(_openaiApiKey, APIConfig.defaultOpenAIKey);
  }

  bool isUsingDefaultGemini() {
    return APIConfig.isUsingDefaultKey(_geminiApiKey, APIConfig.defaultGeminiKey);
  }

  bool isUsingDefaultGrok() {
    return APIConfig.isUsingDefaultKey(_grokApiKey, APIConfig.defaultGrokKey);
  }

  bool isUsingDefaultDoubao() {
    return APIConfig.isUsingDefaultKey(_doubaoApiKey, APIConfig.defaultDoubaoKey);
  }

  bool isUsingDefaultClaude() {
    return APIConfig.isUsingDefaultKey(_claudeApiKey, APIConfig.defaultClaudeKey);
  }

  // 检查是否有可用的API密钥
  bool hasValidDeepSeekKey() {
    return APIConfig.hasValidKey(_deepseekApiKey, APIConfig.defaultDeepSeekKey);
  }

  bool hasValidOpenAIKey() {
    return APIConfig.hasValidKey(_openaiApiKey, APIConfig.defaultOpenAIKey);
  }

  bool hasValidGeminiKey() {
    return APIConfig.hasValidKey(_geminiApiKey, APIConfig.defaultGeminiKey);
  }

  bool hasValidGrokKey() {
    return APIConfig.hasValidKey(_grokApiKey, APIConfig.defaultGrokKey);
  }

  bool hasValidDoubaoKey() {
    return APIConfig.hasValidKey(_doubaoApiKey, APIConfig.defaultDoubaoKey);
  }

  bool hasValidClaudeKey() {
    return APIConfig.hasValidKey(_claudeApiKey, APIConfig.defaultClaudeKey);
  }

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _deepseekApiKey = prefs.getString('deepseekApiKey') ?? '';
    _openaiApiKey = prefs.getString('openaiApiKey') ?? '';
    _geminiApiKey = prefs.getString('geminiApiKey') ?? '';
    _grokApiKey = prefs.getString('grokApiKey') ?? '';
    _doubaoApiKey = prefs.getString('doubaoApiKey') ?? '';
    _claudeApiKey = prefs.getString('claudeApiKey') ?? '';
    _useCustomEndpoints = prefs.getBool('useCustomEndpoints') ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setDeepSeekApiKey(String key) async {
    _deepseekApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deepseekApiKey', key);
    notifyListeners();
  }

  Future<void> setOpenAIApiKey(String key) async {
    _openaiApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('openaiApiKey', key);
    notifyListeners();
  }

  Future<void> setGeminiApiKey(String key) async {
    _geminiApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('geminiApiKey', key);
    notifyListeners();
  }

  Future<void> setGrokApiKey(String key) async {
    _grokApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('grokApiKey', key);
    notifyListeners();
  }

  Future<void> setDoubaoApiKey(String key) async {
    _doubaoApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doubaoApiKey', key);
    notifyListeners();
  }

  Future<void> setClaudeApiKey(String key) async {
    _claudeApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('claudeApiKey', key);
    notifyListeners();
  }

  Future<void> toggleCustomEndpoints() async {
    _useCustomEndpoints = !_useCustomEndpoints;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useCustomEndpoints', _useCustomEndpoints);
    notifyListeners();
  }

  // 清除用户配置的API密钥（恢复使用默认）
  Future<void> clearDeepSeekApiKey() async {
    _deepseekApiKey = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('deepseekApiKey');
    notifyListeners();
  }

  Future<void> clearOpenAIApiKey() async {
    _openaiApiKey = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('openaiApiKey');
    notifyListeners();
  }

  Future<void> clearGeminiApiKey() async {
    _geminiApiKey = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('geminiApiKey');
    notifyListeners();
  }

  Future<void> clearGrokApiKey() async {
    _grokApiKey = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('grokApiKey');
    notifyListeners();
  }

  Future<void> clearDoubaoApiKey() async {
    _doubaoApiKey = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('doubaoApiKey');
    notifyListeners();
  }

  Future<void> clearClaudeApiKey() async {
    _claudeApiKey = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('claudeApiKey');
    notifyListeners();
  }
}