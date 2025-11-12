# config/initializers/tzinfo.rb
require "tzinfo/data"
TZInfo::DataSource.set(:ruby)
