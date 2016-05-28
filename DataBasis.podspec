Pod::Spec.new do |s|
  s.name             = "DataBasis"
  s.version          = "0.1.0"
  s.summary          = "Swift CoreData Framework based on the work of "

  s.homepage         = "https://github.com/wildthink/DataBasis"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Jason Jobe" => "github@jasonjobe.com" }
  s.source           = { :git => "https://github.com/wildthink/DataBasis.git", :tag => s.version.to_s }

  s.ios.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
  s.osx.deployment_target = "10.10"
  #s.tvos.deployment_target = "9.0"

  # s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'DataBasis/*.swift', 'DataBasis/*.[hm]'
  s.resource_bundles = {
    'DataBasis' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'CoreData'
  s.dependency 'KSPFetchedResultsController'

end

