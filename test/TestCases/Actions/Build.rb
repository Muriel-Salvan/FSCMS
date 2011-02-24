#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module FSCMSTest

  module Actions

    class Build < ::Test::Unit::TestCase

      include FSCMSTest::Common

      # Test that a single deliverable builds correctly
      def testBuildSingleDeliverable
        setRepository('UniqueDeliverable') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
        end
      end

      # Test that a single deliverable builds correctly when identified with the versioned object only
      def testBuildSingleDeliverable_VersionedObjectPath
        setRepository('UniqueDeliverable') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
        end
      end

      # Test that a single deliverable builds correctly when identified with the object only
      def testBuildSingleDeliverable_ObjectPath
        setRepository('UniqueDeliverable') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
        end
      end

      # Test that a single deliverable builds correctly when identified with all objects
      def testBuildSingleDeliverable_AllObjects
        setRepository('UniqueDeliverable') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
        end
      end

      # Test that a single deliverable builds correctly just once
      def testBuildSingleDeliverableOnce
        setRepository('UniqueDeliverable') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--target', 'TestType/TestID/0.1/TestDeliverable'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
        end
      end

      # Test that a single deliverable builds only if it is not already built
      def testDontBuildSingleDeliverable
        setRepository('UniqueExistingDeliverable') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable'])
          assert(File.exists?("#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable"))
          assert(!File.exists?("#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/BuiltFile"))
        end
      end

      # Test that a single deliverable builds even if it is already built with the force option
      def testForceBuildSingleDeliverable
        setRepository('UniqueExistingDeliverable') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--force'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
        end
      end

      # Test that a single deliverable builds just once even if it is already built with the force option
      def testForceBuildSingleDeliverableOnce
        setRepository('UniqueExistingDeliverable') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--target', 'TestType/TestID/0.1/TestDeliverable', '--force'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
        end
      end

      # Test that 2 deliverables build correctly when identified with the versioned object only
      def testBuild2Deliverables
        setRepository('2Deliverables') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable1', '--target', 'TestType/TestID/0.1/TestDeliverable2'])
          [
            "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable1/BuiltFile",
            "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable2/BuiltFile"
          ].each do |iBuiltFileName|
            assert(File.exists?(iBuiltFileName))
            File.open(iBuiltFileName, 'r') do |iFile|
              assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
            end
          end
        end
      end

      # Test that 2 deliverables build correctly when identified with the versioned object only
      def testBuild2Deliverables_VersionedObjectPath
        setRepository('2Deliverables') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1'])
          [
            "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable1/BuiltFile",
            "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable2/BuiltFile"
          ].each do |iBuiltFileName|
            assert(File.exists?(iBuiltFileName))
            File.open(iBuiltFileName, 'r') do |iFile|
              assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
            end
          end
        end
      end

      # Test that 2 deliverables from different objects build correctly
      def testBuild2DeliverablesDifferentObjects
        setRepository('2DeliverablesDifferentObjects') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID1/0.1/TestDeliverable', '--target', 'TestType/TestID2/0.1/TestDeliverable'])
          [
            "#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable/BuiltFile",
            "#{iRepoDir}/TestType/TestID2/0.1/Deliverables/TestDeliverable/BuiltFile"
          ].each do |iBuiltFileName|
            assert(File.exists?(iBuiltFileName))
            File.open(iBuiltFileName, 'r') do |iFile|
              assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
            end
          end
        end
      end

      # Test that 2 deliverables from different objects build correctly when specifying all objects
      def testBuild2DeliverablesDifferentObjects_AllObjects
        setRepository('2DeliverablesDifferentObjects') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType'])
          [
            "#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable/BuiltFile",
            "#{iRepoDir}/TestType/TestID2/0.1/Deliverables/TestDeliverable/BuiltFile"
          ].each do |iBuiltFileName|
            assert(File.exists?(iBuiltFileName))
            File.open(iBuiltFileName, 'r') do |iFile|
              assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
            end
          end
        end
      end

    end

  end

end
