program FazSrvMsql;

uses
  {$ifdef INSPECT}
  siAuto,
  {$endif }
  Pooling in 'pool\Pooling.pas',
  aPolo in 'core\aPolo.pas',
  http in 'core\http.pas',
  aEngine in 'core\aEngine.pas',
  Vcl.SvcMgr,
  MainSrvMsql in 'MainSrvMsql.pas' {fFaySrvMs: TService},
  dmdMsql in 'dep\mssql\dmdMsql.pas' {dmd: TDataModule};

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
  //

  {$ifdef INSPECT}
     Si.Connections := 'tcp()';
     Si.Enabled:=true;
     siMain.ClearLog;
     siMain.LogMessage('TFayServer-start');
  {$ENDIF}

  {$IFDEF SERVICE}
    fPolo := TPolo.Create;
  {$else}
    fPolo := nil;
    Application.CreateForm(TDmd, fDmd);
  {$endif}

  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TfFazSrvMs, fFazSrvMs);
  Application.Run;
end.
