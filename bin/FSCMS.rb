#--
# Copyright (c) 2010 - 2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

# Main file

require 'rUtilAnts/Logging'
RUtilAnts::Logging::initializeLogging('', '')
require 'FSCMS/Launcher'

exit FSCMS::Launcher.new.execute(ARGV)
