{
  :Deliverables => {
    'TestDeliverable' => {
      :Processes => {
        :DummyBuild => {
          :FullyAutomated => true,
          :Dir => $FSCMSTest_RepositoryToolsDir,
          :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir}',
          :Output => {
            :Property1 => 'Property1Value',
            :Property2 => '@{DeliverableDir}/Property2Value'
          }
        }
      },
      :Execute => {
        :Process => :DummyBuild
      }
    }
  }
}