#
# Be sure to run `pod lib lint EasyNetRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EasyNetRequest'
  s.version          = '0.1.0'
  s.summary          = 'EasyNetRequest'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    EasyNetRequest es un conjunto de estructuras escritas en Swift 5 (compatibles con Swift 4) para construir el modulo de redes de una app IOS. Los desarrolladores pueden construir el modulo de llamadas a Api creando los endpoints necesarios de una manera muy simple. Esta lib emplea Codable de swift y no tiene dependencias externas. Esta lib esta basada en el desarrollo de Fernando Martín Ortiz (https://github.com/fmo91/Conn.git)
                       DESC

  s.homepage         = 'https://github.com/osmely/EasyNetRequest'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Osmely Fernandez' => 'osmelyf@gmail.com' }
  s.source           = { :git => 'https://github.com/osmely/EasyNetRequest.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'EasyNetRequest/Classes/**/*'
  
  # s.resource_bundles = {
  #   'EasyNetRequest' => ['EasyNetRequest/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
