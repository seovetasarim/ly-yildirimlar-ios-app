# App Store — hızlı notlar (LY Yıldırımlar İnşaat)

## Uygulama
- Ad: LY Yıldırımlar
- Bundle ID: com.lyyildirimlarinsaat.app
- URL: https://www.lyyildirimlarinsaat.com/
- Kategori: Lifestyle (veya Utilities / Business)
- Gizlilik: https://www.lyyildirimlarinsaat.com/gizlilik

## Apple’da yapılacaklar
1. developer.apple.com → Identifiers → Bundle ID oluştur: `com.lyyildirimlarinsaat.app`
2. App Store Connect → New App (aynı Bundle ID)
3. Codemagic → bu repoyu bağla
4. Environment group: `ly_yildirimlar_signing`
   - Hanzade’deki `CERT_KEY_BASE64` değerinin aynısını koy (aynı Apple hesabı / Distribution sertifikası)
5. Build başlat → IPA App Store’a yüklensin
6. Metadata + ekran görüntüsü → Submit for Review

## Not
Site güncellenince uygulama da güncellenir (WebView).
