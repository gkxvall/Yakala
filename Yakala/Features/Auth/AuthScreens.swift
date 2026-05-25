import CoreLocation
import SwiftUI

struct LoginScreen: View {
    var onLogin: () -> Void
    var onBusinessLogin: () -> Void
    @EnvironmentObject private var appState: AppState
    @State private var email = "mert@yakala.app"
    @State private var password = ""
    @State private var alert: AuthAlert?

    var body: some View {
        NavigationStack {
            ScreenContainer {
                ScrollView {
                    VStack(spacing: 22) {
                        VStack(spacing: 12) {
                            YakalaLogoView(size: 84)
                            Text("Yakala’ya Hoş Geldin")
                                .font(.largeTitle.bold())
                                .foregroundStyle(YakalaTheme.textPrimary)
                                .multilineTextAlignment(.center)
                            Text("Yakındaki fırsatları keşfetmek için giriş yap.")
                                .font(.subheadline)
                                .foregroundStyle(YakalaTheme.textSecondary)
                        }
                        .padding(.top, 28)

                            VStack(spacing: 14) {
                            FormInputView(title: "E-posta", placeholder: "ornek@mail.com", text: $email)
                            SecureInputView(title: "Şifre", placeholder: "Şifren", text: $password)

                            HStack {
                                Spacer()
                                NavigationLink("Şifremi Unuttum") {
                                    ForgotPasswordScreen()
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(YakalaTheme.primary)
                            }

                            PrimaryButton(title: "Giriş Yap") {
                                login()
                            }
                        }

                        VStack(spacing: 12) {
                            SocialButton(title: "Apple ile Devam Et", icon: "apple.logo") {
                                alert = AuthAlert(title: "Yakında", message: "Apple ile giriş sonraki sürümde eklenecek.")
                            }
                            SocialButton(title: "Google ile Devam Et", icon: "g.circle.fill") {
                                alert = AuthAlert(title: "Yakında", message: "Google ile giriş sonraki sürümde eklenecek.")
                            }
                        }

                        NavigationLink {
                            RegisterScreen(onRegister: onLogin)
                        } label: {
                            Text("Hesabın yok mu? Kayıt ol")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(YakalaTheme.primary)
                        }

                        Button {
                            onBusinessLogin()
                        } label: {
                            Label("İşletme hesabıyla devam et", systemImage: "storefront.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(YakalaTheme.textPrimary)
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
            }
        }
        .alert(item: $alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Tamam")))
        }
    }

    private func login() {
        guard email.trimmingCharacters(in: .whitespacesAndNewlines).contains("@") else {
            alert = AuthAlert(title: "E-posta gerekli", message: "Lütfen geçerli bir e-posta adresi gir.")
            return
        }
        guard !password.isEmpty else {
            alert = AuthAlert(title: "Şifre gerekli", message: "Demo giriş için herhangi bir şifre yazabilirsin.")
            return
        }
        appState.updateUserProfile(name: appState.userName, email: email, city: appState.selectedCity)
        appState.login(as: .customer)
        onLogin()
    }
}

struct RegisterScreen: View {
    var onRegister: () -> Void
    @EnvironmentObject private var appState: AppState
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var alert: AuthAlert?

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 18) {
                    Text("Hesap Oluştur")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    FormInputView(title: "Ad Soyad", placeholder: "Adın", text: $name)
                    FormInputView(title: "E-posta", placeholder: "ornek@mail.com", text: $email)
                    SecureInputView(title: "Şifre", placeholder: "En az 6 karakter", text: $password)
                    PrimaryButton(title: "Kayıt Ol") {
                        register()
                    }
                    SocialButton(title: "Apple ile Kayıt Ol", icon: "apple.logo") {
                        alert = AuthAlert(title: "Yakında", message: "Sosyal kayıt sonraki sürümde eklenecek.")
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Kayıt")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Tamam")))
        }
    }

    private func register() {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            alert = AuthAlert(title: "Ad soyad gerekli", message: "Devam etmek için adını yaz.")
            return
        }
        guard email.trimmingCharacters(in: .whitespacesAndNewlines).contains("@") else {
            alert = AuthAlert(title: "E-posta gerekli", message: "Lütfen geçerli bir e-posta adresi gir.")
            return
        }
        guard password.count >= 6 else {
            alert = AuthAlert(title: "Şifre kısa", message: "Demo kayıt için en az 6 karakter yaz.")
            return
        }
        appState.updateUserProfile(name: cleanName, email: email, city: appState.selectedCity)
        appState.login(as: .customer)
        onRegister()
    }
}

struct ForgotPasswordScreen: View {
    @State private var email = ""
    @State private var alert: AuthAlert?

    var body: some View {
        ScreenContainer {
            VStack(spacing: 18) {
                EmptyStateView(
                    icon: "envelope.badge.fill",
                    title: "Şifreni sıfırla",
                    message: "E-posta adresini gir, sana mock sıfırlama bağlantısı gönderelim."
                )
                FormInputView(title: "E-posta", placeholder: "ornek@mail.com", text: $email)
                PrimaryButton(title: "Bağlantı Gönder") {
                    guard email.trimmingCharacters(in: .whitespacesAndNewlines).contains("@") else {
                        alert = AuthAlert(title: "E-posta gerekli", message: "Şifre sıfırlama bağlantısı için geçerli bir e-posta gir.")
                        return
                    }
                    alert = AuthAlert(title: "Gönderildi", message: "Şifre sıfırlama bağlantısı gönderildi.")
                }
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Şifremi Unuttum")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Tamam")))
        }
    }
}

