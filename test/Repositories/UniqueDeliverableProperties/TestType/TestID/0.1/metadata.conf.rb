{
  :Deliverables => {
    'TestDeliverable' => {
      :Processes => {
        :DummyBuild => {
          :FullyAutomated => true,
          :Dir => $FSCMSTest_RepositoryToolsDir,
          :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir}'
        }
      },
      :Execute => {
        :Process => :DummyBuild
      },
      :Properties => {
        :Property1 => 'Property1Value',
        :Property2 => '@{DeliverableDir}/Property2Value'
      }
    }
  }
}