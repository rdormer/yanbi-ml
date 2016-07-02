# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

base = File.dirname(__FILE__)
$: << base

Dir[base + "/wordbags/**/*.rb"].each do |bag|
  require bag
end

Dir[base + "/bayes/**/*.rb"].each do |c|
  require c
end

require 'corpus'
require 'version'
