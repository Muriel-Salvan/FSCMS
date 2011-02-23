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

      # Test that a 2 deliverables build correctly when identified with the versioned object only
      def testBuildSingleDeliverable_VersionedObjectPath
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

    end

  end

end
