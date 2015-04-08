Pod::Spec.new do |s|
  s.name         = "SPLMimeEntity"
  s.version      = "1.0.1"
  s.summary      = "Parsing EML files."
  s.description  = "Objective-C binding to mimetic."
  s.homepage     = "https://github.com/OliverLetterer/SPLMimeEntity"
  s.license      = 'MIT'
  s.authors          = { "Oliver Letterer" => "oliver.letterer@gmail.com" }
  s.social_media_url = "http://twitter.com/oletterer"
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/OliverLetterer/SPLMimeEntity.git", :tag => s.version.to_s }
  s.source_files  = 'SPLMimeEntity'
  s.dependency 'mimetic', '~> 0.9.7'
  s.requires_arc = true
end
