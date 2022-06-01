# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Diplom-project' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
	
pod 'FirebaseAuth'
pod 'FirebaseDatabase'
pod 'GoogleMaps', '6.2.1'
pod 'Google-Maps-iOS-Utils', '~> 4.1.0'
pod 'GoogleSignIn'

  # Pods for Diplom-project

end

post_install do |installer|

    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        end
    end

end

