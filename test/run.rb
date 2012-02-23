#--
# Copyright (c) 2010 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++


lRootDir = File.expand_path("#{File.dirname(__FILE__)}/..")
$: << "#{lRootDir}/lib"

require 'test/Common'

Dir.glob("#{lRootDir}/test/TestCases/**/*.rb").each do |iTestFileName|
  require iTestFileName
end
