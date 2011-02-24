{
  :Processes => {
    :DummyBuildVersionedObject => {
      :FullyAutomated => true,
      :Dir => $FSCMSTest_RepositoryToolsDir,
      :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir} VersionedObjectProcess'
    }
  },
  :Deliverables => {
    'TestDeliverableRoot' => {
      :Execute => {
        :Process => :DummyBuildRoot
      }
    },
    'TestDeliverableType' => {
      :Execute => {
        :Process => :DummyBuildType
      }
    },
    'TestDeliverableObject' => {
      :Execute => {
        :Process => :DummyBuildObject
      }
    },
    'TestDeliverableVersionedObject' => {
      :Execute => {
        :Process => :DummyBuildVersionedObject
      }
    },
    'TestDeliverableDeliverable' => {
      :Processes => {
        :DummyBuildDeliverable => {
          :FullyAutomated => true,
          :Dir => $FSCMSTest_RepositoryToolsDir,
          :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir} DeliverableProcess'
        }
      },
      :Execute => {
        :Process => :DummyBuildDeliverable
      }
    }
  }
}