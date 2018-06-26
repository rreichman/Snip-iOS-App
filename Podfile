# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

platform :ios, '11.4'
inhibit_all_warnings!
target 'iOSapp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Cache'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Mixpanel-swift', :git=> 'https://github.com/mixpanel/mixpanel-swift.git', :branch=> 'swift4'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare'
  pod 'LatoFont', :git=>'https://github.com/cj-zeiger/LatoFont', :branch=>'master'
  pod 'MontserratFont', :git => 'https://github.com/cj-zeiger/MontserratFont', :branch=>'master'
  pod 'TrustCore', '~> 0.0.7'
  pod 'TrustKeystore', '~> 0.4.0'
  pod 'TrustWeb3Provider', :git=>'https://github.com/TrustWallet/trust-web3-provider', :branch=>'master'
  pod 'BigInt'
  pod 'NextResponderTextField'
  pod 'RxSwift',    '~> 4.0'
  pod 'RxCocoa',    '~> 4.0'
  pod 'KeychainSwift', '~> 11.0'
  pod 'XLPagerTabStrip', '~> 8.0'
  pod 'Moya/RxSwift', '~> 11.0'
  pod 'RealmSwift'
  pod 'CryptoSwift', '~> 0.8.1'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Performance'
  pod 'Nuke'

  # Pods for iOSapp

  target 'iOSappTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking'
    pod 'RxTest'
  end

  target 'iOSappUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
# Workaround for Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
