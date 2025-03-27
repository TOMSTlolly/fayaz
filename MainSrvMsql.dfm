object fFazSrvMs: TfFazSrvMs
  OnCreate = ServiceCreate
  DisplayName = 'FazMsqlServer'
  AfterInstall = ServiceAfterInstall
  OnExecute = ServiceExecute
  Height = 392
  Width = 372
end
