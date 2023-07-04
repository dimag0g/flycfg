program flycfg;

{$mode objfpc}{$H+}

{$IFOPT D-}
{$warn 9034 off}
{$hints off}
{$ENDIF}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, LazSerialPort, FlyCfgGui;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TFlyCfgForm, MainForm);
  Application.Run;
end.

