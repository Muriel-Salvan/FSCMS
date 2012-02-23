#--
# Copyright (c) 2010 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'test/unit'
require 'tmpdir'
require 'fileutils'
require 'rUtilAnts/Logging'
RUtilAnts::Logging::install_logger_on_object(:debug_mode => false)
require 'FSCMS/Launcher'

$FSCMSTest_RepositoryToolsDir = "#{File.expand_path(File.dirname(__FILE__))}/RepositoryTools"

module FSCMSTest

  module Common

    # Set a given repository as the current.
    # Set also the current directory in the root of this repository.
    #
    # Parameters::
    # * *iRepositoryName* (_String_): Name of repository to set
    # * *CodeBlock*: Code called once the repository has been set
    def setRepository(iRepository)
      # Copy the whole repository to a temporary directory
      lRepoSrcDir = "#{File.dirname(__FILE__)}/Repositories/#{iRepository}"
      assert(File.exists?(lRepoSrcDir))
      lRepoDstDir = "#{Dir.tmpdir}/FSCMSTest/#{iRepository}"
      # Clean the repository if it existed before
      if (File.exists?(lRepoDstDir))
        FileUtils::rm_rf(lRepoDstDir)
      end
      FileUtils::mkdir_p(File.dirname(lRepoDstDir))
      FileUtils::copy_entry(lRepoSrcDir, lRepoDstDir)
      # Change current dir and call client code
      change_dir(lRepoDstDir) do
        yield(lRepoDstDir)
      end
      # Delete temporary directory
      FileUtils::rm_rf(lRepoDstDir)
    end

    # Run the FSCMS launcher with given parameters
    #
    # Parameters::
    # * *iArgs* (<em>list<String></em>): Arguments
    def runFSCMS(iArgs)
      lResult = FSCMS::Launcher.new.execute(iArgs)
      assert_equal(0, lResult)
    end

  end

end
