program rspProj;

uses
  Vcl.Forms,
  main in 'main.pas' {Form1},
  dataModule in 'dataModule.pas' {dmd: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(Tdmd, dmd);
  Application.Run;
end.
