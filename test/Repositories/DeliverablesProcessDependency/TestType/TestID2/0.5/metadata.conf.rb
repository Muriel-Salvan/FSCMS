{
  :Processes => {
    :DummyBuild => {
      :FullyAutomated => true,
      :Dir => $FSCMSTest_RepositoryToolsDir,
      :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir} @{ProcessParam}'
    }
  },
  :Deliverables => {
    'TestDeliverable' => {
      :Execute => {
        :Process => :DummyBuild,
        :Parameters => {
          :ProcessParam => '@{Ref[TestType/TestID1/0.3/TestDeliverable]}'
        }
      }
    }
  }
}