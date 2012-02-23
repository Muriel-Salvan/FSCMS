#--
# Copyright (c) 2010 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

# Main file

require 'rUtilAnts/Logging'
RUtilAnts::Logging::install_logger_on_object
require 'FSCMS/Launcher'

exit FSCMS::Launcher.new.execute(ARGV)
