/// Sunucunun ürettiği AUE yüzdesi için görsel etiket (iş kuralı değildir).
String suitabilityTierLabelTurkish(double suitabilityScore) {
  if (suitabilityScore >= 85) return 'Çok Yüksek Uyum';
  if (suitabilityScore >= 70) return 'Yüksek Uyum';
  if (suitabilityScore >= 50) return 'Orta Uyum';
  return 'Düşük Uyum';
}
