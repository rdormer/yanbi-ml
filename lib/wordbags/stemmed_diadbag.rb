# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

$: << File.dirname(__FILE__)
require 'diadbag'

module Yanbi

  class StemmedDiadBag < DiadBag
    def standardize(raw)
      process(raw) {|word| word.stem}
    end
  end

end
