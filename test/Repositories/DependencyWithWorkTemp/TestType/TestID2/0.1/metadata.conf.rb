{
  :Processes => {
    :DummyBuild => {
      :FullyAutomated => true,
      :Dir => $FSCMSTest_RepositoryToolsDir,
      :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir} @{Ref[TestType/TestID1/0.1/TestDeliverable]}'
    }
  },
  :Deliverables => {
    'TestDeliverable' => {
      :Execute => {
        :Process => :DummyBuild
      }
    }
  }
}