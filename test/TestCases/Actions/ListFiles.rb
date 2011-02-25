#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module FSCMSTest

  module Actions

    class ListFiles < ::Test::Unit::TestCase

      include FSCMSTest::Common

      # Test that a single deliverable lists files correctly
      def testListSingleDeliverable
        setRepository('UniqueDeliverable') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable' => [ [
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile1",
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile2",
                  "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb"
                ], [], [] ]
              }, eval(iFile.read))
          end
        end
      end

      # Test that a single deliverable lists files correctly even in sub-directories
      def testListSingleDeliverableSubDir
        setRepository('UniqueDeliverableSourceSubDir') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable' => [ [
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile1",
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile2",
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir1",
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir1/SourceFile3",
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir1/SubSubDir",
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir1/SubSubDir/SourceFile5",
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir2",
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir2/SourceFile4",
                  "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb"
                ], [], [] ]
              }, eval(iFile.read))
          end
        end
      end

      # Test that a single deliverable lists files correctly even without sources
      def testListSingleDeliverableWithoutSource
        setRepository('UniqueDeliverableNoSource') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable' => [ [
                  "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb"
                ], [], [] ]
              }, eval(iFile.read))
          end
        end
      end

      # Test that a single deliverable lists files correctly even without sources and metadata
      def testListSingleDeliverableWithoutConf
        setRepository('UniqueExistingDeliverableNoConf') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable' => [[], [], []]
              }, eval(iFile.read))
          end
        end
      end

      # Test that a single deliverable lists files correctly including metadata from parent directories
      def testListSingleDeliverableWithParents
        setRepository('UniqueDeliverableUserAliases') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable' => [ [
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile1",
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile2",
                  "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb",
                  "#{iRepoDir}/TestType/TestID/metadata.conf.rb",
                  "#{iRepoDir}/TestType/metadata.conf.rb",
                  "#{iRepoDir}/metadata.conf.rb"
                ], [], [] ]
              }, eval(iFile.read))
          end
        end
      end

      # Test that 2 deliverables from the same object list files correctly
      def testList2DeliverablesSameVersionedObject
        setRepository('2Deliverables') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable1', '--target', 'TestType/TestID/0.1/TestDeliverable2', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable1' => [ [
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile1",
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile2",
                  "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb"
                ], [], [] ],
                'TestType/TestID/0.1/TestDeliverable2' => [ [
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile1",
                  "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile2",
                  "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb"
                ], [], [] ]
              }, eval(iFile.read))
          end
        end
      end

      # Test list an automated dependency
      def testListDependencyAuto
        setRepository('DeliverablesProcessDependency') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID2/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID2/0.1/TestDeliverable' => [ [
                  "#{iRepoDir}/TestType/TestID1/0.1/Source/SourceFile1",
                  "#{iRepoDir}/TestType/TestID1/0.1/Source/SourceFile2",
                  "#{iRepoDir}/TestType/TestID1/0.1/metadata.conf.rb",
                  "#{iRepoDir}/TestType/TestID2/0.1/Source/SourceFile1",
                  "#{iRepoDir}/TestType/TestID2/0.1/Source/SourceFile2",
                  "#{iRepoDir}/TestType/TestID2/0.1/metadata.conf.rb"
                ], [], [] ]
              }, eval(iFile.read))
          end
        end
      end

      # Test list a manual dependency not built yet
      def testListDependencyManualNotBuilt
        setRepository('DeliverablesProcessDependency') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID2/0.4/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID2/0.4/TestDeliverable' => [ [
                  "#{iRepoDir}/TestType/TestID1/0.2/metadata.conf.rb",
                  "#{iRepoDir}/TestType/TestID2/0.4/metadata.conf.rb"
                ], [], [
                  'TestType/TestID1/0.2/TestDeliverable'
                ] ]
              }, eval(iFile.read))
          end
        end
      end

      # Test list a manual dependency already built
      def testListDependencyManualAlreadyBuilt
        setRepository('DeliverablesProcessDependency') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID2/0.5/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID2/0.5/TestDeliverable' => [ [
                  "#{iRepoDir}/TestType/TestID1/0.3/metadata.conf.rb",
                  "#{iRepoDir}/TestType/TestID2/0.5/metadata.conf.rb"
                ], [
                  "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/DeliverableFile1",
                  "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir1",
                  "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir1/DeliverableFile2",
                  "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir1/SubSubDir",
                  "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir1/SubSubDir/DeliverableFile4",
                  "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir2",
                  "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir2/DeliverableFile3"
                ], [] ]
              }, eval(iFile.read))
          end
        end
      end

    end

  end

end