struct LocationPermissionScreen: View {
    var onContinue: () -> Void = {}
    var isEditing: Bool = false
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var locationManager: LocationManager
    @State private var selectedCity = "Kadıköy, İstanbul"
    @State private var showCityPicker = false
    @State private var alert: AuthAlert?

    private let cities = ["Kadıköy, İstanbul", "Beşiktaş, İstanbul", "Şişli, İstanbul", "Karşıyaka, İzmir", "Çankaya, Ankara", "Nilüfer, Bursa"]

    var body: some View {
        ScreenContainer {
            VStack(spacing: 22) {
                Spacer()
                ZStack {
                    Circle()
                        .fill(YakalaTheme.primaryLight)
                        .frame(width: 180, height: 180)
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 84))
                        .foregroundStyle(YakalaTheme.primary)
                }
                VStack(spacing: 12) {
                    Text("Konumunla Daha İyi Fırsatlar")
                        .font(.largeTitle.bold())
                        .foregroundStyle(YakalaTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    Text("Yakındaki işletmeleri, mesafeyi ve sınırlı süreli kampanyaları göstermek için konumunu kullanıyoruz.")
                        .font(.body)
                        .foregroundStyle(YakalaTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                Spacer()
                VStack(spacing: 12) {
                    PrimaryButton(title: "Konumumu Kullan", icon: "location.fill") {
                        locationManager.requestLocationPermission()
                        appState.useRealLocation()
                        onContinue()
                    }
                    SecondaryButton(title: "Şehir Seçerek Devam Et", icon: "building.2.fill") {
                        showCityPicker = true
                    }
                }
            }
            .padding(24)
        }
        .onAppear {
            selectedCity = appState.selectedCity
        }
        .onChange(of: locationManager.authorizationStatus) { _, status in
            if status == .denied || status == .restricted {
                alert = AuthAlert(title: "Konum izni kapalı", message: "Sorun değil. Şehir seçerek Yakala'yı kullanmaya devam edebilirsin.")
                showCityPicker = true
            }
        }
        .sheet(isPresented: $showCityPicker) {
            NavigationStack {
                List(cities, id: \.self) { city in
                    Button {
                        selectedCity = city
                        appState.updateSelectedCity(city)
                        showCityPicker = false
                        onContinue()
                    } label: {
                        HStack {
                            Text(city)
                            Spacer()
                            if city == selectedCity {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(YakalaTheme.primary)
                            }
                        }
                    }
                    .foregroundStyle(YakalaTheme.textPrimary)
                }
                .navigationTitle(isEditing ? "Şehri Güncelle" : "Şehir Seç")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Kapat") { showCityPicker = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .alert(item: $alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Tamam")))
        }
    }
}

struct PreferenceSelectionScreen: View {
    var onContinue: () -> Void = {}
    var isEditing: Bool = false
    @EnvironmentObject private var appState: AppState
    @State private var selectedIds = Set<String>()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScreenContainer {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(isEditing ? "İlgi Alanlarını Düzenle" : "İlgi Alanlarını Seç")
                                .font(.largeTitle.bold())
                                .foregroundStyle(YakalaTheme.textPrimary)
                            Text("Yakala sana daha iyi öneriler hazırlasın.")
                                .foregroundStyle(YakalaTheme.textSecondary)
                        }

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(MockData.categories) { category in
                                PreferenceCard(category: category, isSelected: selectedIds.contains(category.id)) {
                                    if selectedIds.contains(category.id) {
                                        selectedIds.remove(category.id)
                                    } else {
                                        selectedIds.insert(category.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 22)
                    .padding(.bottom, 18)
                }

                PrimaryButton(title: isEditing ? "Kaydet" : "Devam Et", icon: "checkmark") {
                    appState.selectPreferences(Array(selectedIds))
                    onContinue()
                }
                .disabled(selectedIds.isEmpty)
                .opacity(selectedIds.isEmpty ? 0.45 : 1)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .background(YakalaTheme.surface)
            }
        }
        .onAppear {
            if selectedIds.isEmpty {
                selectedIds = Set(appState.selectedPreferenceCategoryIds)
            }
        }
    }
}

private struct SecureInputView: View {
    var title: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            SecureField(placeholder, text: $text)
                .padding(14)
                .frame(height: 48)
                .background(YakalaTheme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(YakalaTheme.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

private struct SocialButton: View {
    var title: String
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundStyle(YakalaTheme.textPrimary)
                .background(YakalaTheme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(YakalaTheme.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct AuthAlert: Identifiable {
    let id = UUID()
    var title: String
    var message: String
}

private struct PreferenceCard: View {
    var category: Category
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : YakalaTheme.primary)
                    .frame(width: 42, height: 42)
                    .background(isSelected ? .white.opacity(0.18) : YakalaTheme.primaryLight)
                    .clipShape(Circle())
                Text(category.name)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : YakalaTheme.textPrimary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer(minLength: 0)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .white : YakalaTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 148, maxHeight: 148, alignment: .topLeading)
            .background(isSelected ? YakalaTheme.primary : YakalaTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? YakalaTheme.primary : YakalaTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Login") {
    LoginScreen(onLogin: {}, onBusinessLogin: {})
        .environmentObject(AppState())
}

#Preview("Location") {
    LocationPermissionScreen {}
        .environmentObject(AppState())
        .environmentObject(LocationManager())
}

#Preview("Preferences") {
    PreferenceSelectionScreen {}
        .environmentObject(AppState())
}
