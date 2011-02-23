#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

rErrorCode = 0

lBuiltFile = "#{ARGV[0]}/BuiltFile"
if (File.exists?(lBuiltFile))
  # This is done to test if we call the script twice
  rErrorCode = 1
else
  File.open(lBuiltFile, 'w') do |oFile|
    oFile << Dir.getwd
  end
end

exit rErrorCode