#
#  Be sure to run `pod spec lint DCTAuth.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|



  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "DCTAuth"
  s.version      = "3.0"
  s.summary      = "A library to connect to services using OAuth, OAuth 2.0 or basic authentication."

  s.description  = <<-DESC
                   A library to handle authorised web requests using an account-based approach similar 
                   to the Accounts framework on iOS. Comes with OAuth, OAuth 2.0 and basic 
                   authentication accounts.
                   DESC

  s.homepage     = "https://github.com/danielctull/DCTAuth"



  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license      = { :type => "BSD", 
                     :file => "LICENSE" }



  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author             = { "Daniel Tull" => "dt@danieltull.co.uk" }
  s.social_media_url   = "http://twitter.com/danielctull"



  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"



  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source       = { :git => "https://github.com/danielctull/DCTAuth.git",
                     :tag => s.version,
                     :submodules => true }



  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  s.source_files  = "DCTAuth/*.{h,m}"
  
  s.public_header_files = [ "DCTAuth/DCTAuth.h",
                            "DCTAuth/DCTAuthAccount.h",
                            "DCTAuth/DCTAuthAccountCredential.h",
                            "DCTAuth/DCTAuthAccountStore.h",
                            "DCTAuth/DCTAuthAccountSubclass.h",
                            "DCTAuth/DCTAuthPlatform.h",
                            "DCTAuth/DCTAuthRequest.h",
                            "DCTAuth/DCTAuthRequestMethod.h",
                            "DCTAuth/DCTAuthResponse.h" ]

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"



  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true

end
