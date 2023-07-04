program fpcunittest;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, Graphics, TestCasesGui, FlyCfgGui, LazSerialPort;

{$R *.res}

var
  s: String;

begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.CreateForm(TFlyCfgForm, MainForm);

  {$IFDEF CMD_LINE}
  TestRunner.RunExecute(nil);

  // If there are errors, report the first one
  if TestRunner.MemoDetails.Lines.Count = 0 then System.ExitCode := 0
  else begin
    for s in TestRunner.MemoDetails.Lines do WriteLn(s);
    System.ExitCode := 1;
  end;
  {$ELSE}
  Application.Run;
  {$ENDIF}

end.

