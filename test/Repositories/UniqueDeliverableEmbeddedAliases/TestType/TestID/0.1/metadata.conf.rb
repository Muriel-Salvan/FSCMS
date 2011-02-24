{
  :Deliverables => {
    'TestDeliverable' => {
      :Aliases => {
        'Alias1' => 'Alias1Value',
        'Alias2' => 'Alias2@{Alias1}',
        'DoubleAlias1ValueDoubleValue' => 'DoubleAliasValue'
      },
      :Processes => {
        :DummyBuild => {
          :FullyAutomated => true,
          :Dir => $FSCMSTest_RepositoryToolsDir,
          :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir} @{Alias1} @{Alias2} @{Double@{Alias1}DoubleValue}'
        }
      },
      :Execute => {
        :Process => :DummyBuild
      }
    }
  }
}