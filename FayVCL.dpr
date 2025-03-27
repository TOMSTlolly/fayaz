program FayVCL;

uses
  {$ifdef INSPECT}
  siAuto,
  {$endif }
  Forms,
  SysUtils,
  Main in 'Main.pas' {fMain},
  dmd in 'dep\absolute\dmd.pas' {dmd: TDataModule},
  Pooling in 'pool\Pooling.pas',
  aPolo in 'core\aPolo.pas',
  http in 'core\http.pas',
  aEngine in 'core\aEngine.pas';

{$R *.res}

begin
  {$ifdef INSPECT}
     Si.Connections := 'tcp()';
     Si.Enabled:=true;
     siMain.ClearLog;
     siMain.LogMessage('Dsnap-start');
  {$ENDIF}

 // {$ifdef SERVICE}
  fPolo := TPolo.Create;
 // {$endif}

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDmd, fDmd);
  Application.CreateForm(TfMain, fMain);
  Application.Run;


  //FreeAndNil(fPolo);
end.
