#--
# Copyright (c) 2010 - 2012 Muriel Salvan (muriel@x-aeon.com)
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

      # Test that a single deliverable builds correctly with hierarchical ID
      def testBuildSingleDeliverableHierarchicalID
        setRepository('UniqueDeliverableHierarchicalID') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/SubTestID/SubSubTestID/0.1/TestDeliverable'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/SubTestID/SubSubTestID/0.1/Deliverables/TestDeliverable/BuiltFile"
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

      # Test that a single deliverable with hierarchical ID builds correctly when identified with its ID
      def testBuildSingleDeliverableHierarchicalID_ObjectPath
        setRepository('UniqueDeliverableHierarchicalID') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/SubTestID/SubSubTestID'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/SubTestID/SubSubTestID/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
        end
      end

      # Test that a single deliverable with hierarchical ID builds correctly when identified with a part of its ID
      def testBuildSingleDeliverableHierarchicalID_PartObjectID
        setRepository('UniqueDeliverableHierarchicalID') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/SubTestID/SubSubTestID/0.1/Deliverables/TestDeliverable/BuiltFile"
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

      # Test that a single deliverable with hierarchical ID builds correctly when identified with all objects
      def testBuildSingleDeliverableHierarchicalID_AllObjects
        setRepository('UniqueDeliverableHierarchicalID') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/SubTestID/SubSubTestID/0.1/Deliverables/TestDeliverable/BuiltFile"
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

      # Test that a dependency defined in a process cmd makes the dependency be built before
      def testBuildProcessCmdDependency
        setRepository('DeliverablesProcessDependency') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID2/0.1/TestDeliverable'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
          lBuiltFileName = "#{iRepoDir}/TestType/TestID2/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal([
                $FSCMSTest_RepositoryToolsDir,
                "#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable"
              ], iFile.read.split("\n"))
          end
        end
      end

      # Test that a dependency defined in a process dir makes the dependency be built before
      def testBuildProcessDirDependency
        setRepository('DeliverablesProcessDependency') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID2/0.2/TestDeliverable'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
          lBuiltFileName = "#{iRepoDir}/TestType/TestID2/0.2/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal("#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable", iFile.read)
          end
        end
      end

      # Test that a dependency defined in a process parameter makes the dependency be built before
      def testBuildProcessParameterDependency
        setRepository('DeliverablesProcessDependency') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID2/0.3/TestDeliverable'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
          lBuiltFileName = "#{iRepoDir}/TestType/TestID2/0.3/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal([
                $FSCMSTest_RepositoryToolsDir,
                "#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable"
              ], iFile.read.split("\n"))
          end
        end
      end

      # Test that a dependency is not built if it was built before
      def testDontBuildBuiltDependency
        setRepository('DeliverablesProcessExistingDependency') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID2/0.1/TestDeliverable'])
          assert(File.exists?("#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable"))
          assert(!File.exists?("#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable/BuiltFile"))
          lBuiltFileName = "#{iRepoDir}/TestType/TestID2/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal([
                $FSCMSTest_RepositoryToolsDir,
                "#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable"
              ], iFile.read.split("\n"))
          end
        end
      end

      # Test that a single deliverable builds correctly with properties
      def testBuildSingleDeliverableWithProperties
        setRepository('UniqueDeliverableProperties') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
          lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/metadata.conf.rb"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal( {
                :Property1 => 'Property1Value',
                :Property2 => "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/Property2Value"
              }, eval(iFile.read))
          end
        end
      end

      # Test that a dependencies go at least at 2 levels
      def testBuild2LevelsDependency
        setRepository('DeliverablesProcessDependency') do |iRepoDir|
          runFSCMS(['Build', '--', '--target', 'TestType/TestID3/0.1/TestDeliverable'])
          lBuiltFileName = "#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal($FSCMSTest_RepositoryToolsDir, iFile.read)
          end
          lBuiltFileName = "#{iRepoDir}/TestType/TestID2/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal([
                $FSCMSTest_RepositoryToolsDir,
                "#{iRepoDir}/TestType/TestID1/0.1/Deliverables/TestDeliverable"
              ], iFile.read.split("\n"))
          end
          lBuiltFileName = "#{iRepoDir}/TestType/TestID3/0.1/Deliverables/TestDeliverable/BuiltFile"
          assert(File.exists?(lBuiltFileName))
          File.open(lBuiltFileName, 'r') do |iFile|
            assert_equal([
                $FSCMSTest_RepositoryToolsDir,
                "#{iRepoDir}/TestType/TestID2/0.1/Deliverables/TestDeliverable"
              ], iFile.read.split("\n"))
          end
        end
      end

    end

  end

end
