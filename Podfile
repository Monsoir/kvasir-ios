# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'kvasir' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for kvasir
  pod 'SnapKit', '~> 4.0.0'
  pod 'SwifterSwift'
  pod 'PKHUD', '~> 5.0'
  pod 'RealmSwift'
  pod 'FontAwesome.swift'
  pod 'Eureka'
  pod 'URLNavigator'
  
  target 'kvasir-with-tesseract' do
    inherit! :search_paths
    # https://stackoverflow.com/a/39930762/5211544
    pod 'TesseractOCRiOS', :git => "https://github.com/gali8/Tesseract-OCR-iOS.git", :tag => '4.0.0'
  end

  target 'kvasirTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'kvasirUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

# https://stackoverflow.com/a/50846651/5211544
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'TesseractOCRiOS' 
            target.build_configurations.each do |config|
                config.build_settings['ENABLE_BITCODE'] = 'NO'
            end
            header_phase = target.build_phases().select do |phase|
                phase.is_a? Xcodeproj::Project::PBXHeadersBuildPhase
            end.first

            duplicated_header_files = header_phase.files.select do |file|
                file.display_name == 'config_auto.h'
            end

            duplicated_header_files.each do |file|
                header_phase.remove_build_file file
            end
        end
    end
end
