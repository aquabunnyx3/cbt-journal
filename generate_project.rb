require 'xcodeproj'

project = Xcodeproj::Project.new('Thoughtdrift.xcodeproj')
target = project.new_target(:application, 'Thoughtdrift', :ios, '16.0')
group = project.main_group.new_group('Thoughtdrift', 'Thoughtdrift')
Dir['Thoughtdrift/*.swift'].sort.each do |f|
  target.add_file_references([group.new_file(File.basename(f))])
end
target.add_resources([group.new_file('Assets.xcassets')])
target.build_configurations.each do |c|
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.aquabunnygames.thoughtdrift'
  s['INFOPLIST_KEY_ITSAppUsesNonExemptEncryption'] = 'NO'
  s['SWIFT_VERSION'] = '5.0'
  s['GENERATE_INFOPLIST_FILE'] = 'YES'
  s['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
  s['INFOPLIST_KEY_CFBundleDisplayName'] = 'Thoughtdrift'
  # No fixed orientation or full-screen lock, so the window can resize freely on fold/unfold.
  s['INFOPLIST_KEY_UISupportedInterfaceOrientations'] = 'UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
  s['INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad'] = s['INFOPLIST_KEY_UISupportedInterfaceOrientations']
  s['INFOPLIST_KEY_UIApplicationSceneManifest_Generation'] = 'YES'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['MARKETING_VERSION'] = '1.0'
  s['CURRENT_PROJECT_VERSION'] = '1'
end
project.save
