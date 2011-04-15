#--
# Copyright (c) 2010 - 2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'Common'

Dir.glob("#{File.expand_path(File.dirname(__FILE__))}/TestCases/**/*.rb").each do |iTestFileName|
  require iTestFileName
end
