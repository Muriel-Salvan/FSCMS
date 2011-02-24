#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module FSCMSTest

  module General

    class Common < ::Test::Unit::TestCase

      include FSCMSTest::Common

      # Test that deliverables are reachable even if tag names are appended to directories name
      def testNamesWithTags
        setRepository('UniqueExistingDeliverableWithTags') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--force'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID ObjectTag/0.1 VersionTag/Deliverables/TestDeliverable DeliverableTag/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
        end
      end

    end

  end

end
