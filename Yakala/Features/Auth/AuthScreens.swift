import SwiftUI

struct LoginScreen: View {
    var onLogin: () -> Void
    var onBusinessLogin: () -> Void
    @State private var email = "mert@yakala.app"
    @State private var password = ""

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
                            SecureInputView(title: "Şifre", placeholder: "Şifren")

                            HStack {
                                Spacer()
                                NavigationLink("Şifremi Unuttum") {
                                    ForgotPasswordScreen()
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(YakalaTheme.primary)
                            }

                            PrimaryButton(title: "Giriş Yap") {
                                onLogin()
                            }
                        }

                        VStack(spacing: 12) {
                            SocialButton(title: "Apple ile Devam Et", icon: "apple.logo")
                            SocialButton(title: "Google ile Devam Et", icon: "g.circle.fill")
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
    }
}

struct RegisterScreen: View {
    var onRegister: () -> Void
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 18) {
                    Text("Hesap Oluştur")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    FormInputView(title: "Ad Soyad", placeholder: "Adın", text: $name)
                    FormInputView(title: "E-posta", placeholder: "ornek@mail.com", text: $email)
                    SecureInputView(title: "Şifre", placeholder: "En az 8 karakter")
                    PrimaryButton(title: "Kayıt Ol") {
                        onRegister()
                    }
                    SocialButton(title: "Apple ile Kayıt Ol", icon: "apple.logo")
                }
                .padding(24)
            }
        }
        .navigationTitle("Kayıt")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ForgotPasswordScreen: View {
    @State private var email = ""

    var body: some View {
        ScreenContainer {
            VStack(spacing: 18) {
                EmptyStateView(
                    icon: "envelope.badge.fill",
                    title: "Şifreni sıfırla",
                    message: "E-posta adresini gir, sana mock sıfırlama bağlantısı gönderelim."
                )
                FormInputView(title: "E-posta", placeholder: "ornek@mail.com", text: $email)
                PrimaryButton(title: "Bağlantı Gönder") {}
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Şifremi Unuttum")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LocationPermissionScreen: View {
    var onContinue: () -> Void

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
                        onContinue()
                    }
                    SecondaryButton(title: "Şehir Seçerek Devam Et", icon: "building.2.fill") {
                        onContinue()
                    }
                }
            }
            .padding(24)
        }
    }
}

struct PreferenceSelectionScreen: View {
    var onContinue: () -> Void
    @State private var selected = Set<Category>(MockData.categories.prefix(4))

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
                            Text("İlgi Alanlarını Seç")
                                .font(.largeTitle.bold())
                                .foregroundStyle(YakalaTheme.textPrimary)
                            Text("Yakala sana daha iyi öneriler hazırlasın.")
                                .foregroundStyle(YakalaTheme.textSecondary)
                        }

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(MockData.categories.prefix(9)) { category in
                                PreferenceCard(category: category, isSelected: selected.contains(category)) {
                                    if selected.contains(category) {
                                        selected.remove(category)
                                    } else {
                                        selected.insert(category)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 22)
                    .padding(.bottom, 18)
                }

                PrimaryButton(title: "Devam Et", icon: "checkmark") {
                    onContinue()
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .background(YakalaTheme.surface)
            }
        }
    }
}

private struct SecureInputView: View {
    var title: String
    var placeholder: String
    @State private var value = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            SecureField(placeholder, text: $value)
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

    var body: some View {
        Button {} label: {
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
}

#Preview("Location") {
    LocationPermissionScreen {}
}

#Preview("Preferences") {
    PreferenceSelectionScreen {}
}
