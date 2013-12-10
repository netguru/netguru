# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "netguru/version"

Gem::Specification.new do |s|
  s.name        = "netguru"
  s.version     = Netguru::VERSION
  s.authors     = ["Marcin Stecki", "Jacek Jakubik", "Tomasz Pewinski", "Wiktor Schmidt", "Adam Nowak", "Kuba Lasecki"]
  s.email       = ["madsheeppl@gmail.com", "jakubik.jacek@gmail.com", "pewniak747@gmail.com", "wiktorschmidt@gmail.com", "adam.nowak@netguru.pl", "kubalasecki@gmail.com"]
  s.homepage    = "http://netguru.pl"
  s.summary     = "Netguru gem, taking care of our projects deployment strategy and stuff."
  s.description = "This is the gem we include in every netguru project, to get proper deployment to staging, beta and production server."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "pry"
  s.add_dependency "hipchat"
  s.add_dependency "capistrano"
  s.add_dependency "konf"
  s.add_dependency "rvm-capistrano"
  s.add_dependency "checker"
  s.add_dependency "pry"
  s.add_dependency "whenever"
end
