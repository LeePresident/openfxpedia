import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Map<String, String> _regionCountryCodes = {
  'Hong Kong': 'HK',
  'Macau': 'MO',
  'Macao': 'MO',
  'United States': 'US',
  'United Kingdom': 'GB',
  'South Korea': 'KR',
  'North Korea': 'KP',
  'Russia': 'RU',
  'Czech Republic': 'CZ',
  'Ivory Coast': 'CI',
  'Côte d’Ivoire': 'CI',
  'Côte d\'Ivoire': 'CI',
  'Laos': 'LA',
  'Vietnam': 'VN',
  'Moldova': 'MD',
  'Palestine': 'PS',
  'Taiwan': 'TW',
  'Tanzania': 'TZ',
  'Venezuela': 'VE',
  'Bolivia': 'BO',
  'Brunei': 'BN',
  'Cape Verde': 'CV',
  'Comoros': 'KM',
  'Congo': 'CG',
  'Democratic Republic of the Congo': 'CD',
  'East Timor': 'TL',
  'Eswatini': 'SZ',
  'Iran': 'IR',
  'Macedonia': 'MK',
  'Micronesia': 'FM',
  'Moldova, Republic of': 'MD',
  'Saint Kitts and Nevis': 'KN',
  'Saint Lucia': 'LC',
  'Saint Vincent and the Grenadines': 'VC',
  'Sao Tome and Principe': 'ST',
  'São Tomé and Príncipe': 'ST',
  'Syria': 'SY',
  'Türkiye': 'TR',
  'Turkey': 'TR',
  'Vatican City': 'VA',
  'Western Sahara': 'EH',
  'American Samoa': 'AS',
  'Aruba': 'AW',
  'Ascension Island': 'AC',
  'Bonaire, Sint Eustatius and Saba (The Caribbean Netherlands)': 'BQ',
  'Bouvet Island': 'BV',
  'Faroe Islands': 'FO',
  'Greenland': 'GL',
  'Latvia': 'LV',
  'North Macedonia': 'MK',
  'Republic of the Congo': 'CG',
  'Saint Helena': 'SH',
  'Sierra Leone': 'SL',
  'Timor-Leste': 'TL',
  'Tristan da Cunha': 'SH',
  'Turkey/Türkiye': 'TR',
  'Åland Islands': 'AX',
  'Anguilla': 'AI',
  'Bermuda': 'BM',
  'British Indian Ocean Territory': 'IO',
  'British Virgin Islands': 'VG',
  'Cayman Islands': 'KY',
  'Christmas Island': 'CX',
  'Cocos (Keeling) Islands': 'CC',
  'Cook Islands': 'CK',
  'Curaçao': 'CW',
  'Falkland Islands': 'FK',
  'French Polynesia': 'PF',
  'Gibraltar': 'GI',
  'Guam': 'GU',
  'Guernsey': 'GG',
  'Heard Island and McDonald Islands': 'HM',
  'Holy See': 'VA',
  'Isle of Man': 'IM',
  'Jersey': 'JE',
  'Kosovo': 'XK',
  'Montserrat': 'MS',
  'New Caledonia': 'NC',
  'Niue': 'NU',
  'Norfolk Island': 'NF',
  'Northern Mariana Islands': 'MP',
  'Pitcairn Islands': 'PN',
  'Puerto Rico': 'PR',
  'Sint Maarten': 'SX',
  'Svalbard and Jan Mayen': 'SJ',
  'Tokelau': 'TK',
  'United States Minor Outlying Islands': 'UM',
  'United States Virgin Islands': 'VI',
  'Wallis and Futuna': 'WF',
};

const Map<String, String> _currencyFlagCodes = {
  'EUR': 'EU',
};

const Set<String> _originalCurrencyIconCodes = {
  'XAF',
  'XCD',
  'XCG',
  'XOF',
  'XPF',
};

String? currencyFlagCode(String currencyCode) =>
    _currencyFlagCodes[currencyCode.toUpperCase()];

