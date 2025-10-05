import 'models.dart';

class CategoryNode {
  const CategoryNode({
    required this.id,
    required this.label,
    this.children = const <CategoryNode>[],
  });

  final String id;
  final String label;
  final List<CategoryNode> children;
}

CategoryNode? findChildById(Iterable<CategoryNode> nodes, String? id) {
  if (id == null) return null;
  for (final node in nodes) {
    if (node.id == id) {
      return node;
    }
  }
  return null;
}

const Map<ListingCategory, List<CategoryNode>> listingCategoryTree = {
  ListingCategory.konut: [
    CategoryNode(
      id: 'konut_daire',
      label: 'Daire',
      children: [
        CategoryNode(id: 'konut_daire_studyo', label: 'Stüdyo (1+0)'),
        CategoryNode(id: 'konut_daire_1_1', label: '1+1'),
        CategoryNode(id: 'konut_daire_2_1', label: '2+1'),
        CategoryNode(id: 'konut_daire_3_1', label: '3+1'),
        CategoryNode(id: 'konut_daire_4_1', label: '4+1'),
        CategoryNode(id: 'konut_daire_duplex', label: 'Dublex'),
        CategoryNode(id: 'konut_daire_triplex', label: 'Triplex'),
        CategoryNode(id: 'konut_daire_loft', label: 'Loft'),
        CategoryNode(id: 'konut_daire_penthouse', label: 'Penthouse'),
      ],
    ),
    CategoryNode(
      id: 'konut_mustakil',
      label: 'Müstakil Ev',
      children: [
        CategoryNode(id: 'konut_mustakil_tekkat', label: 'Tek Katlı'),
        CategoryNode(id: 'konut_mustakil_dublex', label: 'Dublex'),
        CategoryNode(id: 'konut_mustakil_triplex', label: 'Triplex'),
        CategoryNode(id: 'konut_mustakil_bahceli', label: 'Bahçeli'),
      ],
    ),
    CategoryNode(
      id: 'konut_villa',
      label: 'Villa',
      children: [
        CategoryNode(id: 'konut_villa_ikiz', label: 'İkiz Villa'),
        CategoryNode(id: 'konut_villa_site', label: 'Site İçi Villa'),
        CategoryNode(id: 'konut_villa_yazlik', label: 'Yazlık Villa'),
        CategoryNode(id: 'konut_villa_luks', label: 'Ultra Lüks Villa'),
        CategoryNode(id: 'konut_villa_akilli', label: 'Akıllı Ev'),
      ],
    ),
    CategoryNode(
      id: 'konut_rezidans',
      label: 'Rezidans',
      children: [
        CategoryNode(id: 'konut_rezidans_1_1', label: '1+1 Rezidans'),
        CategoryNode(id: 'konut_rezidans_2_1', label: '2+1 Rezidans'),
        CategoryNode(id: 'konut_rezidans_3_1', label: '3+1 Rezidans'),
        CategoryNode(id: 'konut_rezidans_suite', label: 'Suit'),
        CategoryNode(id: 'konut_rezidans_penthouse', label: 'Penthouse'),
      ],
    ),
    CategoryNode(
      id: 'konut_yazlik',
      label: 'Yazlık & Tatil Evi',
      children: [
        CategoryNode(id: 'konut_yazlik_site', label: 'Site İçi Yazlık'),
        CategoryNode(id: 'konut_yazlik_deniz', label: 'Deniz Manzaralı'),
        CategoryNode(id: 'konut_yazlik_tiny', label: 'Tiny House'),
        CategoryNode(id: 'konut_yazlik_bungalov', label: 'Bungalov'),
      ],
    ),
    CategoryNode(
      id: 'konut_apartman_kati',
      label: 'Apartman Katı',
      children: [
        CategoryNode(id: 'konut_apartman_cati', label: 'Çatı Katı'),
        CategoryNode(id: 'konut_apartman_arakat', label: 'Ara Kat'),
        CategoryNode(id: 'konut_apartman_zemin', label: 'Zemin Kat'),
        CategoryNode(id: 'konut_apartman_bahce', label: 'Bahçe Katı'),
      ],
    ),
    CategoryNode(
      id: 'konut_prefabrik',
      label: 'Prefabrik & Tiny House',
      children: [
        CategoryNode(id: 'konut_prefabrik_hazir', label: 'Hazır Prefabrik'),
        CategoryNode(id: 'konut_prefabrik_moduler', label: 'Modüler Yapı'),
        CategoryNode(id: 'konut_prefabrik_tiny', label: 'Treyler Tiny House'),
      ],
    ),
    CategoryNode(
      id: 'konut_ciftlik',
      label: 'Çiftlik & Kırsal Ev',
      children: [
        CategoryNode(id: 'konut_ciftlik_bahceli', label: 'Bahçeli Çiftlik'),
        CategoryNode(id: 'konut_ciftlik_hobi', label: 'Hobi Bahçeli Ev'),
        CategoryNode(id: 'konut_ciftlik_bag', label: 'Bağ Evi'),
      ],
    ),
  ],
  ListingCategory.emlak: [
    CategoryNode(
      id: 'emlak_arsa',
      label: 'Arsa',
      children: [
        CategoryNode(id: 'emlak_arsa_konut', label: 'Konut İmarlı'),
        CategoryNode(id: 'emlak_arsa_ticari', label: 'Ticari İmarlı'),
        CategoryNode(id: 'emlak_arsa_turizm', label: 'Turizm İmarlı'),
        CategoryNode(id: 'emlak_arsa_sanayi', label: 'Sanayi İmarlı'),
        CategoryNode(id: 'emlak_arsa_kose', label: 'Köşe Parsel'),
      ],
    ),
    CategoryNode(
      id: 'emlak_tarla',
      label: 'Tarla',
      children: [
        CategoryNode(id: 'emlak_tarla_sulu', label: 'Sulu Tarla'),
        CategoryNode(id: 'emlak_tarla_kuru', label: 'Kuru Tarla'),
        CategoryNode(id: 'emlak_tarla_hobi', label: 'Hobi Tarlası'),
        CategoryNode(id: 'emlak_tarla_organik', label: 'Organik Tarım Tarlası'),
      ],
    ),
    CategoryNode(
      id: 'emlak_bag_bahce',
      label: 'Bağ & Bahçe',
      children: [
        CategoryNode(id: 'emlak_bahce_zeytin', label: 'Zeytinlik'),
        CategoryNode(id: 'emlak_bahce_bag', label: 'Bağ'),
        CategoryNode(id: 'emlak_bahce_meyve', label: 'Meyve Bahçesi'),
        CategoryNode(id: 'emlak_bahce_sera', label: 'Sera Arazisi'),
      ],
    ),
    CategoryNode(
      id: 'emlak_ticari',
      label: 'Ticari Gayrimenkul',
      children: [
        CategoryNode(id: 'emlak_ticari_magaza', label: 'Mağaza & Showroom'),
        CategoryNode(id: 'emlak_ticari_ofis', label: 'Ofis & Plaza'),
        CategoryNode(id: 'emlak_ticari_depo', label: 'Depo & Antrepo'),
        CategoryNode(id: 'emlak_ticari_akaryakit', label: 'Akaryakıt Arsası'),
      ],
    ),
    CategoryNode(
      id: 'emlak_sanayi',
      label: 'Sanayi & Depolama',
      children: [
        CategoryNode(id: 'emlak_sanayi_arazi', label: 'Sanayi Arsası'),
        CategoryNode(id: 'emlak_sanayi_fabrika', label: 'Fabrika Arazisi'),
        CategoryNode(id: 'emlak_sanayi_loji', label: 'Lojistik Tesisi'),
      ],
    ),
    CategoryNode(
      id: 'emlak_turizm',
      label: 'Turizm & Konaklama',
      children: [
        CategoryNode(id: 'emlak_turizm_otel', label: 'Otel Arsası'),
        CategoryNode(id: 'emlak_turizm_butik', label: 'Butik Otel Arsası'),
        CategoryNode(id: 'emlak_turizm_glamping', label: 'Glamping Tesisi'),
      ],
    ),
    CategoryNode(
      id: 'emlak_enerji',
      label: 'Enerji Yatırımları',
      children: [
        CategoryNode(id: 'emlak_enerji_solar', label: 'Güneş Enerji Arazisi'),
        CategoryNode(id: 'emlak_enerji_ruzg', label: 'Rüzgar Enerji Arazisi'),
        CategoryNode(id: 'emlak_enerji_jeotermal', label: 'Jeotermal Kaynak'),
      ],
    ),
    CategoryNode(
      id: 'emlak_yatirim',
      label: 'Gelişim & Yatırım',
      children: [
        CategoryNode(id: 'emlak_yatirim_kentsel', label: 'Kentsel Dönüşüm'),
        CategoryNode(id: 'emlak_yatirim_toplu', label: 'Toplu Konut Projesi'),
        CategoryNode(id: 'emlak_yatirim_paylasimli', label: 'Ortak Yatırım'),
      ],
    ),
  ],
  ListingCategory.arac: [
    CategoryNode(
      id: 'arac_otomobil',
      label: 'Otomobil',
      children: [
        CategoryNode(id: 'arac_otomobil_sedan', label: 'Sedan'),
        CategoryNode(id: 'arac_otomobil_hatchback', label: 'Hatchback'),
        CategoryNode(id: 'arac_otomobil_station', label: 'Station Wagon'),
        CategoryNode(id: 'arac_otomobil_coupe', label: 'Coupe'),
        CategoryNode(id: 'arac_otomobil_cabrio', label: 'Cabrio'),
        CategoryNode(id: 'arac_otomobil_mpv', label: 'MPV / Minivan'),
      ],
    ),
    CategoryNode(
      id: 'arac_suv_pickup',
      label: 'SUV & Pickup',
      children: [
        CategoryNode(id: 'arac_suv_kompakt', label: 'Kompakt SUV'),
        CategoryNode(id: 'arac_suv_orta', label: 'Orta Segment SUV'),
        CategoryNode(id: 'arac_suv_buyuk', label: 'Full-Size SUV'),
        CategoryNode(id: 'arac_pickup', label: 'Pickup'),
        CategoryNode(id: 'arac_crossover', label: 'Crossover'),
      ],
    ),
    CategoryNode(
      id: 'arac_elektrikli',
      label: 'Elektrikli & Hibrit',
      children: [
        CategoryNode(id: 'arac_elektrikli_bev', label: 'Tam Elektrik (BEV)'),
        CategoryNode(id: 'arac_elektrikli_phev', label: 'Plug-in Hibrit (PHEV)'),
        CategoryNode(id: 'arac_elektrikli_hibrit', label: 'Hibrit (HEV)'),
        CategoryNode(id: 'arac_elektrikli_hidrojen', label: 'Hidrojen Yakıt Hücreli'),
      ],
    ),
    CategoryNode(
      id: 'arac_motosiklet',
      label: 'Motosiklet',
      children: [
        CategoryNode(id: 'arac_moto_scooter', label: 'Scooter'),
        CategoryNode(id: 'arac_moto_enduro', label: 'Enduro'),
        CategoryNode(id: 'arac_moto_sport', label: 'Sport'),
        CategoryNode(id: 'arac_moto_cruiser', label: 'Cruiser'),
        CategoryNode(id: 'arac_moto_touring', label: 'Touring'),
        CategoryNode(id: 'arac_moto_cross', label: 'Motocross'),
      ],
    ),
    CategoryNode(
      id: 'arac_minivan',
      label: 'Minivan & Panelvan',
      children: [
        CategoryNode(id: 'arac_minivan_minibus', label: 'Minibüs'),
        CategoryNode(id: 'arac_minivan_panel', label: 'Panelvan'),
        CategoryNode(id: 'arac_minivan_kombi', label: 'Kombi'),
        CategoryNode(id: 'arac_minivan_okul', label: 'Okul Taşıtı'),
      ],
    ),
    CategoryNode(
      id: 'arac_ticari',
      label: 'Ticari Araç',
      children: [
        CategoryNode(id: 'arac_ticari_kamyonet', label: 'Kamyonet'),
        CategoryNode(id: 'arac_ticari_kamyon', label: 'Kamyon'),
        CategoryNode(id: 'arac_ticari_cekici', label: 'Çekici'),
        CategoryNode(id: 'arac_ticari_dorse', label: 'Dorse'),
        CategoryNode(id: 'arac_ticari_forklift', label: 'Forklift'),
      ],
    ),
    CategoryNode(
      id: 'arac_kiralik',
      label: 'Kiralık Araç',
      children: [
        CategoryNode(id: 'arac_kiralik_ekonomik', label: 'Ekonomik'),
        CategoryNode(id: 'arac_kiralik_prestij', label: 'Prestij'),
        CategoryNode(id: 'arac_kiralik_suv', label: 'SUV'),
        CategoryNode(id: 'arac_kiralik_minivan', label: 'Minivan'),
        CategoryNode(id: 'arac_kiralik_karavan', label: 'Karavan'),
      ],
    ),
    CategoryNode(
      id: 'arac_deniz',
      label: 'Deniz Araçları',
      children: [
        CategoryNode(id: 'arac_deniz_sur', label: 'Sürat Teknesi'),
        CategoryNode(id: 'arac_deniz_yat', label: 'Yat'),
        CategoryNode(id: 'arac_deniz_balikci', label: 'Balıkçı Teknesi'),
        CategoryNode(id: 'arac_deniz_jetski', label: 'Jetski'),
        CategoryNode(id: 'arac_deniz_sisme', label: 'Şişme Bot'),
      ],
    ),
    CategoryNode(
      id: 'arac_hasarli',
      label: 'Hasarlı / Parça',
      children: [
        CategoryNode(id: 'arac_hasarli_tramer', label: 'Tramer Kayıtlı'),
        CategoryNode(id: 'arac_hasarli_parca', label: 'Parça Amaçlı'),
        CategoryNode(id: 'arac_hasarli_motor', label: 'Motor Arızalı'),
        CategoryNode(id: 'arac_hasarli_boya', label: 'Boyalı / Değişenli'),
      ],
    ),
    CategoryNode(
      id: 'arac_karavan',
      label: 'Karavan',
      children: [
        CategoryNode(id: 'arac_karavan_moto', label: 'Motokaravan'),
        CategoryNode(id: 'arac_karavan_cekme', label: 'Çekme Karavan'),
        CategoryNode(id: 'arac_karavan_offroad', label: 'Off-road Karavan'),
        CategoryNode(id: 'arac_karavan_tiny', label: 'Tiny Karavan'),
      ],
    ),
    CategoryNode(
      id: 'arac_klasik',
      label: 'Klasik Araç',
      children: [
        CategoryNode(id: 'arac_klasik_otomobil', label: 'Klasik Otomobil'),
        CategoryNode(id: 'arac_klasik_moto', label: 'Klasik Motosiklet'),
        CategoryNode(id: 'arac_klasik_kamyonet', label: 'Klasik Kamyonet'),
      ],
    ),
    CategoryNode(
      id: 'arac_hava',
      label: 'Hava Araçları',
      children: [
        CategoryNode(id: 'arac_hava_drone', label: 'Drone'),
        CategoryNode(id: 'arac_hava_ultralight', label: 'Ultralight'),
        CategoryNode(id: 'arac_hava_helikopter', label: 'Helikopter'),
        CategoryNode(id: 'arac_hava_yelken', label: 'Yelkenkanat'),
      ],
    ),
    CategoryNode(
      id: 'arac_atv',
      label: 'ATV & UTV',
      children: [
        CategoryNode(id: 'arac_atv', label: 'ATV'),
        CategoryNode(id: 'arac_utv', label: 'UTV / Side-by-side'),
        CategoryNode(id: 'arac_atv_ciftci', label: 'Çiftçi ATV'),
        CategoryNode(id: 'arac_atv_safari', label: 'Safari ATV'),
      ],
    ),
  ],
  ListingCategory.elektronik: [
    CategoryNode(
      id: 'elektronik_telefon',
      label: 'Telefon & Aksesuar',
      children: [
        CategoryNode(id: 'elektronik_telefon_akilli', label: 'Akıllı Telefon'),
        CategoryNode(id: 'elektronik_telefon_dugmeli', label: 'Butonlu Telefon'),
        CategoryNode(id: 'elektronik_telefon_ikinci', label: 'İkinci El Telefon'),
        CategoryNode(id: 'elektronik_telefon_aks', label: 'Aksesuar & Kılıf'),
      ],
    ),
    CategoryNode(
      id: 'elektronik_bilgisayar',
      label: 'Bilgisayar',
      children: [
        CategoryNode(id: 'elektronik_pc_laptop', label: 'Laptop'),
        CategoryNode(id: 'elektronik_pc_masaustu', label: 'Masaüstü'),
        CategoryNode(id: 'elektronik_pc_oyun', label: 'Oyun Bilgisayarı'),
        CategoryNode(id: 'elektronik_pc_allinone', label: 'All-in-one'),
        CategoryNode(id: 'elektronik_pc_workstation', label: 'Workstation'),
      ],
    ),
    CategoryNode(
      id: 'elektronik_tablet',
      label: 'Tablet',
      children: [
        CategoryNode(id: 'elektronik_tablet_ios', label: 'iOS Tablet'),
        CategoryNode(id: 'elektronik_tablet_android', label: 'Android Tablet'),
        CategoryNode(id: 'elektronik_tablet_windows', label: 'Windows Tablet'),
        CategoryNode(id: 'elektronik_tablet_cocuk', label: 'Çocuk Tableti'),
      ],
    ),
    CategoryNode(
      id: 'elektronik_tv',
      label: 'TV & Ses',
      children: [
        CategoryNode(id: 'elektronik_tv_led', label: 'LED TV'),
        CategoryNode(id: 'elektronik_tv_oled', label: 'OLED TV'),
        CategoryNode(id: 'elektronik_tv_soundbar', label: 'Soundbar'),
        CategoryNode(id: 'elektronik_tv_hoparlor', label: 'Hoparlör'),
        CategoryNode(id: 'elektronik_tv_projeksiyon', label: 'Projeksiyon'),
      ],
    ),
    CategoryNode(
      id: 'elektronik_kamera',
      label: 'Fotoğraf & Kamera',
      children: [
        CategoryNode(id: 'elektronik_kamera_dslr', label: 'DSLR'),
        CategoryNode(id: 'elektronik_kamera_mirrorless', label: 'Mirrorless'),
        CategoryNode(id: 'elektronik_kamera_kompakt', label: 'Kompakt Kamera'),
        CategoryNode(id: 'elektronik_kamera_aksiyon', label: 'Aksiyon Kamera'),
        CategoryNode(id: 'elektronik_kamera_lens', label: 'Lens & Aksesuar'),
      ],
    ),
    CategoryNode(
      id: 'elektronik_oyun',
      label: 'Oyun & Konsol',
      children: [
        CategoryNode(id: 'elektronik_oyun_playstation', label: 'PlayStation'),
        CategoryNode(id: 'elektronik_oyun_xbox', label: 'Xbox'),
        CategoryNode(id: 'elektronik_oyun_nintendo', label: 'Nintendo'),
        CategoryNode(id: 'elektronik_oyun_pc', label: 'PC Aksesuar'),
        CategoryNode(id: 'elektronik_oyun_vr', label: 'VR Set'),
      ],
    ),
    CategoryNode(
      id: 'elektronik_giyilebilir',
      label: 'Giyilebilir Teknoloji',
      children: [
        CategoryNode(id: 'elektronik_giyilebilir_saat', label: 'Akıllı Saat'),
        CategoryNode(id: 'elektronik_giyilebilir_bileklik', label: 'Akıllı Bileklik'),
        CategoryNode(id: 'elektronik_giyilebilir_kulaklik', label: 'Kablosuz Kulaklık'),
        CategoryNode(id: 'elektronik_giyilebilir_gozluk', label: 'Akıllı Gözlük'),
      ],
    ),
    CategoryNode(
      id: 'elektronik_ev',
      label: 'Ev Elektroniği & Beyaz Eşya',
      children: [
        CategoryNode(id: 'elektronik_ev_beyazesya', label: 'Beyaz Eşya'),
        CategoryNode(id: 'elektronik_ev_kucuk', label: 'Küçük Ev Aleti'),
        CategoryNode(id: 'elektronik_ev_klima', label: 'Klima & Isıtıcı'),
        CategoryNode(id: 'elektronik_ev_smart', label: 'Akıllı Ev Sistemi'),
      ],
    ),
    CategoryNode(
      id: 'elektronik_ofis',
      label: 'Ofis Elektroniği',
      children: [
        CategoryNode(id: 'elektronik_ofis_yazici', label: 'Yazıcı & Tarayıcı'),
        CategoryNode(id: 'elektronik_ofis_pos', label: 'POS & Tahsilat'),
        CategoryNode(id: 'elektronik_ofis_proj', label: 'Projeksiyon & Sunum'),
        CategoryNode(id: 'elektronik_ofis_ups', label: 'UPS & Güç Ünitesi'),
      ],
    ),
    CategoryNode(
      id: 'elektronik_aksesuar',
      label: 'Aksesuar & Yedek Parça',
      children: [
        CategoryNode(id: 'elektronik_aksesuar_kablo', label: 'Kablo & Adaptör'),
        CategoryNode(id: 'elektronik_aksesuar_sarj', label: 'Şarj Cihazı'),
        CategoryNode(id: 'elektronik_aksesuar_kilif', label: 'Kılıf & Koruyucu'),
        CategoryNode(id: 'elektronik_aksesuar_powerbank', label: 'Powerbank'),
      ],
    ),
  ],
  ListingCategory.hizmet: [
    CategoryNode(
      id: 'hizmet_ev',
      label: 'Ev Hizmetleri',
      children: [
        CategoryNode(id: 'hizmet_ev_temizlik', label: 'Temizlik'),
        CategoryNode(id: 'hizmet_ev_boya', label: 'Boya & Badana'),
        CategoryNode(id: 'hizmet_ev_tadilat', label: 'Tadilat & Dekorasyon'),
        CategoryNode(id: 'hizmet_ev_cilingir', label: 'Çilingir'),
        CategoryNode(id: 'hizmet_ev_pest', label: 'Pest Kontrol'),
      ],
    ),
    CategoryNode(
      id: 'hizmet_nakliye',
      label: 'Nakliye & Lojistik',
      children: [
        CategoryNode(id: 'hizmet_nakliye_sehirici', label: 'Şehir İçi Nakliye'),
        CategoryNode(id: 'hizmet_nakliye_sehirlerarasi', label: 'Şehirler Arası'),
        CategoryNode(id: 'hizmet_nakliye_evdeneve', label: 'Evden Eve Taşımacılık'),
        CategoryNode(id: 'hizmet_nakliye_parca', label: 'Parça Taşımacılığı'),
        CategoryNode(id: 'hizmet_nakliye_asansor', label: 'Asansör Kiralama'),
      ],
    ),
    CategoryNode(
      id: 'hizmet_egitim',
      label: 'Eğitim & Özel Ders',
      children: [
        CategoryNode(id: 'hizmet_egitim_akademik', label: 'Sınav & Okul Desteği'),
        CategoryNode(id: 'hizmet_egitim_dil', label: 'Dil Eğitimi'),
        CategoryNode(id: 'hizmet_egitim_muzik', label: 'Müzik Dersi'),
        CategoryNode(id: 'hizmet_egitim_online', label: 'Online Kurs'),
        CategoryNode(id: 'hizmet_egitim_spor', label: 'Spor & Fitness Eğitmeni'),
      ],
    ),
    CategoryNode(
      id: 'hizmet_saglik',
      label: 'Sağlık & Bakım',
      children: [
        CategoryNode(id: 'hizmet_saglik_fizyoterapi', label: 'Fizyoterapi'),
        CategoryNode(id: 'hizmet_saglik_hemsire', label: 'Hemşire / Ebe'),
        CategoryNode(id: 'hizmet_saglik_yasli', label: 'Yaşlı Bakımı'),
        CategoryNode(id: 'hizmet_saglik_bakici', label: 'Bebek Bakıcısı'),
        CategoryNode(id: 'hizmet_saglik_masaj', label: 'Masaj & Spa'),
      ],
    ),
    CategoryNode(
      id: 'hizmet_it',
      label: 'IT & Tasarım',
      children: [
        CategoryNode(id: 'hizmet_it_web', label: 'Web Geliştirme'),
        CategoryNode(id: 'hizmet_it_mobil', label: 'Mobil Uygulama'),
        CategoryNode(id: 'hizmet_it_grafik', label: 'Grafik & UI Tasarım'),
        CategoryNode(id: 'hizmet_it_seo', label: 'SEO & Dijital Pazarlama'),
        CategoryNode(id: 'hizmet_it_sosyal', label: 'Sosyal Medya Yönetimi'),
      ],
    ),
    CategoryNode(
      id: 'hizmet_etkinlik',
      label: 'Etkinlik & Organizasyon',
      children: [
        CategoryNode(id: 'hizmet_etkinlik_fotograf', label: 'Fotoğraf & Video'),
        CategoryNode(id: 'hizmet_etkinlik_planlama', label: 'Organizasyon Planlama'),
        CategoryNode(id: 'hizmet_etkinlik_dj', label: 'DJ & Müzik'),
        CategoryNode(id: 'hizmet_etkinlik_kiralama', label: 'Ekipman Kiralama'),
        CategoryNode(id: 'hizmet_etkinlik_catering', label: 'Catering'),
      ],
    ),
    CategoryNode(
      id: 'hizmet_arac',
      label: 'Araç Hizmetleri',
      children: [
        CategoryNode(id: 'hizmet_arac_detay', label: 'Oto Kuaför & Detay'),
        CategoryNode(id: 'hizmet_arac_mekanik', label: 'Mekanik & Servis'),
        CategoryNode(id: 'hizmet_arac_lastik', label: 'Lastik & Jant'),
        CategoryNode(id: 'hizmet_arac_kaplama', label: 'Kaplama & Boya Koruma'),
      ],
    ),
    CategoryNode(
      id: 'hizmet_danisman',
      label: 'Danışmanlık',
      children: [
        CategoryNode(id: 'hizmet_danisman_finans', label: 'Finans & Muhasebe'),
        CategoryNode(id: 'hizmet_danisman_gayrimenkul', label: 'Gayrimenkul'),
        CategoryNode(id: 'hizmet_danisman_kariyer', label: 'Kariyer & Koçluk'),
        CategoryNode(id: 'hizmet_danisman_goc', label: 'Göçmenlik & Vize'),
      ],
    ),
    CategoryNode(
      id: 'hizmet_tarim',
      label: 'Tarım & Bahçe',
      children: [
        CategoryNode(id: 'hizmet_tarim_peyzaj', label: 'Peyzaj & Bahçe Düzenleme'),
        CategoryNode(id: 'hizmet_tarim_budama', label: 'Budama & Bakım'),
        CategoryNode(id: 'hizmet_tarim_sulama', label: 'Sulama Sistemi'),
        CategoryNode(id: 'hizmet_tarim_serra', label: 'Sera Kurulumu'),
      ],
    ),
    CategoryNode(
      id: 'hizmet_guvenlik',
      label: 'Güvenlik & Otomasyon',
      children: [
        CategoryNode(id: 'hizmet_guvenlik_alarm', label: 'Alarm Sistemi'),
        CategoryNode(id: 'hizmet_guvenlik_kamera', label: 'Kamera & CCTV'),
        CategoryNode(id: 'hizmet_guvenlik_guvenlik', label: 'Özel Güvenlik'),
        CategoryNode(id: 'hizmet_guvenlik_kapi', label: 'Otomatik Kapı'),
      ],
    ),
  ],
  ListingCategory.isFirsati: [
    CategoryNode(
      id: 'is_tam_zamanli',
      label: 'Tam Zamanlı',
      children: [
        CategoryNode(id: 'is_tam_satis', label: 'Satış & Pazarlama'),
        CategoryNode(id: 'is_tam_teknik', label: 'Teknik & Mühendislik'),
        CategoryNode(id: 'is_tam_idari', label: 'İdari & Ofis'),
        CategoryNode(id: 'is_tam_saglik', label: 'Sağlık'),
        CategoryNode(id: 'is_tam_egitim', label: 'Eğitim'),
      ],
    ),
    CategoryNode(
      id: 'is_yari_zamanli',
      label: 'Yarı Zamanlı',
      children: [
        CategoryNode(id: 'is_yari_magaza', label: 'Mağaza & Satış Danışmanı'),
        CategoryNode(id: 'is_yari_cagri', label: 'Çağrı Merkezi'),
        CategoryNode(id: 'is_yari_garson', label: 'Garson & Barista'),
        CategoryNode(id: 'is_yari_kurye', label: 'Kurye & Dağıtım'),
        CategoryNode(id: 'is_yari_egitmen', label: 'Özel Ders & Eğitmen'),
      ],
    ),
    CategoryNode(
      id: 'is_serbest',
      label: 'Serbest / Proje Bazlı',
      children: [
        CategoryNode(id: 'is_serbest_yazilim', label: 'Yazılım & IT'),
        CategoryNode(id: 'is_serbest_tasarim', label: 'Grafik & Tasarım'),
        CategoryNode(id: 'is_serbest_ceviri', label: 'Çeviri & Lokalizasyon'),
        CategoryNode(id: 'is_serbest_muhasebe', label: 'Muhasebe & Finans'),
        CategoryNode(id: 'is_serbest_video', label: 'Video & Fotoğraf'),
      ],
    ),
    CategoryNode(
      id: 'is_uzaktan',
      label: 'Uzaktan Çalışma',
      children: [
        CategoryNode(id: 'is_uzaktan_destek', label: 'Müşteri Destek'),
        CategoryNode(id: 'is_uzaktan_yazilim', label: 'Yazılım Geliştirme'),
        CategoryNode(id: 'is_uzaktan_egitim', label: 'Online Eğitmen'),
        CategoryNode(id: 'is_uzaktan_icerik', label: 'İçerik Üretimi'),
      ],
    ),
    CategoryNode(
      id: 'is_staj',
      label: 'Staj & Genç Yetenek',
      children: [
        CategoryNode(id: 'is_staj_muhendis', label: 'Mühendislik Stajı'),
        CategoryNode(id: 'is_staj_iktisat', label: 'İktisat & İşletme Stajı'),
        CategoryNode(id: 'is_staj_tasarim', label: 'Grafik Tasarım Stajı'),
        CategoryNode(id: 'is_staj_insank', label: 'İnsan Kaynakları Stajı'),
      ],
    ),
    CategoryNode(
      id: 'is_girisim',
      label: 'Girişim & Ortaklık',
      children: [
        CategoryNode(id: 'is_girisim_startup', label: 'Startup Ortak Arıyor'),
        CategoryNode(id: 'is_girisim_franchise', label: 'Franchise'),
        CategoryNode(id: 'is_girisim_isortak', label: 'İş Ortaklığı'),
        CategoryNode(id: 'is_girisim_yatirimci', label: 'Yatırımcı Aranıyor'),
      ],
    ),
  ],
  ListingCategory.hayvan: [
    CategoryNode(
      id: 'hayvan_kopek',
      label: 'Köpek',
      children: [
        CategoryNode(id: 'hayvan_kopek_golden', label: 'Golden Retriever'),
        CategoryNode(id: 'hayvan_kopek_alman', label: 'Alman Çoban'),
        CategoryNode(id: 'hayvan_kopek_labrador', label: 'Labrador'),
        CategoryNode(id: 'hayvan_kopek_rottweiler', label: 'Rottweiler'),
        CategoryNode(id: 'hayvan_kopek_pomeranian', label: 'Pomeranian'),
        CategoryNode(id: 'hayvan_kopek_yorkshire', label: 'Yorkshire Terrier'),
        CategoryNode(id: 'hayvan_kopek_shihtzu', label: 'Shih Tzu'),
        CategoryNode(id: 'hayvan_kopek_sibirya', label: 'Sibirya Kurdu'),
        CategoryNode(id: 'hayvan_kopek_kangal', label: 'Kangal'),
        CategoryNode(id: 'hayvan_kopek_bully', label: 'American Bully'),
      ],
    ),
    CategoryNode(
      id: 'hayvan_kedi',
      label: 'Kedi',
      children: [
        CategoryNode(id: 'hayvan_kedi_ankara', label: 'Ankara Kedisi'),
        CategoryNode(id: 'hayvan_kedi_van', label: 'Van Kedisi'),
        CategoryNode(id: 'hayvan_kedi_tekir', label: 'Tekir'),
        CategoryNode(id: 'hayvan_kedi_british', label: 'British Shorthair'),
        CategoryNode(id: 'hayvan_kedi_scottish', label: 'Scottish Fold'),
        CategoryNode(id: 'hayvan_kedi_siyam', label: 'Siyam'),
        CategoryNode(id: 'hayvan_kedi_bengal', label: 'Bengal'),
        CategoryNode(id: 'hayvan_kedi_maine', label: 'Maine Coon'),
        CategoryNode(id: 'hayvan_kedi_pers', label: 'Persian'),
        CategoryNode(id: 'hayvan_kedi_sphynx', label: 'Sphynx'),
      ],
    ),
    CategoryNode(
      id: 'hayvan_kus',
      label: 'Kuş',
      children: [
        CategoryNode(id: 'hayvan_kus_muhabbet', label: 'Muhabbet Kuşu'),
        CategoryNode(id: 'hayvan_kus_papagan', label: 'Papağan'),
        CategoryNode(id: 'hayvan_kus_kanarya', label: 'Kanarya'),
        CategoryNode(id: 'hayvan_kus_saka', label: 'Saka Kuşu'),
        CategoryNode(id: 'hayvan_kus_guvercin', label: 'Güvercin'),
        CategoryNode(id: 'hayvan_kus_tavuskusu', label: 'Tavus Kuşu'),
      ],
    ),
    CategoryNode(
      id: 'hayvan_balik',
      label: 'Balık',
      children: [
        CategoryNode(id: 'hayvan_balik_tropikal', label: 'Tropikal Balık'),
        CategoryNode(id: 'hayvan_balik_ciklet', label: 'Ciklet Türleri'),
        CategoryNode(id: 'hayvan_balik_koi', label: 'Koi'),
        CategoryNode(id: 'hayvan_balik_tuzlu', label: 'Tuzlu Su Balığı'),
        CategoryNode(id: 'hayvan_balik_soguk', label: 'Soğuk Su Balığı'),
      ],
    ),
    CategoryNode(
      id: 'hayvan_kemirgen',
      label: 'Kemirgen & Küçük Dostlar',
      children: [
        CategoryNode(id: 'hayvan_kemirgen_hamster', label: 'Hamster'),
        CategoryNode(id: 'hayvan_kemirgen_guinea', label: 'Guinea Pig'),
        CategoryNode(id: 'hayvan_kemirgen_tavsan', label: 'Tavşan'),
        CategoryNode(id: 'hayvan_kemirgen_sincap', label: 'Sincap'),
        CategoryNode(id: 'hayvan_kemirgen_cincilla', label: 'Çinçilla'),
      ],
    ),
    CategoryNode(
      id: 'hayvan_surungen',
      label: 'Sürüngen & Egzotik',
      children: [
        CategoryNode(id: 'hayvan_surungen_kaplumbaga', label: 'Kaplumbağa'),
        CategoryNode(id: 'hayvan_surungen_iguana', label: 'İguana'),
        CategoryNode(id: 'hayvan_surungen_yilan', label: 'Yılan'),
        CategoryNode(id: 'hayvan_surungen_bukalemun', label: 'Bukalemun'),
        CategoryNode(id: 'hayvan_surungen_gecko', label: 'Leopar Gekko'),
      ],
    ),
    CategoryNode(
      id: 'hayvan_ciftlik',
      label: 'Çiftlik Hayvanları',
      children: [
        CategoryNode(id: 'hayvan_ciftlik_inek', label: 'İnek'),
        CategoryNode(id: 'hayvan_ciftlik_koyun', label: 'Koyun'),
        CategoryNode(id: 'hayvan_ciftlik_keci', label: 'Keçi'),
        CategoryNode(id: 'hayvan_ciftlik_tavuk', label: 'Tavuk'),
        CategoryNode(id: 'hayvan_ciftlik_hindi', label: 'Hindi'),
        CategoryNode(id: 'hayvan_ciftlik_kaz', label: 'Kaz'),
        CategoryNode(id: 'hayvan_ciftlik_at', label: 'At'),
      ],
    ),
    CategoryNode(
      id: 'hayvan_aksesuar',
      label: 'Aksesuar & Mama',
      children: [
        CategoryNode(id: 'hayvan_aksesuar_mama', label: 'Mama'),
        CategoryNode(id: 'hayvan_aksesuar_kafes', label: 'Kafes & Taşıma'),
        CategoryNode(id: 'hayvan_aksesuar_yatak', label: 'Yatak & Minder'),
        CategoryNode(id: 'hayvan_aksesuar_oyuncak', label: 'Oyuncak'),
        CategoryNode(id: 'hayvan_aksesuar_tasma', label: 'Tasma & Gezdirme'),
      ],
    ),
  ],
  ListingCategory.diger: [
    CategoryNode(
      id: 'diger_antika',
      label: 'Antika & Koleksiyon',
      children: [
        CategoryNode(id: 'diger_antika_para', label: 'Madeni Para & Banknot'),
        CategoryNode(id: 'diger_antika_pul', label: 'Pul Koleksiyonu'),
        CategoryNode(id: 'diger_antika_plak', label: 'Plak & Kaset'),
        CategoryNode(id: 'diger_antika_oyuncak', label: 'Antika Oyuncak'),
        CategoryNode(id: 'diger_antika_sanat', label: 'Sanat Objeleri'),
      ],
    ),
    CategoryNode(
      id: 'diger_spor',
      label: 'Spor & Outdoor',
      children: [
        CategoryNode(id: 'diger_spor_fitness', label: 'Fitness & Spor Ekipmanı'),
        CategoryNode(id: 'diger_spor_kamp', label: 'Kamp & Kampçılık'),
        CategoryNode(id: 'diger_spor_bisiklet', label: 'Bisiklet & Scooter'),
        CategoryNode(id: 'diger_spor_av', label: 'Avcılık & Outdoor'),
        CategoryNode(id: 'diger_spor_su', label: 'Su Sporları'),
      ],
    ),
    CategoryNode(
      id: 'diger_muzik',
      label: 'Müzik & Enstrüman',
      children: [
        CategoryNode(id: 'diger_muzik_gitar', label: 'Gitar'),
        CategoryNode(id: 'diger_muzik_piyano', label: 'Piyano & Org'),
        CategoryNode(id: 'diger_muzik_davul', label: 'Davul & Perküsyon'),
        CategoryNode(id: 'diger_muzik_keman', label: 'Keman & Yaylılar'),
        CategoryNode(id: 'diger_muzik_dj', label: 'DJ & Stüdyo Ekipmanları'),
      ],
    ),
    CategoryNode(
      id: 'diger_anne_bebek',
      label: 'Anne & Bebek',
      children: [
        CategoryNode(id: 'diger_bebek_araba', label: 'Bebek Arabası'),
        CategoryNode(id: 'diger_bebek_besik', label: 'Beşik & Yatak'),
        CategoryNode(id: 'diger_bebek_oyuncak', label: 'Bebek Oyuncakları'),
        CategoryNode(id: 'diger_bebek_bakim', label: 'Bakım & Hijyen'),
      ],
    ),
    CategoryNode(
      id: 'diger_ofis',
      label: 'Ofis & Kırtasiye',
      children: [
        CategoryNode(id: 'diger_ofis_mobilya', label: 'Ofis Mobilyası'),
        CategoryNode(id: 'diger_ofis_kirtasiye', label: 'Kırtasiye & Sarf'),
        CategoryNode(id: 'diger_ofis_depo', label: 'Depo & Raf Sistemleri'),
        CategoryNode(id: 'diger_ofis_pos', label: 'POS & Tahsilat'),
      ],
    ),
    CategoryNode(
      id: 'diger_hobi',
      label: 'Hobi & Sanat',
      children: [
        CategoryNode(id: 'diger_hobi_resim', label: 'Resim & Boyama'),
        CategoryNode(id: 'diger_hobi_elisi', label: 'El İşi & Craft'),
        CategoryNode(id: 'diger_hobi_model', label: 'Modelcilik'),
        CategoryNode(id: 'diger_hobi_maker', label: 'Maker & Elektronik'),
      ],
    ),
    CategoryNode(
      id: 'diger_moda',
      label: 'Moda & Aksesuar',
      children: [
        CategoryNode(id: 'diger_moda_kadin', label: 'Kadın Giyim'),
        CategoryNode(id: 'diger_moda_erkek', label: 'Erkek Giyim'),
        CategoryNode(id: 'diger_moda_ayakkabi', label: 'Ayakkabı'),
        CategoryNode(id: 'diger_moda_canta', label: 'Çanta & Aksesuar'),
        CategoryNode(id: 'diger_moda_saat', label: 'Saat & Mücevher'),
      ],
    ),
    CategoryNode(
      id: 'diger_ev_dekor',
      label: 'Ev Dekorasyon',
      children: [
        CategoryNode(id: 'diger_ev_mobilya', label: 'Mobilya'),
        CategoryNode(id: 'diger_ev_hali', label: 'Halı & Kilim'),
        CategoryNode(id: 'diger_ev_aydinlatma', label: 'Aydınlatma'),
        CategoryNode(id: 'diger_ev_perde', label: 'Perde & Tekstil'),
        CategoryNode(id: 'diger_ev_bahce', label: 'Bahçe & Balkon'),
      ],
    ),
    CategoryNode(
      id: 'diger_saglik',
      label: 'Sağlık & Güzellik',
      children: [
        CategoryNode(id: 'diger_saglik_bakim', label: 'Kişisel Bakım'),
        CategoryNode(id: 'diger_saglik_kozmetik', label: 'Kozmetik'),
        CategoryNode(id: 'diger_saglik_cihaz', label: 'Sağlık Cihazı'),
        CategoryNode(id: 'diger_saglik_spa', label: 'Spa & Wellness'),
      ],
    ),
    CategoryNode(
      id: 'diger_endustri',
      label: 'Yedek Parça & Makine',
      children: [
        CategoryNode(id: 'diger_endustri_insaat', label: 'İnşaat Ekipmanı'),
        CategoryNode(id: 'diger_endustri_endustriyel', label: 'Endüstriyel Makine'),
        CategoryNode(id: 'diger_endustri_tarim', label: 'Tarım Makinesi'),
        CategoryNode(id: 'diger_endustri_isci', label: 'İş Güvenliği Ekipmanı'),
      ],
    ),
  ],
};
