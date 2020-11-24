# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

def global_pods

  # UI controls
  pod 'MaterialComponents'

  post_install do |installer|
    
    installer.pods_project.build_configurations.each do |config|
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
      
      # MaterialComponents.
      config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']
    end
    
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end

  end

end

target 'AppVision' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AppVision
  global_pods

end
