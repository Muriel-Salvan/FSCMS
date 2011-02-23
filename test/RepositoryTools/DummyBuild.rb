#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

File.open("#{ARGV[0]}/BuiltFile", 'w') do |oFile|
  oFile << Dir.getwd
end
