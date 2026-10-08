import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

final appController = AppController();

const languageNames = <String, String>{
  'en': 'English',
  'hi': 'हिन्दी',
  'as': 'অসমীয়া',
  'bn': 'বাংলা',
  'ne': 'नेपाली',
  'ta': 'தமிழ்',
  'te': 'తెలుగు',
  'kn': 'ಕನ್ನಡ',
  'ml': 'മലയാളം',
  'mr': 'मराठी',
};

const localeIds = <String, String>{
  'en': 'en_IN',
  'hi': 'hi_IN',
  'as': 'as_IN',
  'bn': 'bn_IN',
  'ne': 'ne_NP',
  'ta': 'ta_IN',
  'te': 'te_IN',
  'kn': 'kn_IN',
  'ml': 'ml_IN',
  'mr': 'mr_IN',
};

const Map<String, Map<String, String>> i18n = {
  "en": {
    "app": "GEONEXA",
    "tagline": "Early warning & hazard monitoring",
    "continue": "Continue",
    "name": "Name",
    "mobile": "Mobile number",
    "login_title": "Welcome to GEONEXA",
    "login_subtitle": "Enter your details to continue",
    "otp_title": "Verify mobile number",
    "otp_subtitle": "Enter the 6-digit OTP sent to your mobile",
    "otp_code": "OTP code",
    "send_otp": "Send OTP",
    "verify_otp": "Verify OTP",
    "resend_otp": "Resend OTP",
    "change_number": "Change number",
    "otp_sent": "OTP sent to your mobile number.",
    "invalid_login": "Enter your name and a valid 10-digit mobile number.",
    "invalid_otp": "Enter a valid 6-digit OTP.",
    "otp_failed": "OTP verification failed. Please try again.",
    "risk": "Risk",
    "report": "Report",
    "weather": "Weather",
    "pin": "PIN",
    "language": "Language",
    "risk_monitor": "Risk Monitor",
    "live_gps": "Live GPS",
    "refresh_gps": "Refresh GPS",
    "open_maps": "Open Location in Maps",
    "latitude": "Latitude",
    "longitude": "Longitude",
    "accuracy": "GPS Accuracy",
    "location_off": "Phone location service is turned off.",
    "permission_denied": "Location permission was not granted.",
    "open_settings": "Open App Settings",
    "risk_low": "LOW",
    "risk_medium": "MEDIUM",
    "risk_high": "HIGH",
    "rain_screening": "Rainfall Screening",
    "next24rain": "Next 24h rain",
    "not_probability": "Rainfall screening is not a landslide probability.",
    "stage1": "Stage 1 · Rainfall Alert",
    "stage2": "Stage 2 · Imminent Warning",
    "stage3": "Stage 3 · Confirmed Event",
    "stage1_inactive": "No heavy-rainfall alert is active now.",
    "stage1_active":
        "Heavy forecast rainfall detected. Stay away from unstable slopes and follow official alerts.",
    "stage2_need_feed":
        "A 5-minute imminent warning requires a verified movement sensor or official imminent-hazard feed. No value is invented.",
    "stage3_need_feed":
        "A confirmed-event alert requires a verified official source. Citizen reports stay marked as reports.",
    "seven_day": "7-Day Weather",
    "forecast_gps": "Live forecast for your GPS location",
    "rain": "Rain",
    "rain_chance": "Rain chance",
    "forecast_source": "Forecast data: Open-Meteo",
    "today": "Today",
    "report_hazard": "Report Hazard",
    "report_subtitle": "Save a GPS-tagged hazard observation",
    "hazard_type": "Hazard type",
    "severity": "Severity",
    "note": "Note",
    "save_report": "Save Report",
    "saved_reports": "Saved Reports",
    "report_saved": "Report saved on this device.",
    "type_landslide": "Landslide / debris",
    "type_crack": "Ground crack",
    "type_rockfall": "Rockfall",
    "type_water": "Unusual water flow",
    "type_tree": "Fallen tree / blocked road",
    "sev_low": "Low",
    "sev_medium": "Medium",
    "sev_high": "High",
    "pin_area": "PIN Area",
    "pin_subtitle": "Search an Indian 6-digit PIN code",
    "enter_pin": "Enter PIN code",
    "search": "Search",
    "district": "District",
    "state": "State",
    "post_office": "Post Office",
    "pin_invalid": "Enter a valid 6-digit PIN code.",
    "pin_not_found": "PIN code not found.",
    "online": "Online",
    "offline": "Offline",
    "cached": "Showing last saved data while offline.",
    "language_offline": "Language & Offline",
    "select_language": "Select language",
    "talk": "Talk to Assistant",
    "ask": "Ask about risk, weather, GPS, PIN or SOS",
    "speak": "Ask",
    "assistant": "Assistant",
    "sos": "SOS",
    "emergency": "Emergency SOS",
    "reason": "Reason",
    "injured": "Injured / unable to move",
    "trapped": "Trapped",
    "landslide_nearby": "Landslide nearby",
    "other": "Other",
    "call112": "Call 112",
    "copy_location": "Copy Location",
    "sms_registered": "Open SMS to registered number",
    "logout": "Log out",
    "no_location": "Location not available yet.",
    "profile": "Profile",
    "weather_clear": "Clear sky",
    "weather_cloudy": "Cloudy",
    "weather_fog": "Fog",
    "weather_drizzle": "Drizzle",
    "weather_rain": "Rain",
    "weather_snow": "Snow",
    "weather_thunder": "Thunderstorm",
    "weather_unknown": "Weather",
    "assistant_risk_low":
        "Current rainfall screening is low. Keep watching official alerts and local conditions.",
    "assistant_risk_medium":
        "Current rainfall screening is medium. Stay alert, avoid unstable slopes, and watch updates.",
    "assistant_risk_high":
        "Current rainfall screening is high because forecast rainfall is heavy. Move away from unstable slopes and follow official instructions.",
    "assistant_weather":
        "Open the Weather tab for the latest 7-day forecast from your GPS location.",
    "assistant_sos":
        "Use the SOS button to copy your latest location, open an SMS, or open the 112 dialer.",
    "assistant_pin": "Open the PIN tab and enter a 6-digit Indian PIN code.",
    "assistant_location": "The Risk tab shows your latest device GPS location.",
    "assistant_default":
        "I can help with risk, weather, GPS location, PIN areas and SOS.",
    "live_map": "Live Map",
    "recenter": "Recenter",
    "map_hint": "Pan and zoom the map. The marker is your latest GPS location.",
    "mic_listening": "Listening… speak now.",
    "mic_unavailable":
        "Speech recognition is unavailable on this device. You can type your question below.",
    "mic_error": "Microphone / speech recognition error.",
  },
  "hi": {
    "app": "GEONEXA",
    "tagline": "पूर्व चेतावनी और जोखिम निगरानी",
    "continue": "जारी रखें",
    "name": "नाम",
    "mobile": "मोबाइल नंबर",
    "login_title": "GEONEXA में आपका स्वागत है",
    "login_subtitle": "जारी रखने के लिए अपनी जानकारी दर्ज करें",
    "otp_title": "मोबाइल नंबर सत्यापित करें",
    "otp_subtitle": "आपके मोबाइल पर भेजा गया 6-अंकों का OTP दर्ज करें",
    "otp_code": "OTP कोड",
    "send_otp": "OTP भेजें",
    "verify_otp": "OTP सत्यापित करें",
    "resend_otp": "OTP फिर भेजें",
    "change_number": "नंबर बदलें",
    "otp_sent": "OTP आपके मोबाइल नंबर पर भेज दिया गया है।",
    "invalid_login": "अपना नाम और सही 10-अंकों का मोबाइल नंबर दर्ज करें।",
    "invalid_otp": "सही 6-अंकों का OTP दर्ज करें।",
    "otp_failed": "OTP सत्यापन विफल हुआ। फिर से प्रयास करें।",
    "risk": "जोखिम",
    "report": "रिपोर्ट",
    "weather": "मौसम",
    "pin": "पिन",
    "language": "भाषा",
    "risk_monitor": "जोखिम निगरानी",
    "live_gps": "लाइव GPS",
    "refresh_gps": "GPS रीफ्रेश करें",
    "open_maps": "मानचित्र में स्थान खोलें",
    "latitude": "अक्षांश",
    "longitude": "देशांतर",
    "accuracy": "GPS सटीकता",
    "location_off": "फोन की लोकेशन सेवा बंद है।",
    "permission_denied": "स्थान की अनुमति नहीं मिली।",
    "open_settings": "ऐप सेटिंग खोलें",
    "risk_low": "कम",
    "risk_medium": "मध्यम",
    "risk_high": "उच्च",
    "rain_screening": "वर्षा आधारित जांच",
    "next24rain": "अगले 24 घंटे की बारिश",
    "not_probability": "वर्षा आधारित जांच भूस्खलन की प्रतिशत संभावना नहीं है।",
    "stage1": "चरण 1 · वर्षा अलर्ट",
    "stage2": "चरण 2 · आसन्न चेतावनी",
    "stage3": "चरण 3 · पुष्टि घटना",
    "stage1_inactive": "अभी भारी वर्षा अलर्ट सक्रिय नहीं है।",
    "stage1_active":
        "भारी वर्षा का पूर्वानुमान है। अस्थिर ढलानों से दूर रहें और आधिकारिक अलर्ट का पालन करें।",
    "stage2_need_feed":
        "5 मिनट की आसन्न चेतावनी के लिए सत्यापित मूवमेंट सेंसर या आधिकारिक फीड आवश्यक है। कोई मान गढ़ा नहीं जाता।",
    "stage3_need_feed":
        "पुष्टि घटना अलर्ट के लिए सत्यापित आधिकारिक स्रोत आवश्यक है। नागरिक रिपोर्ट रिपोर्ट ही रहती है।",
    "seven_day": "7-दिन का मौसम",
    "forecast_gps": "आपके GPS स्थान का लाइव पूर्वानुमान",
    "rain": "बारिश",
    "rain_chance": "बारिश की संभावना",
    "forecast_source": "पूर्वानुमान डेटा: Open-Meteo",
    "today": "आज",
    "report_hazard": "खतरा रिपोर्ट करें",
    "report_subtitle": "GPS टैग के साथ खतरे का अवलोकन सहेजें",
    "hazard_type": "खतरे का प्रकार",
    "severity": "गंभीरता",
    "note": "नोट",
    "save_report": "रिपोर्ट सहेजें",
    "saved_reports": "सहेजी गई रिपोर्ट",
    "report_saved": "रिपोर्ट इस डिवाइस में सहेजी गई।",
    "type_landslide": "भूस्खलन / मलबा",
    "type_crack": "जमीन में दरार",
    "type_rockfall": "चट्टान गिरना",
    "type_water": "असामान्य जल प्रवाह",
    "type_tree": "गिरा पेड़ / बंद सड़क",
    "sev_low": "कम",
    "sev_medium": "मध्यम",
    "sev_high": "उच्च",
    "pin_area": "पिन क्षेत्र",
    "pin_subtitle": "भारतीय 6-अंकीय पिन कोड खोजें",
    "enter_pin": "पिन कोड दर्ज करें",
    "search": "खोजें",
    "district": "जिला",
    "state": "राज्य",
    "post_office": "डाकघर",
    "pin_invalid": "सही 6-अंकीय पिन कोड दर्ज करें।",
    "pin_not_found": "पिन कोड नहीं मिला।",
    "online": "ऑनलाइन",
    "offline": "ऑफलाइन",
    "cached": "ऑफलाइन होने पर अंतिम सहेजा डेटा दिखाया जा रहा है।",
    "language_offline": "भाषा और ऑफलाइन",
    "select_language": "भाषा चुनें",
    "talk": "सहायक से बात करें",
    "ask": "जोखिम, मौसम, GPS, पिन या SOS के बारे में पूछें",
    "speak": "पूछें",
    "assistant": "सहायक",
    "sos": "SOS",
    "emergency": "आपात SOS",
    "reason": "कारण",
    "injured": "घायल / चलने में असमर्थ",
    "trapped": "फंसा हुआ",
    "landslide_nearby": "पास में भूस्खलन",
    "other": "अन्य",
    "call112": "112 पर कॉल करें",
    "copy_location": "स्थान कॉपी करें",
    "sms_registered": "पंजीकृत नंबर पर SMS खोलें",
    "logout": "लॉग आउट",
    "no_location": "स्थान अभी उपलब्ध नहीं है।",
    "profile": "प्रोफ़ाइल",
    "weather_clear": "साफ आसमान",
    "weather_cloudy": "बादल",
    "weather_fog": "कोहरा",
    "weather_drizzle": "फुहार",
    "weather_rain": "बारिश",
    "weather_snow": "बर्फ",
    "weather_thunder": "गरज के साथ बारिश",
    "weather_unknown": "मौसम",
    "assistant_risk_low":
        "वर्तमान वर्षा आधारित जोखिम कम है। आधिकारिक अलर्ट और स्थानीय स्थिति देखते रहें।",
    "assistant_risk_medium":
        "वर्तमान वर्षा आधारित जोखिम मध्यम है। सतर्क रहें और अस्थिर ढलानों से दूर रहें।",
    "assistant_risk_high":
        "भारी वर्षा पूर्वानुमान के कारण वर्तमान वर्षा आधारित जोखिम उच्च है। अस्थिर ढलानों से दूर जाएं और आधिकारिक निर्देश मानें।",
    "assistant_weather":
        "अपने GPS स्थान का नवीनतम 7-दिन का पूर्वानुमान देखने के लिए मौसम टैब खोलें।",
    "assistant_sos":
        "अपना नवीनतम स्थान कॉपी करने, SMS खोलने या 112 डायलर खोलने के लिए SOS बटन का उपयोग करें।",
    "assistant_pin": "पिन टैब खोलें और 6-अंकीय भारतीय पिन कोड दर्ज करें।",
    "assistant_location":
        "जोखिम टैब आपके डिवाइस का नवीनतम GPS स्थान दिखाता है।",
    "assistant_default":
        "मैं जोखिम, मौसम, GPS स्थान, पिन क्षेत्र और SOS में मदद कर सकता हूं।",
    "live_map": "लाइव मानचित्र",
    "recenter": "फिर केंद्रित करें",
    "map_hint":
        "मानचित्र को खिसकाएं और ज़ूम करें। मार्कर आपका नवीनतम GPS स्थान है।",
    "mic_listening": "सुन रहा है… अब बोलें।",
    "mic_unavailable":
        "इस डिवाइस पर स्पीच पहचान उपलब्ध नहीं है। आप नीचे अपना प्रश्न टाइप कर सकते हैं।",
    "mic_error": "माइक्रोफोन / स्पीच पहचान त्रुटि।",
  },
  "kn": {
    "app": "GEONEXA",
    "tagline": "ಮುನ್ನೆಚ್ಚರಿಕೆ ಮತ್ತು ಅಪಾಯ ಮೇಲ್ವಿಚಾರಣೆ",
    "continue": "ಮುಂದುವರಿಸಿ",
    "name": "ಹೆಸರು",
    "mobile": "ಮೊಬೈಲ್ ಸಂಖ್ಯೆ",
    "login_title": "GEONEXA ಗೆ ಸ್ವಾಗತ",
    "login_subtitle": "ಮುಂದುವರಿಸಲು ನಿಮ್ಮ ವಿವರಗಳನ್ನು ನಮೂದಿಸಿ",
    "otp_title": "ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ಪರಿಶೀಲಿಸಿ",
    "otp_subtitle": "ನಿಮ್ಮ ಮೊಬೈಲ್‌ಗೆ ಕಳುಹಿಸಿದ 6 ಅಂಕಿಯ OTP ನಮೂದಿಸಿ",
    "otp_code": "OTP ಕೋಡ್",
    "send_otp": "OTP ಕಳುಹಿಸಿ",
    "verify_otp": "OTP ಪರಿಶೀಲಿಸಿ",
    "resend_otp": "OTP ಮತ್ತೆ ಕಳುಹಿಸಿ",
    "change_number": "ಸಂಖ್ಯೆ ಬದಲಿಸಿ",
    "otp_sent": "OTP ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಗೆ ಕಳುಹಿಸಲಾಗಿದೆ.",
    "invalid_login":
        "ನಿಮ್ಮ ಹೆಸರು ಮತ್ತು ಸರಿಯಾದ 10 ಅಂಕಿಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ.",
    "invalid_otp": "ಸರಿಯಾದ 6 ಅಂಕಿಯ OTP ನಮೂದಿಸಿ.",
    "otp_failed": "OTP ಪರಿಶೀಲನೆ ವಿಫಲವಾಗಿದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.",
    "risk": "ಅಪಾಯ",
    "report": "ವರದಿ",
    "weather": "ಹವಾಮಾನ",
    "pin": "ಪಿನ್",
    "language": "ಭಾಷೆ",
    "risk_monitor": "ಅಪಾಯ ಮೇಲ್ವಿಚಾರಣೆ",
    "live_gps": "ಲೈವ್ GPS",
    "refresh_gps": "GPS ನವೀಕರಿಸಿ",
    "open_maps": "ಮ್ಯಾಪ್‌ನಲ್ಲಿ ಸ್ಥಳ ತೆರೆಯಿರಿ",
    "latitude": "ಅಕ್ಷಾಂಶ",
    "longitude": "ರೇಖಾಂಶ",
    "accuracy": "GPS ನಿಖರತೆ",
    "location_off": "ಫೋನ್ ಸ್ಥಳ ಸೇವೆ ಆಫ್ ಆಗಿದೆ.",
    "permission_denied": "ಸ್ಥಳ ಅನುಮತಿ ನೀಡಲಾಗಿಲ್ಲ.",
    "open_settings": "ಆಪ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ",
    "risk_low": "ಕಡಿಮೆ",
    "risk_medium": "ಮಧ್ಯಮ",
    "risk_high": "ಹೆಚ್ಚು",
    "rain_screening": "ಮಳೆಯ ಆಧಾರಿತ ಪರಿಶೀಲನೆ",
    "next24rain": "ಮುಂದಿನ 24 ಗಂಟೆಗಳ ಮಳೆ",
    "not_probability": "ಮಳೆಯ ಪರಿಶೀಲನೆ ಭೂಕುಸಿತದ ಶೇಕಡಾವಾರು ಸಾಧ್ಯತೆ ಅಲ್ಲ.",
    "stage1": "ಹಂತ 1 · ಮಳೆ ಎಚ್ಚರಿಕೆ",
    "stage2": "ಹಂತ 2 · ತಕ್ಷಣದ ಅಪಾಯ ಎಚ್ಚರಿಕೆ",
    "stage3": "ಹಂತ 3 · ದೃಢೀಕೃತ ಘಟನೆ",
    "stage1_inactive": "ಈಗ ಭಾರೀ ಮಳೆ ಎಚ್ಚರಿಕೆ ಸಕ್ರಿಯವಾಗಿಲ್ಲ.",
    "stage1_active":
        "ಭಾರೀ ಮಳೆಯ ಮುನ್ಸೂಚನೆ ಇದೆ. ಅಸ್ಥಿರ ಇಳಿಜಾರುಗಳಿಂದ ದೂರವಿರಿ ಮತ್ತು ಅಧಿಕೃತ ಎಚ್ಚರಿಕೆಗಳನ್ನು ಅನುಸರಿಸಿ.",
    "stage2_need_feed":
        "5 ನಿಮಿಷಗಳ ಮುನ್ನೆಚ್ಚರಿಕೆಗೆ ದೃಢೀಕೃತ ಚಲನೆ ಸೆನ್ಸರ್ ಅಥವಾ ಅಧಿಕೃತ ತಕ್ಷಣದ ಅಪಾಯ ಫೀಡ್ ಅಗತ್ಯ. ಯಾವುದೇ ಮೌಲ್ಯವನ್ನು ಊಹಿಸಲಾಗುವುದಿಲ್ಲ.",
    "stage3_need_feed":
        "ದೃಢೀಕೃತ ಘಟನೆ ಎಚ್ಚರಿಕೆಗೆ ಅಧಿಕೃತವಾಗಿ ದೃಢೀಕರಿಸಿದ ಮೂಲ ಅಗತ್ಯ. ನಾಗರಿಕ ವರದಿಗಳು ವರದಿಗಳಾಗಿಯೇ ಉಳಿಯುತ್ತವೆ.",
    "seven_day": "7 ದಿನಗಳ ಹವಾಮಾನ",
    "forecast_gps": "ನಿಮ್ಮ GPS ಸ್ಥಳದ ಲೈವ್ ಮುನ್ಸೂಚನೆ",
    "rain": "ಮಳೆ",
    "rain_chance": "ಮಳೆಯ ಸಾಧ್ಯತೆ",
    "forecast_source": "ಮುನ್ಸೂಚನೆ ಡೇಟಾ: Open-Meteo",
    "today": "ಇಂದು",
    "report_hazard": "ಅಪಾಯ ವರದಿ ಮಾಡಿ",
    "report_subtitle": "GPS ಜೊತೆಗೆ ಅಪಾಯ ವೀಕ್ಷಣೆಯನ್ನು ಉಳಿಸಿ",
    "hazard_type": "ಅಪಾಯದ ಪ್ರಕಾರ",
    "severity": "ತೀವ್ರತೆ",
    "note": "ಟಿಪ್ಪಣಿ",
    "save_report": "ವರದಿ ಉಳಿಸಿ",
    "saved_reports": "ಉಳಿಸಿದ ವರದಿಗಳು",
    "report_saved": "ವರದಿ ಈ ಸಾಧನದಲ್ಲಿ ಉಳಿಸಲಾಗಿದೆ.",
    "type_landslide": "ಭೂಕುಸಿತ / ಮಣ್ಣು ಜಾರಿಕೆ",
    "type_crack": "ನೆಲ ಬಿರುಕು",
    "type_rockfall": "ಕಲ್ಲು ಬೀಳು",
    "type_water": "ಅಸಾಮಾನ್ಯ ನೀರಿನ ಹರಿವು",
    "type_tree": "ಮರ ಬಿದ್ದು ರಸ್ತೆ ತಡೆ",
    "sev_low": "ಕಡಿಮೆ",
    "sev_medium": "ಮಧ್ಯಮ",
    "sev_high": "ಹೆಚ್ಚು",
    "pin_area": "ಪಿನ್ ಪ್ರದೇಶ",
    "pin_subtitle": "ಭಾರತದ 6 ಅಂಕಿಯ ಪಿನ್ ಕೋಡ್ ಹುಡುಕಿ",
    "enter_pin": "ಪಿನ್ ಕೋಡ್ ನಮೂದಿಸಿ",
    "search": "ಹುಡುಕಿ",
    "district": "ಜಿಲ್ಲೆ",
    "state": "ರಾಜ್ಯ",
    "post_office": "ಅಂಚೆ ಕಚೇರಿ",
    "pin_invalid": "ಸರಿಯಾದ 6 ಅಂಕಿಯ ಪಿನ್ ಕೋಡ್ ನಮೂದಿಸಿ.",
    "pin_not_found": "ಪಿನ್ ಕೋಡ್ ಕಂಡುಬಂದಿಲ್ಲ.",
    "online": "ಆನ್‌ಲೈನ್",
    "offline": "ಆಫ್‌ಲೈನ್",
    "cached": "ಆಫ್‌ಲೈನ್ ಆದ್ದರಿಂದ ಕೊನೆಯ ಉಳಿಸಿದ ಡೇಟಾ ತೋರಿಸಲಾಗುತ್ತಿದೆ.",
    "language_offline": "ಭಾಷೆ ಮತ್ತು ಆಫ್‌ಲೈನ್",
    "select_language": "ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ",
    "talk": "ಸಹಾಯಕನೊಂದಿಗೆ ಮಾತನಾಡಿ",
    "ask": "ಅಪಾಯ, ಹವಾಮಾನ, GPS, ಪಿನ್ ಅಥವಾ SOS ಬಗ್ಗೆ ಕೇಳಿ",
    "speak": "ಕೇಳಿ",
    "assistant": "ಸಹಾಯಕ",
    "sos": "SOS",
    "emergency": "ತುರ್ತು SOS",
    "reason": "ಕಾರಣ",
    "injured": "ಗಾಯವಾಗಿದೆ / ಚಲಿಸಲಾಗುವುದಿಲ್ಲ",
    "trapped": "ಸಿಲುಕಿಕೊಂಡಿದ್ದೇನೆ",
    "landslide_nearby": "ಹತ್ತಿರ ಭೂಕುಸಿತ",
    "other": "ಇತರೆ",
    "call112": "112 ಗೆ ಕರೆ ಮಾಡಿ",
    "copy_location": "ಸ್ಥಳ ನಕಲಿಸಿ",
    "sms_registered": "ನೋಂದಾಯಿತ ಸಂಖ್ಯೆಗೆ SMS ತೆರೆಯಿರಿ",
    "logout": "ಲಾಗ್ ಔಟ್",
    "no_location": "ಸ್ಥಳ ಇನ್ನೂ ಲಭ್ಯವಿಲ್ಲ.",
    "profile": "ಪ್ರೊಫೈಲ್",
    "weather_clear": "ನಿರ್ಮಲ ಆಕಾಶ",
    "weather_cloudy": "ಮೋಡ",
    "weather_fog": "ಮಂಜು",
    "weather_drizzle": "ತುಂತುರು ಮಳೆ",
    "weather_rain": "ಮಳೆ",
    "weather_snow": "ಹಿಮ",
    "weather_thunder": "ಗುಡುಗು ಮಳೆ",
    "weather_unknown": "ಹವಾಮಾನ",
    "assistant_risk_low":
        "ಪ್ರಸ್ತುತ ಮಳೆಯ ಆಧಾರಿತ ಅಪಾಯ ಕಡಿಮೆ. ಅಧಿಕೃತ ಎಚ್ಚರಿಕೆಗಳು ಮತ್ತು ಸ್ಥಳೀಯ ಪರಿಸ್ಥಿತಿಗಳನ್ನು ಗಮನಿಸಿ.",
    "assistant_risk_medium":
        "ಪ್ರಸ್ತುತ ಮಳೆಯ ಆಧಾರಿತ ಅಪಾಯ ಮಧ್ಯಮ. ಎಚ್ಚರಿಕೆಯಿಂದಿರಿ, ಅಸ್ಥಿರ ಇಳಿಜಾರುಗಳಿಂದ ದೂರವಿರಿ ಮತ್ತು ನವೀಕರಣಗಳನ್ನು ಗಮನಿಸಿ.",
    "assistant_risk_high":
        "ಭಾರೀ ಮಳೆಯ ಮುನ್ಸೂಚನೆಯಿಂದ ಪ್ರಸ್ತುತ ಮಳೆಯ ಆಧಾರಿತ ಅಪಾಯ ಹೆಚ್ಚು. ಅಸ್ಥಿರ ಇಳಿಜಾರುಗಳಿಂದ ದೂರವಿದ್ದು ಅಧಿಕೃತ ಸೂಚನೆಗಳನ್ನು ಅನುಸರಿಸಿ.",
    "assistant_weather":
        "ನಿಮ್ಮ GPS ಸ್ಥಳದ ಇತ್ತೀಚಿನ 7 ದಿನಗಳ ಮುನ್ಸೂಚನೆಗಾಗಿ ಹವಾಮಾನ ಟ್ಯಾಬ್ ತೆರೆಯಿರಿ.",
    "assistant_sos":
        "ಇತ್ತೀಚಿನ ಸ್ಥಳವನ್ನು ನಕಲಿಸಲು, SMS ತೆರೆಯಲು ಅಥವಾ 112 ಡಯಲರ್ ತೆರೆಯಲು SOS ಬಟನ್ ಬಳಸಿ.",
    "assistant_pin":
        "ಪಿನ್ ಟ್ಯಾಬ್ ತೆರೆಯಿರಿ ಮತ್ತು 6 ಅಂಕಿಯ ಭಾರತೀಯ ಪಿನ್ ಕೋಡ್ ನಮೂದಿಸಿ.",
    "assistant_location":
        "ಅಪಾಯ ಟ್ಯಾಬ್ ನಿಮ್ಮ ಇತ್ತೀಚಿನ ಸಾಧನ GPS ಸ್ಥಳವನ್ನು ತೋರಿಸುತ್ತದೆ.",
    "assistant_default":
        "ಅಪಾಯ, ಹವಾಮಾನ, GPS ಸ್ಥಳ, ಪಿನ್ ಪ್ರದೇಶಗಳು ಮತ್ತು SOS ಕುರಿತು ನಾನು ಸಹಾಯ ಮಾಡಬಹುದು.",
    "live_map": "ಲೈವ್ ಮ್ಯಾಪ್",
    "recenter": "ಮತ್ತೆ ಕೇಂದ್ರಕ್ಕೆ",
    "map_hint":
        "ಮ್ಯಾಪ್ ಅನ್ನು ಸರಿಸಿ ಮತ್ತು ಜೂಮ್ ಮಾಡಿ. ಮಾರ್ಕರ್ ನಿಮ್ಮ ಇತ್ತೀಚಿನ GPS ಸ್ಥಳವಾಗಿದೆ.",
    "mic_listening": "ಕೇಳುತ್ತಿದೆ… ಈಗ ಮಾತನಾಡಿ.",
    "mic_unavailable":
        "ಈ ಸಾಧನದಲ್ಲಿ ಧ್ವನಿ ಗುರುತಿಸುವಿಕೆ ಲಭ್ಯವಿಲ್ಲ. ಕೆಳಗೆ ನಿಮ್ಮ ಪ್ರಶ್ನೆಯನ್ನು ಟೈಪ್ ಮಾಡಬಹುದು.",
    "mic_error": "ಮೈಕ್ರೋಫೋನ್ / ಧ್ವನಿ ಗುರುತಿಸುವಿಕೆ ದೋಷ.",
  },
  "ta": {
    "app": "GEONEXA",
    "tagline": "முன் எச்சரிக்கை மற்றும் அபாய கண்காணிப்பு",
    "continue": "தொடரவும்",
    "name": "பெயர்",
    "mobile": "மொபைல் எண்",
    "login_title": "GEONEXA-க்கு வரவேற்கிறோம்",
    "login_subtitle": "தொடர உங்கள் விவரங்களை உள்ளிடுங்கள்",
    "otp_title": "மொபைல் எண்ணைச் சரிபார்க்கவும்",
    "otp_subtitle": "உங்கள் மொபைலுக்கு அனுப்பப்பட்ட 6 இலக்க OTP-ஐ உள்ளிடவும்",
    "otp_code": "OTP குறியீடு",
    "send_otp": "OTP அனுப்பவும்",
    "verify_otp": "OTP சரிபார்க்கவும்",
    "resend_otp": "OTP மீண்டும் அனுப்பவும்",
    "change_number": "எண்ணை மாற்றவும்",
    "otp_sent": "OTP உங்கள் மொபைல் எண்ணுக்கு அனுப்பப்பட்டது.",
    "invalid_login":
        "உங்கள் பெயர் மற்றும் சரியான 10 இலக்க மொபைல் எண்ணை உள்ளிடவும்.",
    "invalid_otp": "சரியான 6 இலக்க OTP-ஐ உள்ளிடவும்.",
    "otp_failed": "OTP சரிபார்ப்பு தோல்வியடைந்தது. மீண்டும் முயற்சிக்கவும்.",
    "risk": "அபாயம்",
    "report": "அறிக்கை",
    "weather": "வானிலை",
    "pin": "PIN",
    "language": "மொழி",
    "risk_monitor": "அபாய கண்காணிப்பு",
    "live_gps": "நேரடி GPS",
    "refresh_gps": "GPS புதுப்பிக்கவும்",
    "open_maps": "வரைபடத்தில் இடத்தைத் திறக்கவும்",
    "latitude": "அட்சரேகை",
    "longitude": "தீர்க்கரேகை",
    "accuracy": "GPS துல்லியம்",
    "location_off": "தொலைபேசி இட சேவை அணைக்கப்பட்டுள்ளது.",
    "permission_denied": "இட அனுமதி வழங்கப்படவில்லை.",
    "open_settings": "ஆப் அமைப்புகளைத் திறக்கவும்",
    "risk_low": "குறைவு",
    "risk_medium": "மிதமான",
    "risk_high": "அதிகம்",
    "rain_screening": "மழை அடிப்படையிலான மதிப்பீடு",
    "next24rain": "அடுத்த 24 மணி மழை",
    "not_probability": "மழை மதிப்பீடு நிலச்சரிவு சதவீத வாய்ப்பு அல்ல.",
    "stage1": "நிலை 1 · மழை எச்சரிக்கை",
    "stage2": "நிலை 2 · உடனடி அபாய எச்சரிக்கை",
    "stage3": "நிலை 3 · உறுதி செய்யப்பட்ட நிகழ்வு",
    "stage1_inactive": "இப்போது கனமழை எச்சரிக்கை செயல்பாட்டில் இல்லை.",
    "stage1_active":
        "கனமழை முன்னறிவிப்பு உள்ளது. நிலைகுலைந்த சரிவுகளிலிருந்து விலகி அதிகாரப்பூர்வ எச்சரிக்கைகளைப் பின்பற்றவும்.",
    "stage2_need_feed":
        "5 நிமிட முன் எச்சரிக்கைக்கு சரிபார்க்கப்பட்ட இயக்க சென்சார் அல்லது அதிகாரப்பூர்வ உடனடி அபாய தரவு தேவை. மதிப்புகள் உருவாக்கப்படாது.",
    "stage3_need_feed":
        "உறுதி செய்யப்பட்ட நிகழ்வு எச்சரிக்கைக்கு அதிகாரப்பூர்வமாக சரிபார்க்கப்பட்ட மூலம் தேவை. குடிமக்கள் அறிக்கைகள் அறிக்கைகளாகவே இருக்கும்.",
    "seven_day": "7 நாள் வானிலை",
    "forecast_gps": "உங்கள் GPS இடத்திற்கான நேரடி முன்னறிவிப்பு",
    "rain": "மழை",
    "rain_chance": "மழை வாய்ப்பு",
    "forecast_source": "முன்னறிவிப்பு தரவு: Open-Meteo",
    "today": "இன்று",
    "report_hazard": "அபாயத்தை அறிக்கையிடுங்கள்",
    "report_subtitle": "GPS குறியிடப்பட்ட அபாயக் குறிப்பை சேமிக்கவும்",
    "hazard_type": "அபாய வகை",
    "severity": "தீவிரம்",
    "note": "குறிப்பு",
    "save_report": "அறிக்கை சேமிக்கவும்",
    "saved_reports": "சேமித்த அறிக்கைகள்",
    "report_saved": "அறிக்கை இந்த சாதனத்தில் சேமிக்கப்பட்டது.",
    "type_landslide": "நிலச்சரிவு / கழிவுகள்",
    "type_crack": "தரைப் பிளவு",
    "type_rockfall": "பாறை விழுதல்",
    "type_water": "அசாதாரண நீரோட்டம்",
    "type_tree": "மரம் விழுந்து சாலை மறைவு",
    "sev_low": "குறைவு",
    "sev_medium": "மிதமான",
    "sev_high": "அதிகம்",
    "pin_area": "PIN பகுதி",
    "pin_subtitle": "இந்திய 6 இலக்க PIN குறியீட்டைத் தேடுங்கள்",
    "enter_pin": "PIN குறியீட்டை உள்ளிடுங்கள்",
    "search": "தேடுங்கள்",
    "district": "மாவட்டம்",
    "state": "மாநிலம்",
    "post_office": "அஞ்சலகம்",
    "pin_invalid": "சரியான 6 இலக்க PIN குறியீட்டை உள்ளிடுங்கள்.",
    "pin_not_found": "PIN குறியீடு கிடைக்கவில்லை.",
    "online": "ஆன்லைன்",
    "offline": "ஆஃப்லைன்",
    "cached": "ஆஃப்லைனில் கடைசியாக சேமித்த தரவு காட்டப்படுகிறது.",
    "language_offline": "மொழி மற்றும் ஆஃப்லைன்",
    "select_language": "மொழியைத் தேர்ந்தெடுக்கவும்",
    "talk": "உதவியாளருடன் பேசுங்கள்",
    "ask": "அபாயம், வானிலை, GPS, PIN அல்லது SOS பற்றி கேளுங்கள்",
    "speak": "கேள்",
    "assistant": "உதவியாளர்",
    "sos": "SOS",
    "emergency": "அவசர SOS",
    "reason": "காரணம்",
    "injured": "காயம் / நகர முடியாது",
    "trapped": "சிக்கியுள்ளேன்",
    "landslide_nearby": "அருகில் நிலச்சரிவு",
    "other": "மற்றவை",
    "call112": "112-க்கு அழைக்கவும்",
    "copy_location": "இடத்தை நகலெடுக்கவும்",
    "sms_registered": "பதிவு செய்யப்பட்ட எண்ணிற்கு SMS திறக்கவும்",
    "logout": "வெளியேறு",
    "no_location": "இடம் இன்னும் கிடைக்கவில்லை.",
    "profile": "சுயவிவரம்",
    "weather_clear": "தெளிந்த வானம்",
    "weather_cloudy": "மேகமூட்டம்",
    "weather_fog": "மூடுபனி",
    "weather_drizzle": "தூறல்",
    "weather_rain": "மழை",
    "weather_snow": "பனி",
    "weather_thunder": "இடியுடன் மழை",
    "weather_unknown": "வானிலை",
    "assistant_risk_low":
        "தற்போதைய மழை அடிப்படையிலான அபாயம் குறைவு. அதிகாரப்பூர்வ எச்சரிக்கைகளையும் உள்ளூர் நிலைகளையும் கவனிக்கவும்.",
    "assistant_risk_medium":
        "தற்போதைய மழை அடிப்படையிலான அபாயம் மிதமானது. எச்சரிக்கையாக இருந்து நிலைகுலைந்த சரிவுகளைத் தவிர்க்கவும்.",
    "assistant_risk_high":
        "கனமழை முன்னறிவிப்பால் தற்போதைய மழை அடிப்படையிலான அபாயம் அதிகம். நிலைகுலைந்த சரிவுகளிலிருந்து விலகி அதிகாரப்பூர்வ அறிவுறுத்தல்களைப் பின்பற்றவும்.",
    "assistant_weather":
        "உங்கள் GPS இடத்தின் சமீபத்திய 7 நாள் முன்னறிவிப்புக்கு வானிலை தாவலைத் திறக்கவும்.",
    "assistant_sos":
        "சமீபத்திய இடத்தை நகலெடுக்க, SMS திறக்க அல்லது 112 டயலரைத் திறக்க SOS பொத்தானைப் பயன்படுத்தவும்.",
    "assistant_pin":
        "PIN தாவலைத் திறந்து 6 இலக்க இந்திய PIN குறியீட்டை உள்ளிடுங்கள்.",
    "assistant_location":
        "அபாய தாவல் உங்கள் சாதனத்தின் சமீபத்திய GPS இடத்தை காட்டுகிறது.",
    "assistant_default":
        "அபாயம், வானிலை, GPS இடம், PIN பகுதிகள் மற்றும் SOS குறித்து நான் உதவ முடியும்.",
    "live_map": "நேரடி வரைபடம்",
    "recenter": "மீண்டும் மையப்படுத்து",
    "map_hint":
        "வரைபடத்தை நகர்த்தி பெரிதாக்கலாம். குறியீடு உங்கள் சமீபத்திய GPS இடம்.",
    "mic_listening": "கேட்கிறது… இப்போது பேசுங்கள்.",
    "mic_unavailable":
        "இந்த சாதனத்தில் குரல் அங்கீகாரம் கிடைக்கவில்லை. கீழே உங்கள் கேள்வியை தட்டச்சு செய்யலாம்.",
    "mic_error": "மைக்ரோஃபோன் / குரல் அங்கீகார பிழை.",
  },
  "te": {
    "app": "GEONEXA",
    "tagline": "ముందస్తు హెచ్చరిక మరియు ప్రమాద పర్యవేక్షణ",
    "continue": "కొనసాగించండి",
    "name": "పేరు",
    "mobile": "మొబైల్ నంబర్",
    "login_title": "GEONEXA కు స్వాగతం",
    "login_subtitle": "కొనసాగడానికి మీ వివరాలు నమోదు చేయండి",
    "otp_title": "మొబైల్ నంబర్‌ను ధృవీకరించండి",
    "otp_subtitle": "మీ మొబైల్‌కు పంపిన 6 అంకెల OTP ను నమోదు చేయండి",
    "otp_code": "OTP కోడ్",
    "send_otp": "OTP పంపండి",
    "verify_otp": "OTP ధృవీకరించండి",
    "resend_otp": "OTP మళ్లీ పంపండి",
    "change_number": "నంబర్ మార్చండి",
    "otp_sent": "OTP మీ మొబైల్ నంబర్‌కు పంపబడింది.",
    "invalid_login":
        "మీ పేరు మరియు సరైన 10 అంకెల మొబైల్ నంబర్‌ను నమోదు చేయండి.",
    "invalid_otp": "సరైన 6 అంకెల OTP ను నమోదు చేయండి.",
    "otp_failed": "OTP ధృవీకరణ విఫలమైంది. మళ్లీ ప్రయత్నించండి.",
    "risk": "ప్రమాదం",
    "report": "రిపోర్ట్",
    "weather": "వాతావరణం",
    "pin": "PIN",
    "language": "భాష",
    "risk_monitor": "ప్రమాద పర్యవేక్షణ",
    "live_gps": "లైవ్ GPS",
    "refresh_gps": "GPS రిఫ్రెష్",
    "open_maps": "మ్యాప్‌లో స్థానం తెరవండి",
    "latitude": "అక్షాంశం",
    "longitude": "రేఖాంశం",
    "accuracy": "GPS ఖచ్చితత్వం",
    "location_off": "ఫోన్ లొకేషన్ సేవ ఆఫ్‌లో ఉంది.",
    "permission_denied": "స్థాన అనుమతి ఇవ్వలేదు.",
    "open_settings": "యాప్ సెట్టింగ్స్ తెరవండి",
    "risk_low": "తక్కువ",
    "risk_medium": "మధ్యస్థ",
    "risk_high": "అధిక",
    "rain_screening": "వర్ష ఆధారిత స్క్రీనింగ్",
    "next24rain": "తదుపరి 24గం వర్షం",
    "not_probability": "వర్ష స్క్రీనింగ్ భూస्खలనం శాతం సంభావ్యత కాదు.",
    "stage1": "దశ 1 · వర్ష హెచ్చరిక",
    "stage2": "దశ 2 · సమీప ప్రమాద హెచ్చరిక",
    "stage3": "దశ 3 · నిర్ధారిత ఘటన",
    "stage1_inactive": "ప్రస్తుతం భారీ వర్ష హెచ్చరిక యాక్టివ్‌లో లేదు.",
    "stage1_active":
        "భారీ వర్ష సూచన ఉంది. అస్థిర వాలుదారుల నుంచి దూరంగా ఉండి అధికారిక హెచ్చరికలు పాటించండి.",
    "stage2_need_feed":
        "5 నిమిషాల ముందస్తు హెచ్చరికకు ధృవీకరించిన కదలిక సెన్సర్ లేదా అధికారిక సమీప ప్రమాద ఫీడ్ అవసరం. విలువలు ఊహించబడవు.",
    "stage3_need_feed":
        "నిర్ధారిత ఘటన హెచ్చరికకు ధృవీకరించిన అధికారిక మూలం అవసరం. పౌర రిపోర్టులు రిపోర్టులుగానే ఉంటాయి.",
    "seven_day": "7 రోజుల వాతావరణం",
    "forecast_gps": "మీ GPS స్థానానికి లైవ్ సూచన",
    "rain": "వర్షం",
    "rain_chance": "వర్ష అవకాశం",
    "forecast_source": "సూచన డేటా: Open-Meteo",
    "today": "ఈ రోజు",
    "report_hazard": "ప్రమాదాన్ని రిపోర్ట్ చేయండి",
    "report_subtitle": "GPS-ట్యాగ్ చేసిన ప్రమాద గమనికను సేవ్ చేయండి",
    "hazard_type": "ప్రమాద రకం",
    "severity": "తీవ్రత",
    "note": "గమనిక",
    "save_report": "రిపోర్ట్ సేవ్",
    "saved_reports": "సేవ్ చేసిన రిపోర్టులు",
    "report_saved": "రిపోర్ట్ ఈ పరికరంలో సేవ్ అయింది.",
    "type_landslide": "భూస्खలనం / మట్టి",
    "type_crack": "నేల పగులు",
    "type_rockfall": "రాళ్లు పడటం",
    "type_water": "అసాధారణ నీటి ప్రవాహం",
    "type_tree": "చెట్టు పడటం / రోడ్ బ్లాక్",
    "sev_low": "తక్కువ",
    "sev_medium": "మధ్యస్థ",
    "sev_high": "అధిక",
    "pin_area": "PIN ప్రాంతం",
    "pin_subtitle": "భారత 6 అంకెల PIN కోడ్ వెతకండి",
    "enter_pin": "PIN కోడ్ నమోదు చేయండి",
    "search": "వెతకండి",
    "district": "జిల్లా",
    "state": "రాష్ట్రం",
    "post_office": "పోస్ట్ ఆఫీస్",
    "pin_invalid": "సరైన 6 అంకెల PIN కోడ్ నమోదు చేయండి.",
    "pin_not_found": "PIN కోడ్ కనబడలేదు.",
    "online": "ఆన్‌లైన్",
    "offline": "ఆఫ్‌లైన్",
    "cached": "ఆఫ్‌లైన్‌లో చివరిగా సేవ్ చేసిన డేటా చూపుతోంది.",
    "language_offline": "భాష మరియు ఆఫ్‌లైన్",
    "select_language": "భాష ఎంచుకోండి",
    "talk": "సహాయకుడితో మాట్లాడండి",
    "ask": "ప్రమాదం, వాతావరణం, GPS, PIN లేదా SOS గురించి అడగండి",
    "speak": "అడగండి",
    "assistant": "సహాయకుడు",
    "sos": "SOS",
    "emergency": "అత్యవసర SOS",
    "reason": "కారణం",
    "injured": "గాయపడ్డాను / కదలలేను",
    "trapped": "చిక్కుకున్నాను",
    "landslide_nearby": "దగ్గర భూస्खలనం",
    "other": "ఇతర",
    "call112": "112 కు కాల్ చేయండి",
    "copy_location": "స్థానం కాపీ చేయండి",
    "sms_registered": "రిజిస్టర్ నంబర్‌కు SMS తెరవండి",
    "logout": "లాగ్ అవుట్",
    "no_location": "స్థానం ఇంకా అందుబాటులో లేదు.",
    "profile": "ప్రొఫైల్",
    "weather_clear": "స్పష్టమైన ఆకాశం",
    "weather_cloudy": "మేఘావృతం",
    "weather_fog": "మంచు పొగ",
    "weather_drizzle": "చినుకులు",
    "weather_rain": "వర్షం",
    "weather_snow": "మంచు",
    "weather_thunder": "ఉరుములతో వర్షం",
    "weather_unknown": "వాతావరణం",
    "assistant_risk_low":
        "ప్రస్తుత వర్ష ఆధారిత ప్రమాదం తక్కువ. అధికారిక హెచ్చరికలు మరియు స్థానిక పరిస్థితులు గమనించండి.",
    "assistant_risk_medium":
        "ప్రస్తుత వర్ష ఆధారిత ప్రమాదం మధ్యస్థ. అప్రమత్తంగా ఉండి అస్థిర వాలుదారులను నివారించండి.",
    "assistant_risk_high":
        "భారీ వర్ష సూచన వల్ల ప్రస్తుత వర్ష ఆధారిత ప్రమాదం అధికం. అస్థిర వాలుదారుల నుంచి దూరంగా వెళ్లి అధికారిక సూచనలు పాటించండి.",
    "assistant_weather":
        "మీ GPS స్థానానికి తాజా 7 రోజుల సూచన కోసం వాతావరణ ట్యాబ్ తెరవండి.",
    "assistant_sos":
        "తాజా స్థానాన్ని కాపీ చేయడానికి, SMS తెరవడానికి లేదా 112 డయలర్ తెరవడానికి SOS ఉపయోగించండి.",
    "assistant_pin": "PIN ట్యాబ్ తెరిచి 6 అంకెల భారత PIN కోడ్ నమోదు చేయండి.",
    "assistant_location":
        "ప్రమాద ట్యాబ్ మీ పరికరం తాజా GPS స్థానాన్ని చూపుతుంది.",
    "assistant_default":
        "ప్రమాదం, వాతావరణం, GPS స్థానం, PIN ప్రాంతాలు మరియు SOS విషయంలో నేను సహాయం చేయగలను.",
    "live_map": "లైవ్ మ్యాప్",
    "recenter": "మళ్లీ మధ్యలో చూపించు",
    "map_hint": "మ్యాప్‌ను జరిపి జూమ్ చేయండి. మార్కర్ మీ తాజా GPS స్థానం.",
    "mic_listening": "వింటోంది… ఇప్పుడు మాట్లాడండి.",
    "mic_unavailable":
        "ఈ పరికరంలో స్పీచ్ రికగ్నిషన్ అందుబాటులో లేదు. కింద మీ ప్రశ్న టైప్ చేయవచ్చు.",
    "mic_error": "మైక్రోఫోన్ / స్పీచ్ రికగ్నిషన్ లోపం.",
  },
  "ml": {
    "app": "GEONEXA",
    "tagline": "മുൻകൂർ മുന്നറിയിപ്പും അപകട നിരീക്ഷണവും",
    "continue": "തുടരുക",
    "name": "പേര്",
    "mobile": "മൊബൈൽ നമ്പർ",
    "login_title": "GEONEXA ലേക്ക് സ്വാഗതം",
    "login_subtitle": "തുടരാൻ നിങ്ങളുടെ വിവരങ്ങൾ നൽകുക",
    "otp_title": "മൊബൈൽ നമ്പർ സ്ഥിരീകരിക്കുക",
    "otp_subtitle": "നിങ്ങളുടെ മൊബൈലിലേക്ക് അയച്ച 6 അക്ക OTP നൽകുക",
    "otp_code": "OTP കോഡ്",
    "send_otp": "OTP അയയ്ക്കുക",
    "verify_otp": "OTP സ്ഥിരീകരിക്കുക",
    "resend_otp": "OTP വീണ്ടും അയയ്ക്കുക",
    "change_number": "നമ്പർ മാറ്റുക",
    "otp_sent": "OTP നിങ്ങളുടെ മൊബൈൽ നമ്പറിലേക്ക് അയച്ചു.",
    "invalid_login": "നിങ്ങളുടെ പേരും ശരിയായ 10 അക്ക മൊബൈൽ നമ്പറും നൽകുക.",
    "invalid_otp": "ശരിയായ 6 അക്ക OTP നൽകുക.",
    "otp_failed": "OTP സ്ഥിരീകരണം പരാജയപ്പെട്ടു. വീണ്ടും ശ്രമിക്കുക.",
    "risk": "അപകടം",
    "report": "റിപ്പോർട്ട്",
    "weather": "കാലാവസ്ഥ",
    "pin": "PIN",
    "language": "ഭാഷ",
    "risk_monitor": "അപകട നിരീക്ഷണം",
    "live_gps": "ലൈവ് GPS",
    "refresh_gps": "GPS പുതുക്കുക",
    "open_maps": "മാപ്പിൽ സ്ഥലം തുറക്കുക",
    "latitude": "അക്ഷാംശം",
    "longitude": "രേഖാംശം",
    "accuracy": "GPS കൃത്യത",
    "location_off": "ഫോൺ ലൊക്കേഷൻ സേവനം ഓഫാണ്.",
    "permission_denied": "ലൊക്കേഷൻ അനുമതി ലഭിച്ചില്ല.",
    "open_settings": "ആപ്പ് സെറ്റിംഗ്സ് തുറക്കുക",
    "risk_low": "കുറവ്",
    "risk_medium": "മധ്യം",
    "risk_high": "ഉയർന്ന",
    "rain_screening": "മഴ അടിസ്ഥാനമാക്കിയുള്ള സ്ക്രീനിംഗ്",
    "next24rain": "അടുത്ത 24 മണിക്കൂർ മഴ",
    "not_probability": "മഴ സ്ക്രീനിംഗ് മണ്ണിടിച്ചിൽ ശതമാന സാധ്യതയല്ല.",
    "stage1": "ഘട്ടം 1 · മഴ മുന്നറിയിപ്പ്",
    "stage2": "ഘട്ടം 2 · അടിയന്തര മുന്നറിയിപ്പ്",
    "stage3": "ഘട്ടം 3 · സ്ഥിരീകരിച്ച സംഭവം",
    "stage1_inactive": "ഇപ്പോൾ കനത്ത മഴ മുന്നറിയിപ്പ് സജീവമല്ല.",
    "stage1_active":
        "കനത്ത മഴ പ്രവചിച്ചിട്ടുണ്ട്. അസ്ഥിര ചരിവുകളിൽ നിന്ന് അകലുകയും ഔദ്യോഗിക മുന്നറിയിപ്പുകൾ പാലിക്കുകയും ചെയ്യുക.",
    "stage2_need_feed":
        "5 മിനിറ്റ് മുൻകൂർ മുന്നറിയിപ്പിന് സ്ഥിരീകരിച്ച ചലന സെൻസർ അല്ലെങ്കിൽ ഔദ്യോഗിക അടിയന്തര ഫീഡ് ആവശ്യമാണ്. മൂല്യങ്ങൾ സൃഷ്ടിക്കില്ല.",
    "stage3_need_feed":
        "സ്ഥിരീകരിച്ച സംഭവം മുന്നറിയിപ്പിന് പരിശോധിച്ച ഔദ്യോഗിക ഉറവിടം ആവശ്യമാണ്. പൗര റിപ്പോർട്ടുകൾ റിപ്പോർട്ടുകളായിരിക്കും.",
    "seven_day": "7 ദിവസത്തെ കാലാവസ്ഥ",
    "forecast_gps": "നിങ്ങളുടെ GPS സ്ഥലത്തിനുള്ള ലൈവ് പ്രവചനം",
    "rain": "മഴ",
    "rain_chance": "മഴ സാധ്യത",
    "forecast_source": "പ്രവചന ഡാറ്റ: Open-Meteo",
    "today": "ഇന്ന്",
    "report_hazard": "അപകടം റിപ്പോർട്ട് ചെയ്യുക",
    "report_subtitle": "GPS ടാഗ് ചെയ്ത അപകട നിരീക്ഷണം സേവ് ചെയ്യുക",
    "hazard_type": "അപകട തരം",
    "severity": "തീവ്രത",
    "note": "കുറിപ്പ്",
    "save_report": "റിപ്പോർട്ട് സേവ് ചെയ്യുക",
    "saved_reports": "സേവ് ചെയ്ത റിപ്പോർട്ടുകൾ",
    "report_saved": "റിപ്പോർട്ട് ഈ ഉപകരണത്തിൽ സേവ് ചെയ്തു.",
    "type_landslide": "മണ്ണിടിച്ചിൽ / അവശിഷ്ടം",
    "type_crack": "നിലയിലെ പൊട്ടൽ",
    "type_rockfall": "പാറ വീഴൽ",
    "type_water": "അസാധാരണ ജലപ്രവാഹം",
    "type_tree": "മരം വീണ് റോഡ് തടസം",
    "sev_low": "കുറവ്",
    "sev_medium": "മധ്യം",
    "sev_high": "ഉയർന്ന",
    "pin_area": "PIN പ്രദേശം",
    "pin_subtitle": "ഇന്ത്യൻ 6 അക്ക PIN കോഡ് തിരയുക",
    "enter_pin": "PIN കോഡ് നൽകുക",
    "search": "തിരയുക",
    "district": "ജില്ല",
    "state": "സംസ്ഥാനം",
    "post_office": "പോസ്റ്റ് ഓഫീസ്",
    "pin_invalid": "ശരിയായ 6 അക്ക PIN കോഡ് നൽകുക.",
    "pin_not_found": "PIN കോഡ് കണ്ടെത്തിയില്ല.",
    "online": "ഓൺലൈൻ",
    "offline": "ഓഫ്‌ലൈൻ",
    "cached": "ഓഫ്‌ലൈൻ ആയതിനാൽ അവസാനമായി സേവ് ചെയ്ത ഡാറ്റ കാണിക്കുന്നു.",
    "language_offline": "ഭാഷയും ഓഫ്‌ലൈനും",
    "select_language": "ഭാഷ തിരഞ്ഞെടുക്കുക",
    "talk": "സഹായിയോട് സംസാരിക്കുക",
    "ask": "അപകടം, കാലാവസ്ഥ, GPS, PIN അല്ലെങ്കിൽ SOS കുറിച്ച് ചോദിക്കുക",
    "speak": "ചോദിക്കുക",
    "assistant": "സഹായി",
    "sos": "SOS",
    "emergency": "അടിയന്തര SOS",
    "reason": "കാരണം",
    "injured": "പരിക്ക് / നീങ്ങാൻ കഴിയില്ല",
    "trapped": "കുടുങ്ങി",
    "landslide_nearby": "അടുത്ത് മണ്ണിടിച്ചിൽ",
    "other": "മറ്റ്",
    "call112": "112 വിളിക്കുക",
    "copy_location": "സ്ഥലം പകർത്തുക",
    "sms_registered": "രജിസ്റ്റർ ചെയ്ത നമ്പറിലേക്ക് SMS തുറക്കുക",
    "logout": "ലോഗ് ഔട്ട്",
    "no_location": "സ്ഥലം ഇതുവരെ ലഭ്യമല്ല.",
    "profile": "പ്രൊഫൈൽ",
    "weather_clear": "തെളിഞ്ഞ ആകാശം",
    "weather_cloudy": "മേഘാവൃതം",
    "weather_fog": "മൂടൽമഞ്ഞ്",
    "weather_drizzle": "ചാറ്റൽമഴ",
    "weather_rain": "മഴ",
    "weather_snow": "മഞ്ഞ്",
    "weather_thunder": "ഇടിമിന്നൽ",
    "weather_unknown": "കാലാവസ്ഥ",
    "assistant_risk_low":
        "നിലവിലെ മഴ അടിസ്ഥാനമാക്കിയുള്ള അപകടം കുറവാണ്. ഔദ്യോഗിക മുന്നറിയിപ്പുകളും പ്രാദേശിക സാഹചര്യങ്ങളും ശ്രദ്ധിക്കുക.",
    "assistant_risk_medium":
        "നിലവിലെ മഴ അടിസ്ഥാനമാക്കിയുള്ള അപകടം മധ്യമാണ്. ജാഗ്രത പാലിച്ച് അസ്ഥിര ചരിവുകൾ ഒഴിവാക്കുക.",
    "assistant_risk_high":
        "കനത്ത മഴ പ്രവചനത്തെ തുടർന്ന് നിലവിലെ മഴ അടിസ്ഥാനമാക്കിയുള്ള അപകടം ഉയർന്നതാണ്. അസ്ഥിര ചരിവുകളിൽ നിന്ന് മാറി ഔദ്യോഗിക നിർദ്ദേശങ്ങൾ പാലിക്കുക.",
    "assistant_weather":
        "നിങ്ങളുടെ GPS സ്ഥലത്തിന്റെ ഏറ്റവും പുതിയ 7 ദിവസത്തെ പ്രവചനം കാണാൻ കാലാവസ്ഥ ടാബ് തുറക്കുക.",
    "assistant_sos":
        "പുതിയ സ്ഥലം പകർത്താൻ, SMS തുറക്കാൻ അല്ലെങ്കിൽ 112 ഡയലർ തുറക്കാൻ SOS ഉപയോഗിക്കുക.",
    "assistant_pin": "PIN ടാബ് തുറന്ന് 6 അക്ക ഇന്ത്യൻ PIN കോഡ് നൽകുക.",
    "assistant_location":
        "അപകട ടാബ് നിങ്ങളുടെ ഉപകരണത്തിന്റെ ഏറ്റവും പുതിയ GPS സ്ഥലം കാണിക്കുന്നു.",
    "assistant_default":
        "അപകടം, കാലാവസ്ഥ, GPS സ്ഥലം, PIN പ്രദേശങ്ങൾ, SOS എന്നിവയിൽ ഞാൻ സഹായിക്കാം.",
    "live_map": "ലൈവ് മാപ്പ്",
    "recenter": "വീണ്ടും മധ്യത്തിലാക്കുക",
    "map_hint":
        "മാപ്പ് നീക്കി സൂം ചെയ്യാം. മാർക്കർ നിങ്ങളുടെ ഏറ്റവും പുതിയ GPS സ്ഥലം ആണ്.",
    "mic_listening": "കേൾക്കുന്നു… ഇപ്പോൾ സംസാരിക്കുക.",
    "mic_unavailable":
        "ഈ ഉപകരണത്തിൽ ശബ്ദ തിരിച്ചറിയൽ ലഭ്യമല്ല. താഴെ നിങ്ങളുടെ ചോദ്യം ടൈപ്പ് ചെയ്യാം.",
    "mic_error": "മൈക്രോഫോൺ / ശബ്ദ തിരിച്ചറിയൽ പിശക്.",
  },
  "mr": {
    "app": "GEONEXA",
    "tagline": "पूर्वसूचना आणि धोका निरीक्षण",
    "continue": "पुढे जा",
    "name": "नाव",
    "mobile": "मोबाइल क्रमांक",
    "login_title": "GEONEXA मध्ये स्वागत",
    "login_subtitle": "पुढे जाण्यासाठी माहिती भरा",
    "otp_title": "मोबाइल क्रमांक सत्यापित करा",
    "otp_subtitle": "तुमच्या मोबाइलवर पाठवलेला 6 अंकी OTP टाका",
    "otp_code": "OTP कोड",
    "send_otp": "OTP पाठवा",
    "verify_otp": "OTP सत्यापित करा",
    "resend_otp": "OTP पुन्हा पाठवा",
    "change_number": "क्रमांक बदला",
    "otp_sent": "OTP तुमच्या मोबाइल क्रमांकावर पाठवला आहे.",
    "invalid_login": "तुमचे नाव आणि योग्य 10 अंकी मोबाइल क्रमांक टाका.",
    "invalid_otp": "योग्य 6 अंकी OTP टाका.",
    "otp_failed": "OTP सत्यापन अयशस्वी झाले. पुन्हा प्रयत्न करा.",
    "risk": "धोका",
    "report": "अहवाल",
    "weather": "हवामान",
    "pin": "पिन",
    "language": "भाषा",
    "risk_monitor": "धोका निरीक्षण",
    "live_gps": "लाइव्ह GPS",
    "refresh_gps": "GPS रीफ्रेश करा",
    "open_maps": "नकाशात स्थान उघडा",
    "latitude": "अक्षांश",
    "longitude": "रेखांश",
    "accuracy": "GPS अचूकता",
    "location_off": "फोनची लोकेशन सेवा बंद आहे.",
    "permission_denied": "लोकेशन परवानगी मिळाली नाही.",
    "open_settings": "अॅप सेटिंग उघडा",
    "risk_low": "कमी",
    "risk_medium": "मध्यम",
    "risk_high": "उच्च",
    "rain_screening": "पावसावर आधारित तपासणी",
    "next24rain": "पुढील 24 तासांचा पाऊस",
    "not_probability": "पावसाची तपासणी भूस्खलनाची टक्केवारी शक्यता नाही.",
    "stage1": "टप्पा 1 · पावसाचा इशारा",
    "stage2": "टप्पा 2 · तातडीचा इशारा",
    "stage3": "टप्पा 3 · पुष्टी घटना",
    "stage1_inactive": "सध्या मुसळधार पावसाचा इशारा सक्रिय नाही.",
    "stage1_active":
        "मुसळधार पावसाचा अंदाज आहे. अस्थिर उतारांपासून दूर रहा आणि अधिकृत सूचना पाळा.",
    "stage2_need_feed":
        "5 मिनिटांचा तातडीचा इशारा देण्यासाठी सत्यापित हालचाल सेन्सर किंवा अधिकृत फीड आवश्यक आहे. कोणतीही किंमत बनवली जात नाही.",
    "stage3_need_feed":
        "पुष्टी घटना इशाऱ्यासाठी सत्यापित अधिकृत स्रोत आवश्यक आहे. नागरिक अहवाल हे अहवालच राहतात.",
    "seven_day": "7 दिवसांचे हवामान",
    "forecast_gps": "तुमच्या GPS स्थानासाठी लाइव्ह अंदाज",
    "rain": "पाऊस",
    "rain_chance": "पावसाची शक्यता",
    "forecast_source": "अंदाज डेटा: Open-Meteo",
    "today": "आज",
    "report_hazard": "धोका नोंदवा",
    "report_subtitle": "GPS टॅगसह धोका निरीक्षण जतन करा",
    "hazard_type": "धोक्याचा प्रकार",
    "severity": "तीव्रता",
    "note": "टीप",
    "save_report": "अहवाल जतन करा",
    "saved_reports": "जतन केलेले अहवाल",
    "report_saved": "अहवाल या उपकरणात जतन झाला.",
    "type_landslide": "भूस्खलन / मलबा",
    "type_crack": "जमिनीतील भेग",
    "type_rockfall": "दगड कोसळणे",
    "type_water": "असामान्य पाण्याचा प्रवाह",
    "type_tree": "झाड पडून रस्ता बंद",
    "sev_low": "कमी",
    "sev_medium": "मध्यम",
    "sev_high": "उच्च",
    "pin_area": "पिन क्षेत्र",
    "pin_subtitle": "भारतीय 6 अंकी पिन कोड शोधा",
    "enter_pin": "पिन कोड टाका",
    "search": "शोधा",
    "district": "जिल्हा",
    "state": "राज्य",
    "post_office": "टपाल कार्यालय",
    "pin_invalid": "योग्य 6 अंकी पिन कोड टाका.",
    "pin_not_found": "पिन कोड सापडला नाही.",
    "online": "ऑनलाइन",
    "offline": "ऑफलाइन",
    "cached": "ऑफलाइन असल्याने शेवटचा जतन केलेला डेटा दाखवत आहे.",
    "language_offline": "भाषा आणि ऑफलाइन",
    "select_language": "भाषा निवडा",
    "talk": "सहाय्यकाशी बोला",
    "ask": "धोका, हवामान, GPS, पिन किंवा SOS बद्दल विचारा",
    "speak": "विचारा",
    "assistant": "सहाय्यक",
    "sos": "SOS",
    "emergency": "आपत्कालीन SOS",
    "reason": "कारण",
    "injured": "जखमी / हलू शकत नाही",
    "trapped": "अडकलेलो",
    "landslide_nearby": "जवळ भूस्खलन",
    "other": "इतर",
    "call112": "112 वर कॉल करा",
    "copy_location": "स्थान कॉपी करा",
    "sms_registered": "नोंदणीकृत क्रमांकावर SMS उघडा",
    "logout": "लॉग आउट",
    "no_location": "स्थान अजून उपलब्ध नाही.",
    "profile": "प्रोफाइल",
    "weather_clear": "स्वच्छ आकाश",
    "weather_cloudy": "ढगाळ",
    "weather_fog": "धुके",
    "weather_drizzle": "रिमझिम",
    "weather_rain": "पाऊस",
    "weather_snow": "हिम",
    "weather_thunder": "मेघगर्जना",
    "weather_unknown": "हवामान",
    "assistant_risk_low":
        "सध्याचा पावसावर आधारित धोका कमी आहे. अधिकृत सूचना आणि स्थानिक परिस्थिती पाहत रहा.",
    "assistant_risk_medium":
        "सध्याचा पावसावर आधारित धोका मध्यम आहे. सतर्क रहा आणि अस्थिर उतार टाळा.",
    "assistant_risk_high":
        "मुसळधार पावसाच्या अंदाजामुळे सध्याचा पावसावर आधारित धोका उच्च आहे. अस्थिर उतारांपासून दूर जा आणि अधिकृत सूचना पाळा.",
    "assistant_weather":
        "तुमच्या GPS स्थानाचा नवीनतम 7 दिवसांचा अंदाज पाहण्यासाठी हवामान टॅब उघडा.",
    "assistant_sos":
        "नवीनतम स्थान कॉपी करण्यासाठी, SMS उघडण्यासाठी किंवा 112 डायलर उघडण्यासाठी SOS वापरा.",
    "assistant_pin": "पिन टॅब उघडा आणि 6 अंकी भारतीय पिन कोड टाका.",
    "assistant_location": "धोका टॅब तुमच्या उपकरणाचे नवीनतम GPS स्थान दाखवतो.",
    "assistant_default":
        "मी धोका, हवामान, GPS स्थान, पिन क्षेत्र आणि SOS मध्ये मदत करू शकतो.",
    "live_map": "लाइव्ह नकाशा",
    "recenter": "पुन्हा मध्यभागी",
    "map_hint": "नकाशा हलवा आणि झूम करा. मार्कर तुमचे नवीनतम GPS स्थान आहे.",
    "mic_listening": "ऐकत आहे… आता बोला.",
    "mic_unavailable":
        "या उपकरणावर आवाज ओळख उपलब्ध नाही. खाली तुमचा प्रश्न टाइप करू शकता.",
    "mic_error": "मायक्रोफोन / आवाज ओळख त्रुटी.",
  },
  "bn": {
    "app": "GEONEXA",
    "tagline": "আগাম সতর্কতা ও ঝুঁকি পর্যবেক্ষণ",
    "continue": "চালিয়ে যান",
    "name": "নাম",
    "mobile": "মোবাইল নম্বর",
    "login_title": "GEONEXA-এ স্বাগতম",
    "login_subtitle": "চালিয়ে যেতে আপনার তথ্য দিন",
    "otp_title": "মোবাইল নম্বর যাচাই করুন",
    "otp_subtitle": "আপনার মোবাইলে পাঠানো ৬ সংখ্যার OTP লিখুন",
    "otp_code": "OTP কোড",
    "send_otp": "OTP পাঠান",
    "verify_otp": "OTP যাচাই করুন",
    "resend_otp": "OTP আবার পাঠান",
    "change_number": "নম্বর পরিবর্তন করুন",
    "otp_sent": "OTP আপনার মোবাইল নম্বরে পাঠানো হয়েছে।",
    "invalid_login": "আপনার নাম এবং সঠিক ১০ সংখ্যার মোবাইল নম্বর লিখুন।",
    "invalid_otp": "সঠিক ৬ সংখ্যার OTP লিখুন।",
    "otp_failed": "OTP যাচাই ব্যর্থ হয়েছে। আবার চেষ্টা করুন.",
    "risk": "ঝুঁকি",
    "report": "রিপোর্ট",
    "weather": "আবহাওয়া",
    "pin": "পিন",
    "language": "ভাষা",
    "risk_monitor": "ঝুঁকি পর্যবেক্ষণ",
    "live_gps": "লাইভ GPS",
    "refresh_gps": "GPS রিফ্রেশ করুন",
    "open_maps": "ম্যাপে অবস্থান খুলুন",
    "latitude": "অক্ষাংশ",
    "longitude": "দ্রাঘিমাংশ",
    "accuracy": "GPS নির্ভুলতা",
    "location_off": "ফোনের লোকেশন সেবা বন্ধ।",
    "permission_denied": "লোকেশন অনুমতি দেওয়া হয়নি।",
    "open_settings": "অ্যাপ সেটিং খুলুন",
    "risk_low": "কম",
    "risk_medium": "মাঝারি",
    "risk_high": "উচ্চ",
    "rain_screening": "বৃষ্টিভিত্তিক স্ক্রিনিং",
    "next24rain": "পরবর্তী ২৪ ঘণ্টার বৃষ্টি",
    "not_probability": "বৃষ্টিভিত্তিক স্ক্রিনিং ভূমিধসের শতাংশ সম্ভাবনা নয়।",
    "stage1": "ধাপ ১ · বৃষ্টি সতর্কতা",
    "stage2": "ধাপ ২ · আসন্ন সতর্কতা",
    "stage3": "ধাপ ৩ · নিশ্চিত ঘটনা",
    "stage1_inactive": "এখন ভারী বৃষ্টির সতর্কতা সক্রিয় নয়।",
    "stage1_active":
        "ভারী বৃষ্টির পূর্বাভাস আছে। অস্থিতিশীল ঢাল থেকে দূরে থাকুন এবং সরকারি সতর্কতা মানুন।",
    "stage2_need_feed":
        "৫ মিনিটের আসন্ন সতর্কতার জন্য যাচাইকৃত মুভমেন্ট সেন্সর বা সরকারি ফিড দরকার। কোনো মান বানানো হয় না।",
    "stage3_need_feed":
        "নিশ্চিত ঘটনার সতর্কতার জন্য যাচাইকৃত সরকারি উৎস দরকার। নাগরিক রিপোর্ট রিপোর্ট হিসেবেই থাকে।",
    "seven_day": "৭ দিনের আবহাওয়া",
    "forecast_gps": "আপনার GPS অবস্থানের লাইভ পূর্বাভাস",
    "rain": "বৃষ্টি",
    "rain_chance": "বৃষ্টির সম্ভাবনা",
    "forecast_source": "পূর্বাভাস ডেটা: Open-Meteo",
    "today": "আজ",
    "report_hazard": "ঝুঁকি রিপোর্ট করুন",
    "report_subtitle": "GPS-ট্যাগ করা ঝুঁকি পর্যবেক্ষণ সংরক্ষণ করুন",
    "hazard_type": "ঝুঁকির ধরন",
    "severity": "তীব্রতা",
    "note": "নোট",
    "save_report": "রিপোর্ট সংরক্ষণ",
    "saved_reports": "সংরক্ষিত রিপোর্ট",
    "report_saved": "রিপোর্ট এই ডিভাইসে সংরক্ষিত হয়েছে।",
    "type_landslide": "ভূমিধস / ধ্বংসাবশেষ",
    "type_crack": "মাটিতে ফাটল",
    "type_rockfall": "পাথর পড়া",
    "type_water": "অস্বাভাবিক জলপ্রবাহ",
    "type_tree": "গাছ পড়ে রাস্তা বন্ধ",
    "sev_low": "কম",
    "sev_medium": "মাঝারি",
    "sev_high": "উচ্চ",
    "pin_area": "পিন এলাকা",
    "pin_subtitle": "ভারতের ৬-সংখ্যার পিন কোড খুঁজুন",
    "enter_pin": "পিন কোড লিখুন",
    "search": "খুঁজুন",
    "district": "জেলা",
    "state": "রাজ্য",
    "post_office": "ডাকঘর",
    "pin_invalid": "সঠিক ৬-সংখ্যার পিন কোড দিন।",
    "pin_not_found": "পিন কোড পাওয়া যায়নি।",
    "online": "অনলাইন",
    "offline": "অফলাইন",
    "cached": "অফলাইনে শেষ সংরক্ষিত ডেটা দেখানো হচ্ছে।",
    "language_offline": "ভাষা ও অফলাইন",
    "select_language": "ভাষা নির্বাচন করুন",
    "talk": "সহকারীর সাথে কথা বলুন",
    "ask": "ঝুঁকি, আবহাওয়া, GPS, পিন বা SOS সম্পর্কে জিজ্ঞাসা করুন",
    "speak": "জিজ্ঞাসা করুন",
    "assistant": "সহকারী",
    "sos": "SOS",
    "emergency": "জরুরি SOS",
    "reason": "কারণ",
    "injured": "আহত / নড়তে পারছি না",
    "trapped": "আটকে পড়েছি",
    "landslide_nearby": "কাছাকাছি ভূমিধস",
    "other": "অন্যান্য",
    "call112": "112-এ কল করুন",
    "copy_location": "অবস্থান কপি করুন",
    "sms_registered": "নিবন্ধিত নম্বরে SMS খুলুন",
    "logout": "লগ আউট",
    "no_location": "অবস্থান এখনও পাওয়া যায়নি।",
    "profile": "প্রোফাইল",
    "weather_clear": "পরিষ্কার আকাশ",
    "weather_cloudy": "মেঘলা",
    "weather_fog": "কুয়াশা",
    "weather_drizzle": "গুঁড়ি গুঁড়ি বৃষ্টি",
    "weather_rain": "বৃষ্টি",
    "weather_snow": "তুষার",
    "weather_thunder": "বজ্রঝড়",
    "weather_unknown": "আবহাওয়া",
    "assistant_risk_low":
        "বর্তমান বৃষ্টিভিত্তিক ঝুঁকি কম। সরকারি সতর্কতা ও স্থানীয় অবস্থা নজরে রাখুন.",
    "assistant_risk_medium":
        "বর্তমান বৃষ্টিভিত্তিক ঝুঁকি মাঝারি। সতর্ক থাকুন এবং অস্থিতিশীল ঢাল এড়িয়ে চলুন।",
    "assistant_risk_high":
        "ভারী বৃষ্টির পূর্বাভাসের কারণে বর্তমান বৃষ্টিভিত্তিক ঝুঁকি উচ্চ। অস্থিতিশীল ঢাল থেকে দূরে যান এবং সরকারি নির্দেশ মানুন।",
    "assistant_weather":
        "আপনার GPS অবস্থানের সর্বশেষ ৭ দিনের পূর্বাভাস দেখতে আবহাওয়া ট্যাব খুলুন।",
    "assistant_sos":
        "সর্বশেষ অবস্থান কপি করতে, SMS খুলতে বা 112 ডায়ালার খুলতে SOS ব্যবহার করুন।",
    "assistant_pin": "পিন ট্যাব খুলে ৬-সংখ্যার ভারতীয় পিন কোড লিখুন।",
    "assistant_location":
        "ঝুঁকি ট্যাব আপনার ডিভাইসের সর্বশেষ GPS অবস্থান দেখায়।",
    "assistant_default":
        "আমি ঝুঁকি, আবহাওয়া, GPS অবস্থান, পিন এলাকা ও SOS নিয়ে সাহায্য করতে পারি।",
    "live_map": "লাইভ ম্যাপ",
    "recenter": "আবার কেন্দ্রে আনুন",
    "map_hint": "ম্যাপ টেনে ও জুম করুন। মার্কারটি আপনার সর্বশেষ GPS অবস্থান।",
    "mic_listening": "শুনছি… এখন বলুন।",
    "mic_unavailable":
        "এই ডিভাইসে স্পিচ রিকগনিশন উপলভ্য নয়। নিচে প্রশ্ন টাইপ করতে পারেন।",
    "mic_error": "মাইক্রোফোন / স্পিচ রিকগনিশন ত্রুটি।",
  },
  "as": {
    "app": "GEONEXA",
    "tagline": "আগতীয়া সতৰ্কতা আৰু বিপদ নিৰীক্ষণ",
    "continue": "আগবাঢ়ক",
    "name": "নাম",
    "mobile": "ম'বাইল নম্বৰ",
    "login_title": "GEONEXA লৈ স্বাগতম",
    "login_subtitle": "আগবাঢ়িবলৈ আপোনাৰ তথ্য দিয়ক",
    "otp_title": "মোবাইল নম্বৰ যাচাই কৰক",
    "otp_subtitle": "আপোনাৰ মোবাইললৈ পঠিওৱা ৬ সংখ্যাৰ OTP লিখক",
    "otp_code": "OTP কোড",
    "send_otp": "OTP পঠিয়াওক",
    "verify_otp": "OTP যাচাই কৰক",
    "resend_otp": "OTP পুনৰ পঠিয়াওক",
    "change_number": "নম্বৰ সলনি কৰক",
    "otp_sent": "OTP আপোনাৰ মোবাইল নম্বৰলৈ পঠিওৱা হৈছে।",
    "invalid_login": "আপোনাৰ নাম আৰু সঠিক ১০ সংখ্যাৰ মোবাইল নম্বৰ লিখক।",
    "invalid_otp": "সঠিক ৬ সংখ্যাৰ OTP লিখক।",
    "otp_failed": "OTP যাচাই ব্যৰ্থ হৈছে। পুনৰ চেষ্টা কৰক.",
    "risk": "বিপদ",
    "report": "প্ৰতিবেদন",
    "weather": "বতৰ",
    "pin": "পিন",
    "language": "ভাষা",
    "risk_monitor": "বিপদ নিৰীক্ষণ",
    "live_gps": "লাইভ GPS",
    "refresh_gps": "GPS পুনৰ লওক",
    "open_maps": "মানচিত্ৰত অৱস্থান খোলক",
    "latitude": "অক্ষাংশ",
    "longitude": "দ্ৰাঘিমাংশ",
    "accuracy": "GPS সঠিকতা",
    "location_off": "ফোনৰ লোকেচন সেৱা বন্ধ।",
    "permission_denied": "লোকেচন অনুমতি দিয়া হোৱা নাই।",
    "open_settings": "এপ ছেটিং খোলক",
    "risk_low": "কম",
    "risk_medium": "মধ্যম",
    "risk_high": "উচ্চ",
    "rain_screening": "বৰষুণভিত্তিক স্ক্ৰিনিং",
    "next24rain": "পৰৱৰ্তী ২৪ ঘণ্টাৰ বৰষুণ",
    "not_probability": "বৰষুণভিত্তিক স্ক্ৰিনিং ভূমিস্খলনৰ শতাংশ সম্ভাৱনা নহয়।",
    "stage1": "পৰ্যায় ১ · বৰষুণ সতৰ্কতা",
    "stage2": "পৰ্যায় ২ · তাৎক্ষণিক সতৰ্কতা",
    "stage3": "পৰ্যায় ৩ · নিশ্চিত ঘটনা",
    "stage1_inactive": "এতিয়া ভাৰী বৰষুণ সতৰ্কতা সক্ৰিয় নহয়।",
    "stage1_active":
        "ভাৰী বৰষুণৰ পূৰ্বানুমান আছে। অস্থিৰ ঢালৰ পৰা আঁতৰি থাকক আৰু চৰকাৰী সতৰ্কতা মানক।",
    "stage2_need_feed":
        "৫ মিনিট আগৰ সতৰ্কতাৰ বাবে যাচাইকৃত মুভমেণ্ট ছেন্সৰ বা চৰকাৰী তাৎক্ষণিক ফিড লাগে। কোনো মান কল্পনা কৰা নহয়।",
    "stage3_need_feed":
        "নিশ্চিত ঘটনা সতৰ্কতাৰ বাবে যাচাইকৃত চৰকাৰী উৎস লাগে। নাগৰিক প্ৰতিবেদন প্ৰতিবেদন হিচাপেই থাকে।",
    "seven_day": "৭ দিনৰ বতৰ",
    "forecast_gps": "আপোনাৰ GPS অৱস্থানৰ লাইভ পূৰ্বানুমান",
    "rain": "বৰষুণ",
    "rain_chance": "বৰষুণৰ সম্ভাৱনা",
    "forecast_source": "পূৰ্বানুমান ডাটা: Open-Meteo",
    "today": "আজি",
    "report_hazard": "বিপদ প্ৰতিবেদন কৰক",
    "report_subtitle": "GPS-টেগ কৰা বিপদ পৰ্যবেক্ষণ সংৰক্ষণ কৰক",
    "hazard_type": "বিপদৰ প্ৰকাৰ",
    "severity": "তীব্ৰতা",
    "note": "টোকা",
    "save_report": "প্ৰতিবেদন সংৰক্ষণ কৰক",
    "saved_reports": "সংৰক্ষিত প্ৰতিবেদন",
    "report_saved": "প্ৰতিবেদন এই ডিভাইচত সংৰক্ষিত হৈছে।",
    "type_landslide": "ভূমিস্খলন / ধ্বংসাৱশেষ",
    "type_crack": "মাটিৰ ফাট",
    "type_rockfall": "শিল পৰিব",
    "type_water": "অস্বাভাৱিক পানীৰ প্ৰবাহ",
    "type_tree": "গছ পৰি পথ বন্ধ",
    "sev_low": "কম",
    "sev_medium": "মধ্যম",
    "sev_high": "উচ্চ",
    "pin_area": "পিন এলেকা",
    "pin_subtitle": "ভাৰতীয় ৬ অংকৰ পিন কোড বিচাৰক",
    "enter_pin": "পিন কোড লিখক",
    "search": "বিচাৰক",
    "district": "জিলা",
    "state": "ৰাজ্য",
    "post_office": "ডাকঘৰ",
    "pin_invalid": "সঠিক ৬ অংকৰ পিন কোড লিখক।",
    "pin_not_found": "পিন কোড পোৱা নগ'ল।",
    "online": "অনলাইন",
    "offline": "অফলাইন",
    "cached": "অফলাইনত শেষ সংৰক্ষিত ডাটা দেখুওৱা হৈছে।",
    "language_offline": "ভাষা আৰু অফলাইন",
    "select_language": "ভাষা বাছক",
    "talk": "সহায়কৰ সৈতে কথা পাতক",
    "ask": "বিপদ, বতৰ, GPS, পিন বা SOS বিষয়ে সোধক",
    "speak": "সোধক",
    "assistant": "সহায়ক",
    "sos": "SOS",
    "emergency": "জৰুৰী SOS",
    "reason": "কাৰণ",
    "injured": "আহত / চলিব নোৱাৰা",
    "trapped": "আটকা পৰিছোঁ",
    "landslide_nearby": "ওচৰত ভূমিস্খলন",
    "other": "অন্য",
    "call112": "112 লৈ ফোন কৰক",
    "copy_location": "অৱস্থান কপি কৰক",
    "sms_registered": "নিবন্ধিত নম্বৰলৈ SMS খোলক",
    "logout": "লগ আউট",
    "no_location": "অৱস্থান এতিয়াও পোৱা নাই।",
    "profile": "প্ৰফাইল",
    "weather_clear": "পৰিষ্কাৰ আকাশ",
    "weather_cloudy": "মেঘলা",
    "weather_fog": "কুঁৱলী",
    "weather_drizzle": "টুপটাপ বৰষুণ",
    "weather_rain": "বৰষুণ",
    "weather_snow": "বৰফ",
    "weather_thunder": "ধুমুহা",
    "weather_unknown": "বতৰ",
    "assistant_risk_low":
        "বৰ্তমানৰ বৰষুণভিত্তিক বিপদ কম। চৰকাৰী সতৰ্কতা আৰু স্থানীয় অৱস্থা লক্ষ্য কৰি থাকক।",
    "assistant_risk_medium":
        "বৰ্তমানৰ বৰষুণভিত্তিক বিপদ মধ্যম। সতৰ্ক থাকক আৰু অস্থিৰ ঢাল এৰাই চলক।",
    "assistant_risk_high":
        "ভাৰী বৰষুণৰ পূৰ্বানুমানৰ বাবে বৰ্তমানৰ বিপদ উচ্চ। অস্থিৰ ঢালৰ পৰা আঁতৰি চৰকাৰী নিৰ্দেশ মানক।",
    "assistant_weather":
        "আপোনাৰ GPS অৱস্থানৰ শেহতীয়া ৭ দিনৰ পূৰ্বানুমানৰ বাবে বতৰ টেব খোলক।",
    "assistant_sos":
        "শেহতীয়া অৱস্থান কপি কৰিবলৈ, SMS খুলিবলৈ বা 112 ডায়েলাৰ খুলিবলৈ SOS ব্যৱহাৰ কৰক।",
    "assistant_pin": "পিন টেব খুলি ৬ অংকৰ ভাৰতীয় পিন কোড লিখক।",
    "assistant_location":
        "বিপদ টেবে আপোনাৰ ডিভাইচৰ শেহতীয়া GPS অৱস্থান দেখুৱায়।",
    "assistant_default":
        "মই বিপদ, বতৰ, GPS অৱস্থান, পিন এলেকা আৰু SOS বিষয়ে সহায় কৰিব পাৰোঁ।",
    "live_map": "লাইভ মানচিত্ৰ",
    "recenter": "পুনৰ কেন্দ্ৰিত কৰক",
    "map_hint":
        "মানচিত্ৰ টানি আৰু জুম কৰক। মাৰ্কাৰটো আপোনাৰ শেহতীয়া GPS অৱস্থান।",
    "mic_listening": "শুনি আছে… এতিয়া কওক।",
    "mic_unavailable":
        "এই ডিভাইচত কথাৰ চিনাক্তকৰণ উপলব্ধ নহয়। তলত আপোনাৰ প্ৰশ্ন টাইপ কৰিব পাৰে।",
    "mic_error": "মাইক্ৰ'ফোন / কথাৰ চিনাক্তকৰণ ত্ৰুটি।",
  },
  "ne": {
    "app": "GEONEXA",
    "tagline": "पूर्व चेतावनी र जोखिम निगरानी",
    "continue": "जारी राख्नुहोस्",
    "name": "नाम",
    "mobile": "मोबाइल नम्बर",
    "login_title": "GEONEXA मा स्वागत छ",
    "login_subtitle": "जारी राख्न आफ्नो विवरण प्रविष्ट गर्नुहोस्",
    "otp_title": "मोबाइल नम्बर प्रमाणित गर्नुहोस्",
    "otp_subtitle": "तपाईंको मोबाइलमा पठाइएको ६ अङ्कको OTP प्रविष्ट गर्नुहोस्",
    "otp_code": "OTP कोड",
    "send_otp": "OTP पठाउनुहोस्",
    "verify_otp": "OTP प्रमाणित गर्नुहोस्",
    "resend_otp": "OTP पुनः पठाउनुहोस्",
    "change_number": "नम्बर परिवर्तन गर्नुहोस्",
    "otp_sent": "OTP तपाईंको मोबाइल नम्बरमा पठाइएको छ।",
    "invalid_login":
        "आफ्नो नाम र सही १० अङ्कको मोबाइल नम्बर प्रविष्ट गर्नुहोस्।",
    "invalid_otp": "सही ६ अङ्कको OTP प्रविष्ट गर्नुहोस्।",
    "otp_failed": "OTP प्रमाणीकरण असफल भयो। फेरि प्रयास गर्नुहोस्.",
    "risk": "जोखिम",
    "report": "रिपोर्ट",
    "weather": "मौसम",
    "pin": "पिन",
    "language": "भाषा",
    "risk_monitor": "जोखिम निगरानी",
    "live_gps": "लाइभ GPS",
    "refresh_gps": "GPS रिफ्रेस गर्नुहोस्",
    "open_maps": "नक्सामा स्थान खोल्नुहोस्",
    "latitude": "अक्षांश",
    "longitude": "देशान्तर",
    "accuracy": "GPS शुद्धता",
    "location_off": "फोनको स्थान सेवा बन्द छ।",
    "permission_denied": "स्थान अनुमति दिइएन।",
    "open_settings": "एप सेटिङ खोल्नुहोस्",
    "risk_low": "कम",
    "risk_medium": "मध्यम",
    "risk_high": "उच्च",
    "rain_screening": "वर्षा आधारित जाँच",
    "next24rain": "अर्को २४ घण्टाको वर्षा",
    "not_probability": "वर्षा आधारित जाँच पहिरोको प्रतिशत सम्भावना होइन।",
    "stage1": "चरण १ · वर्षा चेतावनी",
    "stage2": "चरण २ · आसन्न चेतावनी",
    "stage3": "चरण ३ · पुष्टि घटना",
    "stage1_inactive": "अहिले भारी वर्षा चेतावनी सक्रिय छैन।",
    "stage1_active":
        "भारी वर्षाको पूर्वानुमान छ। अस्थिर भिरबाट टाढा रहनुहोस् र आधिकारिक चेतावनी पालना गर्नुहोस्।",
    "stage2_need_feed":
        "५ मिनेटको आसन्न चेतावनीका लागि प्रमाणित मूभमेन्ट सेन्सर वा आधिकारिक फिड चाहिन्छ। कुनै मान बनाइँदैन।",
    "stage3_need_feed":
        "पुष्टि घटना चेतावनीका लागि प्रमाणित आधिकारिक स्रोत चाहिन्छ। नागरिक रिपोर्ट रिपोर्टकै रूपमा रहन्छ।",
    "seven_day": "७-दिने मौसम",
    "forecast_gps": "तपाईंको GPS स्थानको लाइभ पूर्वानुमान",
    "rain": "वर्षा",
    "rain_chance": "वर्षाको सम्भावना",
    "forecast_source": "पूर्वानुमान डेटा: Open-Meteo",
    "today": "आज",
    "report_hazard": "जोखिम रिपोर्ट गर्नुहोस्",
    "report_subtitle": "GPS ट्याग गरिएको जोखिम अवलोकन सुरक्षित गर्नुहोस्",
    "hazard_type": "जोखिम प्रकार",
    "severity": "गम्भीरता",
    "note": "नोट",
    "save_report": "रिपोर्ट सुरक्षित गर्नुहोस्",
    "saved_reports": "सुरक्षित रिपोर्ट",
    "report_saved": "रिपोर्ट यस उपकरणमा सुरक्षित भयो।",
    "type_landslide": "पहिरो / मलबा",
    "type_crack": "जमिन चिरा",
    "type_rockfall": "ढुंगा खस्नु",
    "type_water": "असामान्य पानी बहाव",
    "type_tree": "रुख ढलेर बाटो बन्द",
    "sev_low": "कम",
    "sev_medium": "मध्यम",
    "sev_high": "उच्च",
    "pin_area": "पिन क्षेत्र",
    "pin_subtitle": "भारतीय ६-अङ्कको पिन कोड खोज्नुहोस्",
    "enter_pin": "पिन कोड लेख्नुहोस्",
    "search": "खोज्नुहोस्",
    "district": "जिल्ला",
    "state": "राज्य",
    "post_office": "हुलाक कार्यालय",
    "pin_invalid": "सही ६-अङ्कको पिन कोड लेख्नुहोस्।",
    "pin_not_found": "पिन कोड भेटिएन।",
    "online": "अनलाइन",
    "offline": "अफलाइन",
    "cached": "अफलाइन हुँदा अन्तिम सुरक्षित डेटा देखाइँदैछ।",
    "language_offline": "भाषा र अफलाइन",
    "select_language": "भाषा छान्नुहोस्",
    "talk": "सहायकसँग कुरा गर्नुहोस्",
    "ask": "जोखिम, मौसम, GPS, पिन वा SOS बारे सोध्नुहोस्",
    "speak": "सोध्नुहोस्",
    "assistant": "सहायक",
    "sos": "SOS",
    "emergency": "आपतकालीन SOS",
    "reason": "कारण",
    "injured": "घाइते / चल्न नसक्ने",
    "trapped": "फसेको",
    "landslide_nearby": "नजिक पहिरो",
    "other": "अन्य",
    "call112": "112 मा कल गर्नुहोस्",
    "copy_location": "स्थान कपी गर्नुहोस्",
    "sms_registered": "दर्ता नम्बरमा SMS खोल्नुहोस्",
    "logout": "लग आउट",
    "no_location": "स्थान अझै उपलब्ध छैन।",
    "profile": "प्रोफाइल",
    "weather_clear": "सफा आकाश",
    "weather_cloudy": "बादल",
    "weather_fog": "कुहिरो",
    "weather_drizzle": "सिमसिमे वर्षा",
    "weather_rain": "वर्षा",
    "weather_snow": "हिउँ",
    "weather_thunder": "मेघगर्जन",
    "weather_unknown": "मौसम",
    "assistant_risk_low":
        "हालको वर्षा आधारित जोखिम कम छ। आधिकारिक चेतावनी र स्थानीय अवस्था हेर्दै गर्नुहोस्।",
    "assistant_risk_medium":
        "हालको वर्षा आधारित जोखिम मध्यम छ। सतर्क रहनुहोस् र अस्थिर भिरबाट टाढा रहनुहोस्।",
    "assistant_risk_high":
        "भारी वर्षा पूर्वानुमानका कारण हालको वर्षा आधारित जोखिम उच्च छ। अस्थिर भिरबाट टाढा जानुहोस् र आधिकारिक निर्देशन पालना गर्नुहोस्।",
    "assistant_weather":
        "तपाईंको GPS स्थानको पछिल्लो ७-दिने पूर्वानुमान हेर्न मौसम ट्याब खोल्नुहोस्।",
    "assistant_sos":
        "पछिल्लो स्थान कपी गर्न, SMS खोल्न वा 112 डायलर खोल्न SOS प्रयोग गर्नुहोस्।",
    "assistant_pin":
        "पिन ट्याब खोल्नुहोस् र ६-अङ्कको भारतीय पिन कोड लेख्नुहोस्।",
    "assistant_location":
        "जोखिम ट्याबले तपाईंको उपकरणको पछिल्लो GPS स्थान देखाउँछ।",
    "assistant_default":
        "म जोखिम, मौसम, GPS स्थान, पिन क्षेत्र र SOS मा मद्दत गर्न सक्छु।",
    "live_map": "लाइभ नक्सा",
    "recenter": "फेरि केन्द्रित गर्नुहोस्",
    "map_hint":
        "नक्सा सार्नुहोस् र जुम गर्नुहोस्। मार्कर तपाईंको पछिल्लो GPS स्थान हो।",
    "mic_listening": "सुन्दैछ… अब बोल्नुहोस्।",
    "mic_unavailable":
        "यस उपकरणमा आवाज पहिचान उपलब्ध छैन। तल आफ्नो प्रश्न टाइप गर्न सक्नुहुन्छ।",
    "mic_error": "माइक्रोफोन / आवाज पहिचान त्रुटि।",
  },
};

const Map<String, Map<String, String>> extraI18n = {
  'en': {
    'assistant_subtitle': 'One place for voice and typed help',
    'assistant_unknown':
        'I do not have a verified answer for that question. I can reliably help with GEONEXA risk, weather, GPS, hazard reports, PIN areas, SOS and verified impact information.',
    'assistant_impact':
        'Affected roads, safe routes, road length, schools, hospitals, people affected and event timing are shown only when a verified official alert provides enough geospatial data. I will not invent these values.',
    'live_data': 'LIVE',
    'cached_data': 'CACHED',
    'updating': 'Updating live data…',
    'photo_evidence': 'Photo evidence',
    'take_photo': 'Take photo',
    'choose_photo': 'Choose photo',
    'remove_photo': 'Remove photo',
    'report_screening': 'Report screening',
    'screening_note':
        'Multi-signal screening uses report type, selected severity, attached evidence, note text and available rainfall. It is not an official landslide confirmation.',
    'alert_sent_device': 'High-priority alert shown on this device.',
    'verified_impact': 'Verified Area & Road Impact',
    'impact_truth':
        'Road closures, safe roads, dangerous road length, affected schools/hospitals, people affected and event times require a verified official event boundary/feed. When that evidence is unavailable, GEONEXA shows “unavailable” instead of guessing.',
    'road_impact_unknown':
        'Affected / safe roads: unavailable without a verified live road-impact feed.',
    'people_impact_unknown':
        'People / buildings affected: unavailable without verified official counts.',
    'event_time_unknown':
        'Event timing: no verified active-event timestamp is available from the connected sources.',
    'open_sachet': 'Open NDMA SACHET',
    'open_bhooskhalan': 'Open GSI Bhooskhalan',
    'last_updated': 'Last updated',
    'place_refreshing': 'Resolving exact place…',
    'report_location': 'Report location',
    'photo_saved': 'Photo attached and stored on this device.',
    'camera_error': 'Could not attach the photo.',
    'screen_low_advice':
        'LOW screening: keep observing from a safe distance. Avoid touching cracks or loose debris and report again if conditions worsen.',
    'screen_medium_advice':
        'MEDIUM screening: stay alert, avoid unstable slopes and blocked drains, and watch official alerts and local conditions.',
    'screen_high_advice':
        'HIGH screening: move away from unstable slopes, do not cross fresh debris or falling-rock areas, warn nearby people if safe to do so, and follow official instructions. Call 112 only if there is immediate danger or someone needs emergency help.',
    'official_alerts': 'Verified Official Alerts',
    'official_alerts_note':
        'Live alerts are read inside GEONEXA from the official NDMA SACHET feed. No external page is opened.',
    'official_no_landslide':
        'No active landslide alert was found in the current NDMA feed at the last refresh. This does not prove the area is safe; continue following local authorities and on-ground conditions.',
    'official_feed_unavailable':
        'The official alert feed is temporarily unavailable. GEONEXA will not invent an alert.',
    'official_source': 'Source',
    'official_area': 'Affected area',
    'official_severity': 'Severity',
    'official_validity': 'Validity',
    'official_refresh': 'Refresh official alerts',
    'gsi_status': 'GSI / National Landslide Forecasting Centre',
    'gsi_source_reachable':
        'GSI Bhusanket source is reachable. Event-specific bulletin details are shown only when a machine-readable official feed is available; GEONEXA will not infer a local forecast.',
    'gsi_source_unavailable':
        'GSI Bhusanket source is not reachable right now. No GSI forecast is being guessed.',
    'notification_free_note':
        'High-risk alerts use a free local Android notification on this device. This is not an SMS.',
  },
  'hi': {
    'assistant_subtitle': 'आवाज़ और टाइप सहायता के लिए एक ही पेज',
    'assistant_unknown':
        'इस प्रश्न का मेरे पास सत्यापित उत्तर नहीं है। मैं जोखिम, मौसम, GPS, खतरा रिपोर्ट, PIN, SOS और सत्यापित प्रभाव जानकारी में मदद कर सकता हूँ।',
    'assistant_impact':
        'प्रभावित सड़क, सुरक्षित मार्ग, सड़क की लंबाई, स्कूल, अस्पताल, प्रभावित लोग और समय तभी दिखाए जाते हैं जब सत्यापित आधिकारिक डेटा उपलब्ध हो। कोई मान गढ़ा नहीं जाता।',
    'live_data': 'लाइव',
    'cached_data': 'सहेजा हुआ',
    'updating': 'लाइव डेटा अपडेट हो रहा है…',
    'photo_evidence': 'फोटो प्रमाण',
    'take_photo': 'फोटो लें',
    'choose_photo': 'फोटो चुनें',
    'remove_photo': 'फोटो हटाएँ',
    'report_screening': 'रिपोर्ट जांच',
    'screening_note':
        'रिपोर्ट प्रकार, चुनी गंभीरता, फोटो, नोट और उपलब्ध वर्षा को मिलाकर जांच की जाती है। यह आधिकारिक भूस्खलन पुष्टि नहीं है।',
    'alert_sent_device': 'इस डिवाइस पर उच्च-प्राथमिकता अलर्ट दिखाया गया।',
    'verified_impact': 'सत्यापित क्षेत्र और सड़क प्रभाव',
    'impact_truth':
        'सड़क बंद, सुरक्षित सड़क, खतरनाक सड़क लंबाई, प्रभावित स्कूल/अस्पताल, लोग और घटना समय के लिए सत्यापित आधिकारिक घटना डेटा जरूरी है। डेटा न हो तो ऐप अनुमान नहीं लगाता।',
    'road_impact_unknown':
        'प्रभावित / सुरक्षित सड़कें: सत्यापित लाइव फीड के बिना उपलब्ध नहीं।',
    'people_impact_unknown':
        'प्रभावित लोग / इमारतें: सत्यापित आधिकारिक संख्या उपलब्ध नहीं।',
    'event_time_unknown': 'घटना समय: सत्यापित सक्रिय घटना समय उपलब्ध नहीं।',
    'open_sachet': 'NDMA SACHET खोलें',
    'open_bhooskhalan': 'GSI Bhooskhalan खोलें',
    'last_updated': 'अंतिम अपडेट',
    'place_refreshing': 'सटीक स्थान खोजा जा रहा है…',
    'report_location': 'रिपोर्ट स्थान',
    'photo_saved': 'फोटो इस डिवाइस पर सुरक्षित किया गया।',
    'camera_error': 'फोटो जोड़ नहीं सके।',
    'screen_low_advice':
        'कम जोखिम: सुरक्षित दूरी से देखते रहें। दरार या ढीले मलबे को न छुएँ और स्थिति बिगड़े तो फिर रिपोर्ट करें।',
    'screen_medium_advice':
        'मध्यम जोखिम: सतर्क रहें, अस्थिर ढाल और बंद नालियों से दूर रहें और आधिकारिक अलर्ट देखें।',
    'screen_high_advice':
        'उच्च जोखिम: अस्थिर ढाल से दूर जाएँ, ताज़े मलबे या गिरते पत्थरों वाले क्षेत्र को पार न करें और आधिकारिक निर्देश मानें। तुरंत खतरे में 112 पर कॉल करें।',
    'notification_free_note':
        'उच्च जोखिम अलर्ट इस डिवाइस पर मुफ्त स्थानीय Android नोटिफिकेशन है; यह SMS नहीं है।',
  },
  'kn': {
    'assistant_subtitle': 'ಧ್ವನಿ ಮತ್ತು ಟೈಪ್ ಸಹಾಯಕ್ಕೆ ಒಂದೇ ಪುಟ',
    'assistant_unknown':
        'ಈ ಪ್ರಶ್ನೆಗೆ ಪರಿಶೀಲಿತ ಉತ್ತರ ನನ್ನ ಬಳಿ ಇಲ್ಲ. ಅಪಾಯ, ಹವಾಮಾನ, GPS, ವರದಿ, PIN, SOS ಮತ್ತು ಪರಿಶೀಲಿತ ಪರಿಣಾಮ ಮಾಹಿತಿಯಲ್ಲಿ ಸಹಾಯ ಮಾಡಬಹುದು.',
    'assistant_impact':
        'ರಸ್ತೆ, ಸುರಕ್ಷಿತ ಮಾರ್ಗ, ಶಾಲೆ, ಆಸ್ಪತ್ರೆ, ಜನರು ಮತ್ತು ಸಮಯದ ಪರಿಣಾಮವನ್ನು ಪರಿಶೀಲಿತ ಅಧಿಕೃತ ಡೇಟಾ ಇದ್ದಾಗ ಮಾತ್ರ ತೋರಿಸಲಾಗುತ್ತದೆ.',
    'live_data': 'ಲೈವ್',
    'cached_data': 'ಸಂಗ್ರಹಿತ',
    'updating': 'ಲೈವ್ ಡೇಟಾ ನವೀಕರಿಸಲಾಗುತ್ತಿದೆ…',
    'photo_evidence': 'ಫೋಟೋ ಸಾಕ್ಷ್ಯ',
    'take_photo': 'ಫೋಟೋ ತೆಗೆದುಕೊಳ್ಳಿ',
    'choose_photo': 'ಫೋಟೋ ಆಯ್ಕೆಮಾಡಿ',
    'remove_photo': 'ಫೋಟೋ ತೆಗೆದುಹಾಕಿ',
    'report_screening': 'ವರದಿ ಪರಿಶೀಲನೆ',
    'screening_note':
        'ವರದಿ ಪ್ರಕಾರ, ತೀವ್ರತೆ, ಫೋಟೋ, ಟಿಪ್ಪಣಿ ಮತ್ತು ಲಭ್ಯ ಮಳೆಯನ್ನು ಸೇರಿಸಿ ಪರಿಶೀಲಿಸಲಾಗುತ್ತದೆ. ಇದು ಅಧಿಕೃತ ಭೂಕುಸಿತ ದೃಢೀಕರಣವಲ್ಲ.',
    'alert_sent_device': 'ಈ ಸಾಧನದಲ್ಲಿ ಹೆಚ್ಚಿನ ಆದ್ಯತೆಯ ಎಚ್ಚರಿಕೆ ತೋರಿಸಲಾಗಿದೆ.',
    'verified_impact': 'ಪರಿಶೀಲಿತ ಪ್ರದೇಶ ಮತ್ತು ರಸ್ತೆ ಪರಿಣಾಮ',
    'impact_truth':
        'ರಸ್ತೆ ಮುಚ್ಚುವಿಕೆ, ಸುರಕ್ಷಿತ ರಸ್ತೆ, ಅಪಾಯಕಾರಿ ರಸ್ತೆ ಉದ್ದ, ಶಾಲೆ/ಆಸ್ಪತ್ರೆ/ಜನರ ಪರಿಣಾಮಕ್ಕೆ ಪರಿಶೀಲಿತ ಅಧಿಕೃತ ಘಟನೆ ಡೇಟಾ ಅಗತ್ಯ. ಡೇಟಾ ಇಲ್ಲದಿದ್ದರೆ ಆಪ್ ಊಹಿಸುವುದಿಲ್ಲ.',
    'road_impact_unknown':
        'ಪರಿಣಾಮಿತ / ಸುರಕ್ಷಿತ ರಸ್ತೆಗಳು: ಪರಿಶೀಲಿತ ಲೈವ್ ಫೀಡ್ ಇಲ್ಲದೆ ಲಭ್ಯವಿಲ್ಲ.',
    'people_impact_unknown':
        'ಪರಿಣಾಮಿತ ಜನರು / ಕಟ್ಟಡಗಳು: ಪರಿಶೀಲಿತ ಅಧಿಕೃತ ಸಂಖ್ಯೆ ಲಭ್ಯವಿಲ್ಲ.',
    'event_time_unknown': 'ಘಟನೆ ಸಮಯ: ಪರಿಶೀಲಿತ ಸಕ್ರಿಯ ಘಟನೆ ಸಮಯ ಲಭ್ಯವಿಲ್ಲ.',
    'open_sachet': 'NDMA SACHET ತೆರೆಯಿರಿ',
    'open_bhooskhalan': 'GSI Bhooskhalan ತೆರೆಯಿರಿ',
    'last_updated': 'ಕೊನೆಯ ನವೀಕರಣ',
    'place_refreshing': 'ನಿಖರ ಸ್ಥಳ ಹುಡುಕಲಾಗುತ್ತಿದೆ…',
    'report_location': 'ವರದಿ ಸ್ಥಳ',
    'photo_saved': 'ಫೋಟೋ ಈ ಸಾಧನದಲ್ಲಿ ಉಳಿಸಲಾಗಿದೆ.',
    'camera_error': 'ಫೋಟೋ ಸೇರಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
    'screen_low_advice':
        'ಕಡಿಮೆ: ಸುರಕ್ಷಿತ ದೂರದಿಂದ ಗಮನಿಸಿ. ಬಿರುಕು ಅಥವಾ ಸಡಿಲ ಅವಶೇಷ ಮುಟ್ಟಬೇಡಿ; ಪರಿಸ್ಥಿತಿ ಕೆಡಿದರೆ ಮತ್ತೆ ವರದಿ ಮಾಡಿ.',
    'screen_medium_advice':
        'ಮಧ್ಯಮ: ಎಚ್ಚರಿಕೆಯಿಂದಿರಿ, ಅಸ್ಥಿರ ಇಳಿಜಾರು ಮತ್ತು ತಡೆದ ನೀರುಹರಿವು ತಪ್ಪಿಸಿ, ಅಧಿಕೃತ ಎಚ್ಚರಿಕೆಗಳನ್ನು ಗಮನಿಸಿ.',
    'screen_high_advice':
        'ಹೆಚ್ಚು: ಅಸ್ಥಿರ ಇಳಿಜಾರುಗಳಿಂದ ದೂರ ಹೋಗಿ, ಹೊಸ ಅವಶೇಷ ಅಥವಾ ಕಲ್ಲು ಬೀಳುವ ಪ್ರದೇಶ ದಾಟಬೇಡಿ, ಅಧಿಕೃತ ಸೂಚನೆ ಪಾಲಿಸಿ. ತಕ್ಷಣದ ಅಪಾಯಕ್ಕೆ 112 ಕರೆ ಮಾಡಿ.',
    'notification_free_note':
        'ಹೆಚ್ಚು ಅಪಾಯದ ಎಚ್ಚರಿಕೆ ಈ ಸಾಧನದ ಉಚಿತ ಸ್ಥಳೀಯ Android ನೋಟಿಫಿಕೇಶನ್; ಇದು SMS ಅಲ್ಲ.',
  },
  'ta': {
    'assistant_subtitle': 'குரல் மற்றும் தட்டச்சு உதவிக்கு ஒரே பக்கம்',
    'assistant_unknown':
        'இந்த கேள்விக்கு சரிபார்க்கப்பட்ட பதில் இல்லை. அபாயம், வானிலை, GPS, அறிக்கை, PIN, SOS மற்றும் சரிபார்க்கப்பட்ட தாக்க தகவலில் உதவ முடியும்.',
    'assistant_impact':
        'பாதிக்கப்பட்ட சாலை, பாதுகாப்பான வழி, பள்ளி, மருத்துவமனை, மக்கள் மற்றும் நேரம் அதிகாரப்பூர்வ சரிபார்க்கப்பட்ட தரவு இருந்தால் மட்டுமே காட்டப்படும்.',
    'live_data': 'நேரடி',
    'cached_data': 'சேமிப்பு',
    'updating': 'நேரடி தரவு புதுப்பிக்கிறது…',
    'photo_evidence': 'புகைப்பட சான்று',
    'take_photo': 'புகைப்படம் எடு',
    'choose_photo': 'புகைப்படம் தேர்வு',
    'remove_photo': 'புகைப்படத்தை நீக்கு',
    'report_screening': 'அறிக்கை மதிப்பீடு',
    'screening_note':
        'அறிக்கை வகை, தீவிரம், புகைப்படம், குறிப்பு மற்றும் கிடைக்கும் மழை தரவை இணைத்து மதிப்பிடுகிறது. இது அதிகாரப்பூர்வ நிலச்சரிவு உறுதிப்படுத்தல் அல்ல.',
    'alert_sent_device':
        'இந்த சாதனத்தில் உயர் முன்னுரிமை எச்சரிக்கை காட்டப்பட்டது.',
    'verified_impact': 'சரிபார்க்கப்பட்ட பகுதி மற்றும் சாலை தாக்கம்',
    'impact_truth':
        'சாலை மூடல், பாதுகாப்பான சாலை, அபாய சாலை நீளம், பள்ளி/மருத்துவமனை/மக்கள் தாக்கத்திற்கு அதிகாரப்பூர்வ நிகழ்வு தரவு தேவை. தரவு இல்லையெனில் பயன்பாடு ஊகிக்காது.',
    'road_impact_unknown':
        'பாதிக்கப்பட்ட / பாதுகாப்பான சாலைகள்: சரிபார்க்கப்பட்ட நேரடி தரவு இல்லாமல் கிடைக்காது.',
    'people_impact_unknown':
        'பாதிக்கப்பட்ட மக்கள் / கட்டிடங்கள்: சரிபார்க்கப்பட்ட அதிகாரப்பூர்வ எண்ணிக்கை இல்லை.',
    'event_time_unknown':
        'நிகழ்வு நேரம்: சரிபார்க்கப்பட்ட செயலில் உள்ள நிகழ்வு நேரம் இல்லை.',
    'open_sachet': 'NDMA SACHET திறக்கவும்',
    'open_bhooskhalan': 'GSI Bhooskhalan திறக்கவும்',
    'last_updated': 'கடைசி புதுப்பிப்பு',
    'place_refreshing': 'சரியான இடம் கண்டறியப்படுகிறது…',
    'report_location': 'அறிக்கை இடம்',
    'photo_saved': 'புகைப்படம் இந்த சாதனத்தில் சேமிக்கப்பட்டது.',
    'camera_error': 'புகைப்படத்தை இணைக்க முடியவில்லை.',
    'screen_low_advice':
        'குறைவு: பாதுகாப்பான தூரத்தில் இருந்து கவனியுங்கள். பிளவு அல்லது தளர்ந்த கழிவுகளைத் தொட வேண்டாம்; நிலை மோசமானால் மீண்டும் அறிக்கையிடுங்கள்.',
    'screen_medium_advice':
        'மிதமானது: எச்சரிக்கையாக இருங்கள், நிலையற்ற சரிவுகள் மற்றும் அடைப்பட்ட வடிகால்களை தவிர்த்து அதிகாரப்பூர்வ எச்சரிக்கைகளை கவனியுங்கள்.',
    'screen_high_advice':
        'அதிகம்: நிலையற்ற சரிவுகளிலிருந்து விலகுங்கள், புதிய கழிவு அல்லது பாறை விழும் பகுதியை கடக்க வேண்டாம், அதிகாரப்பூர்வ அறிவுறுத்தல்களை பின்பற்றுங்கள். உடனடி ஆபத்தில் 112 அழைக்கவும்.',
    'notification_free_note':
        'உயர் அபாய எச்சரிக்கை இந்த சாதனத்தில் இலவச உள்ளூர் Android அறிவிப்பு; இது SMS அல்ல.',
  },
  'te': {
    'assistant_subtitle': 'వాయిస్ మరియు టైప్ సహాయానికి ఒకే పేజీ',
    'assistant_unknown':
        'ఈ ప్రశ్నకు ధృవీకరించిన సమాధానం లేదు. ప్రమాదం, వాతావరణం, GPS, రిపోర్ట్, PIN, SOS మరియు ధృవీకరించిన ప్రభావ సమాచారంలో సహాయం చేయగలను.',
    'assistant_impact':
        'రోడ్లు, సురక్షిత మార్గాలు, పాఠశాలలు, ఆసుపత్రులు, ప్రజలు, సమయం వంటి ప్రభావాన్ని ధృవీకరించిన అధికారిక డేటా ఉన్నప్పుడు మాత్రమే చూపుతుంది.',
    'live_data': 'లైవ్',
    'cached_data': 'సేవ్ చేసినది',
    'updating': 'లైవ్ డేటా అప్‌డేట్ అవుతోంది…',
    'photo_evidence': 'ఫోటో ఆధారం',
    'take_photo': 'ఫోటో తీయండి',
    'choose_photo': 'ఫోటో ఎంచుకోండి',
    'remove_photo': 'ఫోటో తొలగించండి',
    'report_screening': 'రిపోర్ట్ స్క్రీనింగ్',
    'screening_note':
        'రిపోర్ట్ రకం, తీవ్రత, ఫోటో, నోట్ మరియు అందుబాటులో ఉన్న వర్ష డేటాను కలిపి పరిశీలిస్తుంది. ఇది అధికారిక భూస्खలనం నిర్ధారణ కాదు.',
    'alert_sent_device': 'ఈ పరికరంలో హై-ప్రయారిటీ అలర్ట్ చూపబడింది.',
    'verified_impact': 'ధృవీకరించిన ప్రాంతం & రోడ్డు ప్రభావం',
    'impact_truth':
        'రోడ్డు మూసివేతలు, సురక్షిత రోడ్లు, ప్రమాదకర రోడ్డు పొడవు, పాఠశాల/ఆసుపత్రి/ప్రజల ప్రభావానికి ధృవీకరించిన అధికారిక ఘటన డేటా అవసరం. డేటా లేకపోతే యాప్ ఊహించదు.',
    'road_impact_unknown':
        'ప్రభావిత / సురక్షిత రోడ్లు: ధృవీకరించిన లైవ్ ఫీడ్ లేకుండా అందుబాటులో లేదు.',
    'people_impact_unknown':
        'ప్రభావిత ప్రజలు / భవనాలు: ధృవీకరించిన అధికారిక సంఖ్య లేదు.',
    'event_time_unknown': 'ఘటన సమయం: ధృవీకరించిన యాక్టివ్ ఘటన సమయం లేదు.',
    'open_sachet': 'NDMA SACHET తెరవండి',
    'open_bhooskhalan': 'GSI Bhooskhalan తెరవండి',
    'last_updated': 'చివరి అప్‌డేట్',
    'place_refreshing': 'ఖచ్చితమైన స్థలం గుర్తిస్తోంది…',
    'report_location': 'రిపోర్ట్ స్థానం',
    'photo_saved': 'ఫోటో ఈ పరికరంలో సేవ్ అయింది.',
    'camera_error': 'ఫోటోను జత చేయలేకపోయాం.',
    'screen_low_advice':
        'తక్కువ: సురక్షిత దూరం నుంచి గమనించండి. పగుళ్లు లేదా సడలిన మట్టిని తాకవద్దు; పరిస్థితి చెడితే మళ్లీ రిపోర్ట్ చేయండి.',
    'screen_medium_advice':
        'మధ్యస్థ: అప్రమత్తంగా ఉండండి, అస్థిర వాలుదారులు మరియు మూసుకుపోయిన డ్రెయిన్లు దూరంగా ఉండండి, అధికారిక అలర్ట్స్ చూడండి.',
    'screen_high_advice':
        'అధికం: అస్థిర వాలుదారుల నుంచి దూరంగా వెళ్లండి, తాజా మట్టి/రాళ్లు పడే ప్రాంతం దాటవద్దు, అధికారిక సూచనలు పాటించండి. తక్షణ ప్రమాదంలో 112 కి కాల్ చేయండి.',
    'notification_free_note':
        'హై రిస్క్ అలర్ట్ ఈ పరికరంలో ఉచిత లోకల్ Android నోటిఫికేషన్; ఇది SMS కాదు.',
  },
  'ml': {
    'assistant_subtitle': 'വോയിസ്, ടൈപ്പ് സഹായത്തിനൊരു പേജ്',
    'assistant_unknown':
        'ഈ ചോദ്യത്തിന് സ്ഥിരീകരിച്ച മറുപടി ലഭ്യമല്ല. അപകടം, കാലാവസ്ഥ, GPS, റിപ്പോർട്ട്, PIN, SOS, സ്ഥിരീകരിച്ച ആഘാത വിവരങ്ങൾ എന്നിവയിൽ സഹായിക്കാം.',
    'assistant_impact':
        'റോഡുകൾ, സുരക്ഷിത പാത, സ്കൂൾ, ആശുപത്രി, ആളുകൾ, സമയം എന്നിവ ഔദ്യോഗികമായി സ്ഥിരീകരിച്ച ഡാറ്റ ഉണ്ടായാൽ മാത്രം കാണിക്കും.',
    'live_data': 'ലൈവ്',
    'cached_data': 'സേവ് ചെയ്തത്',
    'updating': 'ലൈവ് ഡാറ്റ പുതുക്കുന്നു…',
    'photo_evidence': 'ഫോട്ടോ തെളിവ്',
    'take_photo': 'ഫോട്ടോ എടുക്കുക',
    'choose_photo': 'ഫോട്ടോ തിരഞ്ഞെടുക്കുക',
    'remove_photo': 'ഫോട്ടോ നീക്കുക',
    'report_screening': 'റിപ്പോർട്ട് സ്ക്രീനിംഗ്',
    'screening_note':
        'റിപ്പോർട്ട് തരം, തീവ്രത, ഫോട്ടോ, കുറിപ്പ്, ലഭ്യമായ മഴ ഡാറ്റ എന്നിവ ചേർത്ത് പരിശോധിക്കുന്നു. ഇത് ഔദ്യോഗിക മണ്ണിടിച്ചിൽ സ്ഥിരീകരണം അല്ല.',
    'alert_sent_device': 'ഈ ഉപകരണത്തിൽ ഉയർന്ന മുൻഗണനാ മുന്നറിയിപ്പ് കാണിച്ചു.',
    'verified_impact': 'സ്ഥിരീകരിച്ച പ്രദേശവും റോഡ് ആഘാതവും',
    'impact_truth':
        'റോഡ് അടച്ചത്, സുരക്ഷിത റോഡ്, അപകടകരമായ റോഡ് നീളം, സ്കൂൾ/ആശുപത്രി/ആൾക്കാർ എന്നിവയ്ക്കായി സ്ഥിരീകരിച്ച ഔദ്യോഗിക സംഭവം ഡാറ്റ വേണം. ഡാറ്റ ഇല്ലെങ്കിൽ ആപ്പ് ഊഹിക്കില്ല.',
    'road_impact_unknown':
        'ബാധിത / സുരക്ഷിത റോഡുകൾ: സ്ഥിരീകരിച്ച ലൈവ് ഫീഡ് ഇല്ലാതെ ലഭ്യമല്ല.',
    'people_impact_unknown':
        'ബാധിത ആളുകൾ / കെട്ടിടങ്ങൾ: സ്ഥിരീകരിച്ച ഔദ്യോഗിക എണ്ണം ലഭ്യമല്ല.',
    'event_time_unknown': 'സംഭവ സമയം: സ്ഥിരീകരിച്ച സജീവ സംഭവം സമയം ലഭ്യമല്ല.',
    'open_sachet': 'NDMA SACHET തുറക്കുക',
    'open_bhooskhalan': 'GSI Bhooskhalan തുറക്കുക',
    'last_updated': 'അവസാന പുതുക്കൽ',
    'place_refreshing': 'കൃത്യമായ സ്ഥലം കണ്ടെത്തുന്നു…',
    'report_location': 'റിപ്പോർട്ട് സ്ഥലം',
    'photo_saved': 'ഫോട്ടോ ഈ ഉപകരണത്തിൽ സേവ് ചെയ്തു.',
    'camera_error': 'ഫോട്ടോ ചേർക്കാനായില്ല.',
    'screen_low_advice':
        'കുറവ്: സുരക്ഷിത ദൂരത്തിൽ നിന്ന് നിരീക്ഷിക്കുക. പൊട്ടൽ/അവശിഷ്ടം തൊടരുത്; സ്ഥിതി മോശമായാൽ വീണ്ടും റിപ്പോർട്ട് ചെയ്യുക.',
    'screen_medium_advice':
        'മധ്യം: ജാഗ്രത പാലിക്കുക, അസ്ഥിര ചരിവുകളും തടഞ്ഞ ഡ്രെയിനുകളും ഒഴിവാക്കി ഔദ്യോഗിക മുന്നറിയിപ്പുകൾ ശ്രദ്ധിക്കുക.',
    'screen_high_advice':
        'ഉയർന്നത്: അസ്ഥിര ചരിവുകളിൽ നിന്ന് മാറുക, പുതിയ അവശിഷ്ടം/പാറ വീഴുന്ന ഭാഗം കടക്കരുത്, ഔദ്യോഗിക നിർദ്ദേശങ്ങൾ പാലിക്കുക. ഉടൻ അപകടമുണ്ടെങ്കിൽ 112 വിളിക്കുക.',
    'notification_free_note':
        'ഉയർന്ന അപകട മുന്നറിയിപ്പ് ഈ ഉപകരണത്തിലെ സൗജന്യ ലോക്കൽ Android നോട്ടിഫിക്കേഷനാണ്; SMS അല്ല.',
  },
  'mr': {
    'assistant_subtitle': 'आवाज आणि टाइप मदतीसाठी एकच पेज',
    'assistant_unknown':
        'या प्रश्नाचे सत्यापित उत्तर उपलब्ध नाही. धोका, हवामान, GPS, अहवाल, PIN, SOS आणि सत्यापित परिणाम माहितीमध्ये मदत करू शकतो.',
    'assistant_impact':
        'प्रभावित रस्ते, सुरक्षित मार्ग, शाळा, रुग्णालये, लोक आणि वेळ फक्त सत्यापित अधिकृत डेटा असल्यास दाखवला जातो.',
    'live_data': 'लाइव्ह',
    'cached_data': 'जतन केलेले',
    'updating': 'लाइव्ह डेटा अपडेट होत आहे…',
    'photo_evidence': 'फोटो पुरावा',
    'take_photo': 'फोटो घ्या',
    'choose_photo': 'फोटो निवडा',
    'remove_photo': 'फोटो काढा',
    'report_screening': 'अहवाल तपासणी',
    'screening_note':
        'अहवाल प्रकार, तीव्रता, फोटो, नोंद आणि उपलब्ध पाऊस एकत्र तपासला जातो. ही अधिकृत भूस्खलन पुष्टी नाही.',
    'alert_sent_device': 'या डिवाइसवर उच्च-प्राधान्य इशारा दाखवला.',
    'verified_impact': 'सत्यापित क्षेत्र व रस्ता परिणाम',
    'impact_truth':
        'रस्ता बंद, सुरक्षित रस्ता, धोकादायक रस्ता लांबी, शाळा/रुग्णालय/लोक परिणामासाठी सत्यापित अधिकृत घटना डेटा आवश्यक आहे. डेटा नसेल तर अॅप अंदाज लावत नाही.',
    'road_impact_unknown':
        'प्रभावित / सुरक्षित रस्ते: सत्यापित लाइव्ह फीडशिवाय उपलब्ध नाहीत.',
    'people_impact_unknown':
        'प्रभावित लोक / इमारती: सत्यापित अधिकृत संख्या उपलब्ध नाही.',
    'event_time_unknown': 'घटना वेळ: सत्यापित सक्रिय घटना वेळ उपलब्ध नाही.',
    'open_sachet': 'NDMA SACHET उघडा',
    'open_bhooskhalan': 'GSI Bhooskhalan उघडा',
    'last_updated': 'शेवटचे अपडेट',
    'place_refreshing': 'अचूक ठिकाण शोधत आहे…',
    'report_location': 'अहवाल स्थान',
    'photo_saved': 'फोटो या डिवाइसवर जतन झाला.',
    'camera_error': 'फोटो जोडता आला नाही.',
    'screen_low_advice':
        'कमी: सुरक्षित अंतरावरून निरीक्षण करा. भेगा किंवा सैल मलबा स्पर्श करू नका; स्थिती बिघडल्यास पुन्हा अहवाल द्या.',
    'screen_medium_advice':
        'मध्यम: सतर्क रहा, अस्थिर उतार व बंद नाले टाळा आणि अधिकृत सूचना पाहा.',
    'screen_high_advice':
        'उच्च: अस्थिर उतारांपासून दूर जा, ताजा मलबा किंवा दगड पडणारा भाग ओलांडू नका आणि अधिकृत सूचना पाळा. तातडीच्या धोक्यात 112 वर कॉल करा.',
    'notification_free_note':
        'उच्च धोका इशारा हा या डिवाइसवरील मोफत स्थानिक Android नोटिफिकेशन आहे; SMS नाही.',
  },
  'bn': {
    'assistant_subtitle': 'ভয়েস ও টাইপ সহায়তার জন্য এক পেজ',
    'assistant_unknown':
        'এই প্রশ্নের যাচাই করা উত্তর নেই। ঝুঁকি, আবহাওয়া, GPS, রিপোর্ট, PIN, SOS এবং যাচাইকৃত প্রভাব তথ্য নিয়ে সাহায্য করতে পারি।',
    'assistant_impact':
        'প্রভাবিত রাস্তা, নিরাপদ পথ, স্কুল, হাসপাতাল, মানুষ ও সময় শুধু যাচাইকৃত সরকারি ডেটা থাকলে দেখানো হবে।',
    'live_data': 'লাইভ',
    'cached_data': 'সংরক্ষিত',
    'updating': 'লাইভ ডেটা আপডেট হচ্ছে…',
    'photo_evidence': 'ছবির প্রমাণ',
    'take_photo': 'ছবি তুলুন',
    'choose_photo': 'ছবি বাছুন',
    'remove_photo': 'ছবি সরান',
    'report_screening': 'রিপোর্ট যাচাই',
    'screening_note':
        'রিপোর্টের ধরন, তীব্রতা, ছবি, নোট ও উপলভ্য বৃষ্টির তথ্য মিলিয়ে যাচাই করা হয়। এটি সরকারি ভূমিধস নিশ্চিতকরণ নয়।',
    'alert_sent_device': 'এই ডিভাইসে উচ্চ-অগ্রাধিকার সতর্কতা দেখানো হয়েছে।',
    'verified_impact': 'যাচাইকৃত এলাকা ও রাস্তার প্রভাব',
    'impact_truth':
        'রাস্তা বন্ধ, নিরাপদ রাস্তা, বিপজ্জনক রাস্তার দৈর্ঘ্য, স্কুল/হাসপাতাল/মানুষের প্রভাবের জন্য যাচাইকৃত সরকারি ঘটনা ডেটা দরকার। ডেটা না থাকলে অ্যাপ অনুমান করে না।',
    'road_impact_unknown':
        'প্রভাবিত / নিরাপদ রাস্তা: যাচাইকৃত লাইভ ফিড ছাড়া পাওয়া যায় না।',
    'people_impact_unknown':
        'প্রভাবিত মানুষ / ভবন: যাচাইকৃত সরকারি সংখ্যা নেই।',
    'event_time_unknown': 'ঘটনার সময়: যাচাইকৃত সক্রিয় ঘটনার সময় নেই।',
    'open_sachet': 'NDMA SACHET খুলুন',
    'open_bhooskhalan': 'GSI Bhooskhalan খুলুন',
    'last_updated': 'শেষ আপডেট',
    'place_refreshing': 'সঠিক স্থান খোঁজা হচ্ছে…',
    'report_location': 'রিপোর্টের স্থান',
    'photo_saved': 'ছবি এই ডিভাইসে সংরক্ষিত হয়েছে।',
    'camera_error': 'ছবি যোগ করা যায়নি।',
    'screen_low_advice':
        'কম: নিরাপদ দূরত্ব থেকে লক্ষ্য করুন। ফাটল বা আলগা ধ্বংসাবশেষ স্পর্শ করবেন না; অবস্থা খারাপ হলে আবার রিপোর্ট করুন।',
    'screen_medium_advice':
        'মাঝারি: সতর্ক থাকুন, অস্থিতিশীল ঢাল ও বন্ধ নালা এড়িয়ে সরকারি সতর্কতা দেখুন।',
    'screen_high_advice':
        'উচ্চ: অস্থিতিশীল ঢাল থেকে দূরে যান, নতুন ধ্বংসাবশেষ বা পাথর পড়ার এলাকা পার হবেন না, সরকারি নির্দেশ মানুন। তাৎক্ষণিক বিপদে 112 কল করুন।',
    'notification_free_note':
        'উচ্চ ঝুঁকি সতর্কতা এই ডিভাইসে বিনামূল্যের লোকাল Android নোটিফিকেশন; SMS নয়.',
  },
  'as': {
    'assistant_subtitle': 'ভইচ আৰু টাইপ সহায়ৰ বাবে এটা পৃষ্ঠা',
    'assistant_unknown':
        'এই প্ৰশ্নৰ যাচাইকৃত উত্তৰ নাই। বিপদ, বতৰ, GPS, প্ৰতিবেদন, PIN, SOS আৰু যাচাইকৃত প্ৰভাৱ তথ্যত সহায় কৰিব পাৰোঁ।',
    'assistant_impact':
        'প্ৰভাৱিত পথ, নিৰাপদ পথ, বিদ্যালয়, চিকিৎসালয়, মানুহ আৰু সময় কেৱল যাচাইকৃত চৰকাৰী ডাটা থাকিলে দেখুওৱা হয়।',
    'live_data': 'লাইভ',
    'cached_data': 'সংৰক্ষিত',
    'updating': 'লাইভ ডাটা আপডেট হৈছে…',
    'photo_evidence': 'ফটো প্ৰমাণ',
    'take_photo': 'ফটো লওক',
    'choose_photo': 'ফটো বাছক',
    'remove_photo': 'ফটো আঁতৰাওক',
    'report_screening': 'প্ৰতিবেদন পৰীক্ষা',
    'screening_note':
        'প্ৰতিবেদন প্ৰকাৰ, তীব্ৰতা, ফটো, টোকা আৰু উপলভ্য বৰষুণৰ তথ্য একেলগে পৰীক্ষা কৰা হয়। ই চৰকাৰী ভূমিস্খলন নিশ্চিতকৰণ নহয়।',
    'alert_sent_device': 'এই ডিভাইচত উচ্চ-অগ্ৰাধিকাৰ সতৰ্কতা দেখুওৱা হৈছে।',
    'verified_impact': 'যাচাইকৃত এলেকা আৰু পথ প্ৰভাৱ',
    'impact_truth':
        'পথ বন্ধ, নিৰাপদ পথ, বিপদজনক পথৰ দৈৰ্ঘ্য, বিদ্যালয়/চিকিৎসালয়/মানুহৰ প্ৰভাৱৰ বাবে যাচাইকৃত চৰকাৰী ঘটনাৰ ডাটা লাগে। ডাটা নাথাকিলে এপে অনুমান নকৰে।',
    'road_impact_unknown':
        'প্ৰভাৱিত / নিৰাপদ পথ: যাচাইকৃত লাইভ ফিড নাথাকিলে উপলভ্য নহয়।',
    'people_impact_unknown':
        'প্ৰভাৱিত মানুহ / ঘৰ: যাচাইকৃত চৰকাৰী সংখ্যা উপলভ্য নহয়।',
    'event_time_unknown':
        'ঘটনাৰ সময়: যাচাইকৃত সক্ৰিয় ঘটনাৰ সময় উপলভ্য নহয়।',
    'open_sachet': 'NDMA SACHET খোলক',
    'open_bhooskhalan': 'GSI Bhooskhalan খোলক',
    'last_updated': 'শেষ আপডেট',
    'place_refreshing': 'সঠিক স্থান চিনাক্ত কৰা হৈছে…',
    'report_location': 'প্ৰতিবেদন স্থান',
    'photo_saved': 'ফটো এই ডিভাইচত সংৰক্ষণ কৰা হৈছে।',
    'camera_error': 'ফটো সংলগ্ন কৰিব পৰা নগ’ল।',
    'screen_low_advice':
        'কম: নিৰাপদ দূৰত্বৰ পৰা লক্ষ্য কৰক। ফাট বা ঢিলা আবর্জনা স্পৰ্শ নকৰিব; অৱস্থা বেয়া হলে পুনৰ প্ৰতিবেদন কৰক।',
    'screen_medium_advice':
        'মধ্যম: সতৰ্ক থাকক, অস্থিৰ ঢাল আৰু বন্ধ নলা এৰাই চৰকাৰী সতৰ্কতা লক্ষ্য কৰক।',
    'screen_high_advice':
        'উচ্চ: অস্থিৰ ঢালৰ পৰা আঁতৰি যাওক, নতুন আবর্জনা বা শিল পৰাৰ এলেকা পাৰ নকৰিব, চৰকাৰী নিৰ্দেশ মানক। তৎক্ষণাৎ বিপদত 112 ফোন কৰক।',
    'notification_free_note':
        'উচ্চ বিপদ সতৰ্কতা এই ডিভাইচৰ বিনামূলীয়া লোকেল Android নোটিফিকেশন; SMS নহয়।',
  },
  'ne': {
    'assistant_subtitle': 'आवाज र टाइप सहायताका लागि एउटै पृष्ठ',
    'assistant_unknown':
        'यो प्रश्नको प्रमाणित उत्तर उपलब्ध छैन। जोखिम, मौसम, GPS, रिपोर्ट, PIN, SOS र प्रमाणित प्रभाव जानकारीमा मद्दत गर्न सक्छु।',
    'assistant_impact':
        'प्रभावित सडक, सुरक्षित बाटो, विद्यालय, अस्पताल, मानिस र समय प्रमाणित आधिकारिक डेटा हुँदा मात्र देखाइन्छ।',
    'live_data': 'लाइभ',
    'cached_data': 'सुरक्षित',
    'updating': 'लाइभ डेटा अपडेट हुँदैछ…',
    'photo_evidence': 'फोटो प्रमाण',
    'take_photo': 'फोटो खिच्नुहोस्',
    'choose_photo': 'फोटो छान्नुहोस्',
    'remove_photo': 'फोटो हटाउनुहोस्',
    'report_screening': 'रिपोर्ट जाँच',
    'screening_note':
        'रिपोर्ट प्रकार, गम्भीरता, फोटो, नोट र उपलब्ध वर्षा डेटा मिलाएर जाँच गरिन्छ। यो आधिकारिक पहिरो पुष्टि होइन।',
    'alert_sent_device': 'यस उपकरणमा उच्च प्राथमिकता चेतावनी देखाइएको छ।',
    'verified_impact': 'प्रमाणित क्षेत्र र सडक प्रभाव',
    'impact_truth':
        'सडक बन्द, सुरक्षित सडक, जोखिमपूर्ण सडक लम्बाइ, विद्यालय/अस्पताल/मानिस प्रभावका लागि प्रमाणित आधिकारिक घटना डेटा चाहिन्छ। डेटा नभए एपले अनुमान गर्दैन।',
    'road_impact_unknown':
        'प्रभावित / सुरक्षित सडक: प्रमाणित लाइभ फिड बिना उपलब्ध छैन।',
    'people_impact_unknown':
        'प्रभावित मानिस / भवन: प्रमाणित आधिकारिक संख्या उपलब्ध छैन।',
    'event_time_unknown': 'घटना समय: प्रमाणित सक्रिय घटना समय उपलब्ध छैन।',
    'open_sachet': 'NDMA SACHET खोल्नुहोस्',
    'open_bhooskhalan': 'GSI Bhooskhalan खोल्नुहोस्',
    'last_updated': 'अन्तिम अपडेट',
    'place_refreshing': 'ठ्याक्कै स्थान पत्ता लगाउँदै…',
    'report_location': 'रिपोर्ट स्थान',
    'photo_saved': 'फोटो यस उपकरणमा सुरक्षित भयो।',
    'camera_error': 'फोटो जोड्न सकिएन।',
    'screen_low_advice':
        'कम: सुरक्षित दूरीबाट हेर्नुहोस्। चिरा वा खुकुलो माटो नछुनुहोस्; अवस्था बिग्रिए फेरि रिपोर्ट गर्नुहोस्।',
    'screen_medium_advice':
        'मध्यम: सतर्क रहनुहोस्, अस्थिर भिर र बन्द नालीबाट टाढा रहनुहोस् र आधिकारिक चेतावनी हेर्नुहोस्।',
    'screen_high_advice':
        'उच्च: अस्थिर भिरबाट टाढा जानुहोस्, नयाँ मलबा वा ढुंगा खस्ने क्षेत्र नपार गर्नुहोस् र आधिकारिक निर्देशन पालना गर्नुहोस्। तत्काल खतरा भए 112 मा फोन गर्नुहोस्।',
    'notification_free_note':
        'उच्च जोखिम चेतावनी यस उपकरणको निःशुल्क स्थानीय Android नोटिफिकेशन हो; SMS होइन।',
  },
};

const Map<String, Map<String, String>> officialI18n = {
  'en': {
    'official_alerts': 'Verified Official Alerts',
    'official_alerts_note':
        'Live alerts are read inside GEONEXA from the official NDMA SACHET feed. No external page is opened.',
    'official_no_landslide':
        'No active landslide alert was found in the current NDMA feed at the last refresh. This does not prove the area is safe; continue following local authorities and on-ground conditions.',
    'official_feed_unavailable':
        'The official alert feed is temporarily unavailable. GEONEXA will not invent an alert.',
    'official_source': 'Source',
    'official_area': 'Affected area',
    'official_severity': 'Severity',
    'official_validity': 'Validity',
    'official_refresh': 'Refresh official alerts',
    'gsi_status': 'GSI / National Landslide Forecasting Centre',
    'gsi_source_reachable':
        'GSI Bhusanket source is reachable. Event-specific bulletin details are shown only when a machine-readable official feed is available; GEONEXA will not infer a local forecast.',
    'gsi_source_unavailable':
        'GSI Bhusanket source is not reachable right now. No GSI forecast is being guessed.',
  },
  'hi': {
    'official_alerts': 'सत्यापित आधिकारिक अलर्ट',
    'official_alerts_note':
        'लाइव अलर्ट GEONEXA के अंदर आधिकारिक NDMA SACHET फीड से पढ़े जाते हैं। कोई बाहरी पेज नहीं खुलता।',
    'official_no_landslide':
        'पिछले रिफ्रेश में वर्तमान NDMA फीड में कोई सक्रिय भूस्खलन अलर्ट नहीं मिला। इसका मतलब यह नहीं कि क्षेत्र पूरी तरह सुरक्षित है; स्थानीय अधिकारियों और जमीन की स्थिति पर ध्यान दें।',
    'official_feed_unavailable':
        'आधिकारिक अलर्ट फीड अभी उपलब्ध नहीं है। GEONEXA कोई अलर्ट गढ़ेगा नहीं।',
    'official_source': 'स्रोत',
    'official_area': 'प्रभावित क्षेत्र',
    'official_severity': 'गंभीरता',
    'official_validity': 'मान्य अवधि',
    'official_refresh': 'आधिकारिक अलर्ट रिफ्रेश करें',
    'gsi_status': 'GSI / राष्ट्रीय भूस्खलन पूर्वानुमान केंद्र',
    'gsi_source_reachable':
        'GSI Bhusanket स्रोत उपलब्ध है। घटना-विशिष्ट बुलेटिन केवल मशीन-पठनीय आधिकारिक फीड मिलने पर दिखेंगे; GEONEXA स्थानीय पूर्वानुमान का अनुमान नहीं लगाएगा।',
    'gsi_source_unavailable':
        'GSI Bhusanket स्रोत अभी उपलब्ध नहीं है। कोई GSI पूर्वानुमान अनुमान से नहीं दिखाया जा रहा।',
  },
  'kn': {
    'official_alerts': 'ಪರಿಶೀಲಿತ ಅಧಿಕೃತ ಎಚ್ಚರಿಕೆಗಳು',
    'official_alerts_note':
        'ಲೈವ್ ಎಚ್ಚರಿಕೆಗಳನ್ನು GEONEXA ಒಳಗೇ ಅಧಿಕೃತ NDMA SACHET ಫೀಡ್‌ನಿಂದ ಓದುತ್ತದೆ. ಹೊರಗಿನ ಪುಟ ತೆರೆಯುವುದಿಲ್ಲ.',
    'official_no_landslide':
        'ಕೊನೆಯ ನವೀಕರಣದಲ್ಲಿ ಪ್ರಸ್ತುತ NDMA ಫೀಡ್‌ನಲ್ಲಿ ಸಕ್ರಿಯ ಭೂಕುಸಿತ ಎಚ್ಚರಿಕೆ ಕಂಡುಬಂದಿಲ್ಲ. ಇದರಿಂದ ಪ್ರದೇಶ ಸಂಪೂರ್ಣ ಸುರಕ್ಷಿತ ಎಂದು ಅರ್ಥವಲ್ಲ; ಸ್ಥಳೀಯ ಅಧಿಕಾರಿಗಳ ಸೂಚನೆ ಮತ್ತು ಸ್ಥಳೀಯ ಪರಿಸ್ಥಿತಿಯನ್ನು ಗಮನಿಸಿ.',
    'official_feed_unavailable':
        'ಅಧಿಕೃತ ಎಚ್ಚರಿಕೆ ಫೀಡ್ ತಾತ್ಕಾಲಿಕವಾಗಿ ಲಭ್ಯವಿಲ್ಲ. GEONEXA ಯಾವುದೇ ಎಚ್ಚರಿಕೆಯನ್ನು ಕಲ್ಪಿಸದು.',
    'official_source': 'ಮೂಲ',
    'official_area': 'ಪ್ರಭಾವಿತ ಪ್ರದೇಶ',
    'official_severity': 'ತೀವ್ರತೆ',
    'official_validity': 'ಮಾನ್ಯ ಅವಧಿ',
    'official_refresh': 'ಅಧಿಕೃತ ಎಚ್ಚರಿಕೆಗಳನ್ನು ನವೀಕರಿಸಿ',
    'gsi_status': 'GSI / ರಾಷ್ಟ್ರೀಯ ಭೂಕುಸಿತ ಮುನ್ಸೂಚನಾ ಕೇಂದ್ರ',
    'gsi_source_reachable':
        'GSI Bhusanket ಮೂಲ ಲಭ್ಯವಿದೆ. ಯಂತ್ರದಿಂದ ಓದಬಹುದಾದ ಅಧಿಕೃತ ಫೀಡ್ ಇದ್ದಾಗ ಮಾತ್ರ ಘಟನೆ-ನಿರ್ದಿಷ್ಟ ಬುಲೆಟಿನ್ ವಿವರಗಳನ್ನು ತೋರಿಸಲಾಗುತ್ತದೆ; GEONEXA ಸ್ಥಳೀಯ ಮುನ್ಸೂಚನೆಯನ್ನು ಊಹಿಸುವುದಿಲ್ಲ.',
    'gsi_source_unavailable':
        'GSI Bhusanket ಮೂಲ ಈಗ ಲಭ್ಯವಿಲ್ಲ. ಯಾವುದೇ GSI ಮುನ್ಸೂಚನೆಯನ್ನು ಊಹಿಸಿ ತೋರಿಸಲಾಗುವುದಿಲ್ಲ.',
  },
  'ta': {
    'official_alerts': 'சரிபார்க்கப்பட்ட அதிகாரப்பூர்வ எச்சரிக்கைகள்',
    'official_alerts_note':
        'நேரடி எச்சரிக்கைகள் GEONEXA-இல் அதிகாரப்பூர்வ NDMA SACHET தரவிலிருந்து காட்டப்படும். வெளிப்புற பக்கம் திறக்கப்படாது.',
    'official_no_landslide':
        'கடைசி புதுப்பிப்பில் தற்போதைய NDMA தரவில் செயலில் உள்ள நிலச்சரிவு எச்சரிக்கை கிடைக்கவில்லை. இதனால் பகுதி முழுமையாக பாதுகாப்பானது என்று பொருளல்ல; உள்ளூர் அதிகாரிகளையும் நிலைமையையும் கவனிக்கவும்.',
    'official_feed_unavailable':
        'அதிகாரப்பூர்வ எச்சரிக்கை தரவு தற்காலிகமாக கிடைக்கவில்லை. GEONEXA எச்சரிக்கையை உருவாக்காது.',
    'official_source': 'மூலம்',
    'official_area': 'பாதிக்கப்பட்ட பகுதி',
    'official_severity': 'தீவிரம்',
    'official_validity': 'செல்லுபடியாகும் காலம்',
    'official_refresh': 'அதிகாரப்பூர்வ எச்சரிக்கைகளை புதுப்பிக்கவும்',
    'gsi_status': 'GSI / தேசிய நிலச்சரிவு முன்னறிவிப்பு மையம்',
    'gsi_source_reachable':
        'GSI Bhusanket மூலம் அணுகக்கூடியது. இயந்திரம் வாசிக்கக்கூடிய அதிகாரப்பூர்வ தரவு கிடைத்தால் மட்டுமே நிகழ்வு சார்ந்த அறிவிப்புகள் காட்டப்படும்; GEONEXA உள்ளூர் முன்னறிவிப்பை ஊகிக்காது.',
    'gsi_source_unavailable':
        'GSI Bhusanket மூலம் இப்போது அணுக முடியவில்லை. எந்த GSI முன்னறிவிப்பும் ஊகித்து காட்டப்படாது.',
  },
  'te': {
    'official_alerts': 'ధృవీకరించిన అధికారిక హెచ్చరికలు',
    'official_alerts_note':
        'లైవ్ హెచ్చరికలు GEONEXA లోనే అధికారిక NDMA SACHET ఫీడ్ నుంచి చూపబడతాయి. బయట పేజీ తెరవదు.',
    'official_no_landslide':
        'చివరి రిఫ్రెష్‌లో ప్రస్తుత NDMA ఫీడ్‌లో యాక్టివ్ భూస्खలనం హెచ్చరిక కనిపించలేదు. దీని అర్థం ప్రాంతం పూర్తిగా సురక్షితం అని కాదు; స్థానిక అధికారుల సూచనలు మరియు నేల పరిస్థితులను గమనించండి.',
    'official_feed_unavailable':
        'అధికారిక హెచ్చరిక ఫీడ్ తాత్కాలికంగా అందుబాటులో లేదు. GEONEXA ఎలాంటి హెచ్చరికను ఊహించదు.',
    'official_source': 'మూలం',
    'official_area': 'ప్రభావిత ప్రాంతం',
    'official_severity': 'తీవ్రత',
    'official_validity': 'చెల్లుబాటు కాలం',
    'official_refresh': 'అధికారిక హెచ్చరికలను రిఫ్రెష్ చేయండి',
    'gsi_status': 'GSI / జాతీయ భూస्खలనం అంచనా కేంద్రం',
    'gsi_source_reachable':
        'GSI Bhusanket మూలం అందుబాటులో ఉంది. యంత్రంతో చదవగల అధికారిక ఫీడ్ ఉన్నప్పుడే ఘటన-నిర్దిష్ట బులెటిన్ వివరాలు చూపబడతాయి; GEONEXA స్థానిక అంచనాను ఊహించదు.',
    'gsi_source_unavailable':
        'GSI Bhusanket మూలం ప్రస్తుతం అందుబాటులో లేదు. ఎలాంటి GSI అంచనాను ఊహించి చూపడం లేదు.',
  },
  'ml': {
    'official_alerts': 'സ്ഥിരീകരിച്ച ഔദ്യോഗിക മുന്നറിയിപ്പുകൾ',
    'official_alerts_note':
        'ലൈവ് മുന്നറിയിപ്പുകൾ GEONEXA-ൽ തന്നെ ഔദ്യോഗിക NDMA SACHET ഫീഡിൽ നിന്ന് വായിക്കുന്നു. പുറത്തുള്ള പേജ് തുറക്കില്ല.',
    'official_no_landslide':
        'അവസാന പുതുക്കലിൽ നിലവിലെ NDMA ഫീഡിൽ സജീവ മണ്ണിടിച്ചിൽ മുന്നറിയിപ്പ് കണ്ടെത്തിയില്ല. അതുകൊണ്ട് പ്രദേശം പൂർണ്ണമായും സുരക്ഷിതമാണെന്ന് അർത്ഥമില്ല; പ്രാദേശിക അധികാരികളുടെ നിർദ്ദേശങ്ങളും സ്ഥലത്തെ സാഹചര്യങ്ങളും ശ്രദ്ധിക്കുക.',
    'official_feed_unavailable':
        'ഔദ്യോഗിക മുന്നറിയിപ്പ് ഫീഡ് താൽക്കാലികമായി ലഭ്യമല്ല. GEONEXA ഒരു മുന്നറിയിപ്പും സൃഷ്ടിച്ച് കാണിക്കില്ല.',
    'official_source': 'ഉറവിടം',
    'official_area': 'ബാധിത പ്രദേശം',
    'official_severity': 'തീവ്രത',
    'official_validity': 'സാധുവായ കാലം',
    'official_refresh': 'ഔദ്യോഗിക മുന്നറിയിപ്പുകൾ പുതുക്കുക',
    'gsi_status': 'GSI / ദേശീയ മണ്ണിടിച്ചിൽ പ്രവചന കേന്ദ്രം',
    'gsi_source_reachable':
        'GSI Bhusanket ഉറവിടം ലഭ്യമാണ്. യന്ത്രം വായിക്കാവുന്ന ഔദ്യോഗിക ഫീഡ് ലഭിക്കുമ്പോൾ മാത്രമേ സംഭവ-നിർദ്ദിഷ്ട ബുള്ളറ്റിൻ വിവരങ്ങൾ കാണിക്കൂ; GEONEXA പ്രാദേശിക പ്രവചനം ഊഹിക്കില്ല.',
    'gsi_source_unavailable':
        'GSI Bhusanket ഉറവിടം ഇപ്പോൾ ലഭ്യമല്ല. GSI പ്രവചനം ഒന്നും ഊഹിച്ച് കാണിക്കുന്നില്ല.',
  },
  'mr': {
    'official_alerts': 'सत्यापित अधिकृत इशारे',
    'official_alerts_note':
        'लाइव्ह इशारे GEONEXA मध्येच अधिकृत NDMA SACHET फीडमधून दाखवले जातात. बाहेरील पेज उघडत नाही.',
    'official_no_landslide':
        'शेवटच्या रिफ्रेशमध्ये सध्याच्या NDMA फीडमध्ये सक्रिय भूस्खलन इशारा आढळला नाही. याचा अर्थ परिसर पूर्णपणे सुरक्षित आहे असे नाही; स्थानिक अधिकाऱ्यांचे निर्देश आणि प्रत्यक्ष परिस्थिती पाहत रहा.',
    'official_feed_unavailable':
        'अधिकृत इशारा फीड तात्पुरता उपलब्ध नाही. GEONEXA कोणताही इशारा बनवणार नाही.',
    'official_source': 'स्रोत',
    'official_area': 'प्रभावित क्षेत्र',
    'official_severity': 'तीव्रता',
    'official_validity': 'वैध कालावधी',
    'official_refresh': 'अधिकृत इशारे रिफ्रेश करा',
    'gsi_status': 'GSI / राष्ट्रीय भूस्खलन पूर्वानुमान केंद्र',
    'gsi_source_reachable':
        'GSI Bhusanket स्रोत उपलब्ध आहे. मशीन-वाचनीय अधिकृत फीड उपलब्ध असेल तेव्हाच घटना-विशिष्ट बुलेटिन तपशील दाखवले जातील; GEONEXA स्थानिक अंदाज लावणार नाही.',
    'gsi_source_unavailable':
        'GSI Bhusanket स्रोत सध्या उपलब्ध नाही. कोणताही GSI अंदाज गृहित धरून दाखवला जात नाही.',
  },
  'bn': {
    'official_alerts': 'যাচাইকৃত সরকারি সতর্কতা',
    'official_alerts_note':
        'লাইভ সতর্কতা GEONEXA-এর ভেতরেই সরকারি NDMA SACHET ফিড থেকে দেখানো হয়। কোনো বাইরের পেজ খোলে না।',
    'official_no_landslide':
        'শেষ রিফ্রেশে বর্তমান NDMA ফিডে কোনো সক্রিয় ভূমিধস সতর্কতা পাওয়া যায়নি। এর মানে এলাকা পুরোপুরি নিরাপদ নয়; স্থানীয় কর্তৃপক্ষের নির্দেশ ও বাস্তব পরিস্থিতি অনুসরণ করুন।',
    'official_feed_unavailable':
        'সরকারি সতর্কতা ফিড সাময়িকভাবে পাওয়া যাচ্ছে না। GEONEXA কোনো সতর্কতা বানিয়ে দেখাবে না।',
    'official_source': 'উৎস',
    'official_area': 'প্রভাবিত এলাকা',
    'official_severity': 'তীব্রতা',
    'official_validity': 'কার্যকর সময়',
    'official_refresh': 'সরকারি সতর্কতা রিফ্রেশ করুন',
    'gsi_status': 'GSI / জাতীয় ভূমিধস পূর্বাভাস কেন্দ্র',
    'gsi_source_reachable':
        'GSI Bhusanket উৎস পাওয়া যাচ্ছে। মেশিনে পড়া যায় এমন সরকারি ফিড থাকলেই ঘটনা-নির্দিষ্ট বুলেটিন দেখানো হবে; GEONEXA স্থানীয় পূর্বাভাস অনুমান করবে না।',
    'gsi_source_unavailable':
        'GSI Bhusanket উৎস এখন পাওয়া যাচ্ছে না। কোনো GSI পূর্বাভাস অনুমান করে দেখানো হচ্ছে না।',
  },
  'as': {
    'official_alerts': 'যাচাইকৃত চৰকাৰী সতৰ্কতা',
    'official_alerts_note':
        'লাইভ সতৰ্কতা GEONEXA-ৰ ভিতৰতে চৰকাৰী NDMA SACHET ফীডৰ পৰা দেখুওৱা হয়। বাহিৰৰ পৃষ্ঠা খোলা নহয়।',
    'official_no_landslide':
        'শেষ ৰিফ্ৰেশত বৰ্তমান NDMA ফীডত কোনো সক্ৰিয় ভূমিস্খলন সতৰ্কতা পোৱা নগ’ল। ইয়াৰ অৰ্থ এলেকা সম্পূৰ্ণ নিৰাপদ নহয়; স্থানীয় কৰ্তৃপক্ষৰ নিৰ্দেশ আৰু স্থল পৰিস্থিতি লক্ষ্য কৰক।',
    'official_feed_unavailable':
        'চৰকাৰী সতৰ্কতা ফীড সাময়িকভাৱে উপলভ্য নহয়। GEONEXA কোনো সতৰ্কতা বান্ধি নেদেখুৱায়।',
    'official_source': 'উৎস',
    'official_area': 'প্ৰভাৱিত এলেকা',
    'official_severity': 'তীব্ৰতা',
    'official_validity': 'কাৰ্যকৰী সময়',
    'official_refresh': 'চৰকাৰী সতৰ্কতা নৱীকৰণ কৰক',
    'gsi_status': 'GSI / ৰাষ্ট্ৰীয় ভূমিস্খলন পূৰ্বানুমান কেন্দ্ৰ',
    'gsi_source_reachable':
        'GSI Bhusanket উৎস উপলভ্য। মেচিনে পঢ়িব পৰা চৰকাৰী ফীড থাকিলেহে ঘটনা-নির্দিষ্ট বুলেটিনৰ তথ্য দেখুওৱা হয়; GEONEXA স্থানীয় পূৰ্বানুমান অনুমান নকৰে।',
    'gsi_source_unavailable':
        'GSI Bhusanket উৎস এই মুহূর্তত উপলভ্য নহয়। কোনো GSI পূৰ্বানুমান অনুমান কৰি দেখুওৱা নহয়।',
  },
  'ne': {
    'official_alerts': 'प्रमाणित आधिकारिक चेतावनी',
    'official_alerts_note':
        'लाइभ चेतावनी GEONEXA भित्रै आधिकारिक NDMA SACHET फिडबाट देखाइन्छ। बाहिरी पृष्ठ खोलिँदैन।',
    'official_no_landslide':
        'अन्तिम रिफ्रेसमा हालको NDMA फिडमा सक्रिय पहिरो चेतावनी भेटिएन। यसको अर्थ क्षेत्र पूर्ण रूपमा सुरक्षित छ भन्ने होइन; स्थानीय निकायका निर्देशन र वास्तविक अवस्था हेर्नुहोस्।',
    'official_feed_unavailable':
        'आधिकारिक चेतावनी फिड अस्थायी रूपमा उपलब्ध छैन। GEONEXA ले कुनै चेतावनी बनाउँदैन।',
    'official_source': 'स्रोत',
    'official_area': 'प्रभावित क्षेत्र',
    'official_severity': 'गम्भीरता',
    'official_validity': 'मान्य अवधि',
    'official_refresh': 'आधिकारिक चेतावनी रिफ्रेस गर्नुहोस्',
    'gsi_status': 'GSI / राष्ट्रिय पहिरो पूर्वानुमान केन्द्र',
    'gsi_source_reachable':
        'GSI Bhusanket स्रोत उपलब्ध छ। मेसिनले पढ्न सक्ने आधिकारिक फिड उपलब्ध हुँदा मात्र घटना-विशिष्ट बुलेटिन विवरण देखाइन्छ; GEONEXA ले स्थानीय पूर्वानुमान अनुमान गर्दैन।',
    'gsi_source_unavailable':
        'GSI Bhusanket स्रोत अहिले उपलब्ध छैन। कुनै GSI पूर्वानुमान अनुमान गरेर देखाइएको छैन।',
  },
};

String tr(String key) =>
    officialI18n[appController.language]?[key] ??
    extraI18n[appController.language]?[key] ??
    i18n[appController.language]?[key] ??
    extraI18n['en']?[key] ??
    i18n['en']?[key] ??
    key;

const Map<String, Map<String, String>> alertUiI18n = {
  'en': {
    'share_location': 'Share Location',
    'safe': 'SAFE',
    'safe_message':
        'No active verified landslide alert matching this area was found at the last refresh.',
    'caution': 'CAUTION',
    'caution_weather':
        'No verified landslide alert is active for this area, but rainfall screening is elevated. Stay alert.',
    'caution_report':
        'A nearby field report exists. It is not an official landslide confirmation.',
    'affected_road': 'Affected road',
    'safe_road': 'Alternate / safe road',
    'affected_places': 'Places affected',
    'event_time': 'Event time',
    'field_report': 'Nearby field report',
    'open_area': 'Open area',
    'open_affected_road': 'Affected road',
    'open_safe_road': 'Safe road',
    'official_unavailable_short':
        'Live official alert check is temporarily unavailable.',
    'sos_help':
        'Use SOS to share your current GPS location, open SMS, or call 112.',
    'no_verified_route':
        'No verified alternate road was supplied with this alert.',
  },

  'hi': {
    'share_location': 'स्थान साझा करें',
    'safe': 'सुरक्षित',
    'safe_message':
        'अंतिम अपडेट में इस क्षेत्र से मेल खाने वाला कोई सक्रिय सत्यापित भूस्खलन अलर्ट नहीं मिला।',
    'caution': 'सावधानी',
    'caution_weather':
        'इस क्षेत्र के लिए कोई सत्यापित भूस्खलन अलर्ट नहीं है, लेकिन वर्षा जोखिम बढ़ा हुआ है। सतर्क रहें।',
    'caution_report':
        'पास की एक फील्ड रिपोर्ट उपलब्ध है। यह आधिकारिक भूस्खलन पुष्टि नहीं है।',
    'affected_road': 'प्रभावित सड़क',
    'safe_road': 'वैकल्पिक / सुरक्षित मार्ग',
    'affected_places': 'प्रभावित स्थान',
    'event_time': 'घटना समय',
    'field_report': 'पास की फील्ड रिपोर्ट',
    'open_area': 'क्षेत्र खोलें',
    'open_affected_road': 'प्रभावित सड़क',
    'open_safe_road': 'सुरक्षित मार्ग',
    'official_unavailable_short':
        'लाइव आधिकारिक अलर्ट जांच अभी उपलब्ध नहीं है।',
    'sos_help':
        'SOS से अपना वर्तमान GPS स्थान साझा करें, SMS खोलें या 112 पर कॉल करें।',
    'no_verified_route':
        'इस अलर्ट में कोई सत्यापित वैकल्पिक मार्ग नहीं दिया गया है।',
  },

  'kn': {
    'share_location': 'ಸ್ಥಳವನ್ನು ಹಂಚಿಕೊಳ್ಳಿ',
    'safe': 'ಸುರಕ್ಷಿತ',
    'safe_message':
        'ಕೊನೆಯ ನವೀಕರಣದಲ್ಲಿ ಈ ಪ್ರದೇಶಕ್ಕೆ ಹೊಂದುವ ಯಾವುದೇ ಸಕ್ರಿಯ ದೃಢೀಕೃತ ಭೂಕುಸಿತ ಎಚ್ಚರಿಕೆ ಕಂಡುಬಂದಿಲ್ಲ.',
    'caution': 'ಎಚ್ಚರಿಕೆ',
    'caution_weather':
        'ಈ ಪ್ರದೇಶಕ್ಕೆ ದೃಢೀಕೃತ ಭೂಕುಸಿತ ಎಚ್ಚರಿಕೆ ಇಲ್ಲ, ಆದರೆ ಮಳೆ ಆಧಾರಿತ ಅಪಾಯ ಹೆಚ್ಚಾಗಿದೆ. ಎಚ್ಚರಿಕೆಯಿಂದಿರಿ.',
    'caution_report':
        'ಹತ್ತಿರದ ಫೀಲ್ಡ್ ವರದಿ ಲಭ್ಯವಿದೆ. ಇದು ಅಧಿಕೃತ ಭೂಕುಸಿತ ದೃಢೀಕರಣವಲ್ಲ.',
    'affected_road': 'ಪ್ರಭಾವಿತ ರಸ್ತೆ',
    'safe_road': 'ಪರ್ಯಾಯ / ಸುರಕ್ಷಿತ ರಸ್ತೆ',
    'affected_places': 'ಪ್ರಭಾವಿತ ಸ್ಥಳಗಳು',
    'event_time': 'ಘಟನೆಯ ಸಮಯ',
    'field_report': 'ಹತ್ತಿರದ ಫೀಲ್ಡ್ ವರದಿ',
    'open_area': 'ಪ್ರದೇಶ ತೆರೆಯಿರಿ',
    'open_affected_road': 'ಪ್ರಭಾವಿತ ರಸ್ತೆ',
    'open_safe_road': 'ಸುರಕ್ಷಿತ ರಸ್ತೆ',
    'official_unavailable_short':
        'ಲೈವ್ ಅಧಿಕೃತ ಎಚ್ಚರಿಕೆ ಪರಿಶೀಲನೆ ತಾತ್ಕಾಲಿಕವಾಗಿ ಲಭ್ಯವಿಲ್ಲ.',
    'sos_help':
        'SOS ಮೂಲಕ ನಿಮ್ಮ GPS ಸ್ಥಳವನ್ನು ಹಂಚಿಕೊಳ್ಳಿ, SMS ತೆರೆಯಿರಿ ಅಥವಾ 112 ಗೆ ಕರೆ ಮಾಡಿ.',
    'no_verified_route': 'ಈ ಎಚ್ಚರಿಕೆಯಲ್ಲಿ ದೃಢೀಕೃತ ಪರ್ಯಾಯ ರಸ್ತೆ ನೀಡಲಾಗಿಲ್ಲ.',
  },

  'ta': {
    'share_location': 'இடத்தை பகிரவும்',
    'safe': 'பாதுகாப்பு',
    'safe_message':
        'கடைசி புதுப்பிப்பில் இந்த பகுதிக்கு பொருந்தும் செயலில் உள்ள உறுதிப்படுத்தப்பட்ட நிலச்சரிவு எச்சரிக்கை எதுவும் இல்லை.',
    'caution': 'எச்சரிக்கை',
    'caution_weather':
        'இந்த பகுதிக்கு உறுதிப்படுத்தப்பட்ட நிலச்சரிவு எச்சரிக்கை இல்லை, ஆனால் மழை அபாயம் உயர்ந்துள்ளது.',
    'caution_report':
        'அருகிலுள்ள கள அறிக்கை உள்ளது. இது அதிகாரப்பூர்வ நிலச்சரிவு உறுதிப்படுத்தல் அல்ல.',
    'affected_road': 'பாதிக்கப்பட்ட சாலை',
    'safe_road': 'மாற்று / பாதுகாப்பான சாலை',
    'affected_places': 'பாதிக்கப்பட்ட இடங்கள்',
    'event_time': 'நிகழ்வு நேரம்',
    'field_report': 'அருகிலுள்ள கள அறிக்கை',
    'open_area': 'பகுதியை திற',
    'open_affected_road': 'பாதிக்கப்பட்ட சாலை',
    'open_safe_road': 'பாதுகாப்பான சாலை',
    'official_unavailable_short':
        'நேரடி அதிகாரப்பூர்வ எச்சரிக்கை தற்போது கிடைக்கவில்லை.',
    'sos_help':
        'SOS மூலம் தற்போதைய GPS இடத்தை பகிரவும், SMS திறக்கவும் அல்லது 112 அழைக்கவும்.',
    'no_verified_route':
        'இந்த எச்சரிக்கையில் உறுதிப்படுத்தப்பட்ட மாற்று சாலை வழங்கப்படவில்லை.',
  },

  'te': {
    'share_location': 'స్థానాన్ని పంచుకోండి',
    'safe': 'సురక్షితం',
    'safe_message':
        'చివరి నవీకరణలో ఈ ప్రాంతానికి సరిపడే సక్రియ ధృవీకరించిన భూస्खలనం హెచ్చరిక కనబడలేదు.',
    'caution': 'జాగ్రత్త',
    'caution_weather':
        'ఈ ప్రాంతానికి ధృవీకరించిన భూస्खలనం హెచ్చరిక లేదు, కానీ వర్ష ప్రమాదం ఎక్కువగా ఉంది.',
    'caution_report':
        'దగ్గరలో ఒక ఫీల్డ్ రిపోర్ట్ ఉంది. ఇది అధికారిక భూస्खలనం నిర్ధారణ కాదు.',
    'affected_road': 'ప్రభావిత రహదారి',
    'safe_road': 'ప్రత్యామ్నాయ / సురక్షిత రహదారి',
    'affected_places': 'ప్రభావిత ప్రదేశాలు',
    'event_time': 'ఘటన సమయం',
    'field_report': 'దగ్గర ఫీల్డ్ రిపోర్ట్',
    'open_area': 'ప్రాంతం తెరవండి',
    'open_affected_road': 'ప్రభావిత రహదారి',
    'open_safe_road': 'సురక్షిత రహదారి',
    'official_unavailable_short':
        'లైవ్ అధికారిక హెచ్చరిక ప్రస్తుతం అందుబాటులో లేదు.',
    'sos_help':
        'SOS ద్వారా మీ GPS స్థానాన్ని పంచుకోండి, SMS తెరవండి లేదా 112కు కాల్ చేయండి.',
    'no_verified_route':
        'ఈ హెచ్చరికలో ధృవీకరించిన ప్రత్యామ్నాయ రహదారి ఇవ్వలేదు.',
  },

  'ml': {
    'share_location': 'സ്ഥലം പങ്കിടുക',
    'safe': 'സുരക്ഷിതം',
    'safe_message':
        'അവസാന അപ്ഡേറ്റിൽ ഈ പ്രദേശവുമായി പൊരുത്തപ്പെടുന്ന സജീവ സ്ഥിരീകരിച്ച മണ്ണിടിച്ചിൽ മുന്നറിയിപ്പ് കണ്ടെത്തിയില്ല.',
    'caution': 'ജാഗ്രത',
    'caution_weather':
        'ഈ പ്രദേശത്തിന് സ്ഥിരീകരിച്ച മണ്ണിടിച്ചിൽ മുന്നറിയിപ്പ് ഇല്ല, പക്ഷേ മഴാ അപകടനില ഉയർന്നിരിക്കുന്നു.',
    'caution_report':
        'സമീപത്ത് ഒരു ഫീൽഡ് റിപ്പോർട്ട് ഉണ്ട്. ഇത് ഔദ്യോഗിക മണ്ണിടിച്ചിൽ സ്ഥിരീകരണമല്ല.',
    'affected_road': 'ബാധിച്ച റോഡ്',
    'safe_road': 'പകരം / സുരക്ഷിത റോഡ്',
    'affected_places': 'ബാധിച്ച സ്ഥലങ്ങൾ',
    'event_time': 'സംഭവ സമയം',
    'field_report': 'സമീപ ഫീൽഡ് റിപ്പോർട്ട്',
    'open_area': 'പ്രദേശം തുറക്കുക',
    'open_affected_road': 'ബാധിച്ച റോഡ്',
    'open_safe_road': 'സുരക്ഷിത റോഡ്',
    'official_unavailable_short':
        'ലൈവ് ഔദ്യോഗിക മുന്നറിയിപ്പ് ഇപ്പോൾ ലഭ്യമല്ല.',
    'sos_help':
        'SOS ഉപയോഗിച്ച് നിങ്ങളുടെ GPS സ്ഥലം പങ്കിടുക, SMS തുറക്കുക അല്ലെങ്കിൽ 112 വിളിക്കുക.',
    'no_verified_route':
        'ഈ മുന്നറിയിപ്പിൽ സ്ഥിരീകരിച്ച പകരം റോഡ് നൽകിയിട്ടില്ല.',
  },

  'mr': {
    'share_location': 'स्थान शेअर करा',
    'safe': 'सुरक्षित',
    'safe_message':
        'शेवटच्या अपडेटमध्ये या भागाशी जुळणारा कोणताही सक्रिय सत्यापित भूस्खलन इशारा आढळला नाही.',
    'caution': 'सावधान',
    'caution_weather':
        'या भागासाठी सत्यापित भूस्खलन इशारा नाही, परंतु पावसाचा धोका वाढलेला आहे.',
    'caution_report':
        'जवळील फील्ड रिपोर्ट उपलब्ध आहे. ही अधिकृत भूस्खलन पुष्टी नाही.',
    'affected_road': 'प्रभावित रस्ता',
    'safe_road': 'पर्यायी / सुरक्षित रस्ता',
    'affected_places': 'प्रभावित ठिकाणे',
    'event_time': 'घटनेची वेळ',
    'field_report': 'जवळील फील्ड रिपोर्ट',
    'open_area': 'भाग उघडा',
    'open_affected_road': 'प्रभावित रस्ता',
    'open_safe_road': 'सुरक्षित रस्ता',
    'official_unavailable_short':
        'लाइव्ह अधिकृत इशारा तपासणी सध्या उपलब्ध नाही.',
    'sos_help': 'SOS मधून GPS स्थान शेअर करा, SMS उघडा किंवा 112 वर कॉल करा.',
    'no_verified_route': 'या इशाऱ्यासोबत सत्यापित पर्यायी रस्ता दिलेला नाही.',
  },

  'bn': {
    'share_location': 'অবস্থান শেয়ার করুন',
    'safe': 'নিরাপদ',
    'safe_message':
        'শেষ আপডেটে এই এলাকার সঙ্গে মিলে এমন কোনো সক্রিয় যাচাইকৃত ভূমিধস সতর্কতা পাওয়া যায়নি।',
    'caution': 'সতর্কতা',
    'caution_weather':
        'এই এলাকার জন্য যাচাইকৃত ভূমিধস সতর্কতা নেই, তবে বৃষ্টিজনিত ঝুঁকি বেড়েছে।',
    'caution_report':
        'কাছাকাছি একটি ফিল্ড রিপোর্ট আছে। এটি সরকারি ভূমিধস নিশ্চিতকরণ নয়।',
    'affected_road': 'প্রভাবিত রাস্তা',
    'safe_road': 'বিকল্প / নিরাপদ রাস্তা',
    'affected_places': 'প্রভাবিত স্থান',
    'event_time': 'ঘটনার সময়',
    'field_report': 'কাছাকাছি ফিল্ড রিপোর্ট',
    'open_area': 'এলাকা খুলুন',
    'open_affected_road': 'প্রভাবিত রাস্তা',
    'open_safe_road': 'নিরাপদ রাস্তা',
    'official_unavailable_short':
        'লাইভ সরকারি সতর্কতা পরীক্ষা এখন পাওয়া যাচ্ছে না।',
    'sos_help':
        'SOS দিয়ে GPS অবস্থান শেয়ার করুন, SMS খুলুন অথবা 112-এ কল করুন।',
    'no_verified_route': 'এই সতর্কতায় যাচাইকৃত বিকল্প রাস্তা দেওয়া হয়নি।',
  },

  'as': {
    'share_location': 'অৱস্থান শ্বেয়াৰ কৰক',
    'safe': 'নিৰাপদ',
    'safe_message':
        'শেষ আপডেটত এই এলেকাৰ সৈতে মিল থকা কোনো সক্ৰিয় যাচাইকৃত ভূমিস্খলন সতৰ্কতা পোৱা নগ’ল।',
    'caution': 'সতৰ্কতা',
    'caution_weather':
        'এই এলেকাৰ বাবে যাচাইকৃত ভূমিস্খলন সতৰ্কতা নাই, কিন্তু বৰষুণৰ বিপদ বৃদ্ধি পাইছে।',
    'caution_report':
        'ওচৰত এটা ফিল্ড প্ৰতিবেদন আছে। ই চৰকাৰী ভূমিস্খলন নিশ্চিতকৰণ নহয়।',
    'affected_road': 'প্ৰভাৱিত পথ',
    'safe_road': 'বিকল্প / নিৰাপদ পথ',
    'affected_places': 'প্ৰভাৱিত স্থান',
    'event_time': 'ঘটনাৰ সময়',
    'field_report': 'ওচৰৰ ফিল্ড প্ৰতিবেদন',
    'open_area': 'এলেকা খোলক',
    'open_affected_road': 'প্ৰভাৱিত পথ',
    'open_safe_road': 'নিৰাপদ পথ',
    'official_unavailable_short':
        'লাইভ চৰকাৰী সতৰ্কতা পৰীক্ষা এই মুহূর্তত উপলভ্য নহয়।',
    'sos_help':
        'SOS ৰ পৰা GPS অৱস্থান শ্বেয়াৰ কৰক, SMS খোলক অথবা 112 ফোন কৰক।',
    'no_verified_route': 'এই সতৰ্কতাত যাচাইকৃত বিকল্প পথ দিয়া হোৱা নাই।',
  },

  'ne': {
    'share_location': 'स्थान साझा गर्नुहोस्',
    'safe': 'सुरक्षित',
    'safe_message':
        'अन्तिम अपडेटमा यस क्षेत्रसँग मेल खाने सक्रिय प्रमाणित पहिरो चेतावनी भेटिएन।',
    'caution': 'सावधानी',
    'caution_weather':
        'यस क्षेत्रका लागि प्रमाणित पहिरो चेतावनी छैन, तर वर्षासम्बन्धी जोखिम बढेको छ।',
    'caution_report':
        'नजिकैको फील्ड रिपोर्ट उपलब्ध छ। यो आधिकारिक पहिरो पुष्टि होइन।',
    'affected_road': 'प्रभावित सडक',
    'safe_road': 'वैकल्पिक / सुरक्षित सडक',
    'affected_places': 'प्रभावित स्थान',
    'event_time': 'घटना समय',
    'field_report': 'नजिकको फील्ड रिपोर्ट',
    'open_area': 'क्षेत्र खोल्नुहोस्',
    'open_affected_road': 'प्रभावित सडक',
    'open_safe_road': 'सुरक्षित सडक',
    'official_unavailable_short':
        'लाइभ आधिकारिक चेतावनी जाँच अहिले उपलब्ध छैन।',
    'sos_help':
        'SOS बाट GPS स्थान साझा गर्नुहोस्, SMS खोल्नुहोस् वा 112 मा फोन गर्नुहोस्।',
    'no_verified_route': 'यस चेतावनीसँग प्रमाणित वैकल्पिक सडक उपलब्ध छैन।',
  },
};

String alertUiText(String key) =>
    alertUiI18n[appController.language]?[key] ?? alertUiI18n['en']?[key] ?? key;

const nerStates = <String>[
  'Arunachal Pradesh',
  'Assam',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Sikkim',
  'Tripura',
];

const otherIndianStates = <String>[
  'Andhra Pradesh',
  'Bihar',
  'Chhattisgarh',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Madhya Pradesh',
  'Maharashtra',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Tamil Nadu',
  'Telangana',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
];

const nerDistrictFallback = <String, List<String>>{
  'Arunachal Pradesh': [
    'Anjaw',
    'Bichom',
    'Changlang',
    'East Kameng',
    'East Siang',
    'Itanagar Capital Complex',
    'Kamle',
    'Keyi Panyor',
    'Kra Daadi',
    'Kurung Kumey',
    'Lepa Rada',
    'Lohit',
    'Longding',
    'Lower Dibang Valley',
    'Lower Siang',
    'Lower Subansiri',
    'Namsai',
    'Pakke-Kessang',
    'Papum Pare',
    'Shi Yomi',
    'Siang',
    'Tawang',
    'Tirap',
    'Upper Siang',
    'Upper Subansiri',
    'West Kameng',
    'West Siang',
  ],
  'Assam': [
    'Baksa',
    'Bajali',
    'Barpeta',
    'Biswanath',
    'Bongaigaon',
    'Cachar',
    'Charaideo',
    'Chirang',
    'Darrang',
    'Dhemaji',
    'Dhubri',
    'Dibrugarh',
    'Dima Hasao',
    'Goalpara',
    'Golaghat',
    'Hailakandi',
    'Hojai',
    'Jorhat',
    'Kamrup',
    'Kamrup Metropolitan',
    'Karbi Anglong',
    'Karimganj',
    'Kokrajhar',
    'Lakhimpur',
    'Majuli',
    'Morigaon',
    'Nagaon',
    'Nalbari',
    'Sivasagar',
    'Sonitpur',
    'South Salmara-Mankachar',
    'Tamulpur',
    'Tinsukia',
    'Udalguri',
    'West Karbi Anglong',
  ],
  'Manipur': [
    'Bishnupur',
    'Chandel',
    'Churachandpur',
    'Imphal East',
    'Imphal West',
    'Jiribam',
    'Kakching',
    'Kamjong',
    'Kangpokpi',
    'Noney',
    'Pherzawl',
    'Senapati',
    'Tamenglong',
    'Tengnoupal',
    'Thoubal',
    'Ukhrul',
  ],
  'Meghalaya': [
    'East Garo Hills',
    'East Jaintia Hills',
    'East Khasi Hills',
    'Eastern West Khasi Hills',
    'North Garo Hills',
    'Ri Bhoi',
    'South Garo Hills',
    'South West Garo Hills',
    'South West Khasi Hills',
    'West Garo Hills',
    'West Jaintia Hills',
    'West Khasi Hills',
  ],
  'Mizoram': [
    'Aizawl',
    'Champhai',
    'Hnahthial',
    'Khawzawl',
    'Kolasib',
    'Lawngtlai',
    'Lunglei',
    'Mamit',
    'Saitual',
    'Serchhip',
    'Siaha',
  ],
  'Nagaland': [
    'Chumoukedima',
    'Dimapur',
    'Kiphire',
    'Kohima',
    'Longleng',
    'Meluri',
    'Mokokchung',
    'Mon',
    'Niuland',
    'Noklak',
    'Peren',
    'Phek',
    'Shamator',
    'Tseminyu',
    'Tuensang',
    'Wokha',
    'Zunheboto',
  ],
  'Sikkim': ['Gangtok', 'Gyalshing', 'Mangan', 'Namchi', 'Pakyong', 'Soreng'],
  'Tripura': [
    'Dhalai',
    'Gomati',
    'Khowai',
    'North Tripura',
    'Sepahijala',
    'South Tripura',
    'Unakoti',
    'West Tripura',
  ],
};

const regionI18n = <String, Map<String, String>>{
  'en': {
    'explore_regions': 'Explore NER & India',
    'region_subtitle':
        'Live weather and modelled soil moisture by state, district or GPS',
    'ner_focus': 'North-East Focus · 8 States',
    'ner_note': 'Priority monitoring for the 8 North Eastern Region states.',
    'other_states': 'Other 20 States',
    'select_state': 'Select state',
    'select_district': 'Select district',
    'district_loading': 'Loading district directory…',
    'district_unavailable':
        'District directory is unavailable. Connect once to download and cache it.',
    'use_gps': 'Use My GPS',
    'check_condition': 'Check Condition',
    'weather_condition': 'Weather condition',
    'temperature': 'Temperature',
    'humidity': 'Humidity',
    'rain_24h': 'Next 24h rainfall',
    'soil_moisture': 'Modelled soil moisture',
    'soil_surface': '0–1 cm',
    'soil_shallow': '1–3 cm',
    'soil_deeper': '3–9 cm',
    'soil_note':
        'Weather-model soil moisture estimate, not a ground sensor reading.',
    'screening': 'Weather-linked screening',
    'point_note':
        'District result is a representative forecast point, not a district-wide measurement.',
    'gps_note': 'GPS result uses your current phone location.',
    'data_sources': 'Data & AI Sources',
    'live_source': 'Live weather + soil moisture: Open-Meteo',
    'alerts_source': 'Official alerts: NDMA SACHET',
    'gsi_source': 'Landslide inventory / susceptibility: GSI Bhusanket',
    'nasa_source':
        'AI/ML reference: NASA LHASA 2.x (XGBoost) + NASA Global Landslide Catalog',
    'ml_truth':
        'Current app does not claim a locally trained ML model. It uses real live screening and official feeds; NASA/GSI datasets are the research/model sources for the ML phase.',
    'district_source':
        'District directory: open India district JSON, cached on-device after first download.',
    'last_result': 'Last checked location',
    'refreshing_region': 'Checking live conditions…',
    'location_lookup_failed': 'Could not resolve that district to coordinates.',
    'source_live': 'LIVE',
    'source_cached': 'CACHED',
    'record_video': 'Record video',
    'choose_video': 'Choose video',
    'remove_video': 'Remove video',
    'video_evidence': 'Video evidence',
    'video_saved': 'Video attached and stored on this device.',
  },
  'hi': {
    'explore_regions': 'NER और भारत देखें',
    'region_subtitle':
        'राज्य, जिला या GPS के लिए लाइव मौसम और मॉडल आधारित मिट्टी नमी',
    'ner_focus': 'उत्तर-पूर्व फोकस · 8 राज्य',
    'ner_note': 'उत्तर-पूर्व क्षेत्र के 8 राज्यों की प्राथमिक निगरानी।',
    'other_states': 'अन्य 20 राज्य',
    'select_state': 'राज्य चुनें',
    'select_district': 'जिला चुनें',
    'district_loading': 'जिला सूची लोड हो रही है…',
    'district_unavailable':
        'जिला सूची उपलब्ध नहीं है। एक बार इंटरनेट से डाउनलोड करके कैश करें।',
    'use_gps': 'मेरा GPS उपयोग करें',
    'check_condition': 'स्थिति जांचें',
    'weather_condition': 'मौसम स्थिति',
    'temperature': 'तापमान',
    'humidity': 'आर्द्रता',
    'rain_24h': 'अगले 24 घंटे की वर्षा',
    'soil_moisture': 'मॉडल आधारित मिट्टी नमी',
    'soil_surface': '0–1 सेमी',
    'soil_shallow': '1–3 सेमी',
    'soil_deeper': '3–9 सेमी',
    'soil_note':
        'यह मौसम मॉडल का मिट्टी नमी अनुमान है, जमीन पर लगे सेंसर का माप नहीं।',
    'screening': 'मौसम आधारित स्क्रीनिंग',
    'point_note':
        'जिला परिणाम एक प्रतिनिधि पूर्वानुमान बिंदु है, पूरे जिले का माप नहीं।',
    'gps_note': 'GPS परिणाम आपके फोन की वर्तमान लोकेशन उपयोग करता है।',
    'data_sources': 'डेटा और AI स्रोत',
    'live_source': 'लाइव मौसम + मिट्टी नमी: Open-Meteo',
    'alerts_source': 'आधिकारिक अलर्ट: NDMA SACHET',
    'gsi_source': 'भूस्खलन इन्वेंटरी / संवेदनशीलता: GSI Bhusanket',
    'nasa_source':
        'AI/ML संदर्भ: NASA LHASA 2.x (XGBoost) + NASA Global Landslide Catalog',
    'ml_truth':
        'वर्तमान ऐप स्थानीय रूप से प्रशिक्षित ML मॉडल का दावा नहीं करता। यह वास्तविक लाइव स्क्रीनिंग और आधिकारिक फीड उपयोग करता है; NASA/GSI डेटा ML चरण के शोध स्रोत हैं।',
    'district_source':
        'जिला सूची: खुला भारत जिला JSON, पहली डाउनलोड के बाद डिवाइस में कैश।',
    'last_result': 'अंतिम जांच स्थान',
    'refreshing_region': 'लाइव स्थिति जांची जा रही है…',
    'location_lookup_failed': 'जिले के निर्देशांक नहीं मिल सके।',
    'source_live': 'लाइव',
    'source_cached': 'कैश',
    'record_video': 'वीडियो रिकॉर्ड करें',
    'choose_video': 'वीडियो चुनें',
    'remove_video': 'वीडियो हटाएँ',
    'video_evidence': 'वीडियो प्रमाण',
    'video_saved': 'वीडियो इस डिवाइस पर सुरक्षित है।',
  },
  'as': {
    'explore_regions': 'NER আৰু ভাৰত চাওক',
    'region_subtitle':
        'ৰাজ্য, জিলা বা GPS অনুসৰি লাইভ বতৰ আৰু মডেল কৰা মাটিৰ আৰ্দ্ৰতা',
    'ner_focus': 'উত্তৰ-পূব ফোকাছ · ৮ ৰাজ্য',
    'ner_note': 'উত্তৰ-পূব অঞ্চলৰ ৮খন ৰাজ্যৰ অগ্ৰাধিকাৰ নিৰীক্ষণ।',
    'other_states': 'অন্য ২০ ৰাজ্য',
    'select_state': 'ৰাজ্য বাছক',
    'select_district': 'জিলা বাছক',
    'district_loading': 'জিলা তালিকা লোড হৈছে…',
    'district_unavailable':
        'জিলা তালিকা উপলভ্য নহয়। এবাৰ ইণ্টাৰনেটত ডাউনলোড কৰি কেশ কৰক।',
    'use_gps': 'মোৰ GPS ব্যৱহাৰ কৰক',
    'check_condition': 'অৱস্থা পৰীক্ষা কৰক',
    'weather_condition': 'বতৰৰ অৱস্থা',
    'temperature': 'তাপমাত্রা',
    'humidity': 'আৰ্দ্ৰতা',
    'rain_24h': 'পৰৱৰ্তী ২৪ ঘণ্টাৰ বৰষুণ',
    'soil_moisture': 'মডেল কৰা মাটিৰ আৰ্দ্ৰতা',
    'soil_surface': '০–১ ছেমি',
    'soil_shallow': '১–৩ ছেমি',
    'soil_deeper': '৩–৯ ছেমি',
    'soil_note':
        'ই বতৰ মডেলৰ মাটিৰ আৰ্দ্ৰতা অনুমান, মাটিত স্থাপন কৰা সেন্সৰৰ পাঠ নহয়।',
    'screening': 'বতৰ-সংযুক্ত স্ক্ৰিনিং',
    'point_note':
        'জিলাৰ ফলাফল এটা প্ৰতিনিধি পূৰ্বানুমান বিন্দু, সমগ্ৰ জিলাৰ মাপ নহয়।',
    'gps_note': 'GPS ফলাফলে ফোনৰ বৰ্তমান অৱস্থান ব্যৱহাৰ কৰে।',
    'data_sources': 'ডাটা আৰু AI উৎস',
    'live_source': 'লাইভ বতৰ + মাটিৰ আৰ্দ্ৰতা: Open-Meteo',
    'alerts_source': 'চৰকাৰী সতৰ্কতা: NDMA SACHET',
    'gsi_source': 'ভূমিস্খলন ইনভেণ্টৰি / সংবেদনশীলতা: GSI Bhusanket',
    'nasa_source':
        'AI/ML ৰেফাৰেন্স: NASA LHASA 2.x (XGBoost) + NASA Global Landslide Catalog',
    'ml_truth':
        'বৰ্তমান এপে স্থানীয়ভাৱে প্ৰশিক্ষিত ML মডেলৰ দাবী নকৰে। ই বাস্তৱ লাইভ স্ক্ৰিনিং আৰু চৰকাৰী ফীড ব্যৱহাৰ কৰে।',
    'district_source':
        'জিলা তালিকা: খোলা ভাৰত জিলা JSON, প্ৰথম ডাউনলোডৰ পিছত ডিভাইচত কেশ।',
    'last_result': 'শেষ পৰীক্ষিত স্থান',
    'refreshing_region': 'লাইভ অৱস্থা পৰীক্ষা হৈ আছে…',
    'location_lookup_failed': 'জিলাৰ স্থানাংক পোৱা নগ’ল।',
    'source_live': 'লাইভ',
    'source_cached': 'কেশ',
    'record_video': 'ভিডিঅ’ ৰেকৰ্ড কৰক',
    'choose_video': 'ভিডিঅ’ বাছক',
    'remove_video': 'ভিডিঅ’ আঁতৰাওক',
    'video_evidence': 'ভিডিঅ’ প্ৰমাণ',
    'video_saved': 'ভিডিঅ’ ডিভাইচত সংৰক্ষণ কৰা হৈছে।',
  },
  'bn': {
    'explore_regions': 'NER ও ভারত দেখুন',
    'region_subtitle':
        'রাজ্য, জেলা বা GPS অনুযায়ী লাইভ আবহাওয়া ও মডেলভিত্তিক মাটির আর্দ্রতা',
    'ner_focus': 'উত্তর-পূর্ব ফোকাস · ৮ রাজ্য',
    'ner_note': 'উত্তর-পূর্ব অঞ্চলের ৮ রাজ্যের অগ্রাধিকার পর্যবেক্ষণ।',
    'other_states': 'অন্য ২০ রাজ্য',
    'select_state': 'রাজ্য নির্বাচন করুন',
    'select_district': 'জেলা নির্বাচন করুন',
    'district_loading': 'জেলা তালিকা লোড হচ্ছে…',
    'district_unavailable':
        'জেলা তালিকা পাওয়া যাচ্ছে না। একবার ইন্টারনেটে ডাউনলোড করে ক্যাশ করুন।',
    'use_gps': 'আমার GPS ব্যবহার করুন',
    'check_condition': 'অবস্থা পরীক্ষা করুন',
    'weather_condition': 'আবহাওয়ার অবস্থা',
    'temperature': 'তাপমাত্রা',
    'humidity': 'আর্দ্রতা',
    'rain_24h': 'পরবর্তী ২৪ ঘণ্টার বৃষ্টি',
    'soil_moisture': 'মডেলভিত্তিক মাটির আর্দ্রতা',
    'soil_surface': '০–১ সেমি',
    'soil_shallow': '১–৩ সেমি',
    'soil_deeper': '৩–৯ সেমি',
    'soil_note':
        'এটি আবহাওয়া মডেলের মাটির আর্দ্রতার অনুমান, মাঠের সেন্সরের রিডিং নয়।',
    'screening': 'আবহাওয়া-সংযুক্ত স্ক্রিনিং',
    'point_note':
        'জেলার ফল একটি প্রতিনিধিত্বমূলক পূর্বাভাস বিন্দু, পুরো জেলার মাপ নয়।',
    'gps_note': 'GPS ফল আপনার ফোনের বর্তমান অবস্থান ব্যবহার করে।',
    'data_sources': 'ডেটা ও AI উৎস',
    'live_source': 'লাইভ আবহাওয়া + মাটির আর্দ্রতা: Open-Meteo',
    'alerts_source': 'সরকারি সতর্কতা: NDMA SACHET',
    'gsi_source': 'ভূমিধস ইনভেন্টরি / সংবেদনশীলতা: GSI Bhusanket',
    'nasa_source':
        'AI/ML রেফারেন্স: NASA LHASA 2.x (XGBoost) + NASA Global Landslide Catalog',
    'ml_truth':
        'বর্তমান অ্যাপ স্থানীয়ভাবে প্রশিক্ষিত ML মডেলের দাবি করে না। এটি বাস্তব লাইভ স্ক্রিনিং ও সরকারি ফিড ব্যবহার করে।',
    'district_source':
        'জেলা তালিকা: খোলা ভারত জেলা JSON, প্রথম ডাউনলোডের পরে ডিভাইসে ক্যাশ।',
    'last_result': 'শেষ পরীক্ষা করা স্থান',
    'refreshing_region': 'লাইভ অবস্থা পরীক্ষা হচ্ছে…',
    'location_lookup_failed': 'জেলার স্থানাঙ্ক পাওয়া যায়নি।',
    'source_live': 'লাইভ',
    'source_cached': 'ক্যাশ',
    'record_video': 'ভিডিও রেকর্ড করুন',
    'choose_video': 'ভিডিও বেছে নিন',
    'remove_video': 'ভিডিও সরান',
    'video_evidence': 'ভিডিও প্রমাণ',
    'video_saved': 'ভিডিও ডিভাইসে সংরক্ষিত হয়েছে।',
  },
  'ne': {
    'explore_regions': 'NER र भारत हेर्नुहोस्',
    'region_subtitle':
        'राज्य, जिल्ला वा GPS अनुसार लाइभ मौसम र मोडेल गरिएको माटो चिस्यान',
    'ner_focus': 'उत्तर-पूर्व फोकस · ८ राज्य',
    'ner_note': 'उत्तर-पूर्व क्षेत्रका ८ राज्यको प्राथमिक निगरानी।',
    'other_states': 'अन्य २० राज्य',
    'select_state': 'राज्य छान्नुहोस्',
    'select_district': 'जिल्ला छान्नुहोस्',
    'district_loading': 'जिल्ला सूची लोड हुँदैछ…',
    'district_unavailable':
        'जिल्ला सूची उपलब्ध छैन। एकपटक इन्टरनेटमा डाउनलोड गरी क्यास गर्नुहोस्।',
    'use_gps': 'मेरो GPS प्रयोग गर्नुहोस्',
    'check_condition': 'अवस्था जाँच्नुहोस्',
    'weather_condition': 'मौसम अवस्था',
    'temperature': 'तापक्रम',
    'humidity': 'आर्द्रता',
    'rain_24h': 'अर्को २४ घण्टाको वर्षा',
    'soil_moisture': 'मोडेल गरिएको माटो चिस्यान',
    'soil_surface': '०–१ सेमी',
    'soil_shallow': '१–३ सेमी',
    'soil_deeper': '३–९ सेमी',
    'soil_note':
        'यो मौसम मोडेलको माटो चिस्यान अनुमान हो, जमिनको सेन्सर रिडिङ होइन।',
    'screening': 'मौसम-सम्बन्धित स्क्रिनिङ',
    'point_note':
        'जिल्ला नतिजा प्रतिनिधि पूर्वानुमान बिन्दु हो, पुरै जिल्लाको मापन होइन।',
    'gps_note': 'GPS नतिजाले फोनको हालको स्थान प्रयोग गर्छ।',
    'data_sources': 'डाटा र AI स्रोत',
    'live_source': 'लाइभ मौसम + माटो चिस्यान: Open-Meteo',
    'alerts_source': 'आधिकारिक चेतावनी: NDMA SACHET',
    'gsi_source': 'पहिरो इनभेन्टरी / संवेदनशीलता: GSI Bhusanket',
    'nasa_source':
        'AI/ML सन्दर्भ: NASA LHASA 2.x (XGBoost) + NASA Global Landslide Catalog',
    'ml_truth':
        'हालको एपले स्थानीय रूपमा प्रशिक्षित ML मोडेलको दाबी गर्दैन। यसले वास्तविक लाइभ स्क्रिनिङ र आधिकारिक फिड प्रयोग गर्छ।',
    'district_source':
        'जिल्ला सूची: खुला भारत जिल्ला JSON, पहिलो डाउनलोडपछि डिभाइसमा क्यास।',
    'last_result': 'अन्तिम जाँच गरिएको स्थान',
    'refreshing_region': 'लाइभ अवस्था जाँचिँदैछ…',
    'location_lookup_failed': 'जिल्लाको निर्देशाङ्क पत्ता लागेन।',
    'source_live': 'लाइभ',
    'source_cached': 'क्यास',
    'record_video': 'भिडियो रेकर्ड गर्नुहोस्',
    'choose_video': 'भिडियो छान्नुहोस्',
    'remove_video': 'भिडियो हटाउनुहोस्',
    'video_evidence': 'भिडियो प्रमाण',
    'video_saved': 'भिडियो डिभाइसमा सुरक्षित गरिएको छ।',
  },
  'ta': {
    'explore_regions': 'NER மற்றும் இந்தியாவை ஆராய்க',
    'region_subtitle':
        'மாநிலம், மாவட்டம் அல்லது GPS அடிப்படையில் நேரடி வானிலை மற்றும் மாதிரி மண் ஈரப்பதம்',
    'ner_focus': 'வடகிழக்கு கவனம் · 8 மாநிலங்கள்',
    'ner_note':
        'வடகிழக்கு பிராந்தியத்தின் 8 மாநிலங்களுக்கு முன்னுரிமை கண்காணிப்பு.',
    'other_states': 'மற்ற 20 மாநிலங்கள்',
    'select_state': 'மாநிலத்தைத் தேர்ந்தெடுக்கவும்',
    'select_district': 'மாவட்டத்தைத் தேர்ந்தெடுக்கவும்',
    'district_loading': 'மாவட்ட பட்டியல் ஏற்றப்படுகிறது…',
    'district_unavailable':
        'மாவட்ட பட்டியல் கிடைக்கவில்லை. ஒருமுறை இணையத்தில் பதிவிறக்கம் செய்து சேமிக்கவும்.',
    'use_gps': 'என் GPS-ஐ பயன்படுத்தவும்',
    'check_condition': 'நிலையைச் சரிபார்க்கவும்',
    'weather_condition': 'வானிலை நிலை',
    'temperature': 'வெப்பநிலை',
    'humidity': 'ஈரப்பதம்',
    'rain_24h': 'அடுத்த 24 மணி மழை',
    'soil_moisture': 'மாதிரி மண் ஈரப்பதம்',
    'soil_surface': '0–1 செ.மீ',
    'soil_shallow': '1–3 செ.மீ',
    'soil_deeper': '3–9 செ.மீ',
    'soil_note':
        'இது வானிலை மாதிரி மண் ஈரப்பத மதிப்பீடு; தரை சென்சார் அளவு அல்ல.',
    'screening': 'வானிலை சார்ந்த ஸ்கிரீனிங்',
    'point_note':
        'மாவட்ட முடிவு பிரதிநிதி முன்னறிவிப்பு புள்ளி; முழு மாவட்ட அளவீடு அல்ல.',
    'gps_note': 'GPS முடிவு உங்கள் தொலைபேசி தற்போதைய இடத்தை பயன்படுத்துகிறது.',
    'data_sources': 'தரவு மற்றும் AI மூலங்கள்',
    'live_source': 'நேரடி வானிலை + மண் ஈரப்பதம்: Open-Meteo',
    'alerts_source': 'அதிகாரப்பூர்வ எச்சரிக்கை: NDMA SACHET',
    'gsi_source': 'நிலச்சரிவு இன்வென்டரி / உணர்திறன்: GSI Bhusanket',
    'nasa_source':
        'AI/ML குறிப்பு: NASA LHASA 2.x (XGBoost) + NASA Global Landslide Catalog',
    'ml_truth':
        'தற்போதைய ஆப் உள்ளூரில் பயிற்சியளிக்கப்பட்ட ML மாதிரி உள்ளது என்று கூறாது. இது உண்மையான நேரடி ஸ்கிரீனிங் மற்றும் அதிகாரப்பூர்வ தரவை பயன்படுத்துகிறது.',
    'district_source':
        'மாவட்ட பட்டியல்: திறந்த இந்திய மாவட்ட JSON, முதல் பதிவிறக்கத்திற்கு பின் சாதனத்தில் சேமிக்கப்படும்.',
    'last_result': 'கடைசியாக சரிபார்த்த இடம்',
    'refreshing_region': 'நேரடி நிலை சரிபார்க்கப்படுகிறது…',
    'location_lookup_failed':
        'மாவட்டத்தின் இணைக்கோடுகளை கண்டுபிடிக்க முடியவில்லை.',
    'source_live': 'நேரடி',
    'source_cached': 'சேமிப்பு',
    'record_video': 'வீடியோ பதிவு செய்யவும்',
    'choose_video': 'வீடியோ தேர்ந்தெடுக்கவும்',
    'remove_video': 'வீடியோ அகற்றவும்',
    'video_evidence': 'வீடியோ ஆதாரம்',
    'video_saved': 'வீடியோ சாதனத்தில் சேமிக்கப்பட்டது.',
  },
  'te': {
    'explore_regions': 'NER & భారతదేశాన్ని చూడండి',
    'region_subtitle':
        'రాష్ట్రం, జిల్లా లేదా GPS ఆధారంగా లైవ్ వాతావరణం మరియు మోడల్ నేల తేమ',
    'ner_focus': 'ఈశాన్య ఫోకస్ · 8 రాష్ట్రాలు',
    'ner_note': 'ఈశాన్య ప్రాంతంలోని 8 రాష్ట్రాలకు ప్రాధాన్యత గల పర్యవేక్షణ.',
    'other_states': 'ఇతర 20 రాష్ట్రాలు',
    'select_state': 'రాష్ట్రాన్ని ఎంచుకోండి',
    'select_district': 'జిల్లాను ఎంచుకోండి',
    'district_loading': 'జిల్లా జాబితా లోడ్ అవుతోంది…',
    'district_unavailable':
        'జిల్లా జాబితా అందుబాటులో లేదు. ఒకసారి ఇంటర్నెట్‌లో డౌన్‌లోడ్ చేసి కాష్ చేయండి.',
    'use_gps': 'నా GPS ఉపయోగించు',
    'check_condition': 'స్థితిని తనిఖీ చేయండి',
    'weather_condition': 'వాతావరణ స్థితి',
    'temperature': 'ఉష్ణోగ్రత',
    'humidity': 'తేమ',
    'rain_24h': 'తదుపరి 24గం వర్షం',
    'soil_moisture': 'మోడల్ నేల తేమ',
    'soil_surface': '0–1 సెం.మీ',
    'soil_shallow': '1–3 సెం.మీ',
    'soil_deeper': '3–9 సెం.మీ',
    'soil_note':
        'ఇది వాతావరణ మోడల్ నేల తేమ అంచనా; భూమిపై సెన్సార్ రీడింగ్ కాదు.',
    'screening': 'వాతావరణ-లింక్డ్ స్క్రీనింగ్',
    'point_note':
        'జిల్లా ఫలితం ప్రతినిధి అంచనా బిందువు; మొత్తం జిల్లా కొలత కాదు.',
    'gps_note': 'GPS ఫలితం మీ ఫోన్ ప్రస్తుత స్థానాన్ని ఉపయోగిస్తుంది.',
    'data_sources': 'డేటా & AI మూలాలు',
    'live_source': 'లైవ్ వాతావరణం + నేల తేమ: Open-Meteo',
    'alerts_source': 'అధికారిక హెచ్చరికలు: NDMA SACHET',
    'gsi_source': 'భూస्खలనం ఇన్వెంటరీ / ససెప్టిబిలిటీ: GSI Bhusanket',
    'nasa_source':
        'AI/ML రిఫరెన్స్: NASA LHASA 2.x (XGBoost) + NASA Global Landslide Catalog',
    'ml_truth':
        'ప్రస్తుత యాప్ స్థానికంగా శిక్షణ పొందిన ML మోడల్ ఉందని చెప్పదు. ఇది నిజమైన లైవ్ స్క్రీనింగ్ మరియు అధికారిక ఫీడ్లను ఉపయోగిస్తుంది.',
    'district_source':
        'జిల్లా డైరెక్టరీ: ఓపెన్ ఇండియా జిల్లా JSON, మొదటి డౌన్‌లోడ్ తర్వాత డివైస్‌లో కాష్.',
    'last_result': 'చివరిగా తనిఖీ చేసిన స్థలం',
    'refreshing_region': 'లైవ్ పరిస్థితులు తనిఖీ అవుతున్నాయి…',
    'location_lookup_failed': 'జిల్లా కోఆర్డినేట్లు దొరకలేదు.',
    'source_live': 'లైవ్',
    'source_cached': 'కాష్',
    'record_video': 'వీడియో రికార్డ్ చేయండి',
    'choose_video': 'వీడియో ఎంచుకోండి',
    'remove_video': 'వీడియో తొలగించండి',
    'video_evidence': 'వీడియో ఆధారం',
    'video_saved': 'వీడియో డివైస్‌లో నిల్వ చేయబడింది.',
  },
  'kn': {
    'explore_regions': 'NER ಮತ್ತು ಭಾರತ ಅನ್ವೇಷಿಸಿ',
    'region_subtitle':
        'ರಾಜ್ಯ, ಜಿಲ್ಲೆ ಅಥವಾ GPS ಆಧಾರದ ಮೇಲೆ ಲೈವ್ ಹವಾಮಾನ ಮತ್ತು ಮಾದರಿ ಮಣ್ಣಿನ ತೇವಾಂಶ',
    'ner_focus': 'ಈಶಾನ್ಯ ಕೇಂದ್ರೀಕರಣ · 8 ರಾಜ್ಯಗಳು',
    'ner_note': 'ಈಶಾನ್ಯ ಪ್ರದೇಶದ 8 ರಾಜ್ಯಗಳಿಗೆ ಆದ್ಯತಾ ಮೇಲ್ವಿಚಾರಣೆ.',
    'other_states': 'ಇತರೆ 20 ರಾಜ್ಯಗಳು',
    'select_state': 'ರಾಜ್ಯ ಆಯ್ಕೆಮಾಡಿ',
    'select_district': 'ಜಿಲ್ಲೆ ಆಯ್ಕೆಮಾಡಿ',
    'district_loading': 'ಜಿಲ್ಲಾ ಪಟ್ಟಿ ಲೋಡ್ ಆಗುತ್ತಿದೆ…',
    'district_unavailable':
        'ಜಿಲ್ಲಾ ಪಟ್ಟಿ ಲಭ್ಯವಿಲ್ಲ. ಒಮ್ಮೆ ಇಂಟರ್ನೆಟ್‌ನಲ್ಲಿ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ ಕ್ಯಾಶ್ ಮಾಡಿ.',
    'use_gps': 'ನನ್ನ GPS ಬಳಸಿ',
    'check_condition': 'ಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಿ',
    'weather_condition': 'ಹವಾಮಾನ ಸ್ಥಿತಿ',
    'temperature': 'ತಾಪಮಾನ',
    'humidity': 'ಆದ್ರತೆ',
    'rain_24h': 'ಮುಂದಿನ 24ಗಂ ಮಳೆ',
    'soil_moisture': 'ಮಾದರಿ ಮಣ್ಣಿನ ತೇವಾಂಶ',
    'soil_surface': '0–1 ಸೆಂ',
    'soil_shallow': '1–3 ಸೆಂ',
    'soil_deeper': '3–9 ಸೆಂ',
    'soil_note':
        'ಇದು ಹವಾಮಾನ ಮಾದರಿಯ ಮಣ್ಣಿನ ತೇವಾಂಶ ಅಂದಾಜು; ನೆಲದ ಸೆನ್ಸರ್ ಓದು ಅಲ್ಲ.',
    'screening': 'ಹವಾಮಾನ-ಸಂಬಂಧಿತ ಪರಿಶೀಲನೆ',
    'point_note':
        'ಜಿಲ್ಲಾ ಫಲಿತಾಂಶ ಪ್ರತಿನಿಧಿ ಮುನ್ಸೂಚನೆ ಬಿಂದು; ಇಡೀ ಜಿಲ್ಲೆಯ ಮಾಪನವಲ್ಲ.',
    'gps_note': 'GPS ಫಲಿತಾಂಶ ಫೋನ್‌ನ ಪ್ರಸ್ತುತ ಸ್ಥಳವನ್ನು ಬಳಸುತ್ತದೆ.',
    'data_sources': 'ಡೇಟಾ ಮತ್ತು AI ಮೂಲಗಳು',
    'live_source': 'ಲೈವ್ ಹವಾಮಾನ + ಮಣ್ಣಿನ ತೇವಾಂಶ: Open-Meteo',
    'alerts_source': 'ಅಧಿಕೃತ ಎಚ್ಚರಿಕೆಗಳು: NDMA SACHET',
    'gsi_source': 'ಭೂಕುಸಿತ ಇನ್ವೆಂಟರಿ / ಸಂವೇದನಾಶೀಲತೆ: GSI Bhusanket',
    'nasa_source':
        'AI/ML ಉಲ್ಲೇಖ: NASA LHASA 2.x (XGBoost) + NASA Global Landslide Catalog',
    'ml_truth':
        'ಪ್ರಸ್ತುತ ಆಪ್ ಸ್ಥಳೀಯವಾಗಿ ತರಬೇತುಗೊಂಡ ML ಮಾದರಿ ಇದೆ ಎಂದು ಹೇಳುವುದಿಲ್ಲ. ಇದು ನೈಜ ಲೈವ್ ಪರಿಶೀಲನೆ ಮತ್ತು ಅಧಿಕೃತ ಫೀಡ್ ಬಳಸುತ್ತದೆ.',
    'district_source':
        'ಜಿಲ್ಲಾ ಡೈರೆಕ್ಟರಿ: ಓಪನ್ ಇಂಡಿಯಾ ಜಿಲ್ಲಾ JSON, ಮೊದಲ ಡೌನ್‌ಲೋಡ್ ನಂತರ ಸಾಧನದಲ್ಲಿ ಕ್ಯಾಶ್.',
    'last_result': 'ಕೊನೆಯದಾಗಿ ಪರಿಶೀಲಿಸಿದ ಸ್ಥಳ',
    'refreshing_region': 'ಲೈವ್ ಪರಿಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಲಾಗುತ್ತಿದೆ…',
    'location_lookup_failed': 'ಜಿಲ್ಲೆಯ ಸಮನ್ವಯಾಂಕ ಸಿಗಲಿಲ್ಲ.',
    'source_live': 'ಲೈವ್',
    'source_cached': 'ಕ್ಯಾಶ್',
    'record_video': 'ವೀಡಿಯೊ ರೆಕಾರ್ಡ್ ಮಾಡಿ',
    'choose_video': 'ವೀಡಿಯೊ ಆಯ್ಕೆಮಾಡಿ',
    'remove_video': 'ವೀಡಿಯೊ ತೆಗೆದುಹಾಕಿ',
    'video_evidence': 'ವೀಡಿಯೊ ಸಾಕ್ಷ್ಯ',
    'video_saved': 'ವೀಡಿಯೊ ಸಾಧನದಲ್ಲಿ ಉಳಿಸಲಾಗಿದೆ.',
  },
  'ml': {
    'explore_regions': 'NERയും ഇന്ത്യയും പരിശോധിക്കുക',
    'region_subtitle':
        'സംസ്ഥാനം, ജില്ല അല്ലെങ്കിൽ GPS അടിസ്ഥാനത്തിലുള്ള ലൈവ് കാലാവസ്ഥയും മോഡൽ മണ്ണിലെ ഈർപ്പവും',
    'ner_focus': 'വടക്കുകിഴക്കൻ ഫോക്കസ് · 8 സംസ്ഥാനങ്ങൾ',
    'ner_note': 'വടക്കുകിഴക്കൻ മേഖലയിലെ 8 സംസ്ഥാനങ്ങൾക്ക് മുൻഗണനാ നിരീക്ഷണം.',
    'other_states': 'മറ്റ് 20 സംസ്ഥാനങ്ങൾ',
    'select_state': 'സംസ്ഥാനം തിരഞ്ഞെടുക്കുക',
    'select_district': 'ജില്ല തിരഞ്ഞെടുക്കുക',
    'district_loading': 'ജില്ല പട്ടിക ലോഡുചെയ്യുന്നു…',
    'district_unavailable':
        'ജില്ല പട്ടിക ലഭ്യമല്ല. ഒരിക്കൽ ഇന്റർനെറ്റിൽ ഡൗൺലോഡ് ചെയ്ത് കാഷ് ചെയ്യുക.',
    'use_gps': 'എന്റെ GPS ഉപയോഗിക്കുക',
    'check_condition': 'സ്ഥിതി പരിശോധിക്കുക',
    'weather_condition': 'കാലാവസ്ഥ സ്ഥിതി',
    'temperature': 'താപനില',
    'humidity': 'ആർദ്രത',
    'rain_24h': 'അടുത്ത 24 മണിക്കൂർ മഴ',
    'soil_moisture': 'മോഡൽ മണ്ണിലെ ഈർപ്പം',
    'soil_surface': '0–1 സെ.മീ',
    'soil_shallow': '1–3 സെ.മീ',
    'soil_deeper': '3–9 സെ.മീ',
    'soil_note':
        'ഇത് കാലാവസ്ഥാ മോഡലിന്റെ മണ്ണിലെ ഈർപ്പ കണക്ക്; ഗ്രൗണ്ട് സെൻസർ റീഡിംഗ് അല്ല.',
    'screening': 'കാലാവസ്ഥ-ബന്ധിത സ്ക്രീനിംഗ്',
    'point_note':
        'ജില്ലാ ഫലം പ്രതിനിധി പ്രവചന ബിന്ദുവാണ്; മുഴുവൻ ജില്ലയിലെ അളവ് അല്ല.',
    'gps_note': 'GPS ഫലം ഫോണിന്റെ നിലവിലെ സ്ഥലം ഉപയോഗിക്കുന്നു.',
    'data_sources': 'ഡാറ്റ & AI ഉറവിടങ്ങൾ',
    'live_source': 'ലൈവ് കാലാവസ്ഥ + മണ്ണിലെ ഈർപ്പം: Open-Meteo',
    'alerts_source': 'ഔദ്യോഗിക മുന്നറിയിപ്പുകൾ: NDMA SACHET',
    'gsi_source': 'മണ്ണിടിച്ചിൽ ഇൻവെന്ററി / സസെപ്റ്റിബിലിറ്റി: GSI Bhusanket',
    'nasa_source':
        'AI/ML റഫറൻസ്: NASA LHASA 2.x (XGBoost) + NASA Global Landslide Catalog',
    'ml_truth':
        'നിലവിലെ ആപ്പ് പ്രാദേശികമായി പരിശീലിപ്പിച്ച ML മോഡൽ ഉണ്ടെന്ന് അവകാശപ്പെടുന്നില്ല. ഇത് യഥാർത്ഥ ലൈവ് സ്ക്രീനിംഗും ഔദ്യോഗിക ഫീഡുകളും ഉപയോഗിക്കുന്നു.',
    'district_source':
        'ജില്ല ഡയറക്ടറി: ഓപ്പൺ ഇന്ത്യ ജില്ലാ JSON, ആദ്യ ഡൗൺലോഡിന് ശേഷം ഉപകരണത്തിൽ കാഷ്.',
    'last_result': 'അവസാനം പരിശോധിച്ച സ്ഥലം',
    'refreshing_region': 'ലൈവ് സ്ഥിതി പരിശോധിക്കുന്നു…',
    'location_lookup_failed': 'ജില്ലയുടെ കോർഡിനേറ്റുകൾ കണ്ടെത്താനായില്ല.',
    'source_live': 'ലൈവ്',
    'source_cached': 'കാഷ്',
    'record_video': 'വീഡിയോ റെക്കോർഡ് ചെയ്യുക',
    'choose_video': 'വീഡിയോ തിരഞ്ഞെടുക്കുക',
    'remove_video': 'വീഡിയോ നീക്കുക',
    'video_evidence': 'വീഡിയോ തെളിവ്',
    'video_saved': 'വീഡിയോ ഉപകരണത്തിൽ സൂക്ഷിച്ചു.',
  },
  'mr': {
    'explore_regions': 'NER आणि भारत तपासा',
    'region_subtitle':
        'राज्य, जिल्हा किंवा GPS नुसार लाइव्ह हवामान आणि मॉडेल माती आर्द्रता',
    'ner_focus': 'ईशान्य फोकस · 8 राज्ये',
    'ner_note': 'ईशान्य प्रदेशातील 8 राज्यांचे प्राधान्य निरीक्षण.',
    'other_states': 'इतर 20 राज्ये',
    'select_state': 'राज्य निवडा',
    'select_district': 'जिल्हा निवडा',
    'district_loading': 'जिल्हा सूची लोड होत आहे…',
    'district_unavailable':
        'जिल्हा सूची उपलब्ध नाही. एकदा इंटरनेटवर डाउनलोड करून कॅश करा.',
    'use_gps': 'माझा GPS वापरा',
    'check_condition': 'स्थिती तपासा',
    'weather_condition': 'हवामान स्थिती',
    'temperature': 'तापमान',
    'humidity': 'आर्द्रता',
    'rain_24h': 'पुढील 24 तासांचा पाऊस',
    'soil_moisture': 'मॉडेल माती आर्द्रता',
    'soil_surface': '0–1 सेमी',
    'soil_shallow': '1–3 सेमी',
    'soil_deeper': '3–9 सेमी',
    'soil_note':
        'हे हवामान मॉडेलचे माती आर्द्रता अनुमान आहे; जमिनीवरील सेन्सर रीडिंग नाही.',
    'screening': 'हवामान-संबंधित तपासणी',
    'point_note':
        'जिल्हा निकाल प्रतिनिधी पूर्वानुमान बिंदू आहे; संपूर्ण जिल्ह्याचे मापन नाही.',
    'gps_note': 'GPS निकाल फोनचे सध्याचे स्थान वापरतो.',
    'data_sources': 'डेटा आणि AI स्रोत',
    'live_source': 'लाइव्ह हवामान + माती आर्द्रता: Open-Meteo',
    'alerts_source': 'अधिकृत इशारे: NDMA SACHET',
    'gsi_source': 'भूस्खलन इन्व्हेंटरी / संवेदनशीलता: GSI Bhusanket',
    'nasa_source':
        'AI/ML संदर्भ: NASA LHASA 2.x (XGBoost) + NASA Global Landslide Catalog',
    'ml_truth':
        'सध्याचे अॅप स्थानिकरित्या प्रशिक्षित ML मॉडेल असल्याचा दावा करत नाही. ते वास्तविक लाइव्ह तपासणी आणि अधिकृत फीड वापरते.',
    'district_source':
        'जिल्हा सूची: ओपन इंडिया जिल्हा JSON, पहिल्या डाउनलोडनंतर डिव्हाइसवर कॅश.',
    'last_result': 'शेवटचे तपासलेले ठिकाण',
    'refreshing_region': 'लाइव्ह स्थिती तपासली जात आहे…',
    'location_lookup_failed': 'जिल्ह्याचे निर्देशांक मिळाले नाहीत.',
    'source_live': 'लाइव्ह',
    'source_cached': 'कॅश',
    'record_video': 'व्हिडिओ रेकॉर्ड करा',
    'choose_video': 'व्हिडिओ निवडा',
    'remove_video': 'व्हिडिओ काढा',
    'video_evidence': 'व्हिडिओ पुरावा',
    'video_saved': 'व्हिडिओ डिव्हाइसवर साठवला.',
  },
};

String regionText(String key) =>
    regionI18n[appController.language]?[key] ?? regionI18n['en']?[key] ?? key;

Future<void> _finishStartupInBackground() async {
  // Give Flutter time to render the first frame before
  // initializing non-essential services.
  await Future<void>.delayed(const Duration(milliseconds: 900));

  try {
    await NotificationService.init();
  } catch (_) {}

  // Old report history is no longer used by the new
  // AI image screening page.
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hazard_reports');
  } catch (_) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This is local SharedPreferences data and is needed
  // to know whether login is already completed.
  await appController.load();

  // Paint the UI immediately.
  runApp(const GEONEXAApp());

  // Everything non-essential continues after first paint.
  unawaited(_finishStartupInBackground());
}

class AppController extends ChangeNotifier {
  String language = 'en';
  String userName = '';
  String mobile = '';

  bool get loggedIn =>
      userName.trim().isNotEmpty && RegExp(r'^\d{10}$').hasMatch(mobile);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    language = p.getString('language') ?? 'en';
    userName = p.getString('user_name') ?? '';
    mobile = p.getString('mobile') ?? '';
  }

  Future<void> setLanguage(String value) async {
    language = value;
    final p = await SharedPreferences.getInstance();
    await p.setString('language', value);
    notifyListeners();
  }

  Future<void> saveProfile(String name, String phone) async {
    userName = name.trim();
    mobile = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final p = await SharedPreferences.getInstance();
    await p.setString('user_name', userName);
    await p.setString('mobile', mobile);
    notifyListeners();
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('user_name');
    await p.remove('mobile');
    userName = '';
    mobile = '';
    notifyListeners();
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await plugin.initialize(settings: settings);

    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> highRain(double mm) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'landslide_alerts',
        'GEONEXA Alerts',
        channelDescription: 'Rainfall and verified hazard alerts',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await plugin.show(
      id: 1001,
      title: 'GEONEXA',
      body:
          '${tr('stage1_active')} ${tr('next24rain')}: ${mm.toStringAsFixed(1)} mm',
      notificationDetails: details,
    );
  }

  static Future<void> highReport(String place) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'landslide_report_alerts',
        'GEONEXA Report Alerts',
        channelDescription: 'High-priority screened hazard reports',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'GEONEXA · ${tr('risk_high')}',
      body: '${tr('screen_high_advice')} ${place.isNotEmpty ? place : ''}',
      notificationDetails: details,
    );
  }
}

class GEONEXAApp extends StatelessWidget {
  const GEONEXAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GEONEXA',
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF061724),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5DE0B5),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF102838),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appController,
      builder: (context, _) {
        return appController.loggedIn
            ? const MainScreen()
            : const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final name = TextEditingController();
  final mobile = TextEditingController();
  String? error;
  bool loading = false;

  @override
  void dispose() {
    name.dispose();
    mobile.dispose();
    super.dispose();
  }

  Future<void> continueLogin() async {
    final n = name.text.trim();
    final m = mobile.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (n.isEmpty || !RegExp(r'^\d{10}$').hasMatch(m)) {
      setState(() => error = tr('invalid_login'));
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    await appController.saveProfile(n, m);
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 42),
            Center(
              child: Image.asset(
                'assets/branding/geonexa_logo.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              tr('login_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              tr('login_subtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              initialValue: appController.language,
              decoration: InputDecoration(
                labelText: tr('language'),
                prefixIcon: const Icon(Icons.language),
              ),
              items: languageNames.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: loading
                  ? null
                  : (value) async {
                      if (value != null) {
                        await appController.setLanguage(value);
                        if (mounted) setState(() {});
                      }
                    },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: name,
              enabled: !loading,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: tr('name'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: mobile,
              enabled: !loading,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: tr('mobile'),
                prefixIcon: const Icon(Icons.phone_outlined),
                prefixText: '+91 ',
              ),
              onSubmitted: (_) => continueLogin(),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton.icon(
                onPressed: continueLogin,
                icon: const Icon(Icons.arrow_forward),
                label: Text(tr('continue')),
              ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  late final List<Widget?> _pages;

  Widget _makePage(int page) {
    switch (page) {
      case 0:
        return const RiskScreen();
      case 1:
        return const ReportScreen();
      case 2:
        return const WeatherScreen();
      case 3:
        return const PinScreen();
      case 4:
        return const AssistantScreen();
      case 5:
        return const LanguageScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();

    // Do not initialize every network-heavy page
    // when the application starts.
    _pages = List<Widget?>.filled(6, null);

    // Risk is the initial page.
    _pages[0] = _makePage(0);

    appController.addListener(_onAppControllerChanged);
  }

  void _onAppControllerChanged() {
    if (!mounted) return;

    // Recreate only pages already opened so translated
    // text can refresh after language changes.
    for (var i = 0; i < _pages.length; i++) {
      if (_pages[i] != null) {
        _pages[i] = _makePage(i);
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    appController.removeListener(_onAppControllerChanged);
    super.dispose();
  }

  Future<void> showSos() async {
    final prefs = await SharedPreferences.getInstance();

    final lat = prefs.getDouble('last_latitude');
    final lon = prefs.getDouble('last_longitude');
    final place = prefs.getString('last_place_name') ?? '';

    if (!mounted) return;

    String reason = 'injured';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF102838),
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final reasonLabel =
                {
                  'injured': tr('injured'),
                  'trapped': tr('trapped'),
                  'landslide': tr('landslide_nearby'),
                  'other': tr('other'),
                }[reason] ??
                tr('other');

            final mapLink = lat != null && lon != null
                ? 'https://maps.google.com/?q=$lat,$lon'
                : '';

            final messageParts = <String>[
              '🚨 GEONEXA SOS',
              '${tr('reason')}: $reasonLabel',
              if (place.isNotEmpty) place,
              if (lat != null && lon != null)
                'GPS: ${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}',
              if (mapLink.isNotEmpty) mapLink,
            ];

            final message = messageParts.join('\n');

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sos, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Text(
                          tr('emergency'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: reason,
                      decoration: InputDecoration(labelText: tr('reason')),
                      items: [
                        DropdownMenuItem(
                          value: 'injured',
                          child: Text(tr('injured')),
                        ),
                        DropdownMenuItem(
                          value: 'trapped',
                          child: Text(tr('trapped')),
                        ),
                        DropdownMenuItem(
                          value: 'landslide',
                          child: Text(tr('landslide_nearby')),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text(tr('other')),
                        ),
                      ],
                      onChanged: (value) {
                        setSheetState(() {
                          reason = value ?? reason;
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    ListTile(
                      leading: const Icon(Icons.call, color: Colors.redAccent),
                      title: Text(tr('call112')),
                      onTap: () async {
                        Navigator.pop(context);

                        await launchUrl(
                          Uri.parse('tel:112'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.share_location_outlined,
                        color: Color(0xFF5DE0B5),
                      ),
                      title: Text(alertUiText('share_location')),
                      subtitle: mapLink.isNotEmpty
                          ? Text(
                              place.isNotEmpty ? place : mapLink,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () async {
                        if (mapLink.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(tr('no_location'))),
                          );
                          return;
                        }

                        await SharePlus.instance.share(
                          ShareParams(subject: 'GEONEXA SOS', text: message),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.sms_outlined),
                      title: Text(tr('sms_registered')),
                      subtitle: Text(appController.mobile),
                      onTap: () async {
                        Navigator.pop(context);

                        final uri = Uri(
                          scheme: 'sms',
                          path: appController.mobile,
                          queryParameters: {'body': message},
                        );

                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          await SharePlus.instance.share(
                            ShareParams(subject: 'GEONEXA SOS', text: message),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = List<Widget>.generate(
      6,
      (page) => _pages[page] ?? const SizedBox.shrink(),
    );

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) {
          if (_pages[v] == null) {
            _pages[v] = _makePage(v);
          }

          setState(() {
            index = v;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: tr('risk'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.report_outlined),
            selectedIcon: const Icon(Icons.report),
            label: tr('report'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.cloud_outlined),
            selectedIcon: const Icon(Icons.cloud),
            label: tr('weather'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.location_on_outlined),
            selectedIcon: const Icon(Icons.location_on),
            label: tr('pin'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.smart_toy_outlined),
            selectedIcon: const Icon(Icons.smart_toy),
            label: tr('assistant'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.language),
            label: tr('language'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE9365D),
        foregroundColor: Colors.white,
        onPressed: showSos,
        icon: const Icon(Icons.emergency_outlined),
        label: Text(
          tr('sos'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AppHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E3548), Color(0xFF0A2030)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF5DE0B5).withValues(alpha: .24),
              ),
            ),
            child: Image.asset(
              'assets/branding/geonexa_logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  const AppCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3042), Color(0xFF0A2232)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF5DE0B5).withValues(alpha: .18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white54)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String place;
  final bool cached;
  final DateTime? updatedAt;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.place,
    required this.cached,
    this.updatedAt,
  });
}

class WeatherData {
  final List<String> dailyDates;
  final List<num> maxTemp;
  final List<num> minTemp;
  final List<num> dailyRain;
  final List<num> dailyProb;
  final List<num> dailyCode;
  final double next24Rain;
  final bool cached;
  final String fetchedAt;

  WeatherData({
    required this.dailyDates,
    required this.maxTemp,
    required this.minTemp,
    required this.dailyRain,
    required this.dailyProb,
    required this.dailyCode,
    required this.next24Rain,
    this.cached = false,
    String? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toJson() => {
    'dailyDates': dailyDates,
    'maxTemp': maxTemp,
    'minTemp': minTemp,
    'dailyRain': dailyRain,
    'dailyProb': dailyProb,
    'dailyCode': dailyCode,
    'next24Rain': next24Rain,
    'fetchedAt': fetchedAt,
  };

  factory WeatherData.fromJson(Map<String, dynamic> j, {bool cached = false}) =>
      WeatherData(
        dailyDates: List<String>.from(j['dailyDates'] ?? []),
        maxTemp: List<num>.from(j['maxTemp'] ?? []),
        minTemp: List<num>.from(j['minTemp'] ?? []),
        dailyRain: List<num>.from(j['dailyRain'] ?? []),
        dailyProb: List<num>.from(j['dailyProb'] ?? []),
        dailyCode: List<num>.from(j['dailyCode'] ?? []),
        next24Rain: (j['next24Rain'] ?? 0).toDouble(),
        cached: cached,
        fetchedAt: j['fetchedAt']?.toString(),
      );
}

class DataService {
  static Future<LocationData?> cachedLocation() async {
    final p = await SharedPreferences.getInstance();
    final lat = p.getDouble('last_latitude');
    final lon = p.getDouble('last_longitude');
    if (lat == null || lon == null) return null;
    final time = DateTime.tryParse(p.getString('last_location_time') ?? '');
    return LocationData(
      latitude: lat,
      longitude: lon,
      accuracy: p.getDouble('last_accuracy') ?? 0,
      place:
          p.getString('last_place_name') ??
          '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}',
      cached: true,
      updatedAt: time,
    );
  }

  static Future<LocationData?> lastKnownLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getLastKnownPosition();
      if (pos == null) return null;

      final prefs = await SharedPreferences.getInstance();
      final cachedLat = prefs.getDouble('last_latitude');
      final cachedLon = prefs.getDouble('last_longitude');
      var place = prefs.getString('last_place_name') ?? '';

      final closeToCached =
          cachedLat != null &&
          cachedLon != null &&
          Geolocator.distanceBetween(
                cachedLat,
                cachedLon,
                pos.latitude,
                pos.longitude,
              ) <
              250;

      if (!closeToCached || place.trim().isEmpty) {
        place =
            '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
      }

      await prefs.setDouble('last_latitude', pos.latitude);
      await prefs.setDouble('last_longitude', pos.longitude);
      await prefs.setDouble('last_accuracy', pos.accuracy);
      await prefs.setString(
        'last_location_time',
        DateTime.now().toIso8601String(),
      );

      return LocationData(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        place: place,
        cached: true,
        updatedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<WeatherData?> cachedWeather() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('weather_cache');
    if (raw == null) return null;
    try {
      return WeatherData.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw)),
        cached: true,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<LocationData> getLocation({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw Exception(tr('location_off'));

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception(tr('permission_denied'));
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(tr('open_settings'));
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).timeout(timeout);

    final p = await SharedPreferences.getInstance();
    await p.setDouble('last_latitude', pos.latitude);
    await p.setDouble('last_longitude', pos.longitude);
    await p.setDouble('last_accuracy', pos.accuracy);
    await p.setString('last_location_time', DateTime.now().toIso8601String());

    var place =
        p.getString('last_place_name') ??
        '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
    try {
      place = await reverseGeocode(
        pos.latitude,
        pos.longitude,
      ).timeout(const Duration(seconds: 8));
      await p.setString('last_place_name', place);
    } catch (_) {}

    return LocationData(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      place: place,
      cached: false,
      updatedAt: DateTime.now(),
    );
  }

  static Future<String> reverseGeocode(double lat, double lon) async {
    final fallback = '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': '$lat',
        'lon': '$lon',
        'zoom': '18',
        'addressdetails': '1',
        'namedetails': '1',
      });
      final r = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'GEONEXA/1.0 (educational mobile app)',
              'Accept-Language':
                  localeIds[appController.language] ?? appController.language,
            },
          )
          .timeout(const Duration(seconds: 6));

      if (r.statusCode == 200) {
        final j = jsonDecode(r.body) as Map<String, dynamic>;
        final a = Map<String, dynamic>.from(j['address'] ?? const {});

        final road =
            [
                  a['house_number'],
                  a['road'] ?? a['pedestrian'] ?? a['residential'] ?? a['path'],
                ]
                .where((x) => x != null && x.toString().trim().isNotEmpty)
                .map((x) => x.toString().trim())
                .join(' ');

        final parts = <String>[
          road,
          (a['neighbourhood'] ?? a['quarter'] ?? '').toString(),
          (a['suburb'] ?? '').toString(),
          (a['village'] ?? a['town'] ?? a['city'] ?? a['hamlet'] ?? '')
              .toString(),
          (a['city_district'] ?? a['state_district'] ?? a['county'] ?? '')
              .toString(),
          (a['state'] ?? '').toString(),
          (a['postcode'] ?? '').toString(),
        ].where((x) => x.trim().isNotEmpty).toList();

        final unique = <String>[];
        for (final part in parts) {
          if (!unique.any((x) => x.toLowerCase() == part.toLowerCase())) {
            unique.add(part);
          }
        }
        if (unique.isNotEmpty) return unique.join(', ');

        final display = j['display_name']?.toString().trim() ?? '';
        if (display.isNotEmpty) return display;
      }
    } catch (_) {}
    return fallback;
  }

  static Future<WeatherData> weather(double lat, double lon) async {
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '$lat',
        'longitude': '$lon',
        'hourly': 'precipitation',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max',
        'forecast_days': '7',
        'timezone': 'auto',
      });
      final r = await http.get(uri).timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) throw Exception('Weather service unavailable');

      final j = jsonDecode(r.body) as Map<String, dynamic>;
      final h = j['hourly'] as Map<String, dynamic>;
      final d = j['daily'] as Map<String, dynamic>;
      final times = List<String>.from(h['time'] ?? []);
      final rain = List<num>.from(h['precipitation'] ?? []);
      final now = DateTime.now();
      final end = now.add(const Duration(hours: 24));
      double next24 = 0;
      for (var i = 0; i < times.length && i < rain.length; i++) {
        final t = DateTime.tryParse(times[i]);
        if (t != null && !t.isBefore(now) && t.isBefore(end)) {
          next24 += rain[i].toDouble();
        }
      }
      if (next24 == 0 && rain.isNotEmpty) {
        next24 = rain.take(24).fold<double>(0, (a, b) => a + b.toDouble());
      }

      final data = WeatherData(
        dailyDates: List<String>.from(d['time'] ?? []),
        maxTemp: List<num>.from(d['temperature_2m_max'] ?? []),
        minTemp: List<num>.from(d['temperature_2m_min'] ?? []),
        dailyRain: List<num>.from(d['precipitation_sum'] ?? []),
        dailyProb: List<num>.from(d['precipitation_probability_max'] ?? []),
        dailyCode: List<num>.from(d['weather_code'] ?? []),
        next24Rain: next24,
        cached: false,
      );
      final p = await SharedPreferences.getInstance();
      await p.setString('weather_cache', jsonEncode(data.toJson()));
      return data;
    } catch (_) {
      final cached = await cachedWeather();
      if (cached != null) return cached;
      rethrow;
    }
  }
}

class StageCard extends StatelessWidget {
  final String title;
  final bool active;
  final String text;
  const StageCard({
    super.key,
    required this.title,
    required this.active,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            active ? Icons.notifications_active : Icons.verified_outlined,
            color: active ? Colors.orangeAccent : Colors.white38,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(color: Colors.white60, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Ner3DTerrainMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String place;

  // Raw code: LOW / MEDIUM / HIGH.
  final String riskCode;

  // Translated text shown to the user.
  final String riskLabel;

  const Ner3DTerrainMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.place,
    required this.riskCode,
    required this.riskLabel,
  });

  @override
  State<Ner3DTerrainMap> createState() => _Ner3DTerrainMapState();
}

class _Ner3DTerrainMapState extends State<Ner3DTerrainMap> {
  late final WebViewController controller;

  bool loading = true;

  String _riskColor(String risk) {
    if (risk == 'HIGH') {
      return '#ff315c';
    }

    if (risk == 'MEDIUM') {
      return '#ffad42';
    }

    return '#5de0b5';
  }

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF061724))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;

            setState(() {
              loading = false;
            });
          },
        ),
      )
      ..loadHtmlString(_html());
  }

  @override
  void didUpdateWidget(covariant Ner3DTerrainMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.place != widget.place ||
        oldWidget.riskCode != widget.riskCode ||
        oldWidget.riskLabel != widget.riskLabel) {
      controller.runJavaScript('''
        updateUser(
          ${widget.latitude},
          ${widget.longitude},
          ${jsonEncode(widget.place)},
          ${jsonEncode(widget.riskCode)},
          ${jsonEncode(widget.riskLabel)},
          ${jsonEncode(_riskColor(widget.riskCode))}
        );
        ''');
    }
  }

  String _html() {
    final place = jsonEncode(widget.place);

    final riskCode = jsonEncode(widget.riskCode);

    final riskLabel = jsonEncode(widget.riskLabel);

    final color = jsonEncode(_riskColor(widget.riskCode));

    return '''
<!DOCTYPE html>

<html>

<head>

<meta charset="utf-8">

<meta
  name="viewport"
  content="width=device-width,
  initial-scale=1,
  maximum-scale=1,
  user-scalable=no"
>

<link
  href="https://unpkg.com/maplibre-gl@5.6.0/dist/maplibre-gl.css"
  rel="stylesheet"
/>

<script
  src="https://unpkg.com/maplibre-gl@5.6.0/dist/maplibre-gl.js">
</script>


<style>

html,
body,
#map {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
  overflow: hidden;
  background: #061724;
}

* {
  box-sizing: border-box;
  font-family: Arial, sans-serif;
}


#loading {
  position: absolute;
  inset: 0;
  z-index: 100;

  display: flex;
  justify-content: center;
  align-items: center;

  color: white;
  background: #061724;

  font-size: 13px;
}


#info {
  position: absolute;

  z-index: 20;

  left: 12px;
  top: 12px;

  width: min(68%, 330px);

  padding: 10px 12px;

  border-radius: 15px;

  background:
    rgba(3, 20, 32, .88);

  border:
    1px solid
    rgba(93, 224, 181, .40);

  backdrop-filter:
    blur(8px);

  color: white;
}


#brand {
  font-size: 12px;

  font-weight: 900;

  letter-spacing: .7px;

  color: #5de0b5;
}


#place {
  margin-top: 5px;

  font-size: 11px;

  color: #d3e1e6;

  white-space: nowrap;

  overflow: hidden;

  text-overflow: ellipsis;
}


#risk {
  display: inline-block;

  margin-top: 7px;

  padding: 5px 10px;

  border-radius: 30px;

  color: #04151e;

  font-size: 11px;

  font-weight: 900;
}


#buttons {
  position: absolute;

  z-index: 25;

  right: 12px;

  bottom: 72px;

  display: flex;

  flex-direction: column;

  gap: 8px;
}


.circleButton {
  width: 46px;

  height: 46px;

  border-radius: 50%;

  border:
    1px solid
    rgba(93, 224, 181, .55);

  color: #5de0b5;

  background:
    rgba(3, 20, 32, .92);

  font-weight: 900;
}


#states {
  position: absolute;

  z-index: 30;

  left: 8px;
  right: 8px;
  bottom: 8px;

  display: flex;

  gap: 6px;

  padding: 7px;

  overflow-x: auto;

  border-radius: 15px;

  background:
    rgba(3, 20, 32, .88);

  border:
    1px solid
    rgba(93, 224, 181, .28);
}


.stateButton {
  flex: 0 0 auto;

  padding: 7px 10px;

  border-radius: 18px;

  border:
    1px solid
    rgba(93, 224, 181, .55);

  color: white;

  background:
    rgba(12, 57, 72, .94);

  font-size: 10px;

  font-weight: 700;
}


.userMarker {
  width: 26px;

  height: 26px;

  border-radius: 50%;

  border:
    4px solid white;

  box-shadow:
    0 0 0 8px
    rgba(255, 49, 92, .22);
}

</style>

</head>


<body>


<div id="map"></div>


<div id="loading">

Loading GEONEXA 3D terrain...

</div>


<div id="info">

  <div id="brand">
    GEONEXA · NER 3D
  </div>

  <div id="place"></div>

  <div id="risk"></div>

</div>


<div id="buttons">

  <button
    class="circleButton"
    onclick="goNER()">
    NER
  </button>

  <button
    class="circleButton"
    onclick="goGPS()">
    ⦿
  </button>

</div>


<div id="states">

  <button
    class="stateButton"
    onclick="flyToState(94.7278,28.2180,7.5)">
    Arunachal
  </button>

  <button
    class="stateButton"
    onclick="flyToState(92.9376,26.2006,7.3)">
    Assam
  </button>

  <button
    class="stateButton"
    onclick="flyToState(93.9063,24.6637,8.0)">
    Manipur
  </button>

  <button
    class="stateButton"
    onclick="flyToState(91.3662,25.4670,8.0)">
    Meghalaya
  </button>

  <button
    class="stateButton"
    onclick="flyToState(92.9376,23.1645,8.0)">
    Mizoram
  </button>

  <button
    class="stateButton"
    onclick="flyToState(94.5624,26.1584,8.0)">
    Nagaland
  </button>

  <button
    class="stateButton"
    onclick="flyToState(88.5122,27.5330,8.4)">
    Sikkim
  </button>

  <button
    class="stateButton"
    onclick="flyToState(91.9882,23.9408,8.0)">
    Tripura
  </button>

</div>


<script>

let userLat =
  ${widget.latitude};


let userLon =
  ${widget.longitude};


let userPlace =
  $place;


let riskCode =
  $riskCode;


let riskLabel =
  $riskLabel;


let riskColor =
  $color;


let userMarker = null;



function insideNER(
  lat,
  lon
) {

  return (
    lat >= 21.0 &&
    lat <= 30.5 &&
    lon >= 87.0 &&
    lon <= 98.5
  );

}



const startInNER =
  insideNER(
    userLat,
    userLon
  );



const map =
  new maplibregl.Map({

    container:
      'map',

    attributionControl:
      false,

    center:
      startInNER
        ? [userLon, userLat]
        : [93.50, 26.20],

    zoom:
      startInNER
        ? 10.5
        : 4.8,

    pitch:
      72,

    bearing:
      -25,

    maxPitch:
      85,

    maxZoom:
      17,


    style: {

      version: 8,


      sources: {


        osm: {

          type:
            'raster',

          tiles: [

            'https://tile.openstreetmap.org/{z}/{x}/{y}.png'

          ],

          tileSize:
            256,

          maxzoom:
            19,

          attribution:
            '© OpenStreetMap contributors'

        },


        terrainDem: {

          type:
            'raster-dem',

          tiles: [

            'https://s3.amazonaws.com/elevation-tiles-prod/terrarium/{z}/{x}/{y}.png'

          ],

          tileSize:
            256,

          maxzoom:
            15,

          encoding:
            'terrarium'

        }

      },


      layers: [

        {

          id:
            'base-map',

          type:
            'raster',

          source:
            'osm'

        },


        {

          id:
            'terrain-shading',

          type:
            'hillshade',

          source:
            'terrainDem',

          paint: {

            'hillshade-shadow-color':
              '#06131d',

            'hillshade-highlight-color':
              '#88d7bb',

            'hillshade-accent-color':
              '#1e574d',

            'hillshade-exaggeration':
              0.58

          }

        }

      ],


      terrain: {

        source:
          'terrainDem',

        exaggeration:
          1.65

      }

    }

  });



map.addControl(

  new maplibregl.NavigationControl({

    visualizePitch:
      true,

    showCompass:
      true,

    showZoom:
      true

  }),

  'top-right'

);



map.addControl(

  new maplibregl.AttributionControl({

    compact:
      true

  }),

  'top-right'

);



function updateInfo() {

  document
    .getElementById('place')
    .innerText =
      userPlace ||
      'GPS location';


  const badge =
    document
      .getElementById('risk');


  badge.innerText =
    riskLabel;


  badge.style.background =
    riskColor;

}



function createUserMarker() {

  if (userMarker) {
    userMarker.remove();
  }


  const marker =
    document.createElement(
      'div'
    );


  marker.className =
    'userMarker';


  marker.style.background =
    riskColor;


  userMarker =
    new maplibregl.Marker({

      element:
        marker

    })

    .setLngLat([

      userLon,
      userLat

    ])

    .setPopup(

      new maplibregl.Popup({

        offset:
          20

      })

      .setHTML(

        '<b>GEONEXA</b><br>' +

        userPlace +

        '<br><b>' +

        riskLabel +

        '</b>'

      )

    )

    .addTo(map);

}



function flyToState(
  lon,
  lat,
  zoom
) {

  map.flyTo({

    center:
      [lon, lat],

    zoom:
      zoom,

    pitch:
      76,

    bearing:
      -28,

    speed:
      1.0,

    curve:
      1.25,

    essential:
      true

  });

}



function goNER() {

  map.flyTo({

    center:
      [93.50, 26.20],

    zoom:
      4.8,

    pitch:
      72,

    bearing:
      -25,

    speed:
      1.0,

    essential:
      true

  });

}



function goGPS() {

  map.flyTo({

    center:
      [userLon, userLat],

    zoom:
      13,

    pitch:
      78,

    bearing:
      -32,

    speed:
      1.0,

    essential:
      true

  });


  if (userMarker) {
    userMarker.togglePopup();
  }

}



window.updateUser =
function(
  lat,
  lon,
  place,
  code,
  label,
  color
) {

  userLat =
    lat;

  userLon =
    lon;

  userPlace =
    place;

  riskCode =
    code;

  riskLabel =
    label;

  riskColor =
    color;


  updateInfo();

  createUserMarker();

};



map.on(
  'load',
  function() {

    updateInfo();

    createUserMarker();


    document
      .getElementById(
        'loading'
      )
      .style
      .display =
        'none';

  }
);


</script>


</body>

</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(
          controller: controller,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
          },
        ),

        if (loading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0xFF061724),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class RiskScreen extends StatefulWidget {
  const RiskScreen({super.key});
  @override
  State<RiskScreen> createState() => _RiskScreenState();
}

class _RiskScreenState extends State<RiskScreen> {
  bool refreshing = false;
  String error = '';
  LocationData? location;
  WeatherData? weather;
  StreamSubscription<Position>? stream;

  bool officialLoading = false;
  String officialFeedError = '';
  List<Map<String, String>> officialLandslideAlerts = [];
  String gsiOfficialStatus = '';
  DateTime? officialInfoUpdatedAt;

  String nearbyCitizenPhotoPath = '';
  String nearbyCitizenPlace = '';
  String nearbyCitizenTime = '';
  String nearbyCitizenRisk = '';
  String nearbyCitizenNote = '';

  bool showLegacyOfficialDetails = false;

  DateTime? lastReverseTime;
  double? lastReverseLat;
  double? lastReverseLon;
  String? lastReverseLanguage;

  DateTime? lastWeatherRefresh;
  double? lastWeatherLat;
  double? lastWeatherLon;

  @override
  void initState() {
    super.initState();
    unawaited(_primeRiskScreen());
  }

  @override
  void dispose() {
    stream?.cancel();
    super.dispose();
  }

  Future<void> _primeRiskScreen() async {
    // 1) Paint the page immediately from locally stored real data.
    final cachedLoc = await DataService.cachedLocation();
    final cachedWeather = await DataService.cachedWeather();
    if (!mounted) return;
    setState(() {
      location = cachedLoc;
      weather = cachedWeather;
    });

    // 2) If no app cache exists, use Android's last known real GPS position.
    if (cachedLoc == null) {
      final lastKnown = await DataService.lastKnownLocation();
      if (mounted && lastKnown != null) {
        setState(() => location = lastKnown);
      }
    }

    // 3) Start continuous GPS updates as soon as permission/service allows.
    unawaited(startLocationStream());

    // 4) Refresh fresh GPS + weather in the background without blocking the page.
    unawaited(refreshLive());

    // 5) Load official NDMA/GSI information directly inside the app.
    unawaited(refreshOfficialInfo());
  }

  String _cleanOfficialText(String value) {
    var text = value
        .replaceAll(RegExp(r'<!\[CDATA\[|\]\]>'), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return text;
  }

  String _xmlTag(String item, String tag) {
    final match = RegExp(
      '<' + tag + r'[^>]*>([\s\S]*?)</' + tag + '>',
      caseSensitive: false,
    ).firstMatch(item);
    return match == null ? '' : _cleanOfficialText(match.group(1) ?? '');
  }

  bool _looksLikeLandslide(String value) {
    final v = value.toLowerCase();
    return v.contains('landslide') ||
        v.contains('landslip') ||
        v.contains('rockfall') ||
        v.contains('slope failure');
  }

  String _normalKey(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _deepOfficialValue(dynamic node, List<String> keys, [int depth = 0]) {
    if (node == null || depth > 5) return '';

    final wanted = keys.map(_normalKey).toSet();

    if (node is Map) {
      for (final entry in node.entries) {
        final key = _normalKey(entry.key.toString());

        if (wanted.contains(key)) {
          final value = entry.value;

          if (value != null && value is! Map && value is! List) {
            final text = value.toString().trim();

            if (text.isNotEmpty && text.toLowerCase() != 'null') {
              return _cleanOfficialText(text);
            }
          }
        }
      }

      for (final value in node.values) {
        final result = _deepOfficialValue(value, keys, depth + 1);

        if (result.isNotEmpty) return result;
      }
    }

    if (node is List) {
      for (final value in node) {
        final result = _deepOfficialValue(value, keys, depth + 1);

        if (result.isNotEmpty) return result;
      }
    }

    return '';
  }

  String _ndmaAbsoluteUrl(String value) {
    final text = value.trim();

    if (text.isEmpty) return '';

    if (text.startsWith('http://') || text.startsWith('https://')) {
      return text;
    }

    if (text.startsWith('/')) {
      return 'https://sachet.ndma.gov.in$text';
    }

    return '';
  }

  String _deepImageUrl(dynamic node, [int depth = 0]) {
    if (node == null || depth > 6) return '';

    if (node is String) {
      final value = node.trim();
      final lower = value.toLowerCase();

      if ((value.startsWith('http://') ||
              value.startsWith('https://') ||
              value.startsWith('/')) &&
          (lower.contains('.jpg') ||
              lower.contains('.jpeg') ||
              lower.contains('.png') ||
              lower.contains('.webp'))) {
        return _ndmaAbsoluteUrl(value);
      }

      return '';
    }

    if (node is Map) {
      for (final entry in node.entries) {
        final key = _normalKey(entry.key.toString());

        final looksLikeImageKey =
            key.contains('image') ||
            key.contains('photo') ||
            key.contains('picture') ||
            key.contains('thumbnail');

        if (looksLikeImageKey &&
            entry.value != null &&
            entry.value is! Map &&
            entry.value is! List) {
          final url = _ndmaAbsoluteUrl(entry.value.toString());

          if (url.isNotEmpty) return url;
        }
      }

      for (final value in node.values) {
        final result = _deepImageUrl(value, depth + 1);

        if (result.isNotEmpty) return result;
      }
    }

    if (node is List) {
      for (final value in node) {
        final result = _deepImageUrl(value, depth + 1);

        if (result.isNotEmpty) return result;
      }
    }

    return '';
  }

  String _xmlAttribute(String xml, String tag, String attribute) {
    final match = RegExp(
      '<$tag\\b[^>]*\\b$attribute=["\']([^"\']+)["\'][^>]*>',
      caseSensitive: false,
    ).firstMatch(xml);

    return match?.group(1)?.trim() ?? '';
  }

  String _firstWebUrl(String value) {
    final match = RegExp(
      r'https?://[^\s<>" ]+',
      caseSensitive: false,
    ).firstMatch(value);

    return match?.group(0) ?? '';
  }

  List<String> _sentences(String value) {
    return value
        .split(RegExp(r'[\n\r]+|[.!?]\s+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _roadFromMessage(String message) {
    for (final sentence in _sentences(message)) {
      final text = sentence.toLowerCase();

      final roadWord =
          text.contains('road') ||
          text.contains('highway') ||
          text.contains('nh-') ||
          text.contains('nh ') ||
          text.contains('route');

      final impactWord =
          text.contains('blocked') ||
          text.contains('closed') ||
          text.contains('affected') ||
          text.contains('damaged') ||
          text.contains('disrupted') ||
          text.contains('washed away');

      if (roadWord && impactWord) {
        return sentence;
      }
    }

    return '';
  }

  String _safeRoadFromMessage(String message) {
    for (final sentence in _sentences(message)) {
      final text = sentence.toLowerCase();

      if (text.contains('alternate route') ||
          text.contains('alternative route') ||
          text.contains('diversion') ||
          text.contains('safe route') ||
          text.contains('alternate road')) {
        return sentence;
      }
    }

    return '';
  }

  String _placesFromMessage(String message) {
    final matches = <String>[];

    for (final sentence in _sentences(message)) {
      final text = sentence.toLowerCase();

      if (text.contains('village') ||
          text.contains('school') ||
          text.contains('hospital') ||
          text.contains('bridge') ||
          text.contains('settlement') ||
          text.contains('town') ||
          text.contains('district')) {
        matches.add(sentence);
      }

      if (matches.length == 2) break;
    }

    return matches.join(' ');
  }

  bool _alertMatchesCurrentArea(Map<String, String> alert) {
    final currentPlace = (location?.place ?? '').toLowerCase();

    if (currentPlace.trim().isEmpty) {
      return true;
    }

    final alertText =
        '${alert['area'] ?? ''} '
                '${alert['message'] ?? ''}'
            .toLowerCase();

    final ignored = <String>{
      'city',
      'corporation',
      'india',
      'south',
      'north',
      'east',
      'west',
      'road',
      'near',
      'district',
    };

    final tokens = currentPlace
        .split(RegExp(r'[\s,;/]+'))
        .map((e) => e.trim())
        .where(
          (e) =>
              e.length >= 4 &&
              !ignored.contains(e) &&
              !RegExp(r'^\d+$').hasMatch(e),
        )
        .toSet();

    if (tokens.isEmpty) {
      // If local-language place names cannot be
      // compared with the English official feed,
      // remain conservative and do not filter.
      return true;
    }

    return tokens.any(alertText.contains);
  }

  Future<Map<String, String>> _nearestCitizenEvidence() async {
    try {
      final current = location;

      if (current == null) return {};

      final prefs = await SharedPreferences.getInstance();

      final raw = prefs.getString('hazard_reports');

      if (raw == null || raw.isEmpty) {
        return {};
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) return {};

      double nearestDistance = double.infinity;

      Map<String, String> best = {};

      for (final entry in decoded) {
        if (entry is! Map) continue;

        final map = Map<String, dynamic>.from(entry);

        final type = (map['type'] ?? '').toString();

        if (type != 'landslide' && type != 'rockfall' && type != 'crack') {
          continue;
        }

        final path = (map['photoPath'] ?? '').toString();

        if (path.isEmpty || !File(path).existsSync()) {
          continue;
        }

        final lat = (map['lat'] as num?)?.toDouble();

        final lon = (map['lon'] as num?)?.toDouble();

        if (lat == null || lon == null) {
          continue;
        }

        final distance = Geolocator.distanceBetween(
          current.latitude,
          current.longitude,
          lat,
          lon,
        );

        // Show only reports close enough
        // to be relevant to the current area.
        if (distance > 15000 || distance >= nearestDistance) {
          continue;
        }

        nearestDistance = distance;

        best = {
          'photo': path,
          'place': (map['place'] ?? '').toString(),
          'time': (map['time'] ?? '').toString(),
          'risk': (map['screenedRisk'] ?? '').toString(),
          'note': (map['note'] ?? '').toString(),
        };
      }

      return best;
    } catch (_) {
      return {};
    }
  }

  Future<void> _openMapSearch(String query) async {
    final text = query.trim();

    if (text.isEmpty) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/search/'
      '?api=1&query=${Uri.encodeComponent(text)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<List<Map<String, String>>> _loadNdmaLandslideAlerts() async {
    const jsonUrl =
        'https://sachet.ndma.gov.in/'
        'cap_public_website/FetchAllAlertDetails';

    const rssUrl =
        'https://sachet.ndma.gov.in/'
        'cap_public_website/rss/rss_india.xml';

    try {
      final response = await http
          .get(
            Uri.parse(jsonUrl),
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'GEONEXA/1.0',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);

        List<dynamic> rows = const [];

        if (decoded is List) {
          rows = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          rows = decoded['data'] as List<dynamic>;
        } else if (decoded is Map && decoded['alerts'] is List) {
          rows = decoded['alerts'] as List<dynamic>;
        }

        final alerts = <Map<String, String>>[];

        for (final raw in rows) {
          if (raw is! Map) continue;

          final map = Map<String, dynamic>.from(raw);

          final type = _deepOfficialValue(map, [
            'disaster_type',
            'disasterType',
            'event',
            'event_type',
            'eventType',
            'alert_type',
            'alertType',
          ]);

          final message = _deepOfficialValue(map, [
            'warning_message',
            'warningMessage',
            'message',
            'description',
            'instruction',
            'headline',
          ]);

          final area = _deepOfficialValue(map, [
            'area_description',
            'areaDescription',
            'affected_area',
            'affectedArea',
            'area',
            'district',
            'location',
          ]);

          if (!_looksLikeLandslide('$type $message $area')) {
            continue;
          }

          var affectedRoad = _deepOfficialValue(map, [
            'affected_road',
            'affectedRoad',
            'road_name',
            'roadName',
            'blocked_road',
            'blockedRoad',
            'road_status',
            'roadStatus',
          ]);

          if (affectedRoad.isEmpty) {
            affectedRoad = _roadFromMessage(message);
          }

          var safeRoad = _deepOfficialValue(map, [
            'safe_road',
            'safeRoad',
            'alternate_route',
            'alternateRoute',
            'alternative_route',
            'alternativeRoute',
            'diversion_route',
            'diversionRoute',
          ]);

          if (safeRoad.isEmpty) {
            safeRoad = _safeRoadFromMessage(message);
          }

          var affectedPlaces = _deepOfficialValue(map, [
            'affected_places',
            'affectedPlaces',
            'affected_locations',
            'affectedLocations',
            'places_affected',
            'placesAffected',
          ]);

          if (affectedPlaces.isEmpty) {
            affectedPlaces = _placesFromMessage(message);
          }

          final start = _deepOfficialValue(map, [
            'effective_start_time',
            'effectiveStartTime',
            'effective',
            'onset',
            'start_time',
            'startTime',
          ]);

          final end = _deepOfficialValue(map, [
            'effective_end_time',
            'effectiveEndTime',
            'expires',
            'end_time',
            'endTime',
          ]);

          final severity = _deepOfficialValue(map, [
            'severity',
            'severity_level',
            'severityLevel',
          ]);

          final source = _deepOfficialValue(map, [
            'alert_source',
            'alertSource',
            'source',
            'senderName',
          ]);

          final alertLink = _firstWebUrl(
            _deepOfficialValue(map, [
              'web',
              'link',
              'url',
              'alert_url',
              'alertUrl',
            ]),
          );

          alerts.add({
            'type': type.isEmpty ? 'Landslide alert' : type,
            'area': area,
            'severity': severity,
            'message': message,
            'start': start,
            'end': end,
            'eventTime': start,
            'image': _deepImageUrl(map),
            'affectedRoad': affectedRoad,
            'safeRoad': safeRoad,
            'affectedPlaces': affectedPlaces,
            'source': source,
            'alertLink': alertLink,
          });

          if (alerts.length >= 10) break;
        }

        return alerts;
      }
    } catch (_) {
      // Use the official RSS feed below.
    }

    final response = await http
        .get(
          Uri.parse(rssUrl),
          headers: const {
            'Accept':
                'application/rss+xml, '
                'application/xml, text/xml',
            'User-Agent': 'GEONEXA/1.0',
          },
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Official alert feed unavailable.');
    }

    final alerts = <Map<String, String>>[];

    final itemRegex = RegExp(
      r'<item\b[^>]*>([\s\S]*?)</item>',
      caseSensitive: false,
    );

    for (final match in itemRegex.allMatches(response.body)) {
      final item = match.group(1) ?? '';

      final title = _xmlTag(item, 'title');

      final description = _xmlTag(item, 'description');

      if (!_looksLikeLandslide('$title $description')) {
        continue;
      }

      var image = _xmlAttribute(item, 'enclosure', 'url');

      if (image.isEmpty) {
        image = _xmlAttribute(item, 'media:content', 'url');
      }

      image = _ndmaAbsoluteUrl(image);

      alerts.add({
        'type': title.isEmpty ? 'Landslide alert' : title,
        'area': '',
        'severity': '',
        'message': description,
        'start': _xmlTag(item, 'pubDate'),
        'end': '',
        'eventTime': _xmlTag(item, 'pubDate'),
        'image': image,
        'affectedRoad': _roadFromMessage(description),
        'safeRoad': _safeRoadFromMessage(description),
        'affectedPlaces': _placesFromMessage(description),
        'source': 'NDMA SACHET',
        'alertLink': _xmlTag(item, 'link'),
      });

      if (alerts.length >= 10) break;
    }

    return alerts;
  }

  Future<String> _loadGsiSourceStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://bhusanket.gsi.gov.in/index.html'),
            headers: const {'User-Agent': 'GEONEXA/1.0'},
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final body = _cleanOfficialText(response.body);
        final updated = RegExp(
          r'Last Updated\s*:?\s*([^<]{3,40})',
          caseSensitive: false,
        ).firstMatch(body)?.group(1)?.trim();
        final suffix = (updated != null && updated.isNotEmpty)
            ? ' ${tr('last_updated')}: $updated'
            : '';
        return '${tr('gsi_source_reachable')}$suffix';
      }
    } catch (_) {}
    return tr('gsi_source_unavailable');
  }

  Future<void> refreshOfficialInfo() async {
    if (mounted) {
      setState(() {
        officialLoading = true;
        officialFeedError = '';
      });
    }

    List<Map<String, String>> relevantAlerts = const [];

    String ndmaError = '';

    try {
      final allAlerts = await _loadNdmaLandslideAlerts();

      relevantAlerts = allAlerts.where(_alertMatchesCurrentArea).toList();
    } catch (_) {
      ndmaError = tr('official_feed_unavailable');
    }

    final citizen = await _nearestCitizenEvidence();

    // Keep the GSI reachability check in the
    // background, but it is no longer displayed
    // as a large source/explanation card.
    unawaited(
      _loadGsiSourceStatus().then((value) {
        if (mounted) {
          setState(() {
            gsiOfficialStatus = value;
          });
        }
      }),
    );

    if (!mounted) return;

    setState(() {
      officialLandslideAlerts = relevantAlerts;

      officialFeedError = ndmaError;

      officialInfoUpdatedAt = DateTime.now();

      nearbyCitizenPhotoPath = citizen['photo'] ?? '';

      nearbyCitizenPlace = citizen['place'] ?? '';

      nearbyCitizenTime = citizen['time'] ?? '';

      nearbyCitizenRisk = citizen['risk'] ?? '';

      nearbyCitizenNote = citizen['note'] ?? '';

      officialLoading = false;
    });
  }

  Future<void> _savePosition(Position p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_latitude', p.latitude);
    await prefs.setDouble('last_longitude', p.longitude);
    await prefs.setDouble('last_accuracy', p.accuracy);
    await prefs.setString(
      'last_location_time',
      DateTime.now().toIso8601String(),
    );
  }

  bool _shouldReverseGeocode(Position p) {
    final now = DateTime.now();
    if (lastReverseTime == null ||
        lastReverseLat == null ||
        lastReverseLon == null ||
        lastReverseLanguage != appController.language) {
      return true;
    }
    final moved = Geolocator.distanceBetween(
      lastReverseLat!,
      lastReverseLon!,
      p.latitude,
      p.longitude,
    );
    return moved >= 150 || now.difference(lastReverseTime!).inMinutes >= 3;
  }

  Future<void> _updatePlaceFromPosition(Position p) async {
    if (!_shouldReverseGeocode(p)) return;
    final place = await DataService.reverseGeocode(p.latitude, p.longitude);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_place_name', place);

    lastReverseTime = DateTime.now();
    lastReverseLat = p.latitude;
    lastReverseLon = p.longitude;
    lastReverseLanguage = appController.language;

    if (!mounted) return;
    final current = location;
    if (current == null) return;
    setState(() {
      location = LocationData(
        latitude: current.latitude,
        longitude: current.longitude,
        accuracy: current.accuracy,
        place: place,
        cached: false,
        updatedAt: current.updatedAt,
      );
    });
  }

  Future<void> _refreshWeatherFor(
    double lat,
    double lon, {
    bool force = false,
  }) async {
    final now = DateTime.now();
    var shouldRefresh =
        force ||
        lastWeatherRefresh == null ||
        lastWeatherLat == null ||
        lastWeatherLon == null;

    if (!shouldRefresh) {
      final moved = Geolocator.distanceBetween(
        lastWeatherLat!,
        lastWeatherLon!,
        lat,
        lon,
      );
      shouldRefresh =
          moved >= 1000 || now.difference(lastWeatherRefresh!).inMinutes >= 10;
    }
    if (!shouldRefresh) return;

    final w = await DataService.weather(lat, lon);
    lastWeatherRefresh = now;
    lastWeatherLat = lat;
    lastWeatherLon = lon;

    if (!w.cached && w.next24Rain >= 64.5) {
      final p = await SharedPreferences.getInstance();
      final last = p.getString('last_high_rain_notification');
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (last != today) {
        await NotificationService.highRain(w.next24Rain);
        await p.setString('last_high_rain_notification', today);
      }
    }

    if (mounted) {
      setState(() => weather = w);
    }
  }

  Future<void> startLocationStream() async {
    if (stream != null) return;
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      stream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((p) async {
            await _savePosition(p);
            final now = DateTime.now();

            var currentPlace = location?.place ?? '';
            if (currentPlace.trim().isEmpty) {
              currentPlace =
                  '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}';
            }

            if (mounted) {
              setState(() {
                location = LocationData(
                  latitude: p.latitude,
                  longitude: p.longitude,
                  accuracy: p.accuracy,
                  place: currentPlace,
                  cached: false,
                  updatedAt: now,
                );
              });
            }

            // Address and weather refresh asynchronously so GPS never freezes the UI.
            unawaited(_updatePlaceFromPosition(p));
            unawaited(_refreshWeatherFor(p.latitude, p.longitude));
          });
    } catch (_) {}
  }

  Future<void> refreshLive() async {
    if (mounted) {
      setState(() {
        refreshing = true;
        error = '';
      });
    }

    try {
      // Try fresh GPS, but the screen is already visible from cache/last-known GPS.
      final loc = await DataService.getLocation(
        timeout: const Duration(seconds: 8),
      );
      if (mounted) {
        setState(() => location = loc);
      }

      lastReverseTime = DateTime.now();
      lastReverseLat = loc.latitude;
      lastReverseLon = loc.longitude;
      lastReverseLanguage = appController.language;

      unawaited(startLocationStream());
      await _refreshWeatherFor(loc.latitude, loc.longitude, force: true);
    } catch (e) {
      // Keep any real cached/last-known data visible instead of replacing it
      // with an endless spinner.
      if (!mounted) return;
      if (location == null) {
        setState(() {
          error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => refreshing = false);
      }
    }
  }

  String get risk {
    final mm = weather?.next24Rain ?? 0;
    if (mm >= 64.5) return 'HIGH';
    if (mm >= 15.6) return 'MEDIUM';
    return 'LOW';
  }

  Color get riskColor => risk == 'HIGH'
      ? Colors.redAccent
      : risk == 'MEDIUM'
      ? Colors.orangeAccent
      : const Color(0xFF5DE0B5);

  String get riskText => risk == 'HIGH'
      ? tr('risk_high')
      : risk == 'MEDIUM'
      ? tr('risk_medium')
      : tr('risk_low');

  String _timeLabel(DateTime? value) {
    if (value == null) return '';
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '${value.day}/${value.month}/${value.year} $h:$m';
  }

  Widget sourceBadge(bool cached) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: (cached ? Colors.orangeAccent : const Color(0xFF5DE0B5))
          .withValues(alpha: .12),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(
      cached ? tr('cached_data') : tr('live_data'),
      style: TextStyle(
        color: cached ? Colors.orangeAccent : const Color(0xFF5DE0B5),
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _officialImage(Map<String, String> alert) {
    final image = alert['image']?.trim() ?? '';

    if (image.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          image,
          width: double.infinity,
          height: 190,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }

            return Container(
              height: 190,
              alignment: Alignment.center,
              color: const Color(0xFF071A28),
              child: const CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stack) {
            // Never substitute a fake image.
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _impactRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: const Color(0xFF5DE0B5)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white70, height: 1.35),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _citizenEvidenceCard() {
    final path = nearbyCitizenPhotoPath;

    if (path.isEmpty || !File(path).existsSync()) {
      return const SizedBox.shrink();
    }

    final reportTime = DateTime.tryParse(nearbyCitizenTime);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF102838),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_camera_outlined,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alertUiText('field_report'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(path),
              width: double.infinity,
              height: 190,
              fit: BoxFit.cover,
            ),
          ),

          if (nearbyCitizenPlace.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              nearbyCitizenPlace,
              style: const TextStyle(color: Colors.white70),
            ),
          ],

          if (nearbyCitizenNote.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              nearbyCitizenNote,
              style: const TextStyle(color: Colors.white60),
            ),
          ],

          const SizedBox(height: 7),

          Wrap(
            spacing: 8,
            runSpacing: 5,
            children: [
              if (nearbyCitizenRisk.isNotEmpty)
                Text(
                  '${tr('report_screening')}: '
                  '$nearbyCitizenRisk',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: nearbyCitizenRisk == 'HIGH'
                        ? Colors.redAccent
                        : nearbyCitizenRisk == 'MEDIUM'
                        ? Colors.orangeAccent
                        : const Color(0xFF5DE0B5),
                  ),
                ),

              if (reportTime != null)
                Text(
                  _timeLabel(reportTime),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedAlertsCard() {
    final hasCitizenReport =
        nearbyCitizenPhotoPath.isNotEmpty &&
        File(nearbyCitizenPhotoPath).existsSync();

    final weatherConcern = risk != 'LOW';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF5DE0B5),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  tr('official_alerts'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                tooltip: tr('official_refresh'),
                onPressed: officialLoading ? null : refreshOfficialInfo,
                icon: officialLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),

          if (officialInfoUpdatedAt != null) ...[
            const SizedBox(height: 3),
            Text(
              '${tr('last_updated')}: '
              '${_timeLabel(officialInfoUpdatedAt)}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],

          const SizedBox(height: 12),

          if (officialFeedError.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.orangeAccent),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(alertUiText('official_unavailable_short')),
                  ),
                ],
              ),
            )
          else if (!officialLoading &&
              officialLandslideAlerts.isEmpty &&
              !hasCitizenReport &&
              !weatherConcern)
            // SAFE is shown only when:
            // 1) official alert feed succeeded,
            // 2) no alert matches this area,
            // 3) no nearby field evidence exists,
            // 4) rainfall screening is LOW.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF5DE0B5).withValues(alpha: .09),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF5DE0B5).withValues(alpha: .42),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF5DE0B5),
                    size: 40,
                  ),

                  const SizedBox(height: 7),

                  Text(
                    alertUiText('safe'),
                    style: const TextStyle(
                      color: Color(0xFF5DE0B5),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  if ((location?.place ?? '').isNotEmpty)
                    Text(
                      location!.place,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                  const SizedBox(height: 6),

                  Text(
                    alertUiText('safe_message'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, height: 1.35),
                  ),
                ],
              ),
            )
          else ...[
            if (officialLandslideAlerts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.orangeAccent.withValues(alpha: .35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orangeAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          alertUiText('caution'),
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Text(
                      hasCitizenReport
                          ? alertUiText('caution_report')
                          : alertUiText('caution_weather'),
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

            ...officialLandslideAlerts.map((alert) {
              final area = alert['area'] ?? '';

              final affectedRoad = alert['affectedRoad'] ?? '';

              final safeRoad = alert['safeRoad'] ?? '';

              final places = alert['affectedPlaces'] ?? '';

              final eventTime = alert['eventTime'] ?? '';

              final message = alert['message'] ?? '';

              final severity = alert['severity'] ?? '';

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF102838),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: .40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alert['type'] ?? 'Landslide alert',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (severity.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: .14),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              severity,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    _officialImage(alert),

                    if (area.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _impactRow(
                        Icons.location_on_outlined,
                        tr('official_area'),
                        area,
                      ),
                    ],

                    if (affectedRoad.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _impactRow(
                        Icons.block_outlined,
                        alertUiText('affected_road'),
                        affectedRoad,
                      ),
                    ],

                    if (safeRoad.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _impactRow(
                        Icons.alt_route,
                        alertUiText('safe_road'),
                        safeRoad,
                      ),
                    ],

                    if (places.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _impactRow(
                        Icons.apartment_outlined,
                        alertUiText('affected_places'),
                        places,
                      ),
                    ],

                    if (eventTime.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _impactRow(
                        Icons.schedule_outlined,
                        alertUiText('event_time'),
                        eventTime,
                      ),
                    ],

                    if (message.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        message,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.35,
                        ),
                      ),
                    ],

                    if (safeRoad.isEmpty &&
                        (area.isNotEmpty || affectedRoad.isNotEmpty)) ...[
                      const SizedBox(height: 9),
                      Text(
                        alertUiText('no_verified_route'),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (area.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () => _openMapSearch(area),
                            icon: const Icon(Icons.map),
                            label: Text(alertUiText('open_area')),
                          ),

                        if (affectedRoad.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () => _openMapSearch(
                              '$affectedRoad '
                              '$area',
                            ),
                            icon: const Icon(Icons.wrong_location_outlined),
                            label: Text(alertUiText('open_affected_road')),
                          ),

                        if (safeRoad.isNotEmpty)
                          FilledButton.tonalIcon(
                            onPressed: () => _openMapSearch(
                              '$safeRoad '
                              '$area',
                            ),
                            icon: const Icon(Icons.alt_route),
                            label: Text(alertUiText('open_safe_road')),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            _citizenEvidenceCard(),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = location;
    return Column(
      children: [
        AppHeader(title: tr('app'), subtitle: tr('tagline')),
        Expanded(
          child: RefreshIndicator(
            onRefresh: refreshLive,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tr('risk_monitor'),
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (refreshing)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5DE0B5),
                      foregroundColor: const Color(0xFF06202B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegionExplorerScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.travel_explore),
                    label: Text(
                      regionText('explore_regions'),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                if (refreshing)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      tr('updating'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (error.isNotEmpty)
                  AppCard(
                    child: Column(
                      children: [
                        Text(error, textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: refreshLive,
                          icon: const Icon(Icons.refresh),
                          label: Text(tr('refresh_gps')),
                        ),
                      ],
                    ),
                  ),
                if (loc != null) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.my_location,
                              color: Color(0xFF5DE0B5),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tr('live_gps'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            sourceBadge(loc.cached),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.place,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (loc.updatedAt != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            '${tr('last_updated')}: ${_timeLabel(loc.updatedAt)}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        InfoRow(
                          tr('latitude'),
                          loc.latitude.toStringAsFixed(6),
                        ),
                        InfoRow(
                          tr('longitude'),
                          loc.longitude.toStringAsFixed(6),
                        ),
                        InfoRow(
                          tr('accuracy'),
                          loc.accuracy > 0
                              ? '${loc.accuracy.toStringAsFixed(1)} m'
                              : '—',
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await launchUrl(
                                Uri.parse(
                                  'https://www.google.com/maps/search/?api=1&query=${loc.latitude},${loc.longitude}',
                                ),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            icon: const Icon(Icons.map_outlined),
                            label: Text(tr('open_maps')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.terrain, color: Color(0xFF5DE0B5)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${tr('live_map')} · 3D NER',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: riskColor.withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: riskColor),
                              ),
                              child: Text(
                                riskText,
                                style: TextStyle(
                                  color: riskColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 560,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Ner3DTerrainMap(
                              latitude: loc.latitude,
                              longitude: loc.longitude,
                              place: loc.place,
                              riskCode: risk,
                              riskLabel: riskText,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          tr('map_hint'),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (weather != null)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tr('rain_screening'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            sourceBadge(weather!.cached),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: riskColor.withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: riskColor),
                              ),
                              child: Text(
                                riskText,
                                style: TextStyle(
                                  color: riskColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${weather!.next24Rain.toStringAsFixed(1)} mm',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          tr('next24rain'),
                          style: const TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                StageCard(
                  title: tr('stage1'),
                  active: risk == 'HIGH',
                  text: risk == 'HIGH'
                      ? tr('stage1_active')
                      : tr('stage1_inactive'),
                ),
                StageCard(
                  title: tr('stage2'),
                  active: false,
                  text: tr('stage2_need_feed'),
                ),
                StageCard(
                  title: tr('stage3'),
                  active: false,
                  text: tr('stage3_need_feed'),
                ),
                _buildVerifiedAlertsCard(),
                if (showLegacyOfficialDetails)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF5DE0B5),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tr('official_alerts'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: tr('official_refresh'),
                              onPressed: officialLoading
                                  ? null
                                  : refreshOfficialInfo,
                              icon: officialLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.refresh),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr('official_alerts_note'),
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        if (officialInfoUpdatedAt != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${tr('last_updated')}: ${_timeLabel(officialInfoUpdatedAt)}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (officialFeedError.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orangeAccent.withValues(
                                  alpha: .35,
                                ),
                              ),
                            ),
                            child: Text(
                              officialFeedError,
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                              ),
                            ),
                          )
                        else if (!officialLoading &&
                            officialLandslideAlerts.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF5DE0B5,
                              ).withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFF5DE0B5,
                                ).withValues(alpha: .30),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.verified_outlined,
                                  color: Color(0xFF5DE0B5),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tr('official_no_landslide'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (officialLandslideAlerts.isNotEmpty) ...[
                          ...officialLandslideAlerts.map((alert) {
                            final validity = [alert['start'], alert['end']]
                                .where((v) => v != null && v!.trim().isNotEmpty)
                                .join(' → ');
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF102838),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.redAccent.withValues(
                                    alpha: .25,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orangeAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          alert['type'] ?? 'Landslide alert',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ((alert['severity'] ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      '${tr('official_severity')}: ${alert['severity']}',
                                      style: const TextStyle(
                                        color: Colors.orangeAccent,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  if ((alert['area'] ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      '${tr('official_area')}: ${alert['area']}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                  if ((alert['message'] ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 7),
                                    Text(
                                      alert['message']!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                  if (validity.isNotEmpty) ...[
                                    const SizedBox(height: 7),
                                    Text(
                                      '${tr('official_validity')}: $validity',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 7),
                                  Text(
                                    '${tr('official_source')}: ${alert['source'] ?? 'NDMA SACHET'}',
                                    style: const TextStyle(
                                      color: Color(0xFF5DE0B5),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        const Divider(height: 28),
                        Row(
                          children: [
                            const Icon(
                              Icons.terrain,
                              color: Color(0xFF5DE0B5),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tr('gsi_status'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          gsiOfficialStatus.isEmpty
                              ? (officialLoading
                                    ? tr('updating')
                                    : tr('gsi_source_unavailable'))
                              : gsiOfficialStatus,
                          style: const TextStyle(
                            color: Colors.white60,
                            height: 1.35,
                          ),
                        ),
                        const Divider(height: 28),
                        Text(
                          tr('verified_impact'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr('impact_truth'),
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          '• ${tr('road_impact_unknown')}',
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• ${tr('people_impact_unknown')}',
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• ${tr('event_time_unknown')}',
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RegionSnapshot {
  final String place;
  final double latitude;
  final double longitude;
  final double temperature;
  final double humidity;
  final int weatherCode;
  final double next24Rain;
  final double? soil0to1;
  final double? soil1to3;
  final double? soil3to9;
  final bool cached;
  final DateTime checkedAt;

  const RegionSnapshot({
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.humidity,
    required this.weatherCode,
    required this.next24Rain,
    required this.soil0to1,
    required this.soil1to3,
    required this.soil3to9,
    required this.cached,
    required this.checkedAt,
  });

  Map<String, dynamic> toJson() => {
    'place': place,
    'latitude': latitude,
    'longitude': longitude,
    'temperature': temperature,
    'humidity': humidity,
    'weatherCode': weatherCode,
    'next24Rain': next24Rain,
    'soil0to1': soil0to1,
    'soil1to3': soil1to3,
    'soil3to9': soil3to9,
    'checkedAt': checkedAt.toIso8601String(),
  };

  factory RegionSnapshot.fromJson(
    Map<String, dynamic> json, {
    bool cached = false,
  }) {
    return RegionSnapshot(
      place: (json['place'] ?? '').toString(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      weatherCode: (json['weatherCode'] ?? 0).toInt(),
      next24Rain: (json['next24Rain'] ?? 0).toDouble(),
      soil0to1: json['soil0to1'] == null
          ? null
          : (json['soil0to1'] as num).toDouble(),
      soil1to3: json['soil1to3'] == null
          ? null
          : (json['soil1to3'] as num).toDouble(),
      soil3to9: json['soil3to9'] == null
          ? null
          : (json['soil3to9'] as num).toDouble(),
      cached: cached,
      checkedAt:
          DateTime.tryParse((json['checkedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class RegionExplorerScreen extends StatefulWidget {
  const RegionExplorerScreen({super.key});

  @override
  State<RegionExplorerScreen> createState() => _RegionExplorerScreenState();
}

class _RegionExplorerScreenState extends State<RegionExplorerScreen> {
  static const districtDirectoryUrl =
      'https://raw.githubusercontent.com/iaseth/data-for-india/master/data/readable/districts.json';

  String? stateName;
  String? districtName;
  List<String> districts = [];
  bool loadingDistricts = false;
  bool loading = false;
  String error = '';
  RegionSnapshot? snapshot;

  // Kept false so technical/source explanations
  // do not clutter the public-facing app UI.
  bool showTechnicalSources = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLastSnapshot());
  }

  Future<void> _loadLastSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('region_last_snapshot');
    if (raw == null) return;
    try {
      final parsed = RegionSnapshot.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw)),
        cached: true,
      );
      if (mounted) setState(() => snapshot = parsed);
    } catch (_) {}
  }

  Future<String?> _districtDirectoryRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('district_directory_cache');
    try {
      final response = await http
          .get(
            Uri.parse(districtDirectoryUrl),
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'GEONEXA/1.0',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 && response.body.trim().startsWith('{')) {
        await prefs.setString('district_directory_cache', response.body);
        return response.body;
      }
    } catch (_) {}
    return cached;
  }

  Future<void> _loadDistricts(String selectedState) async {
    setState(() {
      stateName = selectedState;
      districtName = null;
      loadingDistricts = true;
      error = '';
      districts = List<String>.from(
        nerDistrictFallback[selectedState] ?? const [],
      );
    });

    final raw = await _districtDirectoryRaw();
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final rows = List<dynamic>.from(decoded['districts'] ?? const []);
        final found =
            rows
                .whereType<Map>()
                .where(
                  (row) =>
                      (row['state'] ?? '').toString().trim().toLowerCase() ==
                      selectedState.trim().toLowerCase(),
                )
                .map((row) => (row['district'] ?? '').toString().trim())
                .where((value) => value.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

        if (found.isNotEmpty && mounted) {
          setState(() => districts = found);
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      loadingDistricts = false;
      if (districts.isEmpty) {
        error = regionText('district_unavailable');
      }
    });
  }

  Future<({double lat, double lon})?> _districtCoordinates(
    String district,
    String state,
  ) async {
    try {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': district,
        'count': '20',
        'language': 'en',
        'format': 'json',
        'countryCode': 'IN',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final rows = List<dynamic>.from(decoded['results'] ?? const []);
      if (rows.isEmpty) return null;

      Map<String, dynamic>? best;
      for (final raw in rows) {
        if (raw is! Map) continue;
        final item = Map<String, dynamic>.from(raw);
        final admin1 = (item['admin1'] ?? '').toString().trim().toLowerCase();
        if (admin1 == state.trim().toLowerCase() ||
            admin1.contains(state.trim().toLowerCase())) {
          best = item;
          break;
        }
      }
      best ??= Map<String, dynamic>.from(rows.first as Map);
      final lat = (best['latitude'] as num?)?.toDouble();
      final lon = (best['longitude'] as num?)?.toDouble();
      if (lat == null || lon == null) return null;
      return (lat: lat, lon: lon);
    } catch (_) {
      return null;
    }
  }

  int _nearestHourlyIndex(List<String> times) {
    if (times.isEmpty) return 0;
    final now = DateTime.now();
    var best = 0;
    var bestDiff = const Duration(days: 9999);
    for (var i = 0; i < times.length; i++) {
      final parsed = DateTime.tryParse(times[i]);
      if (parsed == null) continue;
      final diff = parsed.difference(now).abs();
      if (diff < bestDiff) {
        best = i;
        bestDiff = diff;
      }
    }
    return best;
  }

  Future<RegionSnapshot> _fetchSnapshot({
    required double lat,
    required double lon,
    required String place,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$lat',
      'longitude': '$lon',
      'current': 'temperature_2m,relative_humidity_2m,weather_code',
      'hourly':
          'precipitation,soil_moisture_0_to_1cm,soil_moisture_1_to_3cm,soil_moisture_3_to_9cm',
      'forecast_hours': '24',
      'past_hours': '1',
      'timezone': 'auto',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Open-Meteo returned ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final current = Map<String, dynamic>.from(decoded['current'] ?? const {});
    final hourly = Map<String, dynamic>.from(decoded['hourly'] ?? const {});
    final times = List<String>.from(hourly['time'] ?? const []);
    final precipitation = List<num>.from(hourly['precipitation'] ?? const []);
    final soil0 = List<num>.from(hourly['soil_moisture_0_to_1cm'] ?? const []);
    final soil1 = List<num>.from(hourly['soil_moisture_1_to_3cm'] ?? const []);
    final soil3 = List<num>.from(hourly['soil_moisture_3_to_9cm'] ?? const []);

    var rain = 0.0;
    for (final value in precipitation.take(24)) {
      rain += value.toDouble();
    }

    final index = _nearestHourlyIndex(times);
    double? getSoil(List<num> values) {
      if (values.isEmpty) return null;
      final safeIndex = index < 0
          ? 0
          : (index >= values.length ? values.length - 1 : index);
      return values[safeIndex].toDouble();
    }

    final result = RegionSnapshot(
      place: place,
      latitude: lat,
      longitude: lon,
      temperature: (current['temperature_2m'] ?? 0).toDouble(),
      humidity: (current['relative_humidity_2m'] ?? 0).toDouble(),
      weatherCode: (current['weather_code'] ?? 0).toInt(),
      next24Rain: rain,
      soil0to1: getSoil(soil0),
      soil1to3: getSoil(soil1),
      soil3to9: getSoil(soil3),
      cached: false,
      checkedAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('region_last_snapshot', jsonEncode(result.toJson()));
    return result;
  }

  Future<void> _checkDistrict() async {
    final state = stateName;
    final district = districtName;
    if (state == null || district == null) return;

    setState(() {
      loading = true;
      error = '';
    });
    try {
      final coordinates = await _districtCoordinates(district, state);
      if (coordinates == null) {
        throw Exception(regionText('location_lookup_failed'));
      }
      final result = await _fetchSnapshot(
        lat: coordinates.lat,
        lon: coordinates.lon,
        place: '$district, $state, India',
      );
      if (mounted) setState(() => snapshot = result);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _checkGps() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final location = await DataService.getLocation(
        timeout: const Duration(seconds: 12),
      );
      final result = await _fetchSnapshot(
        lat: location.latitude,
        lon: location.longitude,
        place: location.place,
      );
      if (mounted) setState(() => snapshot = result);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _weatherLabel(int code) {
    if (code == 0) return tr('weather_clear');
    if ([1, 2, 3].contains(code)) return tr('weather_cloudy');
    if ([45, 48].contains(code)) return tr('weather_fog');
    if ([51, 53, 55, 56, 57].contains(code)) return tr('weather_drizzle');
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      return tr('weather_rain');
    }
    if ([71, 73, 75, 77, 85, 86].contains(code)) {
      return tr('weather_snow');
    }
    if ([95, 96, 99].contains(code)) return tr('weather_thunder');
    return tr('weather_unknown');
  }

  String _screening(double rain) {
    if (rain >= 64.5) return tr('risk_high');
    if (rain >= 15.6) return tr('risk_medium');
    return tr('risk_low');
  }

  Color _screeningColor(double rain) {
    if (rain >= 64.5) return Colors.redAccent;
    if (rain >= 15.6) return Colors.orangeAccent;
    return const Color(0xFF5DE0B5);
  }

  String _soil(double? value) =>
      value == null ? '—' : '${value.toStringAsFixed(3)} m³/m³';

  Widget _sourceLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5DE0B5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = snapshot;
    final allStates = [...nerStates, ...otherIndianStates];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: AppHeader(
                    title: regionText('explore_regions'),
                    subtitle: regionText('region_subtitle'),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.landscape,
                              color: Color(0xFF5DE0B5),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                regionText('ner_focus'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          regionText('ner_note'),
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: nerStates.map((state) {
                            final selected = stateName == state;
                            return ChoiceChip(
                              selected: selected,
                              label: Text(state),
                              avatar: const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                              ),
                              onSelected: (_) => _loadDistricts(state),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    regionText('other_states'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: ValueKey('region-state-$stateName'),
                    initialValue: stateName,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: regionText('select_state'),
                      prefixIcon: const Icon(Icons.map_outlined),
                    ),
                    items: allStates
                        .map(
                          (state) => DropdownMenuItem(
                            value: state,
                            child: Row(
                              children: [
                                if (nerStates.contains(state))
                                  Container(
                                    margin: const EdgeInsets.only(right: 7),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF5DE0B5,
                                      ).withValues(alpha: .13),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Text(
                                      'NER',
                                      style: TextStyle(
                                        color: Color(0xFF5DE0B5),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Flexible(child: Text(state)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) unawaited(_loadDistricts(value));
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      'region-district-$districtName-${districts.length}',
                    ),
                    initialValue: districtName,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: loadingDistricts
                          ? regionText('district_loading')
                          : regionText('select_district'),
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                    items: districts
                        .map(
                          (district) => DropdownMenuItem(
                            value: district,
                            child: Text(district),
                          ),
                        )
                        .toList(),
                    onChanged: loadingDistricts || districts.isEmpty
                        ? null
                        : (value) => setState(() => districtName = value),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              loading ||
                                  stateName == null ||
                                  districtName == null
                              ? null
                              : _checkDistrict,
                          icon: const Icon(Icons.analytics_outlined),
                          label: Text(regionText('check_condition')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: loading ? null : _checkGps,
                          icon: const Icon(Icons.my_location),
                          label: Text(regionText('use_gps')),
                        ),
                      ),
                    ],
                  ),
                  if (loading)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 9),
                          Text(regionText('refreshing_region')),
                        ],
                      ),
                    ),
                  if (error.isNotEmpty)
                    AppCard(
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.orangeAccent),
                      ),
                    ),
                  if (result != null) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.place, color: Color(0xFF5DE0B5)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  result.place,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (result.cached
                                              ? Colors.orangeAccent
                                              : const Color(0xFF5DE0B5))
                                          .withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  result.cached
                                      ? regionText('source_cached')
                                      : regionText('source_live'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: result.cached
                                        ? Colors.orangeAccent
                                        : const Color(0xFF5DE0B5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _MetricTile(
                                  icon: Icons.thermostat,
                                  label: regionText('temperature'),
                                  value:
                                      '${result.temperature.toStringAsFixed(1)}°C',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _MetricTile(
                                  icon: Icons.water_drop_outlined,
                                  label: regionText('humidity'),
                                  value:
                                      '${result.humidity.toStringAsFixed(0)}%',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _MetricTile(
                            icon: Icons.cloud_outlined,
                            label: regionText('weather_condition'),
                            value: _weatherLabel(result.weatherCode),
                          ),
                          const SizedBox(height: 8),
                          _MetricTile(
                            icon: Icons.grain,
                            label: regionText('rain_24h'),
                            value: '${result.next24Rain.toStringAsFixed(1)} mm',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                regionText('screening'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _screeningColor(
                                    result.next24Rain,
                                  ).withValues(alpha: .13),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: _screeningColor(result.next24Rain),
                                  ),
                                ),
                                child: Text(
                                  _screening(result.next24Rain),
                                  style: TextStyle(
                                    color: _screeningColor(result.next24Rain),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr('not_probability'),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.eco_outlined,
                                color: Color(0xFF5DE0B5),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                regionText('soil_moisture'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          InfoRow(
                            regionText('soil_surface'),
                            _soil(result.soil0to1),
                          ),
                          InfoRow(
                            regionText('soil_shallow'),
                            _soil(result.soil1to3),
                          ),
                          InfoRow(
                            regionText('soil_deeper'),
                            _soil(result.soil3to9),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            regionText('soil_note'),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.terrain,
                                color: Color(0xFF5DE0B5),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${tr('live_map')} · 3D',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 430,
                              child: Ner3DTerrainMap(
                                latitude: result.latitude,
                                longitude: result.longitude,
                                place: result.place,
                                riskCode: result.next24Rain >= 64.5
                                    ? 'HIGH'
                                    : result.next24Rain >= 15.6
                                    ? 'MEDIUM'
                                    : 'LOW',
                                riskLabel: _screening(result.next24Rain),
                              ),
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            stateName != null && districtName != null
                                ? regionText('point_note')
                                : regionText('gps_note'),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (showTechnicalSources)
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.dataset_outlined,
                                color: Color(0xFF5DE0B5),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                regionText('data_sources'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _sourceLine(
                            Icons.cloud_outlined,
                            regionText('live_source'),
                          ),
                          _sourceLine(
                            Icons.notifications_active_outlined,
                            regionText('alerts_source'),
                          ),
                          _sourceLine(Icons.terrain, regionText('gsi_source')),
                          _sourceLine(
                            Icons.psychology,
                            regionText('nasa_source'),
                          ),
                          _sourceLine(
                            Icons.location_city,
                            regionText('district_source'),
                          ),
                          const Divider(height: 24),
                          Text(
                            regionText('ml_truth'),
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF071A28).withValues(alpha: .72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF5DE0B5).withValues(alpha: .10),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5DE0B5), size: 21),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool loading = true;
  String error = '';
  String place = '';
  WeatherData? data;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final loc = await DataService.getLocation();
      final w = await DataService.weather(loc.latitude, loc.longitude);
      if (!mounted) return;
      setState(() {
        place = loc.place;
        data = w;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String dayName(String s) {
    final d = DateTime.parse(s);
    const x = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return x[d.weekday - 1];
  }

  String weatherText(int code) {
    if (code == 0) return tr('weather_clear');
    if (code <= 3) return tr('weather_cloudy');
    if (code == 45 || code == 48) return tr('weather_fog');
    if (code >= 51 && code <= 57) return tr('weather_drizzle');
    if (code >= 61 && code <= 67) return tr('weather_rain');
    if (code >= 71 && code <= 77) return tr('weather_snow');
    if (code >= 80 && code <= 82) return tr('weather_rain');
    if (code >= 95) return tr('weather_thunder');
    return tr('weather_unknown');
  }

  IconData weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code <= 3) return Icons.cloud_outlined;
    if (code >= 95) return Icons.thunderstorm_outlined;
    return Icons.water_drop_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(title: tr('seven_day'), subtitle: tr('forecast_gps')),
        Expanded(
          child: RefreshIndicator(
            onRefresh: load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
              children: [
                if (place.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF5DE0B5)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          place,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (error.isNotEmpty)
                  AppCard(child: Text(error, textAlign: TextAlign.center)),
                if (data != null)
                  ...List.generate(data!.dailyDates.length, (i) {
                    final code = data!.dailyCode[i].toInt();
                    return AppCard(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 58,
                            child: Text(
                              i == 0
                                  ? tr('today')
                                  : dayName(data!.dailyDates[i]),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            weatherIcon(code),
                            color: const Color(0xFF5DE0B5),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weatherText(code),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${tr('rain')} ${data!.dailyRain[i].toStringAsFixed(1)} mm · '
                                  '${tr('rain_chance')} ${data!.dailyProb[i]}%',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${data!.maxTemp[i].round()}° / ${data!.minTemp[i].round()}°',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HazardReport {
  final String type;
  final String severity;
  final String note;
  final double lat;
  final double lon;
  final String place;
  final String time;
  final String photoPath;
  final String videoPath;
  final String screenedRisk;
  final double rainAtReport;

  HazardReport({
    required this.type,
    required this.severity,
    required this.note,
    required this.lat,
    required this.lon,
    required this.place,
    required this.time,
    required this.photoPath,
    required this.videoPath,
    required this.screenedRisk,
    required this.rainAtReport,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'severity': severity,
    'note': note,
    'lat': lat,
    'lon': lon,
    'place': place,
    'time': time,
    'photoPath': photoPath,
    'videoPath': videoPath,
    'screenedRisk': screenedRisk,
    'rainAtReport': rainAtReport,
  };

  factory HazardReport.fromJson(Map<String, dynamic> j) => HazardReport(
    type: j['type'] ?? '',
    severity: j['severity'] ?? '',
    note: j['note'] ?? '',
    lat: (j['lat'] ?? 0).toDouble(),
    lon: (j['lon'] ?? 0).toDouble(),
    place: j['place'] ?? '',
    time: j['time'] ?? '',
    photoPath: j['photoPath'] ?? '',
    videoPath: j['videoPath'] ?? '',
    screenedRisk: j['screenedRisk'] ?? 'LOW',
    rainAtReport: (j['rainAtReport'] ?? 0).toDouble(),
  );
}

String reportUiText(String key) {
  const values = <String, Map<String, String>>{
    'en': {
      'other_image': 'Other / non-disaster image',
      'other_message':
          'This image is not related to a disaster. Please upload a clear disaster-related image.',
      'image_identification': 'Image identification',
      'risk_chances': 'Landslide Risk Chances',
      'risk_subtitle': 'Near-real-time satellite & model update',
      'risk_checking': 'Checking latest landslide risk update…',
      'risk_available': 'Latest landslide risk data is available.',
      'risk_unavailable': 'Risk update is temporarily unavailable.',
      'risk_note':
          'This near-real-time satellite and model update supports landslide risk screening. It is not an on-ground disaster confirmation.',
    },

    'hi': {
      'other_image': 'अन्य / गैर-आपदा छवि',
      'other_message':
          'यह तस्वीर किसी आपदा से संबंधित नहीं है। कृपया आपदा से संबंधित स्पष्ट तस्वीर अपलोड करें।',
      'image_identification': 'छवि पहचान',
      'risk_chances': 'भूस्खलन जोखिम संभावना',
      'risk_subtitle': 'निकट-वास्तविक समय उपग्रह और मॉडल अपडेट',
      'risk_checking': 'नवीनतम भूस्खलन जोखिम अपडेट जांचा जा रहा है…',
      'risk_available': 'नवीनतम भूस्खलन जोखिम डेटा उपलब्ध है।',
      'risk_unavailable': 'जोखिम अपडेट फिलहाल उपलब्ध नहीं है।',
      'risk_note':
          'यह निकट-वास्तविक समय अपडेट भूस्खलन जोखिम जांच में सहायता करता है। यह वास्तविक घटना की पुष्टि नहीं है।',
    },

    'kn': {
      'other_image': 'ಇತರೆ / ವಿಪತ್ತು ಅಲ್ಲದ ಚಿತ್ರ',
      'other_message':
          'ಈ ಚಿತ್ರವು ವಿಪತ್ತಿಗೆ ಸಂಬಂಧಿಸಿಲ್ಲ. ದಯವಿಟ್ಟು ಸ್ಪಷ್ಟವಾದ ವಿಪತ್ತು ಸಂಬಂಧಿತ ಚಿತ್ರವನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ.',
      'image_identification': 'ಚಿತ್ರ ಗುರುತಿಸುವಿಕೆ',
      'risk_chances': 'ಭೂಕುಸಿತ ಅಪಾಯ ಸಾಧ್ಯತೆ',
      'risk_subtitle': 'ಸಮೀಪ-ನೈಜ ಸಮಯ ಉಪಗ್ರಹ ಮತ್ತು ಮಾದರಿ ನವೀಕರಣ',
      'risk_checking': 'ಇತ್ತೀಚಿನ ಭೂಕುಸಿತ ಅಪಾಯ ನವೀಕರಣ ಪರಿಶೀಲಿಸಲಾಗುತ್ತಿದೆ…',
      'risk_available': 'ಇತ್ತೀಚಿನ ಭೂಕುಸಿತ ಅಪಾಯ ಮಾಹಿತಿ ಲಭ್ಯವಿದೆ.',
      'risk_unavailable': 'ಅಪಾಯ ನವೀಕರಣ ತಾತ್ಕಾಲಿಕವಾಗಿ ಲಭ್ಯವಿಲ್ಲ.',
      'risk_note':
          'ಈ ಸಮೀಪ-ನೈಜ ಸಮಯದ ನವೀಕರಣ ಭೂಕುಸಿತ ಅಪಾಯ ಪರಿಶೀಲನೆಗೆ ಸಹಾಯ ಮಾಡುತ್ತದೆ. ಇದು ನೈಜ ಘಟನೆಯ ದೃಢೀಕರಣವಲ್ಲ.',
    },

    'ta': {
      'other_image': 'மற்ற / பேரிடர் அல்லாத படம்',
      'other_message':
          'இந்த படம் பேரிடருடன் தொடர்புடையது அல்ல. தெளிவான பேரிடர் தொடர்புடைய படத்தை பதிவேற்றவும்.',
      'image_identification': 'பட அடையாளம்',
      'risk_chances': 'நிலச்சரிவு அபாய வாய்ப்பு',
      'risk_subtitle': 'அருகிய நேர செயற்கைக்கோள் மற்றும் மாதிரி புதுப்பிப்பு',
      'risk_checking':
          'சமீபத்திய நிலச்சரிவு அபாய புதுப்பிப்பு சரிபார்க்கப்படுகிறது…',
      'risk_available': 'சமீபத்திய நிலச்சரிவு அபாய தகவல் கிடைக்கிறது.',
      'risk_unavailable': 'அபாய புதுப்பிப்பு தற்காலிகமாக கிடைக்கவில்லை.',
      'risk_note':
          'இந்த புதுப்பிப்பு நிலச்சரிவு அபாய மதிப்பீட்டிற்கு உதவுகிறது. இது உண்மையான நிகழ்வின் உறுதிப்படுத்தல் அல்ல.',
    },

    'te': {
      'other_image': 'ఇతర / విపత్తు కాని చిత్రం',
      'other_message':
          'ఈ చిత్రం విపత్తుకు సంబంధించినది కాదు. స్పష్టమైన విపత్తు సంబంధిత చిత్రాన్ని అప్‌లోడ్ చేయండి.',
      'image_identification': 'చిత్ర గుర్తింపు',
      'risk_chances': 'భూస्खలనం ప్రమాద అవకాశం',
      'risk_subtitle': 'సమీప-రియల్ టైమ్ ఉపగ్రహ మరియు మోడల్ నవీకరణ',
      'risk_checking': 'తాజా భూస्खలనం ప్రమాద నవీకరణను పరిశీలిస్తోంది…',
      'risk_available': 'తాజా భూస्खలనం ప్రమాద సమాచారం అందుబాటులో ఉంది.',
      'risk_unavailable': 'ప్రమాద నవీకరణ ప్రస్తుతం అందుబాటులో లేదు.',
      'risk_note':
          'ఈ నవీకరణ భూస्खలనం ప్రమాద స్క్రీనింగ్‌కు సహాయపడుతుంది. ఇది నిజమైన ఘటనకు నిర్ధారణ కాదు.',
    },

    'ml': {
      'other_image': 'മറ്റ് / ദുരന്തമല്ലാത്ത ചിത്രം',
      'other_message':
          'ഈ ചിത്രം ദുരന്തവുമായി ബന്ധപ്പെട്ടതല്ല. വ്യക്തമായ ദുരന്തബന്ധപ്പെട്ട ചിത്രം അപ്‌ലോഡ് ചെയ്യുക.',
      'image_identification': 'ചിത്ര തിരിച്ചറിയൽ',
      'risk_chances': 'മണ്ണിടിച്ചിൽ അപകട സാധ്യത',
      'risk_subtitle': 'സമീപ-തത്സമയ ഉപഗ്രഹവും മോഡൽ അപ്ഡേറ്റും',
      'risk_checking': 'പുതിയ മണ്ണിടിച്ചിൽ അപകട അപ്ഡേറ്റ് പരിശോധിക്കുന്നു…',
      'risk_available': 'പുതിയ മണ്ണിടിച്ചിൽ അപകട വിവരം ലഭ്യമാണ്.',
      'risk_unavailable': 'അപകട അപ്ഡേറ്റ് താൽക്കാലികമായി ലഭ്യമല്ല.',
      'risk_note':
          'ഈ അപ്ഡേറ്റ് മണ്ണിടിച്ചിൽ അപകട പരിശോധനയെ സഹായിക്കുന്നു. ഇത് യഥാർത്ഥ സംഭവത്തിന്റെ സ്ഥിരീകരണമല്ല.',
    },

    'mr': {
      'other_image': 'इतर / आपत्ती नसलेले चित्र',
      'other_message':
          'हे चित्र आपत्तीशी संबंधित नाही. कृपया आपत्तीशी संबंधित स्पष्ट चित्र अपलोड करा.',
      'image_identification': 'प्रतिमा ओळख',
      'risk_chances': 'भूस्खलन धोका शक्यता',
      'risk_subtitle': 'जवळपास रिअल-टाइम उपग्रह आणि मॉडेल अपडेट',
      'risk_checking': 'नवीनतम भूस्खलन धोका अपडेट तपासत आहे…',
      'risk_available': 'नवीनतम भूस्खलन धोका माहिती उपलब्ध आहे.',
      'risk_unavailable': 'धोका अपडेट सध्या उपलब्ध नाही.',
      'risk_note':
          'हे अपडेट भूस्खलन धोका तपासणीस मदत करते. हे प्रत्यक्ष घटनेची पुष्टी नाही.',
    },

    'bn': {
      'other_image': 'অন্যান্য / দুর্যোগ নয় এমন ছবি',
      'other_message':
          'এই ছবিটি দুর্যোগের সঙ্গে সম্পর্কিত নয়। দুর্যোগ সম্পর্কিত একটি পরিষ্কার ছবি আপলোড করুন।',
      'image_identification': 'ছবি শনাক্তকরণ',
      'risk_chances': 'ভূমিধস ঝুঁকির সম্ভাবনা',
      'risk_subtitle': 'প্রায় রিয়েল-টাইম স্যাটেলাইট ও মডেল আপডেট',
      'risk_checking': 'সর্বশেষ ভূমিধস ঝুঁকি আপডেট পরীক্ষা করা হচ্ছে…',
      'risk_available': 'সর্বশেষ ভূমিধস ঝুঁকির তথ্য পাওয়া গেছে।',
      'risk_unavailable': 'ঝুঁকির আপডেট সাময়িকভাবে পাওয়া যাচ্ছে না।',
      'risk_note':
          'এই আপডেট ভূমিধস ঝুঁকি যাচাইয়ে সহায়তা করে। এটি বাস্তব ঘটনার নিশ্চিতকরণ নয়।',
    },

    'as': {
      'other_image': 'অন্য / দুৰ্যোগ নহোৱা ছবি',
      'other_message':
          'এই ছবিখন দুৰ্যোগৰ সৈতে সম্পৰ্কিত নহয়। দুৰ্যোগ-সম্পৰ্কীয় স্পষ্ট ছবি আপলোড কৰক।',
      'image_identification': 'ছবি চিনাক্তকৰণ',
      'risk_chances': 'ভূমিস্খলন বিপদ সম্ভাৱনা',
      'risk_subtitle': 'নিকট-বাস্তৱ সময় উপগ্ৰহ আৰু মডেল আপডেট',
      'risk_checking': 'শেহতীয়া ভূমিস্খলন বিপদ আপডেট পৰীক্ষা কৰা হৈছে…',
      'risk_available': 'শেহতীয়া ভূমিস্খলন বিপদ তথ্য উপলব্ধ।',
      'risk_unavailable': 'বিপদ আপডেট সাময়িকভাৱে উপলব্ধ নহয়।',
      'risk_note':
          'এই আপডেটে ভূমিস্খলন বিপদ পৰীক্ষাত সহায় কৰে। ই বাস্তৱ ঘটনাৰ নিশ্চিতকৰণ নহয়।',
    },

    'ne': {
      'other_image': 'अन्य / विपद् नभएको तस्बिर',
      'other_message':
          'यो तस्बिर विपद्सँग सम्बन्धित छैन। स्पष्ट विपद् सम्बन्धित तस्बिर अपलोड गर्नुहोस्।',
      'image_identification': 'तस्बिर पहिचान',
      'risk_chances': 'पहिरो जोखिम सम्भावना',
      'risk_subtitle': 'नजिकको वास्तविक समय उपग्रह तथा मोडेल अपडेट',
      'risk_checking': 'पछिल्लो पहिरो जोखिम अपडेट जाँच भइरहेको छ…',
      'risk_available': 'पछिल्लो पहिरो जोखिम जानकारी उपलब्ध छ।',
      'risk_unavailable': 'जोखिम अपडेट हाल उपलब्ध छैन।',
      'risk_note':
          'यो अपडेटले पहिरो जोखिम स्क्रिनिङलाई सहयोग गर्छ। यो वास्तविक घटनाको पुष्टि होइन।',
    },
  };

  return values[appController.language]?[key] ?? values['en']?[key] ?? key;
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ImagePicker picker = ImagePicker();

  final TextEditingController note = TextEditingController();

  late final ImageLabeler imageLabeler;

  bool analysing = false;

  String photoPath = '';

  String detectedImage = '';

  String detectedLabels = '';

  String lastScreening = '';

  String lastPlace = '';

  String statusMessage = '';

  double? lastLat;
  double? lastLon;
  double? lastRain;

  // GPS captured specifically for this report image.
  double? taggedAccuracy;
  bool locationTagging = false;

  // NASA LHASA status.
  bool lhasaLoading = false;
  String lhasaStatus = '';
  String lhasaProduct = '';
  String lhasaDate = '';
  List<String> currentLabelNames = [];

  @override
  void initState() {
    super.initState();

    imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.45),
    );

    // Remove old report history because this page
    // no longer contains Saved Reports.
    unawaited(
      SharedPreferences.getInstance().then(
        (prefs) => prefs.remove('hazard_reports'),
      ),
    );
  }

  @override
  void dispose() {
    note.dispose();
    imageLabeler.close();
    super.dispose();
  }

  Future<void> attachPhoto(ImageSource source) async {
    if (analysing) return;

    try {
      final picked = await picker.pickImage(
        source: source,

        // Smaller image = much faster ML analysis,
        // while still keeping enough detail.
        imageQuality: 76,
        maxWidth: 1280,
      );

      if (picked == null) return;

      final directory = await getApplicationDocumentsDirectory();

      final original = picked.path;

      final dot = original.lastIndexOf('.');

      final extension = dot >= 0 ? original.substring(dot) : '.jpg';

      final target =
          '${directory.path}/geonexa_ai_'
          '${DateTime.now().millisecondsSinceEpoch}'
          '$extension';

      final saved = await File(original).copy(target);

      if (!mounted) return;

      setState(() {
        photoPath = saved.path;

        detectedImage = '';

        detectedLabels = '';

        lastScreening = '';

        statusMessage = '';

        lastPlace = '';

        lastLat = null;

        lastLon = null;

        lastRain = null;

        currentLabelNames = [];
      });

      // Analyse automatically.
      // Tag THIS report image with the phone's
      // current GPS position first.
      await _tagUploadedPhotoLocation();

      // Keep the existing AI image analysis.
      await analysePhoto();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        statusMessage = 'Could not open or analyse the image.';
      });
    }
  }

  bool _containsAny(List<String> labels, List<String> words) {
    for (final label in labels) {
      for (final word in words) {
        if (label.contains(word)) {
          return true;
        }
      }
    }

    return false;
  }

  int _matchingCount(List<String> labels, List<String> words) {
    var count = 0;

    for (final label in labels) {
      if (words.any(label.contains)) {
        count++;
      }
    }

    return count;
  }

  String _identifyImage(List<ImageLabel> labels) {
    if (labels.isEmpty) {
      return 'UNSUPPORTED|Unknown image';
    }

    final names = labels
        .map((label) => label.label.toLowerCase().trim())
        .where((value) => value.isNotEmpty)
        .toList();

    const flowerTerms = [
      'flower',
      'petal',
      'bouquet',
      'blossom',
      'rose',
      'floral',
    ];

    const foodTerms = [
      'food',
      'dish',
      'meal',
      'fruit',
      'vegetable',
      'cake',
      'dessert',
      'drink',
      'beverage',
    ];

    const peopleTerms = [
      'selfie',
      'face',
      'portrait',
      'smile',
      'person',
      'human',
      'crowd',
    ];

    const animalTerms = ['cat', 'dog', 'pet', 'bird', 'animal', 'horse', 'cow'];

    const ordinaryObjectTerms = [
      'computer',
      'laptop',
      'phone',
      'television',
      'furniture',
      'shoe',
      'clothing',
      'toy',
      'book',
      'document',
      'receipt',
    ];

    const landslideTerms = [
      'landslide',
      'mudslide',
      'mud',
      'erosion',
      'soil',
      'debris',
      'rubble',
      'rockfall',
      'rock',
      'cliff',
      'slope',
      'terrain',
      'geology',
      'mountain',
      'hill',
      'earth',
    ];

    const floodTerms = [
      'flood',
      'flooding',
      'tsunami',
      'wave',
      'overflow',
      'water disaster',
    ];

    const fireTerms = [
      'wildfire',
      'forest fire',
      'fire',
      'flame',
      'smoke',
      'burning',
    ];

    const stormTerms = [
      'tornado',
      'hurricane',
      'cyclone',
      'storm',
      'thunderstorm',
      'lightning',
    ];

    const structuralTerms = [
      'earthquake',
      'collapsed',
      'collapse',
      'ruin',
      'rubble',
      'damaged building',
      'destroyed building',
    ];

    final explicitHazard =
        _containsAny(names, landslideTerms) ||
        _containsAny(names, floodTerms) ||
        _containsAny(names, fireTerms) ||
        _containsAny(names, stormTerms) ||
        _containsAny(names, structuralTerms);

    // Explicitly reject common unrelated images.
    // If the same image has strong genuine hazard
    // labels, hazard evidence takes priority.
    if (!explicitHazard) {
      if (_containsAny(names, flowerTerms)) {
        return 'UNSUPPORTED|Flower / plant image';
      }

      if (_containsAny(names, foodTerms)) {
        return 'UNSUPPORTED|Food / everyday image';
      }

      if (_containsAny(names, peopleTerms)) {
        return 'UNSUPPORTED|Person / selfie image';
      }

      if (_containsAny(names, animalTerms)) {
        return 'UNSUPPORTED|Animal / pet image';
      }

      if (_containsAny(names, ordinaryObjectTerms)) {
        return 'UNSUPPORTED|Everyday object image';
      }
    }

    if (_containsAny(names, fireTerms)) {
      return 'SUPPORTED|Possible wildfire / fire hazard';
    }

    if (_containsAny(names, floodTerms)) {
      return 'SUPPORTED|Possible flood / water hazard';
    }

    if (_containsAny(names, stormTerms)) {
      return 'SUPPORTED|Possible severe storm hazard';
    }

    if (_containsAny(names, structuralTerms)) {
      return 'SUPPORTED|Possible structural / earthquake damage';
    }

    final terrainHits = _matchingCount(names, landslideTerms);

    // Require multiple terrain-related cues unless
    // the model gave a very explicit hazard label.
    final explicitSlopeHazard = _containsAny(names, [
      'landslide',
      'mudslide',
      'erosion',
      'debris',
      'rubble',
      'rockfall',
    ]);

    if (explicitSlopeHazard || terrainHits >= 2) {
      return 'SUPPORTED|Possible landslide / slope / rock hazard';
    }

    final first = labels.first.label.trim();

    return 'UNSUPPORTED|'
        '${first.isEmpty ? 'Unsupported image' : first}';
  }

  bool _seriousNote() {
    final value = note.text.toLowerCase();

    const dangerWords = [
      'people trapped',
      'person trapped',
      'road blocked',
      'road closed',
      'house damaged',
      'building damaged',
      'collapse',
      'collapsed',
      'moving debris',
      'debris flowing',
      'rock falling',
      'crack widening',
      'water rising',
      'water gushing',
      'slope moving',
      'mud flowing',
      'injured',
      'danger',
      'emergency',
    ];

    return dangerWords.any(value.contains);
  }

  int _hazardEvidenceCount(List<String> labels) {
    const strongTerms = [
      'landslide',
      'mudslide',
      'erosion',
      'debris',
      'rubble',
      'rockfall',
      'flood',
      'flooding',
      'wildfire',
      'fire',
      'smoke',
      'tornado',
      'cyclone',
      'hurricane',
      'earthquake',
      'collapsed',
      'collapse',
      'avalanche',
      'sinkhole',
    ];

    return _matchingCount(labels, strongTerms);
  }

  String _screenRisk({
    required String imageType,
    required List<String> labels,
    required double? rain,
  }) {
    var score = 0;

    final strongEvidence = _hazardEvidenceCount(labels);

    if (strongEvidence >= 2) {
      score += 3;
    } else if (strongEvidence == 1) {
      score += 2;
    } else {
      // Accepted terrain image but without a strong
      // explicit disaster label.
      score += 1;
    }

    if (imageType.contains('wildfire') ||
        imageType.contains('structural') ||
        imageType.contains('earthquake') ||
        imageType.contains('flood')) {
      score += 1;
    }

    if (_seriousNote()) {
      score += 2;
    }

    if (rain != null) {
      if (rain >= 64.5) {
        score += 3;
      } else if (rain >= 35) {
        score += 2;
      } else if (rain >= 15.6) {
        score += 1;
      } else if (rain < 5) {
        score -= 1;
      }
    }

    // EXTREME HIGH is intentionally difficult
    // to trigger. We do not want a normal image
    // to create an emergency-level result.
    if (score >= 7) {
      return 'EXTREME HIGH';
    }

    if (score >= 5) {
      return 'HIGH';
    }

    if (score >= 3) {
      return 'MEDIUM';
    }

    if (score >= 1) {
      return 'LOW';
    }

    return 'VERY LOW';
  }

  Color screeningColor(String value) {
    switch (value) {
      case 'EXTREME HIGH':
        return const Color(0xFFFF315C);

      case 'HIGH':
        return Colors.redAccent;

      case 'MEDIUM':
        return Colors.orangeAccent;

      case 'LOW':
        return const Color(0xFF5DE0B5);

      case 'VERY LOW':
        return Colors.lightBlueAccent;

      default:
        return Colors.white60;
    }
  }

  String advice(String value) {
    switch (value) {
      case 'EXTREME HIGH':
        return 'Strong danger signals were detected. '
            'Move away from unstable slopes, floodwater, falling-rock zones '
            'or damaged structures. Do not enter the affected area. '
            'Follow official/local-authority instructions. '
            'If anyone is in immediate danger, use the emergency 112 action below.';

      case 'HIGH':
        return 'High screening: keep away from the suspected hazard area, '
            'do not cross fresh debris, blocked roads or fast-flowing water, '
            'and follow official alerts. Use 112 if there is immediate danger.';

      case 'MEDIUM':
        return 'Medium screening: stay alert and keep a safe distance. '
            'Avoid unstable slopes, loose rocks and water channels, '
            'and monitor official warnings.';

      case 'LOW':
        return 'Low screening: no strong danger combination was detected. '
            'Continue observing only from a safe distance and watch for changes.';

      case 'VERY LOW':
        return 'Very low screening: hazard evidence is weak at present. '
            'Do not rely on this result alone; continue following local conditions '
            'and official information.';

      default:
        return '';
    }
  }

  Future<void> _tagUploadedPhotoLocation() async {
    if (!mounted) return;

    // Clear the previous photo's location first.
    setState(() {
      locationTagging = true;

      lastLat = null;
      lastLon = null;
      lastPlace = '';
      taggedAccuracy = null;

      lhasaStatus = '';
      lhasaProduct = '';
      lhasaDate = '';
    });

    try {
      // Capture the CURRENT device GPS when the
      // user selects/takes this report photo.
      final loc = await DataService.getLocation(
        timeout: const Duration(seconds: 8),
      );

      if (!mounted) return;

      setState(() {
        lastLat = loc.latitude;
        lastLon = loc.longitude;
        lastPlace = loc.place;
        taggedAccuracy = loc.accuracy;
      });

      // Do not block image analysis while waiting for NASA.
      unawaited(_loadNasaLhasa());
    } catch (e) {
      if (!mounted) return;

      setState(() {
        lastLat = null;
        lastLon = null;
        lastPlace = '';
        taggedAccuracy = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not tag current location: '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          locationTagging = false;
        });
      }
    }
  }

  String _nasaDay(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>?> _getLhasaProduct(
    String product,
    DateTime date,
  ) async {
    final day = _nasaDay(date);

    final uri = Uri.https('pmmpublisher.pps.eosdis.nasa.gov', '/opensearch', {
      'q': product,
      'limit': '1',
      'startTime': day,
      'endTime': day,
    });

    final response = await http
        .get(
          uri,
          headers: const {
            'Accept': 'application/activity+json, application/json',
          },
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      return null;
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      return null;
    }

    final root = Map<String, dynamic>.from(decoded);

    final items = root['items'];

    if (items is! List || items.isEmpty || items.first is! Map) {
      return null;
    }

    return Map<String, dynamic>.from(items.first as Map);
  }

  String _findNasaText(dynamic value, List<String> wantedKeys) {
    if (value is Map) {
      for (final key in wantedKeys) {
        final candidate = value[key];

        if (candidate != null && candidate is! Map && candidate is! List) {
          final text = candidate.toString().trim();

          if (text.isNotEmpty) {
            return text;
          }
        }
      }

      for (final child in value.values) {
        final result = _findNasaText(child, wantedKeys);

        if (result.isNotEmpty) {
          return result;
        }
      }
    }

    if (value is List) {
      for (final child in value) {
        final result = _findNasaText(child, wantedKeys);

        if (result.isNotEmpty) {
          return result;
        }
      }
    }

    return '';
  }

  Future<void> _loadNasaLhasa() async {
    if (lastLat == null || lastLon == null) {
      return;
    }

    if (mounted) {
      setState(() {
        lhasaLoading = true;
        lhasaStatus = reportUiText('risk_checking');
      });
    }

    try {
      Map<String, dynamic>? item;

      String selectedProduct = '';

      String selectedDay = '';

      final now = DateTime.now().toUtc();

      // Near-real-time data can have latency,
      // so try today followed by the previous 3 days.
      for (var offset = 0; offset <= 3; offset++) {
        final date = now.subtract(Duration(days: offset));

        item = await _getLhasaProduct('global_landslide_nowcast_30mn', date);

        if (item != null) {
          selectedProduct = 'Global Landslide Nowcast · 30-minute product';
          selectedDay = _nasaDay(date);
          break;
        }

        item = await _getLhasaProduct('global_landslide_nowcast', date);

        if (item != null) {
          selectedProduct = 'Global Landslide Nowcast';
          selectedDay = _nasaDay(date);
          break;
        }
      }

      if (!mounted) return;

      if (item == null) {
        setState(() {
          lhasaStatus = reportUiText('risk_unavailable');
          lhasaProduct = '';
          lhasaDate = '';
        });

        return;
      }

      final nasaName = _findNasaText(item, ['displayName', 'name', 'title']);

      setState(() {
        lhasaStatus = reportUiText('risk_available');

        lhasaProduct = nasaName.isNotEmpty ? nasaName : selectedProduct;

        lhasaDate = selectedDay;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        lhasaStatus = reportUiText('risk_unavailable');
        lhasaProduct = '';
        lhasaDate = '';
      });
    } finally {
      if (mounted) {
        setState(() {
          lhasaLoading = false;
        });
      }
    }
  }

  Future<void> _openNasaLhasaViewer() async {
    final uri = Uri.parse(
      'https://gpm.nasa.gov/data/visualization/precip-apps',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> analysePhoto() async {
    if (analysing) return;

    if (photoPath.isEmpty || !File(photoPath).existsSync()) {
      return;
    }

    setState(() {
      analysing = true;

      detectedImage = '';

      detectedLabels = '';

      lastScreening = '';

      statusMessage = 'AI is checking the image…';
    });

    try {
      final input = InputImage.fromFilePath(photoPath);

      final labels = await imageLabeler.processImage(input);

      final sorted = List<ImageLabel>.from(labels)
        ..sort((a, b) => b.confidence.compareTo(a.confidence));

      final useful = sorted.take(6).toList();

      final labelNames = useful
          .map((label) => label.label.toLowerCase().trim())
          .where((label) => label.isNotEmpty)
          .toList();

      final prettyLabels = useful
          .map(
            (label) =>
                '${label.label} '
                '${(label.confidence * 100).toStringAsFixed(0)}%',
          )
          .join('  •  ');

      final identification = _identifyImage(useful);

      final parts = identification.split('|');

      final supported = parts.first == 'SUPPORTED';

      final imageType = parts.length > 1
          ? parts.sublist(1).join('|')
          : identification;

      if (!supported) {
        if (!mounted) return;

        setState(() {
          detectedImage = imageType;

          detectedLabels = prettyLabels.isEmpty
              ? 'No reliable labels'
              : prettyLabels;

          currentLabelNames = labelNames;

          lastScreening = '';

          lastRain = null;

          statusMessage =
              'This does not appear to be a supported natural-disaster '
              'or landslide-related image. No risk level was assigned. '
              'Please upload a clear photo of the actual hazard.';
        });

        return;
      }

      // First use cached real data so results do not
      // wait unnecessarily for network/GPS.
      LocationData? location;

      // Prefer the GPS captured specifically for this
      // report photo instead of an older cached GPS.
      if (lastLat != null && lastLon != null) {
        location = LocationData(
          latitude: lastLat!,
          longitude: lastLon!,
          accuracy: taggedAccuracy ?? 0,
          place: lastPlace,
          cached: false,
          updatedAt: DateTime.now(),
        );
      } else {
        location = await DataService.cachedLocation();
      }

      WeatherData? weather = await DataService.cachedWeather();

      // If cached GPS does not exist, request fresh GPS.
      if (location == null) {
        try {
          location = await DataService.getLocation(
            timeout: const Duration(seconds: 5),
          );
        } catch (_) {}
      }

      // If no cached weather exists, fetch fresh data.
      if (weather == null && location != null) {
        try {
          weather = await DataService.weather(
            location.latitude,
            location.longitude,
          ).timeout(const Duration(seconds: 6));
        } catch (_) {}
      }

      final rain = weather?.next24Rain;

      final screening = _screenRisk(
        imageType: imageType,
        labels: labelNames,
        rain: rain,
      );

      if (!mounted) return;

      setState(() {
        detectedImage = imageType;

        detectedLabels = prettyLabels;

        currentLabelNames = labelNames;

        lastScreening = screening;

        lastRain = rain;

        lastPlace = location?.place ?? '';

        lastLat = location?.latitude;

        lastLon = location?.longitude;

        statusMessage = 'Image accepted for hazard screening.';
      });

      if (screening == 'HIGH' || screening == 'EXTREME HIGH') {
        try {
          unawaited(
            NotificationService.highReport(
              lastPlace.isEmpty ? 'reported area' : lastPlace,
            ),
          );
        } catch (_) {}
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        statusMessage =
            'Image analysis could not be completed. '
            'Please try another clear image.';
      });
    } finally {
      if (mounted) {
        setState(() {
          analysing = false;
        });
      }
    }
  }

  Future<void> _openReportMap() async {
    if (lastLat == null || lastLon == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location is not available yet.')),
        );
      }

      return;
    }

    final uri = Uri.parse(
      'https://maps.google.com/'
      '?q=$lastLat,$lastLon',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareLocation() async {
    if (lastLat == null || lastLon == null) {
      return;
    }

    final mapLink =
        'https://maps.google.com/'
        '?q=$lastLat,$lastLon';

    final text = [
      'GEONEXA hazard screening',
      if (lastScreening.isNotEmpty) 'Screening: $lastScreening',
      if (detectedImage.isNotEmpty) 'Image: $detectedImage',
      if (lastPlace.isNotEmpty) lastPlace,
      mapLink,
    ].join('\n');

    await SharePlus.instance.share(
      ShareParams(subject: 'GEONEXA hazard location', text: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = photoPath.isEmpty ? null : File(photoPath);

    final serious = lastScreening == 'HIGH' || lastScreening == 'EXTREME HIGH';

    return Column(
      children: [
        const AppHeader(
          title: 'AI Hazard Image Check',
          subtitle:
              'Upload a real hazard photo · GEONEXA identifies the image before screening',
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload hazard image',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Upload a clear image of a landslide, rockfall, flood, '
                      'storm damage, wildfire or another natural-disaster scene. '
                      'Unrelated images such as flowers, food, selfies or pets '
                      'will not receive a risk level.',
                      style: TextStyle(color: Colors.white60, height: 1.4),
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: analysing
                              ? null
                              : () => attachPhoto(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Take photo'),
                        ),

                        OutlinedButton.icon(
                          onPressed: analysing
                              ? null
                              : () => attachPhoto(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Choose photo'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: note,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Optional observation',
                        hintText:
                            'Example: road blocked, debris moving, water rising...',
                      ),
                    ),
                  ],
                ),
              ),

              if (photo != null && photo.existsSync()) ...[
                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(
                    photo,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: analysing
                        ? null
                        : () {
                            setState(() {
                              photoPath = '';

                              detectedImage = '';

                              detectedLabels = '';

                              lastScreening = '';

                              statusMessage = '';
                            });
                          },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                  ),
                ),
              ],
              if (photoPath.isNotEmpty)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF5DE0B5),
                          ),

                          const SizedBox(width: 8),

                          const Expanded(
                            child: Text(
                              'Report location',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          if (locationTagging)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      if (locationTagging)
                        const Text(
                          'Capturing current phone GPS…',
                          style: TextStyle(color: Colors.white60),
                        )
                      else if (lastLat != null && lastLon != null) ...[
                        if (lastPlace.isNotEmpty)
                          Text(
                            lastPlace,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),

                        const SizedBox(height: 8),

                        InfoRow('Latitude', lastLat!.toStringAsFixed(6)),

                        InfoRow('Longitude', lastLon!.toStringAsFixed(6)),

                        if (taggedAccuracy != null)
                          InfoRow(
                            'GPS accuracy',
                            '±${taggedAccuracy!.toStringAsFixed(0)} m',
                          ),

                        const SizedBox(height: 6),

                        const Text(
                          'Location captured automatically when this report image was selected.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ] else
                        const Text(
                          'Current GPS could not be attached. Check Location permission/service and try again.',
                          style: TextStyle(color: Colors.orangeAccent),
                        ),
                    ],
                  ),
                ),

              if (lastScreening.isNotEmpty &&
                  lastLat != null &&
                  lastLon != null)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.satellite_alt_outlined,
                            color: Color(0xFF5DE0B5),
                          ),

                          const SizedBox(width: 8),

                          const Expanded(
                            child: Text(
                              'Landslide Risk Chances',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          if (lhasaLoading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        reportUiText('risk_subtitle'),
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        lhasaStatus.isEmpty
                            ? reportUiText('risk_checking')
                            : lhasaStatus,
                        style: const TextStyle(height: 1.4),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        reportUiText('risk_note'),
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

              if (analysing)
                const AppCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text('Checking image with on-device AI…'),
                      ),
                    ],
                  ),
                ),

              if (detectedImage.isNotEmpty)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reportUiText('image_identification'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        detectedImage,
                        style: const TextStyle(
                          color: Color(0xFF5DE0B5),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      if (detectedLabels.isNotEmpty) ...[
                        const SizedBox(height: 8),

                        Text(
                          'AI labels: '
                          '$detectedLabels',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],

                      if (statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 10),

                        Text(
                          statusMessage,
                          style: const TextStyle(height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),

              if (lastScreening.isNotEmpty)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'GEONEXA screening',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: screeningColor(
                                lastScreening,
                              ).withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: screeningColor(lastScreening),
                              ),
                            ),
                            child: Text(
                              lastScreening,
                              style: TextStyle(
                                color: screeningColor(lastScreening),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (lastPlace.isNotEmpty) ...[
                        const SizedBox(height: 12),

                        Text(
                          lastPlace,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],

                      if (lastRain != null) ...[
                        const SizedBox(height: 8),

                        Text(
                          'Next 24h rainfall: '
                          '${lastRain!.toStringAsFixed(1)} mm',
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],

                      const SizedBox(height: 12),

                      Text(
                        advice(lastScreening),
                        style: const TextStyle(height: 1.45),
                      ),

                      if (serious) ...[
                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: .35),
                            ),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Government emergency action',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text('Emergency number: 112'),
                              SizedBox(height: 8),
                              Text(
                                'Safe route: GEONEXA will not guess an evacuation road. '
                                'Use only routes confirmed by police, disaster-management '
                                'authorities or a verified official alert.',
                                style: TextStyle(
                                  color: Colors.white60,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              onPressed: () async {
                                await launchUrl(
                                  Uri.parse('tel:112'),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              icon: const Icon(Icons.call),
                              label: const Text('Call 112'),
                            ),

                            OutlinedButton.icon(
                              onPressed: _openReportMap,
                              icon: const Icon(Icons.map_outlined),
                              label: const Text('Open location'),
                            ),

                            OutlinedButton.icon(
                              onPressed: _shareLocation,
                              icon: const Icon(Icons.share_location_outlined),
                              label: const Text('Share location'),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),

                      const Text(
                        'This is an automated screening aid, not an official disaster confirmation.',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final controller = TextEditingController();

  bool loading = false;
  bool conditionLoading = false;

  String error = '';
  String conditionError = '';
  String selectedOfficeKey = '';

  List<Map<String, dynamic>> offices = [];
  Map<String, dynamic>? condition;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> search() async {
    final pin = controller.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      setState(() {
        error = tr('pin_invalid');
      });
      return;
    }

    setState(() {
      loading = true;
      error = '';
      offices = [];
      condition = null;
      conditionError = '';
      selectedOfficeKey = '';
    });

    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http
          .get(Uri.parse('https://api.postalpincode.in/pincode/$pin'))
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as List;

      if (data.isEmpty || data.first['Status'] != 'Success') {
        throw Exception(tr('pin_not_found'));
      }

      final list = List<Map<String, dynamic>>.from(
        (data.first['PostOffice'] as List).map(
          (e) => Map<String, dynamic>.from(e),
        ),
      );

      await prefs.setString('pin_cache_$pin', jsonEncode(list));

      if (!mounted) return;

      setState(() {
        offices = list;
      });
    } catch (e) {
      final cache = prefs.getString('pin_cache_$pin');

      if (cache != null) {
        final list = (jsonDecode(cache) as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        if (!mounted) return;

        setState(() {
          offices = list;
          error = tr('cached');
        });
      } else {
        if (!mounted) return;

        setState(() {
          error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  String _officeKey(Map<String, dynamic> office) {
    return '${office['Name']}|'
        '${office['District']}|'
        '${office['State']}';
  }

  Future<({double lat, double lon})?> _geocode(
    String name,
    String district,
    String state,
  ) async {
    try {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': name,
        'count': '20',
        'language': 'en',
        'format': 'json',
        'countryCode': 'IN',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      final results = List<dynamic>.from(decoded['results'] ?? const []);

      if (results.isEmpty) {
        return null;
      }

      Map<String, dynamic>? best;

      final targetState = state.trim().toLowerCase();

      final targetDistrict = district.trim().toLowerCase();

      for (final raw in results) {
        if (raw is! Map) continue;

        final item = Map<String, dynamic>.from(raw);

        final admin1 = (item['admin1'] ?? '').toString().toLowerCase();

        final admin2 = (item['admin2'] ?? '').toString().toLowerCase();

        final stateMatch =
            targetState.isEmpty ||
            admin1.contains(targetState) ||
            targetState.contains(admin1);

        final districtMatch =
            targetDistrict.isEmpty ||
            admin2.contains(targetDistrict) ||
            targetDistrict.contains(admin2);

        if (stateMatch && districtMatch) {
          best = item;
          break;
        }

        if (stateMatch && best == null) {
          best = item;
        }
      }

      best ??= Map<String, dynamic>.from(results.first as Map);

      final lat = (best['latitude'] as num?)?.toDouble();

      final lon = (best['longitude'] as num?)?.toDouble();

      if (lat == null || lon == null) {
        return null;
      }

      return (lat: lat, lon: lon);
    } catch (_) {
      return null;
    }
  }

  Future<({double lat, double lon})?> _officeCoordinates(
    Map<String, dynamic> office,
  ) async {
    final name = (office['Name'] ?? '').toString();

    final district = (office['District'] ?? '').toString();

    final state = (office['State'] ?? '').toString();

    // First try the exact place/post-office name.
    if (name.isNotEmpty) {
      final exact = await _geocode(name, district, state);

      if (exact != null) {
        return exact;
      }
    }

    // If a small locality is not in the geocoder,
    // fall back to its district forecast point.
    if (district.isNotEmpty) {
      return _geocode(district, district, state);
    }

    return null;
  }

  Future<Map<String, dynamic>> _fetchCondition(double lat, double lon) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$lat',
      'longitude': '$lon',
      'current': 'temperature_2m,relative_humidity_2m,weather_code',
      'hourly':
          'precipitation,soil_moisture_0_to_1cm,soil_moisture_1_to_3cm,soil_moisture_3_to_9cm',
      'forecast_hours': '24',
      'timezone': 'auto',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Unable to load live condition.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    final current = Map<String, dynamic>.from(decoded['current'] ?? const {});

    final hourly = Map<String, dynamic>.from(decoded['hourly'] ?? const {});

    final precipitation = List<num>.from(hourly['precipitation'] ?? const []);

    final soil0 = List<num>.from(hourly['soil_moisture_0_to_1cm'] ?? const []);

    final soil1 = List<num>.from(hourly['soil_moisture_1_to_3cm'] ?? const []);

    final soil3 = List<num>.from(hourly['soil_moisture_3_to_9cm'] ?? const []);

    var rain = 0.0;

    for (final v in precipitation.take(24)) {
      rain += v.toDouble();
    }

    double? firstValue(List<num> values) {
      if (values.isEmpty) return null;
      return values.first.toDouble();
    }

    return {
      'lat': lat,
      'lon': lon,
      'temperature': (current['temperature_2m'] ?? 0).toDouble(),
      'humidity': (current['relative_humidity_2m'] ?? 0).toDouble(),
      'weatherCode': (current['weather_code'] ?? 0).toInt(),
      'rain': rain,
      'soil0': firstValue(soil0),
      'soil1': firstValue(soil1),
      'soil3': firstValue(soil3),
    };
  }

  Future<void> _showCondition(Map<String, dynamic> office) async {
    final key = _officeKey(office);

    setState(() {
      selectedOfficeKey = key;
      conditionLoading = true;
      conditionError = '';
      condition = null;
    });

    try {
      final coordinates = await _officeCoordinates(office);

      if (coordinates == null) {
        throw Exception('Could not locate this place.');
      }

      final result = await _fetchCondition(coordinates.lat, coordinates.lon);

      result['name'] = (office['Name'] ?? '').toString();

      result['district'] = (office['District'] ?? '').toString();

      result['state'] = (office['State'] ?? '').toString();

      if (!mounted) return;

      setState(() {
        condition = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        conditionError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          conditionLoading = false;
        });
      }
    }
  }

  String _risk(double rain) {
    if (rain >= 64.5) {
      return 'HIGH';
    }

    if (rain >= 15.6) {
      return 'MEDIUM';
    }

    return 'LOW';
  }

  Color _riskColor(String risk) {
    if (risk == 'HIGH') {
      return Colors.redAccent;
    }

    if (risk == 'MEDIUM') {
      return Colors.orangeAccent;
    }

    return const Color(0xFF5DE0B5);
  }

  String _riskLabel(String risk) {
    if (risk == 'HIGH') {
      return tr('risk_high');
    }

    if (risk == 'MEDIUM') {
      return tr('risk_medium');
    }

    return tr('risk_low');
  }

  String _weatherText(int code) {
    if (code == 0) {
      return tr('weather_clear');
    }

    if (code <= 3) {
      return tr('weather_cloudy');
    }

    if (code == 45 || code == 48) {
      return tr('weather_fog');
    }

    if (code >= 51 && code <= 57) {
      return tr('weather_drizzle');
    }

    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return tr('weather_rain');
    }

    if (code >= 71 && code <= 77) {
      return tr('weather_snow');
    }

    if (code == 95 || code == 96 || code == 99) {
      return tr('weather_thunder');
    }

    return tr('weather_unknown');
  }

  String _soil(dynamic value) {
    if (value == null) return '—';

    return '${(value as num).toDouble().toStringAsFixed(3)} m³/m³';
  }

  Widget _conditionCard() {
    final c = condition!;

    final rain = (c['rain'] as num).toDouble();

    final risk = _risk(rain);

    final riskColor = _riskColor(risk);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF5DE0B5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c['name']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            '${c['district']}, ${c['state']}',
            style: const TextStyle(color: Colors.white60),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: riskColor),
                ),
                child: Text(
                  _riskLabel(risk),
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                '${rain.toStringAsFixed(1)} mm',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          InfoRow(
            regionText('weather_condition'),
            _weatherText((c['weatherCode'] as num).toInt()),
          ),

          InfoRow(
            regionText('temperature'),
            '${(c['temperature'] as num).toDouble().toStringAsFixed(1)} °C',
          ),

          InfoRow(
            regionText('humidity'),
            '${(c['humidity'] as num).toDouble().toStringAsFixed(0)}%',
          ),

          InfoRow(regionText('rain_24h'), '${rain.toStringAsFixed(1)} mm'),

          const SizedBox(height: 12),

          Text(
            regionText('soil_moisture'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          InfoRow(regionText('soil_surface'), _soil(c['soil0'])),

          InfoRow(regionText('soil_shallow'), _soil(c['soil1'])),

          InfoRow(regionText('soil_deeper'), _soil(c['soil3'])),

          const SizedBox(height: 12),

          Text(
            risk == 'HIGH'
                ? tr('assistant_risk_high')
                : risk == 'MEDIUM'
                ? tr('assistant_risk_medium')
                : tr('assistant_risk_low'),
            style: const TextStyle(height: 1.4),
          ),

          const SizedBox(height: 8),

          Text(
            tr('not_probability'),
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(title: tr('pin_area'), subtitle: tr('pin_subtitle')),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: tr('enter_pin'),
                  prefixIcon: const Icon(Icons.pin_drop_outlined),
                ),
              ),

              FilledButton.icon(
                onPressed: loading ? null : search,
                icon: const Icon(Icons.search),
                label: Text(tr('search')),
              ),

              if (loading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(error, textAlign: TextAlign.center),
                ),

              const SizedBox(height: 8),

              ...offices.map((office) {
                final key = _officeKey(office);

                final selected = key == selectedOfficeKey;

                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _showCondition(office),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    office['Name']?.toString() ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),

                            const SizedBox(height: 8),

                            InfoRow(
                              tr('district'),
                              office['District']?.toString() ?? '',
                            ),

                            InfoRow(
                              tr('state'),
                              office['State']?.toString() ?? '',
                            ),

                            InfoRow(
                              tr('post_office'),
                              office['BranchType']?.toString() ?? '',
                            ),

                            const SizedBox(height: 6),

                            Text(
                              regionText('check_condition'),
                              style: const TextStyle(
                                color: Color(0xFF5DE0B5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (selected && conditionLoading)
                      const Padding(
                        padding: EdgeInsets.all(15),
                        child: CircularProgressIndicator(),
                      ),

                    if (selected && conditionError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          conditionError,
                          style: const TextStyle(color: Colors.orangeAccent),
                        ),
                      ),

                    if (selected && condition != null) _conditionCard(),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String connection = '';

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Future<void> checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() {
      connection = result.contains(ConnectivityResult.none)
          ? tr('offline')
          : tr('online');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: tr('language_offline'),
          subtitle: tr('select_language'),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
            children: [
              ...languageNames.entries.map(
                (e) => RadioListTile<String>(
                  value: e.key,
                  groupValue: appController.language,
                  title: Text(e.value),
                  onChanged: (v) async {
                    if (v != null) {
                      await appController.setLanguage(v);
                      setState(() {});
                      await checkConnection();
                    }
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  connection == tr('offline')
                      ? Icons.cloud_off
                      : Icons.cloud_done,
                ),
                title: Text(connection),
                subtitle: connection == tr('offline')
                    ? Text(tr('cached'))
                    : null,
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(tr('profile')),
                subtitle: Text(
                  '${appController.userName} · ${appController.mobile}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(tr('logout')),
                onTap: () async => appController.logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const keywordSets = <String, Map<String, List<String>>>{
  'en': {
    'risk': ['risk', 'landslide', 'danger', 'safe', 'unsafe'],
    'weather': ['weather', 'rain', 'forecast', 'temperature', 'rainfall'],
    'sos': ['sos', '112', 'emergency', 'help me', 'emergency help'],
    'pin': ['pin', 'postal', 'postcode'],
    'location': ['location', 'gps', 'where am i', 'place', 'address'],
    'report': [
      'report',
      'hazard',
      'photo',
      'crack',
      'rockfall',
      'blocked road',
    ],
    'impact': [
      'road',
      'affected',
      'safe road',
      'hospital',
      'school',
      'people affected',
      'route',
      'street',
    ],
    'notification': ['notification', 'alert', 'message', 'sms'],
    'offline': ['offline', 'cached', 'internet', 'network'],
    'language': ['language', 'translate'],
    'app': ['what is this app', 'what can you do', 'geonexa', 'about app'],
    'help': ['help', 'how to use', 'what can i ask'],
  },
  'hi': {
    'risk': ['जोखिम', 'भूस्खलन', 'खतरा', 'सुरक्षित'],
    'weather': ['मौसम', 'बारिश', 'पूर्वानुमान', 'तापमान'],
    'sos': ['आपात', 'मदद', '112'],
    'pin': ['पिन', 'डाक'],
    'location': ['स्थान', 'जीपीएस', 'पता', 'मैं कहाँ'],
    'report': ['रिपोर्ट', 'खतरा', 'फोटो', 'दरार', 'चट्टान'],
    'impact': ['सड़क', 'प्रभावित', 'अस्पताल', 'स्कूल', 'मार्ग'],
    'notification': ['सूचना', 'अलर्ट', 'संदेश', 'एसएमएस'],
    'offline': ['ऑफलाइन', 'कैश', 'इंटरनेट', 'नेटवर्क'],
    'language': ['भाषा', 'अनुवाद'],
    'app': ['ऐप', 'लैंडस्लाइडगार्ड'],
    'help': ['मदद', 'कैसे उपयोग'],
  },
  'kn': {
    'risk': ['ಅಪಾಯ', 'ಭೂಕುಸಿತ', 'ಸುರಕ್ಷಿತ'],
    'weather': ['ಹವಾಮಾನ', 'ಮಳೆ', 'ಮುನ್ಸೂಚನೆ', 'ತಾಪಮಾನ'],
    'sos': ['ತುರ್ತು', 'ಸಹಾಯ', '112'],
    'pin': ['ಪಿನ್'],
    'location': ['ಸ್ಥಳ', 'ಜಿಪಿಎಸ್', 'ವಿಳಾಸ'],
    'report': ['ವರದಿ', 'ಫೋಟೋ', 'ಬಿರುಕು', 'ಕಲ್ಲು'],
    'impact': ['ರಸ್ತೆ', 'ಆಸ್ಪತ್ರೆ', 'ಶಾಲೆ', 'ಮಾರ್ಗ'],
    'notification': ['ನೋಟಿಫಿಕೇಶನ್', 'ಎಚ್ಚರಿಕೆ', 'ಸಂದೇಶ'],
    'offline': ['ಆಫ್‌ಲೈನ್', 'ಇಂಟರ್ನೆಟ್', 'ನೆಟ್‌ವರ್ಕ್'],
    'language': ['ಭಾಷೆ'],
    'app': ['ಆಪ್', 'ಲ್ಯಾಂಡ್‌ಸ್ಲೈಡ್‌ಗಾರ್ಡ್'],
    'help': ['ಸಹಾಯ', 'ಹೇಗೆ ಬಳಸುವುದು'],
  },
  'ta': {
    'risk': ['அபாயம்', 'நிலச்சரிவு', 'பாதுகாப்பு'],
    'weather': ['வானிலை', 'மழை', 'முன்னறிவிப்பு', 'வெப்பநிலை'],
    'sos': ['அவசரம்', 'உதவி', '112'],
    'pin': ['பின்'],
    'location': ['இடம்', 'ஜிபிஎஸ்', 'முகவரி'],
    'report': ['அறிக்கை', 'புகைப்படம்', 'பிளவு', 'பாறை'],
    'impact': ['சாலை', 'மருத்துவமனை', 'பள்ளி', 'வழி'],
    'notification': ['அறிவிப்பு', 'எச்சரிக்கை', 'செய்தி'],
    'offline': ['ஆஃப்லைன்', 'இணையம்', 'நெட்வொர்க்'],
    'language': ['மொழி'],
    'app': ['ஆப்', 'லேண்ட்ஸ்லைட்கார்ட்'],
    'help': ['உதவி', 'எப்படி பயன்படுத்துவது'],
  },
  'te': {
    'risk': ['ప్రమాదం', 'భూస्खలనం', 'సురక్షితం'],
    'weather': ['వాతావరణం', 'వర్షం', 'సూచన', 'ఉష్ణోగ్రత'],
    'sos': ['అత్యవసర', 'సహాయం', '112'],
    'pin': ['పిన్'],
    'location': ['స్థానం', 'జిపిఎస్', 'చిరునామా'],
    'report': ['రిపోర్ట్', 'ఫోటో', 'పగులు', 'రాయి'],
    'impact': ['రోడ్', 'ఆసుపత్రి', 'పాఠశాల', 'మార్గం'],
    'notification': ['నోటిఫికేషన్', 'అలర్ట్', 'సందేశం'],
    'offline': ['ఆఫ్‌లైన్', 'ఇంటర్నెట్', 'నెట్‌వర్క్'],
    'language': ['భాష'],
    'app': ['యాప్', 'ల్యాండ్స్లైడ్‌గార్డ్'],
    'help': ['సహాయం', 'ఎలా ఉపయోగించాలి'],
  },
  'ml': {
    'risk': ['അപകടം', 'മണ്ണിടിച്ചിൽ', 'സുരക്ഷിതം'],
    'weather': ['കാലാവസ്ഥ', 'മഴ', 'പ്രവചനം', 'താപനില'],
    'sos': ['അടിയന്തര', 'സഹായം', '112'],
    'pin': ['പിൻ'],
    'location': ['സ്ഥലം', 'ജിപിഎസ്', 'വിലാസം'],
    'report': ['റിപ്പോർട്ട്', 'ഫോട്ടോ', 'പൊട്ടൽ', 'പാറ'],
    'impact': ['റോഡ്', 'ആശുപത്രി', 'സ്കൂൾ', 'പാത'],
    'notification': ['നോട്ടിഫിക്കേഷൻ', 'അലർട്ട്', 'സന്ദേശം'],
    'offline': ['ഓഫ്‌ലൈൻ', 'ഇന്റർനെറ്റ്', 'നെറ്റ്‌വർക്ക്'],
    'language': ['ഭാഷ'],
    'app': ['ആപ്പ്', 'ലാൻഡ്സ്ലൈഡ്ഗാർഡ്'],
    'help': ['സഹായം', 'എങ്ങനെ ഉപയോഗിക്കാം'],
  },
  'mr': {
    'risk': ['धोका', 'भूस्खलन', 'सुरक्षित'],
    'weather': ['हवामान', 'पाऊस', 'अंदाज', 'तापमान'],
    'sos': ['आपत्कालीन', 'मदत', '112'],
    'pin': ['पिन'],
    'location': ['स्थान', 'जीपीएस', 'पत्ता'],
    'report': ['अहवाल', 'फोटो', 'भेग', 'दगड'],
    'impact': ['रस्ता', 'रुग्णालय', 'शाळा', 'मार्ग'],
    'notification': ['नोटिफिकेशन', 'इशारा', 'संदेश'],
    'offline': ['ऑफलाइन', 'इंटरनेट', 'नेटवर्क'],
    'language': ['भाषा'],
    'app': ['अॅप', 'लँडस्लाइडगार्ड'],
    'help': ['मदत', 'कसे वापरावे'],
  },
  'bn': {
    'risk': ['ঝুঁকি', 'ভূমিধস', 'নিরাপদ'],
    'weather': ['আবহাওয়া', 'বৃষ্টি', 'পূর্বাভাস', 'তাপমাত্রা'],
    'sos': ['জরুরি', 'সাহায্য', '112'],
    'pin': ['পিন'],
    'location': ['অবস্থান', 'জিপিএস', 'ঠিকানা'],
    'report': ['রিপোর্ট', 'ছবি', 'ফাটল', 'পাথর'],
    'impact': ['রাস্তা', 'হাসপাতাল', 'স্কুল', 'পথ'],
    'notification': ['নোটিফিকেশন', 'সতর্কতা', 'বার্তা'],
    'offline': ['অফলাইন', 'ইন্টারনেট', 'নেটওয়ার্ক'],
    'language': ['ভাষা'],
    'app': ['অ্যাপ', 'ল্যান্ডস্লাইডগার্ড'],
    'help': ['সাহায্য', 'কীভাবে ব্যবহার'],
  },
  'as': {
    'risk': ['বিপদ', 'ভূমিস্খলন', 'নিৰাপদ'],
    'weather': ['বতৰ', 'বৰষুণ', 'পূৰ্বানুমান', 'তাপমাত্রা'],
    'sos': ['জৰুৰী', 'সহায়', '112'],
    'pin': ['পিন'],
    'location': ['অৱস্থান', 'জিপিএছ', 'ঠিকনা'],
    'report': ['প্ৰতিবেদন', 'ফটো', 'ফাট', 'শিল'],
    'impact': ['পথ', 'চিকিৎসালয়', 'বিদ্যালয়', 'মাৰ্গ'],
    'notification': ['নোটিফিকেশ্যন', 'সতৰ্কতা', 'বাৰ্তা'],
    'offline': ['অফলাইন', 'ইণ্টাৰনেট', 'নেটৱৰ্ক'],
    'language': ['ভাষা'],
    'app': ['এপ', 'ল্যান্ডস্লাইডগাৰ্ড'],
    'help': ['সহায়', 'কেনেকৈ ব্যৱহাৰ'],
  },
  'ne': {
    'risk': ['जोखिम', 'पहिरो', 'सुरक्षित'],
    'weather': ['मौसम', 'वर्षा', 'पूर्वानुमान', 'तापक्रम'],
    'sos': ['आपतकालीन', 'मद्दत', '112'],
    'pin': ['पिन'],
    'location': ['स्थान', 'जिपिएस', 'ठेगाना'],
    'report': ['रिपोर्ट', 'फोटो', 'चिरा', 'ढुंगा'],
    'impact': ['सडक', 'अस्पताल', 'विद्यालय', 'बाटो'],
    'notification': ['नोटिफिकेशन', 'चेतावनी', 'सन्देश'],
    'offline': ['अफलाइन', 'इन्टरनेट', 'नेटवर्क'],
    'language': ['भाषा'],
    'app': ['एप', 'ल्यान्डस्लाइडगार्ड'],
    'help': ['मद्दत', 'कसरी प्रयोग'],
  },
};

const assistantControlI18n = <String, Map<String, String>>{
  'en': {
    'start_listening': 'Start Listening',
    'stop_listening': 'Stop Listening',
    'stop_voice': 'Stop Voice',
    'analyze_answer': 'Analyze / Answer',
    'voice_stopped': 'Voice stopped.',
    'listening_stopped': 'Listening stopped.',
    'assistant_hint':
        'Ask about current risk, rain, GPS, reports, alerts, roads, SOS, offline data or how to use the app.',
  },
  'hi': {
    'start_listening': 'सुनना शुरू करें',
    'stop_listening': 'सुनना बंद करें',
    'stop_voice': 'आवाज़ बंद करें',
    'analyze_answer': 'विश्लेषण / उत्तर',
    'voice_stopped': 'आवाज़ बंद कर दी गई।',
    'listening_stopped': 'सुनना बंद कर दिया गया।',
    'assistant_hint':
        'वर्तमान जोखिम, बारिश, GPS, रिपोर्ट, अलर्ट, सड़क, SOS, ऑफलाइन डेटा या ऐप उपयोग के बारे में पूछें।',
  },
  'kn': {
    'start_listening': 'ಕೇಳಲು ಪ್ರಾರಂಭಿಸಿ',
    'stop_listening': 'ಕೇಳುವುದನ್ನು ನಿಲ್ಲಿಸಿ',
    'stop_voice': 'ಧ್ವನಿ ನಿಲ್ಲಿಸಿ',
    'analyze_answer': 'ವಿಶ್ಲೇಷಿಸಿ / ಉತ್ತರಿಸಿ',
    'voice_stopped': 'ಧ್ವನಿ ನಿಲ್ಲಿಸಲಾಗಿದೆ.',
    'listening_stopped': 'ಕೇಳುವುದನ್ನು ನಿಲ್ಲಿಸಲಾಗಿದೆ.',
    'assistant_hint':
        'ಪ್ರಸ್ತುತ ಅಪಾಯ, ಮಳೆ, GPS, ವರದಿ, ಎಚ್ಚರಿಕೆ, ರಸ್ತೆ, SOS, ಆಫ್‌ಲೈನ್ ಡೇಟಾ ಅಥವಾ ಆಪ್ ಬಳಕೆ ಬಗ್ಗೆ ಕೇಳಿ.',
  },
  'ta': {
    'start_listening': 'கேட்கத் தொடங்கு',
    'stop_listening': 'கேட்பதை நிறுத்து',
    'stop_voice': 'குரலை நிறுத்து',
    'analyze_answer': 'பகுப்பாய்வு / பதில்',
    'voice_stopped': 'குரல் நிறுத்தப்பட்டது.',
    'listening_stopped': 'கேட்பது நிறுத்தப்பட்டது.',
    'assistant_hint':
        'தற்போதைய அபாயம், மழை, GPS, அறிக்கை, எச்சரிக்கை, சாலை, SOS, ஆஃப்லைன் தரவு அல்லது பயன்பாட்டைப் பற்றி கேளுங்கள்.',
  },
  'te': {
    'start_listening': 'వినడం ప్రారంభించు',
    'stop_listening': 'వినడం ఆపు',
    'stop_voice': 'వాయిస్ ఆపు',
    'analyze_answer': 'విశ్లేషించు / సమాధానం',
    'voice_stopped': 'వాయిస్ ఆపబడింది.',
    'listening_stopped': 'వినడం ఆపబడింది.',
    'assistant_hint':
        'ప్రస్తుత ప్రమాదం, వర్షం, GPS, రిపోర్ట్, అలర్ట్, రోడ్లు, SOS, ఆఫ్‌లైన్ డేటా లేదా యాప్ వినియోగం గురించి అడగండి.',
  },
  'ml': {
    'start_listening': 'കേൾക്കാൻ തുടങ്ങുക',
    'stop_listening': 'കേൾക്കുന്നത് നിർത്തുക',
    'stop_voice': 'ശബ്ദം നിർത്തുക',
    'analyze_answer': 'വിശകലനം / മറുപടി',
    'voice_stopped': 'ശബ്ദം നിർത്തി.',
    'listening_stopped': 'കേൾക്കുന്നത് നിർത്തി.',
    'assistant_hint':
        'നിലവിലെ അപകടം, മഴ, GPS, റിപ്പോർട്ട്, അലർട്ട്, റോഡ്, SOS, ഓഫ്‌ലൈൻ ഡാറ്റ അല്ലെങ്കിൽ ആപ്പ് ഉപയോഗം കുറിച്ച് ചോദിക്കുക.',
  },
  'mr': {
    'start_listening': 'ऐकणे सुरू करा',
    'stop_listening': 'ऐकणे थांबवा',
    'stop_voice': 'आवाज थांबवा',
    'analyze_answer': 'विश्लेषण / उत्तर',
    'voice_stopped': 'आवाज थांबवला.',
    'listening_stopped': 'ऐकणे थांबवले.',
    'assistant_hint':
        'सध्याचा धोका, पाऊस, GPS, अहवाल, इशारे, रस्ते, SOS, ऑफलाइन डेटा किंवा अॅप वापर याबद्दल विचारा.',
  },
  'bn': {
    'start_listening': 'শোনা শুরু করুন',
    'stop_listening': 'শোনা বন্ধ করুন',
    'stop_voice': 'ভয়েস বন্ধ করুন',
    'analyze_answer': 'বিশ্লেষণ / উত্তর',
    'voice_stopped': 'ভয়েস বন্ধ হয়েছে।',
    'listening_stopped': 'শোনা বন্ধ হয়েছে।',
    'assistant_hint':
        'বর্তমান ঝুঁকি, বৃষ্টি, GPS, রিপোর্ট, সতর্কতা, রাস্তা, SOS, অফলাইন ডেটা বা অ্যাপ ব্যবহারের বিষয়ে জিজ্ঞাসা করুন।',
  },
  'as': {
    'start_listening': 'শুনা আৰম্ভ কৰক',
    'stop_listening': 'শুনা বন্ধ কৰক',
    'stop_voice': 'ভইচ বন্ধ কৰক',
    'analyze_answer': 'বিশ্লেষণ / উত্তৰ',
    'voice_stopped': 'ভইচ বন্ধ কৰা হৈছে।',
    'listening_stopped': 'শুনা বন্ধ কৰা হৈছে।',
    'assistant_hint':
        'বৰ্তমান বিপদ, বৰষুণ, GPS, প্ৰতিবেদন, সতৰ্কতা, পথ, SOS, অফলাইন ডাটা বা এপ ব্যৱহাৰ বিষয়ে সোধক.',
  },
  'ne': {
    'start_listening': 'सुन्न सुरु गर्नुहोस्',
    'stop_listening': 'सुन्न रोक्नुहोस्',
    'stop_voice': 'आवाज रोक्नुहोस्',
    'analyze_answer': 'विश्लेषण / उत्तर',
    'voice_stopped': 'आवाज रोकियो।',
    'listening_stopped': 'सुन्न रोकियो।',
    'assistant_hint':
        'हालको जोखिम, वर्षा, GPS, रिपोर्ट, चेतावनी, सडक, SOS, अफलाइन डेटा वा एप प्रयोगबारे सोध्नुहोस्।',
  },
};

String assistantText(String key) =>
    assistantControlI18n[appController.language]?[key] ??
    assistantControlI18n['en']![key] ??
    key;

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();
  final TextEditingController input = TextEditingController();

  String answer = '';
  String voiceStatus = '';
  bool listening = false;
  bool speaking = false;
  bool working = false;
  String lastLanguage = '';

  @override
  void initState() {
    super.initState();
    lastLanguage = appController.language;
    answer = tr('assistant_default');
    appController.addListener(_languageChanged);

    tts.setStartHandler(() {
      if (mounted) setState(() => speaking = true);
    });
    tts.setCompletionHandler(() {
      if (mounted) setState(() => speaking = false);
    });
    tts.setCancelHandler(() {
      if (mounted) setState(() => speaking = false);
    });
    tts.setErrorHandler((_) {
      if (mounted) setState(() => speaking = false);
    });
  }

  void _languageChanged() {
    if (lastLanguage == appController.language) {
      if (mounted) setState(() {});
      return;
    }
    lastLanguage = appController.language;
    unawaited(speech.stop());
    unawaited(tts.stop());
    if (mounted) {
      setState(() {
        listening = false;
        speaking = false;
        working = false;
        voiceStatus = '';
        answer = tr('assistant_default');
      });
    }
  }

  @override
  void dispose() {
    appController.removeListener(_languageChanged);
    speech.stop();
    tts.stop();
    input.dispose();
    super.dispose();
  }

  bool matches(String q, String category) {
    final lower = q.toLowerCase();
    final local = keywordSets[appController.language]?[category] ?? const [];
    final english = keywordSets['en']?[category] ?? const [];
    return [...local, ...english].any((k) => lower.contains(k.toLowerCase()));
  }

  Future<WeatherData?> _savedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('weather_cache');
    if (raw == null) return null;
    try {
      return WeatherData.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw)),
        cached: true,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> reply(String q) async {
    final prefs = await SharedPreferences.getInstance();
    final weather = await _savedWeather();
    final rain = weather?.next24Rain ?? 0.0;

    if (matches(q, 'risk')) {
      final riskText = rain >= 64.5
          ? tr('assistant_risk_high')
          : rain >= 15.6
          ? tr('assistant_risk_medium')
          : tr('assistant_risk_low');
      return '$riskText ${tr('next24rain')}: ${rain.toStringAsFixed(1)} mm. '
          '${tr('not_probability')}';
    }

    if (matches(q, 'weather')) {
      if (weather == null) return tr('assistant_weather');
      final chance = weather.dailyProb.isNotEmpty
          ? weather.dailyProb.first.toStringAsFixed(0)
          : '';
      final todayRain = weather.dailyRain.isNotEmpty
          ? weather.dailyRain.first.toStringAsFixed(1)
          : '';
      final parts = <String>[
        '${tr('next24rain')}: ${weather.next24Rain.toStringAsFixed(1)} mm',
        if (todayRain.isNotEmpty) '${tr('today')} ${tr('rain')}: $todayRain mm',
        if (chance.isNotEmpty) '${tr('rain_chance')}: $chance%',
        tr('cached'),
      ];
      return '${parts.join('. ')}.';
    }

    if (matches(q, 'location')) {
      final place = prefs.getString('last_place_name') ?? '';
      final lat = prefs.getDouble('last_latitude');
      final lon = prefs.getDouble('last_longitude');
      if (place.isEmpty && (lat == null || lon == null)) {
        return tr('no_location');
      }
      final coords = lat != null && lon != null
          ? ' (${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)})'
          : '';
      return '${tr('assistant_location')} '
          '${place.isNotEmpty ? place : ''}$coords';
    }

    if (matches(q, 'sos')) {
      return alertUiText('sos_help');
    }

    if (matches(q, 'pin')) {
      return tr('assistant_pin');
    }

    if (matches(q, 'report')) {
      return '${tr('report_subtitle')} ${tr('screening_note')} '
          '${tr('photo_evidence')}: ${tr('take_photo')} / ${tr('choose_photo')}.';
    }

    if (matches(q, 'impact')) {
      return '${tr('assistant_impact')} ${tr('impact_truth')}';
    }

    if (matches(q, 'notification')) {
      return '${tr('notification_free_note')} ${tr('stage1_active')}';
    }

    if (matches(q, 'offline')) {
      return '${tr('offline')}: ${tr('cached')}';
    }

    if (matches(q, 'language')) {
      final languageName =
          languageNames[appController.language] ?? appController.language;
      return '${tr('language')}: $languageName. ${tr('select_language')}.';
    }

    if (matches(q, 'app')) {
      return '${tr('app')} — ${tr('tagline')}. '
          '${tr('risk_monitor')}, ${tr('seven_day')}, '
          '${tr('report_hazard')}, ${tr('pin_area')}, '
          '${tr('assistant')} & ${tr('sos')}.';
    }

    if (matches(q, 'help')) {
      return '${tr('assistant_default')} ${assistantText('assistant_hint')}';
    }

    return tr('assistant_unknown');
  }

  Future<void> speakAnswer(String value) async {
    final lang = localeIds[appController.language] ?? 'en_IN';
    try {
      await tts.stop();
      await tts.setLanguage(lang);
      await tts.setSpeechRate(0.48);
      await tts.setVolume(1.0);
      await tts.speak(value);
    } catch (_) {
      if (mounted) setState(() => speaking = false);
    }
  }

  Future<void> ask() async {
    final q = input.text.trim();
    if (q.isEmpty || working) return;

    if (listening) {
      try {
        await speech.stop();
      } catch (_) {}
    }
    try {
      await tts.stop();
    } catch (_) {}

    if (mounted) {
      setState(() {
        listening = false;
        speaking = false;
        working = true;
        voiceStatus = '';
      });
    }

    final a = await reply(q);
    if (!mounted) return;
    setState(() {
      answer = a;
      working = false;
    });
    await speakAnswer(a);
  }

  Future<String?> bestSpeechLocale() async {
    final preferred = localeIds[appController.language] ?? 'en_IN';
    try {
      final locales = await speech.locales();
      for (final l in locales) {
        if (l.localeId == preferred) return l.localeId;
      }
      final prefix = appController.language.toLowerCase();
      for (final l in locales) {
        if (l.localeId.toLowerCase().startsWith(prefix)) {
          return l.localeId;
        }
      }
    } catch (_) {}
    return preferred;
  }

  Future<void> listen() async {
    if (listening) return;

    try {
      await tts.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        speaking = false;
        voiceStatus = tr('mic_listening');
      });
    }

    bool available = false;
    try {
      available = await speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          setState(() {
            listening = status == stt.SpeechToText.listeningStatus;
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            listening = false;
            voiceStatus = '${tr('mic_error')} ${error.errorMsg}';
          });
        },
        options: [
          stt.SpeechToText.androidNoBluetooth,
          stt.SpeechToText.androidIntentLookup,
        ],
      );
    } catch (_) {
      available = false;
    }

    if (!available) {
      if (mounted) {
        setState(() {
          listening = false;
          voiceStatus = tr('mic_unavailable');
        });
      }
      return;
    }

    final locale = await bestSpeechLocale();
    try {
      await speech.listen(
        onResult: (result) {
          input.text = result.recognizedWords;
          input.selection = TextSelection.fromPosition(
            TextPosition(offset: input.text.length),
          );

          if (result.finalResult) {
            if (mounted) {
              setState(() {
                listening = false;
                voiceStatus = '';
              });
            }
            unawaited(ask());
          }
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: locale,
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
          cancelOnError: false,
          pauseFor: const Duration(seconds: 4),
          listenFor: const Duration(seconds: 30),
        ),
      );

      if (mounted) {
        setState(() {
          listening = true;
          voiceStatus = tr('mic_listening');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          listening = false;
          voiceStatus = '${tr('mic_error')} $e';
        });
      }
    }
  }

  Future<void> stopListening() async {
    try {
      await speech.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        listening = false;
        voiceStatus = assistantText('listening_stopped');
      });
    }
  }

  Future<void> stopVoice() async {
    try {
      await tts.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        speaking = false;
        voiceStatus = assistantText('voice_stopped');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(title: tr('assistant'), subtitle: tr('assistant_subtitle')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.smart_toy, color: Color(0xFF5DE0B5)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tr('assistant'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (speaking)
                          const Icon(
                            Icons.volume_up,
                            color: Color(0xFF5DE0B5),
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      answer,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      assistantText('assistant_hint'),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    if (voiceStatus.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        voiceStatus,
                        style: TextStyle(
                          color: listening
                              ? const Color(0xFF5DE0B5)
                              : Colors.orangeAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: input,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: tr('ask'),
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                ),
                onSubmitted: (_) => ask(),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: listening ? null : listen,
                    icon: const Icon(Icons.mic),
                    label: Text(assistantText('start_listening')),
                  ),
                  OutlinedButton.icon(
                    onPressed: listening ? stopListening : null,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: Text(assistantText('stop_listening')),
                  ),
                  OutlinedButton.icon(
                    onPressed: speaking ? stopVoice : null,
                    icon: const Icon(Icons.volume_off_outlined),
                    label: Text(assistantText('stop_voice')),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: working ? null : ask,
                  icon: working
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.psychology),
                  label: Text(assistantText('analyze_answer')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
