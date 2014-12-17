Gem::Specification.new do |s|
  s.name        = 'securedb'
  s.version     = '0.0.0'
  s.executables << 'SecureDB'
  s.date        = '2014-12-18'
  s.summary     = "SecureDB"
  s.description = "A simple hello world gem"
  s.authors     = ["securasu"]
  s.email       = 'sephicrash@live.cn'
  s.files       = ["bin/SecureDB",
                   "lib/securedb.rb",
                   "lib/securedb/database.rb",
                   "lib/securedb/crypto.rb",
                   "lib/securedb/errors.rb",
                   "lib/securedb/logger.rb",
                   "lib/securedb/main.rb"]
  s.homepage    =
  'https://github.com/securasu/SecureDB'
  s.license       = 'nil'
end
