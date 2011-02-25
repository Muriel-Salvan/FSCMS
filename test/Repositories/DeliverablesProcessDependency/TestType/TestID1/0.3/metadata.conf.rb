{
  :Processes => {
    :DummyBuild => {
      :FullyAutomated => false,
      :Dir => $FSCMSTest_RepositoryToolsDir,
      :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir}'
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