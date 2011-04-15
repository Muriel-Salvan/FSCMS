#--
# Copyright (c) 2010 - 2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
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
    if (ARGV.size > 1)
      # Dump all parameters
      ARGV[1..-1].each do |iArg|
        oFile << "\n#{iArg}"
      end
    end
  end
end

exit rErrorCode