program FaySrv;

uses
  {$ifdef INSPECT}
  siAuto,
  {$endif }
  Vcl.SvcMgr,
  MainSrv in 'MainSrv.pas' {FayService: TService},
  Pooling in 'pool\Pooling.pas',
  aPolo in 'core\aPolo.pas',
  http in 'core\http.pas',
  aEngine in 'core\aEngine.pas',
  dmd in 'dep\absolute\dmd.pas' {Dmd: TDataModule};

{$R *.RES}

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;

  {$ifdef INSPECT}
     Si.Connections := 'tcp()';
     Si.Enabled:=true;
     siMain.ClearLog;
     siMain.LogMessage('TFayServer-start');
  {$ENDIF}

  fPolo := TPolo.Create;
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TFayService, FayService);
  Application.Run;
end.
