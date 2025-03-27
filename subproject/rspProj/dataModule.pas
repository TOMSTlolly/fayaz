unit dataModule;

interface

uses
  System.SysUtils, System.Classes;

type
  Tdmd = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmd: Tdmd;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
