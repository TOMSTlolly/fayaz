object FayService: TFayService
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = 'FayServiceName'
  AfterInstall = ServiceAfterInstall
  OnExecute = ServiceExecute
  Height = 285
  Width = 294
end
