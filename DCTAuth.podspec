Pod::Spec.new do |s|
  s.name         = "DCTAuth"
  s.version      = "0.0.1"
  s.summary      = "A library for performing authorised web requests to services using OAuth, OAuth 2.0 and basic authentiaction."
  s.homepage     = "http://danieltull.co.uk/DCTAuth/documentation/"
   s.license      = {
     :type => 'MIT',
     :text => <<-LICENSE
              Copyright © 2012 Daniel Tull. All rights reserved.

              Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

              Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
              Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
              Neither the name of the author nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
              THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
     LICENSE
   }
  s.author       = { "Daniel Tull" => "dt@danieltull.co.uk" }
  s.source       = { :git => "https://github.com/danielctull/DCTAuth.git", :commit => "09fb9fa666c9cbb8cd605c3da8c89946ca362449" }

  s.platform     = :ios, '5.0'
  s.source_files = 'DCTAuth/**/*.{h,m}'

  s.requires_arc = true
end
