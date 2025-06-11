import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addKanaData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List of Kana characters with their information (Gojuon)
  List<Map<String, dynamic>> kanaData = [
    // A-series (already added)
    {
      'character': 'a',
      'hiragana': 'あ',
      'katakana': 'ア',
      'pronunciation': 'a',
      'imageUrlHiragana': 'https://i.imgur.com/rbr2vBQ.png',
      'imageUrlKatakana': 'https://i.imgur.com/w3EJhxO.png',
    },
    {
      'character': 'i',
      'hiragana': 'い',
      'katakana': 'イ',
      'pronunciation': 'i',
      'imageUrlHiragana': 'https://i.imgur.com/ktQf8Oe.png',
      'imageUrlKatakana': 'https://i.imgur.com/m75JK3I.png',
    },
    {
      'character': 'u',
      'hiragana': 'う',
      'katakana': 'ウ',
      'pronunciation': 'u',
      'imageUrlHiragana': 'https://i.imgur.com/l8xEdT6.png',
      'imageUrlKatakana': 'https://i.imgur.com/QkDSHm6.png',
    },
    {
      'character': 'e',
      'hiragana': 'え',
      'katakana': 'エ',
      'pronunciation': 'e',
      'imageUrlHiragana': 'https://i.imgur.com/3TmDUsh.png',
      'imageUrlKatakana': 'https://i.imgur.com/9khXeH0.png',
    },
    {
      'character': 'o',
      'hiragana': 'お',
      'katakana': 'オ',
      'pronunciation': 'o',
      'imageUrlHiragana': 'https://i.imgur.com/nYxDzSu.png',
      'imageUrlKatakana': 'https://i.imgur.com/u2FVEYk.png',
    },

    // K-series
    {
      'character': 'ka',
      'hiragana': 'か',
      'katakana': 'カ',
      'pronunciation': 'ka',
      'imageUrlHiragana': 'https://i.imgur.com/FqgJ1WZ.png',
      'imageUrlKatakana': 'https://i.imgur.com/TOS2VuR.png',
    },
    {
      'character': 'ki',
      'hiragana': 'き',
      'katakana': 'キ',
      'pronunciation': 'ki',
      'imageUrlHiragana': 'https://i.imgur.com/WrukAqd.png',
      'imageUrlKatakana': 'https://i.imgur.com/B8j2IFe.png',
    },
    {
      'character': 'ku',
      'hiragana': 'く',
      'katakana': 'ク',
      'pronunciation': 'ku',
      'imageUrlHiragana': 'https://i.imgur.com/iQw7h37.png',
      'imageUrlKatakana': 'https://i.imgur.com/E97Pgv7.png',
    },
    {
      'character': 'ke',
      'hiragana': 'け',
      'katakana': 'ケ',
      'pronunciation': 'ke',
      'imageUrlHiragana': 'https://i.imgur.com/MzZTsFE.png',
      'imageUrlKatakana': 'https://i.imgur.com/xConAOR.png',
    },
    {
      'character': 'ko',
      'hiragana': 'こ',
      'katakana': 'コ',
      'pronunciation': 'ko',
      'imageUrlHiragana': 'https://i.imgur.com/OZYxTkW.png',
      'imageUrlKatakana': 'https://i.imgur.com/DzeLNBz.png',
    },

    // S-series
    {
      'character': 'sa',
      'hiragana': 'さ',
      'katakana': 'サ',
      'pronunciation': 'sa',
      'imageUrlHiragana': 'https://i.imgur.com/ArE81qn.png',
      'imageUrlKatakana': 'https://i.imgur.com/WSF839A.png',
    },
    {
      'character': 'shi',
      'hiragana': 'し',
      'katakana': 'シ',
      'pronunciation': 'shi',
      'imageUrlHiragana': 'https://i.imgur.com/wqRyBo0.png',
      'imageUrlKatakana': 'https://i.imgur.com/MU7mYej.png',
    },
    {
      'character': 'su',
      'hiragana': 'す',
      'katakana': 'ス',
      'pronunciation': 'su',
      'imageUrlHiragana': 'https://i.imgur.com/kmJkclu.png',
      'imageUrlKatakana': 'https://i.imgur.com/DfM3g2R.png',
    },
    {
      'character': 'se',
      'hiragana': 'せ',
      'katakana': 'セ',
      'pronunciation': 'se',
      'imageUrlHiragana': 'https://i.imgur.com/Hmwqggw.png',
      'imageUrlKatakana': 'https://i.imgur.com/VOIwp8r.png',
    },
    {
      'character': 'so',
      'hiragana': 'そ',
      'katakana': 'ソ',
      'pronunciation': 'so',
      'imageUrlHiragana': 'https://i.imgur.com/NADRjEr.png',
      'imageUrlKatakana': 'https://i.imgur.com/PgdslpW.png',
    },

    // T-series
    {
      'character': 'ta',
      'hiragana': 'た',
      'katakana': 'タ',
      'pronunciation': 'ta',
      'imageUrlHiragana': 'https://i.imgur.com/MYAu9rX.png',
      'imageUrlKatakana': 'https://i.imgur.com/tvyfV6G.png',
    },
    {
      'character': 'chi',
      'hiragana': 'ち',
      'katakana': 'チ',
      'pronunciation': 'chi',
      'imageUrlHiragana': 'https://i.imgur.com/3C16WTO.png',
      'imageUrlKatakana': 'https://i.imgur.com/pnTVFk8.png',
    },
    {
      'character': 'tsu',
      'hiragana': 'つ',
      'katakana': 'ツ',
      'pronunciation': 'tsu',
      'imageUrlHiragana': 'https://i.imgur.com/uNvHVFs.png',
      'imageUrlKatakana': 'https://i.imgur.com/mW9qIKx.png',
    },
    {
      'character': 'te',
      'hiragana': 'て',
      'katakana': 'テ',
      'pronunciation': 'te',
      'imageUrlHiragana': 'https://i.imgur.com/5ER3rPa.png',
      'imageUrlKatakana': 'https://i.imgur.com/Q2498NL.png',
    },
    {
      'character': 'to',
      'hiragana': 'と',
      'katakana': 'ト',
      'pronunciation': 'to',
      'imageUrlHiragana': 'https://i.imgur.com/v6DuEMc.png',
      'imageUrlKatakana': 'https://i.imgur.com/k23Ax7t.png',
    },

    // N-series
    {
      'character': 'na',
      'hiragana': 'な',
      'katakana': 'ナ',
      'pronunciation': 'na',
      'imageUrlHiragana': 'https://i.imgur.com/Sq6ccQw.png',
      'imageUrlKatakana': 'https://i.imgur.com/4qdg03p.png',
    },
    {
      'character': 'ni',
      'hiragana': 'に',
      'katakana': 'ニ',
      'pronunciation': 'ni',
      'imageUrlHiragana': 'https://i.imgur.com/4zUIbc0.png',
      'imageUrlKatakana': 'https://i.imgur.com/pp5kUnV.png',
    },
    {
      'character': 'nu',
      'hiragana': 'ぬ',
      'katakana': 'ヌ',
      'pronunciation': 'nu',
      'imageUrlHiragana': 'https://i.imgur.com/LN95v0Q.png',
      'imageUrlKatakana': 'https://i.imgur.com/thZ7p7e.png',
    },
    {
      'character': 'ne',
      'hiragana': 'ね',
      'katakana': 'ネ',
      'pronunciation': 'ne',
      'imageUrlHiragana': 'https://i.imgur.com/tZ3GAry.png',
      'imageUrlKatakana': 'https://i.imgur.com/kJFuxpQ.png',
    },
    {
      'character': 'no',
      'hiragana': 'の',
      'katakana': 'ノ',
      'pronunciation': 'no',
      'imageUrlHiragana': 'https://i.imgur.com/v6DuEMc.png',
      'imageUrlKatakana': 'https://i.imgur.com/a8qANdz.png',
    },

    // H-series
    {
      'character': 'ha',
      'hiragana': 'は',
      'katakana': 'ハ',
      'pronunciation': 'ha',
      'imageUrlHiragana': 'https://i.imgur.com/Nx2hm3l.png',
      'imageUrlKatakana': 'https://i.imgur.com/mXuIWDx.png',
    },
    {
      'character': 'hi',
      'hiragana': 'ひ',
      'katakana': 'ヒ',
      'pronunciation': 'hi',
      'imageUrlHiragana': 'https://i.imgur.com/CbVMNiK.png',
      'imageUrlKatakana': 'https://i.imgur.com/R47fp2y.png',
    },
    {
      'character': 'fu',
      'hiragana': 'ふ',
      'katakana': 'フ',
      'pronunciation': 'fu',
      'imageUrlHiragana': 'https://i.imgur.com/IE0sP8r.png',
      'imageUrlKatakana': 'https://i.imgur.com/N0fLd27.png',
    },
    {
      'character': 'he',
      'hiragana': 'へ',
      'katakana': 'ヘ',
      'pronunciation': 'he',
      'imageUrlHiragana': 'https://i.imgur.com/GS1MzZE.png',
      'imageUrlKatakana': 'https://i.imgur.com/kaBdjpp.png',
    },
    {
      'character': 'ho',
      'hiragana': 'ほ',
      'katakana': 'ホ',
      'pronunciation': 'ho',
      'imageUrlHiragana': 'https://i.imgur.com/QdIMNXy.png',
      'imageUrlKatakana': 'https://i.imgur.com/KhUDwfk.png',
    },

    // M-series
    {
      'character': 'ma',
      'hiragana': 'ま',
      'katakana': 'マ',
      'pronunciation': 'ma',
      'imageUrlHiragana': 'https://i.imgur.com/am0B5tA.png',
      'imageUrlKatakana': 'https://i.imgur.com/JNaDbQs.png',
    },
    {
      'character': 'mi',
      'hiragana': 'み',
      'katakana': 'ミ',
      'pronunciation': 'mi',
      'imageUrlHiragana': 'https://i.imgur.com/PT8XTiT.png',
      'imageUrlKatakana': 'https://i.imgur.com/FmN82rK.png',
    },
    {
      'character': 'mu',
      'hiragana': 'む',
      'katakana': 'ム',
      'pronunciation': 'mu',
      'imageUrlHiragana': 'https://i.imgur.com/MW0w8ii.png',
      'imageUrlKatakana': 'https://i.imgur.com/miCj9lO.png',
    },
    {
      'character': 'me',
      'hiragana': 'め',
      'katakana': 'メ',
      'pronunciation': 'me',
      'imageUrlHiragana': 'https://i.imgur.com/FUmPJSY.png',
      'imageUrlKatakana': 'https://i.imgur.com/QGF9MOk.png',
    },
    {
      'character': 'mo',
      'hiragana': 'も',
      'katakana': 'モ',
      'pronunciation': 'mo',
      'imageUrlHiragana': 'https://i.imgur.com/RyrbQL2.png',
      'imageUrlKatakana': 'https://i.imgur.com/Vdkwh3n.png',
    },

    // Y-series
    {
      'character': 'ya',
      'hiragana': 'や',
      'katakana': 'ヤ',
      'pronunciation': 'ya',
      'imageUrlHiragana': 'https://i.imgur.com/AygE28U.png',
      'imageUrlKatakana': 'https://i.imgur.com/NsDYeFL.png',
    },
    {
      'character': 'yu',
      'hiragana': 'ゆ',
      'katakana': 'ユ',
      'pronunciation': 'yu',
      'imageUrlHiragana': 'https://i.imgur.com/Lw4wThT.png',
      'imageUrlKatakana': 'https://i.imgur.com/gTobO24.png',
    },
    {
      'character': 'yo',
      'hiragana': 'よ',
      'katakana': 'ヨ',
      'pronunciation': 'yo',
      'imageUrlHiragana': 'https://i.imgur.com/GWR8sey.png',
      'imageUrlKatakana': 'https://i.imgur.com/qB9WauH.png',
    },

    // R-series
    {
      'character': 'ra',
      'hiragana': 'ら',
      'katakana': 'ラ',
      'pronunciation': 'ra',
      'imageUrlHiragana': 'https://i.imgur.com/wWFIkSb.png',
      'imageUrlKatakana': 'https://i.imgur.com/HwycnAY.png',
    },
    {
      'character': 'ri',
      'hiragana': 'り',
      'katakana': 'リ',
      'pronunciation': 'ri',
      'imageUrlHiragana': 'https://i.imgur.com/1QTMZm1.png',
      'imageUrlKatakana': 'https://i.imgur.com/Gx0mYko.png',
    },
    {
      'character': 'ru',
      'hiragana': 'る',
      'katakana': 'ル',
      'pronunciation': 'ru',
      'imageUrlHiragana': 'https://i.imgur.com/JPgNH3V.png',
      'imageUrlKatakana': 'https://i.imgur.com/gs96oh4.png',
    },
    {
      'character': 're',
      'hiragana': 'れ',
      'katakana': 'レ',
      'pronunciation': 're',
      'imageUrlHiragana': 'https://i.imgur.com/zpilZ5t.png',
      'imageUrlKatakana': 'https://i.imgur.com/QyX6iv1.png',
    },
    {
      'character': 'ro',
      'hiragana': 'ろ',
      'katakana': 'ロ',
      'pronunciation': 'ro',
      'imageUrlHiragana': 'https://i.imgur.com/mqFFtfH.png',
      'imageUrlKatakana': 'https://i.imgur.com/4i8MHdX.png',
    },

    // W-series
    {
      'character': 'wa',
      'hiragana': 'わ',
      'katakana': 'ワ',
      'pronunciation': 'wa',
      'imageUrlHiragana': 'https://i.imgur.com/DBpk3Nw.png',
      'imageUrlKatakana': 'https://i.imgur.com/GuMHCzl.png',
    },
    {
      'character': 'wo',
      'hiragana': 'を',
      'katakana': 'ヲ',
      'pronunciation': 'wo',
      'imageUrlHiragana': 'https://i.imgur.com/bpFArla.png',
      'imageUrlKatakana': 'https://i.imgur.com/owPUJmC.png',
    },

    // n
    {
      'character': 'n',
      'hiragana': 'ん',
      'katakana': 'ン',
      'pronunciation': 'n',
      'imageUrlHiragana': 'https://i.imgur.com/d38xzJN.png',
      'imageUrlKatakana': 'https://i.imgur.com/PbmytoX.png',
    },
  ];

  // Adding kana data to Firestore (for each kana character)
  for (var kana in kanaData) {
    await firestore.collection('hiraganaGujuon').doc(kana['character']).set({
      'hiragana': kana['hiragana'],
      'katakana': kana['katakana'],
      'pronunciation': kana['pronunciation'],
      'imageUrlHiragana': kana['imageUrlHiragana'],
      'imageUrlKatakana': kana['imageUrlKatakana'],
    });
  }

  print('Kana data has been added to Firestore!');
}
