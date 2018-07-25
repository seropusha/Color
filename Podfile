# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
use_frameworks!
workspace 'Color.xcworkspace'
project 'Color.xcodeproj'

inhibit_all_warnings!

def common_pods
  pod 'SwiftLint'
 # pod 'ReactiveSwift', '~> 3.1.0'
 # pod 'ReactiveCocoa', '~> 7.1.0'
end

abstract_target 'Application' do 
  target 'Color' do
    project 'Color.xcodeproj'
    inherit! :search_paths

    common_pods
  end

  target 'Domain' do
    project 'Domain/Domain.xcodeproj'
    inherit! :search_paths

    common_pods

    #Misc
   # pod 'Sourcery', '~> 0.12.0'
  end

  target 'Platform' do
    project 'Platform/Platform.xcodeproj'
    inherit! :search_paths

    common_pods

    # Analytics
   # pod 'Crashlytics'
   # pod 'Fabric'
    
    # Networking
    pod 'Reqres', '~> 2.1.1'
    pod 'Moya', '~> 11.0.0'
    pod 'Moya/ReactiveSwift'
    
    # Storage
    pod 'KeychainAccess', '~> 3.1.0'
    pod 'SwiftyUserDefaults', '~> 3.0.1'
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == "Pods-Color"
            puts "Updating #{target.name} OTHER_LDFLAGS"
            target.build_configurations.each do |config|
                xcconfig_path = config.base_configuration_reference.real_path
                
                # read from xcconfig to build_settings dictionary
                build_settings = Hash[*File.read(xcconfig_path).lines.map{|x| x.split(/\s*=\s*/, 2)}.flatten]
                
                # modify OTHER_LDFLAGS
                frameworks_to_remove = []
                
                frameworks_to_remove.each do |framework|
                    build_settings['OTHER_LDFLAGS'] = build_settings['OTHER_LDFLAGS'].gsub(/-framework "#{framework}"\s?/, '')
                end
                
                # write build_settings dictionary to xcconfig
                File.open(xcconfig_path, "w") do |file|
                    build_settings.each do |key,value|
                        file.puts "#{key} = #{value}"
                    end
                end
            end
        end
    end
end
