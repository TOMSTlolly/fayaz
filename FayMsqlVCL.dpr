program FayMsqlVCL;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  {$ifdef INSPECT}
  siAuto,
  {$endif }
  Vcl.Forms,
  SysUtils,
  Main in 'Main.pas' {fMain},
  Pooling in 'pool\Pooling.pas',
  aPolo in 'core\aPolo.pas',
  http in 'core\http.pas',
  aEngine in 'core\aEngine.pas',
  dmdMsql in 'dep\mssql\dmdMsql.pas' {dmd: TDataModule},
  VVersionInfo in 'core\VVersionInfo.pas';

{$R *.res}

begin
  {$ifdef INSPECT}
     Si.Connections := 'tcp()';
     Si.Enabled:=true;
     siMain.ClearLog;
     siMain.LogMessage('Dsnap-start');
  {$ENDIF}


  {$ifdef SERVICE}
  fPolo := TPolo.Create;
  {$endif}

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tdmd, fdmd);

  Application.CreateForm(TfMain, fMain);
  Application.Run;
  Application.Terminate;

//  Sleep(5000);

//  fPolo.Destroy;
 // FreeAndNil(fPolo);
end.
