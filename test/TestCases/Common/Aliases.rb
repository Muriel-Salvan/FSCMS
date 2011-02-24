#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module FSCMSTest

  module Common

    class Aliases < ::Test::Unit::TestCase

      include FSCMSTest::Common

      # Test default aliases set by FSCMS itself
      def testDefaultAliases
        setRepository('UniqueDeliverableDefaultAliases') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal( [
                $FSCMSTest_RepositoryToolsDir,
                "#{iRepoDir}/TestType/TestID/0.1/Sources",
                "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable"
              ], iFile.read.split("\n"))
          end
        end
      end

      # Test user aliases set in all parts of the repository
      def testUserAliases
        setRepository('UniqueDeliverableUserAliases') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal( [
                $FSCMSTest_RepositoryToolsDir,
                'RootAliasValue',
                'TypeAliasValue',
                'ObjectAliasValue',
                'VersionedObjectAliasValue',
                'DeliverableAliasValue'
              ], iFile.read.split("\n"))
          end
        end
      end

      # Test user aliases set in all parts of the repository with some overwriting
      def testUserAliasesOverwriting
        setRepository('2DeliverablesOverwritingAliases') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable1', '--target', 'TestType/TestID/0.1/TestDeliverable2'])
          # First deliverable
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable1/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal( [
                $FSCMSTest_RepositoryToolsDir,
                'RootAlias1ValueTypeOverwrite',
                'RootAlias2ValueObjectOverwrite',
                'RootAlias3ValueVersionedObjectOverwrite',
                'RootAlias4ValueDeliverable1Overwrite',
                'RootAlias5ValueDeliverable1Overwrite',
                'TypeAlias1ValueObjectOverwrite',
                'TypeAlias2ValueVersionedObjectOverwrite',
                'TypeAlias3ValueDeliverable1Overwrite',
                'TypeAlias4ValueDeliverable1Overwrite',
                'ObjectAlias1ValueVersionedObjectOverwrite',
                'ObjectAlias2ValueDeliverable1Overwrite',
                'ObjectAlias3ValueDeliverable1Overwrite',
                'VersionedObjectAlias1ValueDeliverable1Overwrite'
              ], iFile.read.split("\n"))
          end
          # Second deliverable
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable2/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal( [
                $FSCMSTest_RepositoryToolsDir,
                'RootAlias1ValueTypeOverwrite',
                'RootAlias2ValueObjectOverwrite',
                'RootAlias3ValueVersionedObjectOverwrite',
                'RootAlias4Value',
                'RootAlias5ValueVersionedObjectOverwrite',
                'TypeAlias1ValueObjectOverwrite',
                'TypeAlias2ValueVersionedObjectOverwrite',
                'TypeAlias3Value',
                'TypeAlias4ValueVersionedObjectOverwrite',
                'ObjectAlias1ValueVersionedObjectOverwrite',
                'ObjectAlias2Value',
                'ObjectAlias3ValueVersionedObjectOverwrite',
                'VersionedObjectAlias1Value'
              ], iFile.read.split("\n"))
          end
        end
      end

    end

  end

end
