# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "ssn-redaction"
  s.version     = "0.0.1"
  s.authors     = ["Waldo Jaquith", "Manuel Aristaran", "Gabriela Rodriguez", "Jonathan Stray", "Ying Quan Tan"]
  s.email       = ["manuel@jazzido.com"]
  s.homepage    = "https://github.com/USODI/SSN-Redaction"
  s.summary     = %q{redact SSNs from PDF files}
  s.description = %q{redact SSNs from PDF files}
  s.license     = 'MIT'

  s.platform = 'java'

  s.files         = `git ls-files`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "tabula-extractor", ["~> 0.7.4"]
  s.add_runtime_dependency "trollop"
end
