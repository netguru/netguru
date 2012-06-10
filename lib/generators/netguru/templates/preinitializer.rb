require 'active_support/core_ext'
require 'konf'

pub_config = (YAML.load(ERB.new(File.read(File.expand_path('../config.yml',     __FILE__))).result)[Rails.env] rescue {}) || {}
sec_config = (YAML.load(ERB.new(File.read(File.expand_path('../sec_config.yml', __FILE__))).result)[Rails.env] rescue {}) || {}
AppConfig = Konf.new(pub_config.deep_merge(sec_config))