String? regionCountryCode(String region) {
  final baseName = region.split(' (').first.trim();
  return _regionCountryCodes[region] ??
      _regionCountryCodes[baseName] ??
      _countryCodeByCommonName[baseName];
}

Widget buildRegionFlag(String region, {String? regionCode}) {
  final code = regionCode ?? regionCountryCode(region);
  if (code == null) return const SizedBox(width: 24);

  return Padding(
    padding: const EdgeInsets.only(top: 2),
    child: SizedBox(
      width: 24,
      height: 16,
      child: CountryFlag.fromCountryCode(code),
    ),
  );
}

Widget buildCurrencyFlag({
  required String currencyCode,
  required List<String> regions,
  required List<String?> regionCodes,
  double width = 40,
  double height = 40,
}) {
  final normalizedCurrencyCode = currencyCode.toUpperCase();
  if (_originalCurrencyIconCodes.contains(normalizedCurrencyCode)) {
    return ClipOval(
      child: SvgPicture.asset(
        'assets/icons/${currencyCode.toLowerCase()}.svg',
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  final overrideCode = currencyFlagCode(currencyCode);
  if (overrideCode != null) {
    final flag = normalizedCurrencyCode == 'EUR'
        ? CountryFlag.fromCurrencyCode(
            currencyCode,
            theme: ImageTheme(
              width: width,
              height: height,
              shape: const Circle(),
            ),
          )
        : CountryFlag.fromCountryCode(
            overrideCode,
            theme: ImageTheme(
              width: width,
              height: height,
              shape: const Circle(),
            ),
          );
    return flag;
  }

  String? regionFlagCode;
  for (var index = 0; index < regions.length; index++) {
    final candidate = index < regionCodes.length
        ? regionCodes[index]
        : regionCountryCode(regions[index]);
    if (candidate != null && candidate.isNotEmpty) {
      regionFlagCode = candidate;
      break;
    }
  }

  if (regionFlagCode == null) {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(child: Icon(Icons.public, size: 20)),
    );
  }

  return CountryFlag.fromCountryCode(
    regionFlagCode,
    theme: ImageTheme(
      width: width,
      height: height,
      shape: const Circle(),
    ),
  );
}

const Map<String, String> _countryCodeByCommonName = {
  'Afghanistan': 'AF',
  'Albania': 'AL',
  'Algeria': 'DZ',
  'Andorra': 'AD',
  'Angola': 'AO',
  'Antigua and Barbuda': 'AG',
  'Argentina': 'AR',
  'Armenia': 'AM',
  'Australia': 'AU',
  'Austria': 'AT',
  'Azerbaijan': 'AZ',
  'Bahamas': 'BS',
  'Bahrain': 'BH',
  'Bangladesh': 'BD',
  'Barbados': 'BB',
  'Belarus': 'BY',
  'Belgium': 'BE',
  'Belize': 'BZ',
  'Benin': 'BJ',
  'Bhutan': 'BT',
  'Bosnia and Herzegovina': 'BA',
  'Botswana': 'BW',
  'Brazil': 'BR',
  'Bulgaria': 'BG',
  'Burkina Faso': 'BF',
  'Burundi': 'BI',
  'Cambodia': 'KH',
  'Cameroon': 'CM',
  'Canada': 'CA',
  'Central African Republic': 'CF',
  'Chad': 'TD',
  'Chile': 'CL',
  'China': 'CN',
  'Colombia': 'CO',
  'Costa Rica': 'CR',
  'Croatia': 'HR',
  'Cuba': 'CU',
  'Cyprus': 'CY',
  'Denmark': 'DK',
  'Djibouti': 'DJ',
  'Dominica': 'DM',
  'Dominican Republic': 'DO',
  'Ecuador': 'EC',
  'Egypt': 'EG',
  'El Salvador': 'SV',
  'Equatorial Guinea': 'GQ',
  'Eritrea': 'ER',
  'Estonia': 'EE',
  'Ethiopia': 'ET',
  'Fiji': 'FJ',
  'Finland': 'FI',
  'France': 'FR',
  'Gabon': 'GA',
  'Gambia': 'GM',
  'Georgia': 'GE',
  'Germany': 'DE',
  'Ghana': 'GH',
  'Greece': 'GR',
  'Grenada': 'GD',
  'Guatemala': 'GT',
  'Guinea': 'GN',
  'Guinea-Bissau': 'GW',
  'Guyana': 'GY',
  'Haiti': 'HT',
  'Honduras': 'HN',
  'Hungary': 'HU',
  'Iceland': 'IS',
  'India': 'IN',
  'Indonesia': 'ID',
  'Iraq': 'IQ',
  'Ireland': 'IE',
  'Israel': 'IL',
  'Italy': 'IT',
  'Jamaica': 'JM',
  'Japan': 'JP',
  'Jordan': 'JO',
  'Kazakhstan': 'KZ',
  'Kenya': 'KE',
  'Kiribati': 'KI',
  'Kuwait': 'KW',
  'Kyrgyzstan': 'KG',
  'Lebanon': 'LB',
  'Lesotho': 'LS',
  'Liberia': 'LR',
  'Libya': 'LY',
  'Liechtenstein': 'LI',
  'Lithuania': 'LT',
  'Luxembourg': 'LU',
  'Madagascar': 'MG',
  'Malawi': 'MW',
  'Malaysia': 'MY',
  'Maldives': 'MV',
  'Mali': 'ML',
  'Malta': 'MT',
  'Marshall Islands': 'MH',
  'Mauritania': 'MR',
  'Mauritius': 'MU',
  'Mexico': 'MX',
  'Monaco': 'MC',
  'Mongolia': 'MN',
  'Montenegro': 'ME',
  'Morocco': 'MA',
  'Mozambique': 'MZ',
  'Myanmar': 'MM',
  'Namibia': 'NA',
  'Nauru': 'NR',
  'Nepal': 'NP',
  'Netherlands': 'NL',
  'New Zealand': 'NZ',
  'Nicaragua': 'NI',
  'Niger': 'NE',
  'Nigeria': 'NG',
  'Norway': 'NO',
  'Oman': 'OM',
  'Pakistan': 'PK',
  'Palau': 'PW',
  'Panama': 'PA',
  'Papua New Guinea': 'PG',
  'Paraguay': 'PY',
  'Peru': 'PE',
  'Philippines': 'PH',
  'Poland': 'PL',
  'Portugal': 'PT',
  'Qatar': 'QA',
  'Romania': 'RO',
  'Rwanda': 'RW',
  'Samoa': 'WS',
  'San Marino': 'SM',
  'Saudi Arabia': 'SA',
  'Senegal': 'SN',
  'Serbia': 'RS',
  'Seychelles': 'SC',
  'Singapore': 'SG',
  'Slovakia': 'SK',
  'Slovenia': 'SI',
  'Solomon Islands': 'SB',
  'Somalia': 'SO',
  'South Africa': 'ZA',
  'South Sudan': 'SS',
  'Spain': 'ES',
  'Sri Lanka': 'LK',
  'Sudan': 'SD',
  'Suriname': 'SR',
  'Sweden': 'SE',
  'Switzerland': 'CH',
  'Tajikistan': 'TJ',
  'Thailand': 'TH',
  'Togo': 'TG',
  'Tonga': 'TO',
  'Trinidad and Tobago': 'TT',
  'Tunisia': 'TN',
  'Turkmenistan': 'TM',
  'Tuvalu': 'TV',
  'Uganda': 'UG',
  'Ukraine': 'UA',
  'United Arab Emirates': 'AE',
  'Uruguay': 'UY',
  'Uzbekistan': 'UZ',
  'Vanuatu': 'VU',
  'Yemen': 'YE',
  'Zambia': 'ZM',
  'Zimbabwe': 'ZW',
};
